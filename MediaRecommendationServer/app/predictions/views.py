from rest_framework import status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import action
from django.views.decorators.csrf import csrf_exempt
import requests
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

        return self.predict_movies_for_user(user)

    def predict_movies_for_user(user, embedding_id=None):
        ''' Removes old predictions then gathers predictions for the user from the TorchServe model 
            and saves them. For emphasis on more popular movies right now, predictions are only for 
            movies with atleast 15 watches and average rating >= 4.

        :param user: User
        :param embedding_id: Int embedding index for the user. Defautls to the user.movie_user.embedding_id.
        :return: Response with status
        '''
        batch_size = 4096
        MODEL_UID = user.movie_user.embedding_id if embedding_id is None else embedding_id

        movies = Movie.objects.filter(num_watched__gte=15).filter(average_rating__gte=4.0)
        movie_ids = [movie.movielens_id for movie in movies]
        genres = [movie.genres for movie in movies]
        n_ratings = [movie.num_watched for movie in movies]
        avg_rating = [movie.average_rating for movie in movies]
        assert len(movie_ids) == len(genres) == len(n_ratings) == len(avg_rating)
        
        preds = []
        # Split up movies
        for start_idx in range(0, len(movie_ids), batch_size):
            batch_mids = movie_ids[start_idx:start_idx+batch_size] if len(movie_ids) > start_idx+batch_size else movie_ids[start_idx:]
            batch_genres = genres[start_idx:start_idx+batch_size] if len(genres) > start_idx+batch_size else genres[start_idx:]
            batch_n_ratings = n_ratings[start_idx:start_idx+batch_size] if len(n_ratings) > start_idx+batch_size else n_ratings[start_idx:]
            batch_avg_rating = avg_rating[start_idx:start_idx+batch_size] if len(avg_rating) > start_idx+batch_size else avg_rating[start_idx:]
            
            # Get predictions from TorchServe
            r_json = {"userId":MODEL_UID, "movieId":batch_mids, "genres":batch_genres, "numRatings":batch_n_ratings, "avgRating":batch_avg_rating}
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

        return Response(status=status.HTTP_201_CREATED)
    

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
        ratings_vector = MoviePredictionViewSet.__get_workflow_ratings_vector(ratings)
        embedding_id = MoviePredictionViewSet.__find_closest_cluster(ratings_vector)
        print('Embedding ID: {}, was {}'.format(embedding_id, curr_embedding_id))
        # No updating needed if the embedding wasn't updated
        if curr_embedding_id == embedding_id:
            return Response(status=status.HTTP_200_OK)
        
        # Update user
        user.movie_user.embedding_id = embedding_id
        user.movie_user.save()
        # Get new predictions
        return MoviePredictionViewSet.predict_movies_for_user(user)


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