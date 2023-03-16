from rest_framework import status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import action
from django.views.decorators.csrf import csrf_exempt
from threading import Thread
from celery import shared_task
import requests
import json
import numpy as np
import pandas as pd
import nvtabular as nvt
from nvtabular.loader.torch import TorchAsyncItr, DLDataLoader

from . import serializers
from . import models
from media.models import Book, Movie
from userauth.models import User


class BookPredictionViewSet(viewsets.ModelViewSet):
    queryset = models.BookPrediction.objects.all()
    serializer_class = serializers.BookPredictionSerializer

    @csrf_exempt
    @action(detail=False, methods=['post'])
    def new(self, request):
        try:
            user = User.objects.get(pk=request.POST['id'])
        except User.DoesNotExist or ValueError:
            Response(status=status.HTTP_400_BAD_REQUEST)

        return BookPredictionViewSet.predict_books_for_user(user.id, user.book_user.embedding_id)

    @shared_task()
    def predict_books_for_user(uid, embedding_id):
        ''' Removes old predictions then gathers predictions for the user from the TorchServe model 
            and saves them. For emphasis on more popular books right now, predictions are only for 
            books with atleast 15 reads and average rating >= 4.

        :param user: User.id
        :param embedding_id: Int embedding index for the user.
        :return: Response with status
        '''
        batch_size = 4096
        MODEL_UID = embedding_id
        user = User.objects.get(pk=uid)

        books = Book.objects.all()[:20000]
        book_ids = [book.goodreads_id for book in books]
        
        preds = []
        # Split up books
        for start_idx in range(0, len(book_ids), batch_size):
            batch_bids = book_ids[start_idx:start_idx+batch_size] \
                if len(book_ids) > start_idx+batch_size else book_ids[start_idx:]
            
            # Get predictions from TorchServe
            r_json = {"userId":MODEL_UID, "bookId":batch_bids}
            r = requests.post('http://34.73.88.144:3000/predictions/book', json=r_json)
            if r.status_code == 200:
                preds.extend(r.json())
            else:
                print(r.status_code)
        
        # Delete old predictions
        models.BookPrediction.objects.filter(prediction_user=user.book_user).delete()

        book_preds = []
        # Create predictions from books/preds
        for pred, book_id, book in zip(preds, book_ids, books):
            assert book_id == book.goodreads_id
            book_preds.append(models.BookPrediction(prediction_user=user.book_user, 
                                                    book=book, prediction=pred))

        models.BookPrediction.objects.bulk_create(book_preds, batch_size=batch_size)
    
    def update_user_embedding(user):
        ''' Finds the best model embedding for the user based on the user's ratings.
            If this is different than the current embedding for the user then updates
            user's predictions.

        :param user: User
        :return: Response with status
        '''
        curr_embedding_id = user.book_user.embedding_id

        # Get user ratings
        ratings = [{'bookId': rating.book.goodreads_id, 'rating': rating.rating} \
                   for rating in user.book_user.ratings.all()]
        print('ratings: {}'.format(ratings))
        if len(ratings) == 0:
            embedding_id = 0
        else:
            ratings_vector, id_vector = BookPredictionViewSet.__get_workflow_ratings_vector(ratings)
            embedding_id = BookPredictionViewSet.__find_closest_cluster(ratings_vector, id_vector)
            # To handle default embedding
            embedding_id += 1 
        
        print('Embedding ID: {}, was {}'.format(embedding_id, curr_embedding_id))
        # No updating needed if the embedding wasn't updated
        if curr_embedding_id == embedding_id:
            return Response(status=status.HTTP_200_OK)
        
        # Update user
        user.book_user.embedding_id = embedding_id
        user.book_user.save()

        # Make new predictions - offload to celery 
        BookPredictionViewSet.predict_books_for_user.delay(user.id, embedding_id)

        return Response(status=status.HTTP_200_OK)
    
    
    def __get_workflow_ratings_vector(user_ratings):
        ''' Computes the ratings vector from original ratings for use in clustering.
        
        :param user_ratings: [{'bookId': int, 'rating': float}]
        :return np.array of user ratings after transforming data by workflow
        '''
        # Load ML Workflow
        workflow = nvt.Workflow.load('mlworkflow/book_workflow')

        # Load join values for goodreads_id
        df_idmap = pd.read_csv('mlworkflow/book_workflow/book_id_map-dedup-v1.csv')
        df_idmap = df_idmap.drop(columns=['Unnamed: 0'])
        df_idmap = df_idmap.rename(columns={'book_id': 'goodreads_id'})
        df_idmap = df_idmap.rename(columns={'book_id_csv': 'book_id'})

        book_ids, goodreads_ids, book_ratings = [], [], []
        for r in user_ratings:
            bids = df_idmap[df_idmap['goodreads_id'] == r['bookId']]['book_id']
            if len(bids) == 0:
                continue
            book_ids.append(bids.iloc[0])
            goodreads_ids.append(r['bookId'])
            book_ratings.append(int(r['rating']))

        ratings_vector = np.array(book_ratings)

        df = pd.DataFrame({'user_id': [0]*len(book_ids),
                            'book_id': book_ids,
                            'rating': book_ratings})

        ds = nvt.Dataset(df)
        torch_ds = TorchAsyncItr(
            workflow.transform(ds),
            batch_size=1,
            cats=['user_id', 'goodreads_id'],
            conts=["rating"], 
        )
        dl = DLDataLoader(torch_ds, batch_size=None, pin_memory=False, num_workers=0)

        id_vector = np.array([x['goodreads_id'][0][0].numpy() for x, _ in dl])

        return ratings_vector, id_vector
        
    def __find_closest_cluster(user_ratings, user_bookids):
        ''' Computes the closest ratings to the user from the model embeddings.
        
        :param user_ratings: np.array of user ratings after transforming data by workflow
        :param user_bookids: np.array of book_ids after workflow corresponding to user_ratings 
        :return int index of the closest cluster
        '''
        with open('mlworkflow/book_workflow/cluster_ratings.json', 'r') as f:
            cluster_ratings = json.load(f)

        # Extract cluster rating matrix to match user_rating vector
        cluster_ratings_mat = np.zeros((len(cluster_ratings), len(user_ratings)))
        for rating_idx, id in enumerate(user_bookids):
            for i, cluster in cluster_ratings.items():
                cluster_ratings_mat[int(i)][rating_idx] = cluster[str(id)] if str(id) in cluster else 0

        diff = np.linalg.norm(cluster_ratings_mat - user_ratings, axis=1)
        cluster = np.argmin(diff)
        return int(cluster)

    @action(detail=False)
    def get_prediction(self, request):
        """Get the book prediction for the User with the given ID and bookId.

        :param request: /books/predictions/get_prediction/ -- 'bookId': int, 'id': int (user id)
        :return: Response with the serialized Prediction
        """
        try:
            book = Book.objects.get(pk=request.GET['bookId'])
            user = User.objects.get(pk=request.GET['id'])
            prediction = models.BookPrediction.objects.get(prediction_user=user.book_user,
                                                            book=book)

        except User.DoesNotExist or ValueError:
            Response(status=status.HTTP_400_BAD_REQUEST)

        serializer = serializers.PredictionSerializer(prediction)
        return Response(serializer.data)


class MoviePredictionViewSet(viewsets.ModelViewSet):
    queryset = models.MoviePrediction.objects.all()
    serializer_class = serializers.MoviePredictionSerializer


    @csrf_exempt
    @action(detail=False, methods=['post'])
    def new(self, request):
        try:
            user = User.objects.get(pk=request.POST['id'])
        except User.DoesNotExist or ValueError:
            Response(status=status.HTTP_400_BAD_REQUEST)

        return MoviePredictionViewSet.predict_movies_for_user(user.id, user.movie_user.embedding_id)

    @shared_task()
    def predict_movies_for_user(uid, embedding_id):
        ''' Removes old predictions then gathers predictions for the user from the TorchServe model 
            and saves them. For emphasis on more popular movies right now, predictions are only for 
            movies with atleast 15 watches and average rating >= 4.

        :param uid: User.id
        :param embedding_id: Int embedding index for the user.
        :return: Response with status
        '''
        batch_size = 4096
        MODEL_UID = embedding_id
        user = User.objects.get(pk=uid)

        movies = Movie.objects.filter(num_watched__gte=15).filter(average_rating__gte=3.5)
        movie_ids = [movie.movielens_id for movie in movies]
        genres = [movie.genres for movie in movies]
        n_ratings = [movie.num_watched for movie in movies]
        avg_rating = [movie.average_rating for movie in movies]
        assert len(movie_ids) == len(genres) == len(n_ratings) == len(avg_rating)
        
        preds = []
        # Split up movies
        for start_idx in range(0, len(movie_ids), batch_size):
            batch_mids = movie_ids[start_idx:start_idx+batch_size] \
                if len(movie_ids) > start_idx+batch_size else movie_ids[start_idx:]
            batch_genres = genres[start_idx:start_idx+batch_size] \
                if len(genres) > start_idx+batch_size else genres[start_idx:]
            batch_n_ratings = n_ratings[start_idx:start_idx+batch_size] \
                if len(n_ratings) > start_idx+batch_size else n_ratings[start_idx:]
            batch_avg_rating = avg_rating[start_idx:start_idx+batch_size] \
                if len(avg_rating) > start_idx+batch_size else avg_rating[start_idx:]
            
            # Get predictions from TorchServe
            r_json = {"userId":MODEL_UID, "movieId":batch_mids, "genres":batch_genres, 
                      "numRatings":batch_n_ratings, "avgRating":batch_avg_rating}
            r = requests.post('http://34.73.88.144:3000/predictions/movie', json=r_json)
            if r.status_code == 200:
                preds.extend(r.json())
            else:
                print(r.status_code)
        
        # Delete old predictions
        models.MoviePrediction.objects.filter(prediction_user=user.movie_user).delete()

        movie_preds = []
        # Create predictions from movies/preds
        for pred, movie_id, movie in zip(preds, movie_ids, movies):
            assert movie_id == movie.movielens_id
            movie_preds.append(models.MoviePrediction(prediction_user=user.movie_user, movie=movie, prediction=pred))

        models.MoviePrediction.objects.bulk_create(movie_preds, batch_size=batch_size)
    

    def update_user_embedding(user):
        ''' Finds the best model embedding for the user based on the user's ratings.
            If this is different than the current embedding for the user then updates
            user's predictions.

        :param user: User
        :return: Response with status
        '''
        curr_embedding_id = user.movie_user.embedding_id

        # Get user ratings
        ratings = [{'movieId': rating.movie.movielens_id, 'rating': rating.rating} \
                   for rating in user.movie_user.ratings.all()]
        print('ratings: {}'.format(ratings))
        if len(ratings) == 0:
            embedding_id = 0
        else:
            ratings_vector = MoviePredictionViewSet.__get_workflow_ratings_vector(ratings)
            embedding_id = MoviePredictionViewSet.__find_closest_cluster(ratings_vector)
            # To handle default embedding
            embedding_id += 1 
        
        print('Embedding ID: {}, was {}'.format(embedding_id, curr_embedding_id))
        # No updating needed if the embedding wasn't updated
        if curr_embedding_id == embedding_id:
            return Response(status=status.HTTP_200_OK)
        
        # Update user
        user.movie_user.embedding_id = embedding_id
        user.movie_user.save()

        # Make new predictions - offload to celery 
        MoviePredictionViewSet.predict_movies_for_user.delay(user.id, embedding_id)

        return Response(status=status.HTTP_200_OK)


    def __get_workflow_ratings_vector(user_ratings):
        ''' Computes the ratings vector from original ratings for use in clustering.
        
        :param user_ratings: [{'movieId': int, 'rating': float}]
        :return np.array of user ratings after transforming data by workflow
        '''
        # Load ML Workflow
        workflow = nvt.Workflow.load('mlworkflow/movie_workflow')
        cat_emb_shape, genre_emb_shape = nvt.ops.get_embedding_sizes(workflow)
        n_media = cat_emb_shape['movieId'][0]

        ratings_vector = np.zeros(n_media)
        movie_ids = [r['movieId'] for r in user_ratings]
        movie_ratings = [r['rating'] for r in user_ratings]
        df = pd.DataFrame({'userId': [0]*len(movie_ids), 'movieId': movie_ids, 'rating': movie_ratings})
        # Throw away values for join
        df_movies = pd.DataFrame({'movieId': movie_ids, 
                                'split_genres': [["Adventure"]]*len(movie_ids), 
                                'num_ratings': [0]*len(movie_ids),
                                'avg_rating': [3.0]*len(movie_ids)})

        ds = nvt.Dataset(df)
        torch_ds = TorchAsyncItr(
            workflow.transform(ds),
            batch_size=1,
            cats=['userId', 'movieId', 'split_genres'],
            conts=["rating", 'avg_rating', 'num_ratings'], 
        )
        dl = DLDataLoader(torch_ds, batch_size=None, pin_memory=False, num_workers=0)
        for x, _ in dl:
            media = x['movieId']
            y = x['rating']
            ratings_vector[media] = y*5
        
        return ratings_vector

    def __find_closest_cluster(user_ratings):
        ''' Computes the closest ratings to the user from the model embeddings.
        
        :param user_ratings: np.array of user ratings after transforming data by workflow
        :return int index of the closest cluster
        '''
        cluster_ratings = np.load('mlworkflow/movie_workflow/cluster_ratings.npy')
        diff = np.linalg.norm(cluster_ratings*(user_ratings>0) - user_ratings, axis=1)
        cluster = np.argmin(diff)
        return int(cluster)

    @action(detail=False)
    def get_prediction(self, request):
        """Get the movie prediction for the User with the given ID and movieId

        :param request: /movies/predictions/get_prediction/ -- 'movieId': int, 'id': int (user id)
        :return: Response with the serialized Prediction
        """
        try:
            movie = Movie.objects.get(pk=request.GET['movieId'])
            user = User.objects.get(pk=request.GET['id'])
            prediction = models.MoviePrediction.objects.get(prediction_user=user.movie_user,
                                                            movie=movie)
            prediction.prediction *= 5
        except User.DoesNotExist or ValueError:
            Response(status=status.HTTP_400_BAD_REQUEST)

        serializer = serializers.PredictionSerializer(prediction)
        return Response(serializer.data)