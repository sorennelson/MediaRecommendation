from rest_framework import status, viewsets, permissions
from rest_framework.response import Response
from rest_framework.decorators import action
from django.views.decorators.csrf import csrf_exempt

from . import serializers
from . import models

from userauth.models import User
from media.models import Book, Movie
from predictions.views import MoviePredictionViewSet, BookPredictionViewSet


class BookRatingViewSet(viewsets.ModelViewSet):
    queryset = models.BookRating.objects.all()
    serializer_class = serializers.BookRatingSerializer
    permission_classes = ()
    authentication_classes = ()

    @csrf_exempt
    @action(detail=False, methods=['post'])
    def new(self, request):
        user = User.objects.get(pk=request.data['id'])

        if models.BookRating.objects.filter(rating_user=user.book_user,
                                            book=Book.objects.get(pk=int(request.data['book']))).exists():
            book_rating = models.BookRating.objects.get(rating_user=user.book_user,
                                                        book=Book.objects.get(pk=int(request.data['book'])))
            book_rating.rating = float(request.data['rating'])

        else:
            book_rating = models.BookRating(rating_user=user.book_user,
                                             book=Book.objects.get(pk=int(request.data['book'])),
                                             rating=float(request.data['rating']))
        book_rating.save()
        BookPredictionViewSet.update_user_embedding(user) 
        
        return Response(status=status.HTTP_201_CREATED)

    @action(detail=False)
    def get_user_ratings(self, request):
        """Gets all the Book Ratings for the given User.

        :param request: /books/ratings/get_user_ratings/ -- 'id': int (user id)
        :return: Response with the serialized [BookRating]
        """
        try:
            user = User.objects.get(pk=request.GET['id'])
        except User.DoesNotExist or ValueError:
            Response(status=status.HTTP_400_BAD_REQUEST)

        ratings = user.book_user.ratings
        serializer = serializers.BookRatingSerializer(ratings, many=True)
        return Response(serializer.data)


class MovieRatingViewSet(viewsets.ModelViewSet):
    queryset = models.MovieRating.objects.all()
    serializer_class = serializers.MovieRatingSerializer
    permission_classes = ()
    authentication_classes = ()

    @csrf_exempt
    @action(detail=False, methods=['post'])
    def new(self, request):
        """Adds a new rating for the user on the given media. Updates the user model embedding
           which updates the user's predictions.

        :param request: /movies/ratings/new/ -- 'id': int (user id), 'movie': int (movieId), 'rating': float
        :return Response with status
        """
        user = User.objects.get(pk=int(request.data['id']))

        if models.MovieRating.objects.filter(rating_user=user.movie_user,
                                             movie=Movie.objects.get(pk=int(request.data['movie']))).exists():
            movie_rating = models.MovieRating.objects.get(rating_user=user.movie_user,
                                                          movie=Movie.objects.get(pk=int(request.data['movie'])))
            movie_rating.rating = float(request.data['rating'])

        else:
            movie_rating = models.MovieRating(rating_user=user.movie_user,
                                              movie=Movie.objects.get(pk=int(request.data['movie'])),
                                              rating=float(request.data['rating']))
        movie_rating.save()
        MoviePredictionViewSet.update_user_embedding(user)

        return Response(status=status.HTTP_201_CREATED)

    @action(detail=False)
    def get_user_ratings(self, request):
        """Gets all the Movie Ratings for the given User.

        :param request: /movies/ratings/get_user_ratings/ -- 'id': int (user id)
        :return: Response with the serialized [BookRating]
        """
        try:
            user = User.objects.get(pk=request.GET['id'])
        except User.DoesNotExist or ValueError:
            Response(status=status.HTTP_400_BAD_REQUEST)

        ratings = user.movie_user.ratings
        serializer = serializers.MovieRatingSerializer(ratings, many=True)
        return Response(serializer.data)
