from django.db.models import Case, When

from rest_framework import status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import action

from media.serializers import BookSerializer, MovieSerializer
from predictions.models import BookPrediction, MoviePrediction
from userauth.models import User
from . import serializers
from . import models


class BookGenreViewSet(viewsets.ModelViewSet):
    queryset = models.BookGenre.objects.order_by(
        Case(When(name='All', then=0), default=1),
        'name'
    )
    serializer_class = serializers.BookGenreSerializer

    @action(detail=False)
    def get_genre_media(self, request):
        """Gets all the Books for a given Genre. Defaults to the predictions for the genre, otherwise returns all.

        :param request: /books/genres/get_genre_media/ -- 'name': string (genre name), 'id': int (user id)
        :return: Response with the serialized [Books]
        """
        try:
            genre = models.BookGenre.objects.get(name=request.GET['name'])
            user = User.objects.get(pk=request.GET['id'])
        except genre.DoesNotExist or user.DoesNotExist or ValueError:
            Response(status=status.HTTP_400_BAD_REQUEST)

        predictions = BookPrediction.objects.filter(prediction_user=user.book_user).filter(book__in=genre.books.all())
        n_return_books = 500
        if len(predictions) > 50:
            n_return_books = min(len(predictions), n_return_books)
            books = [pred.book for pred in predictions[:n_return_books]]
        else:
            n_return_books = min(genre.books.count, n_return_books)
            books = genre.books[:n_return_books]

        serializer = BookSerializer(books, many=True)
        response = Response(serializer.data)
        return response


class MovieGenreViewSet(viewsets.ModelViewSet):
    queryset = models.MovieGenre.objects.order_by(
        Case(When(name='All', then=0), default=1),
        'name'
    )
    serializer_class = serializers.MovieGenreSerializer

    @action(detail=False)
    def get_genre_media(self, request):
        """Gets the Movies for a given Genre. Defaults to the predictions for the genre, otherwise returns all.

        :param request: /movies/genres/get_genre_media/ -- 'name': string (genre name), 'id': int (user id)
        :return: Response with the serialized [Movies]
        """
        try:
            genre = models.MovieGenre.objects.get(name=request.GET['name'])
            user = User.objects.get(pk=request.GET['id'])
        except genre.DoesNotExist or user.DoesNotExist or ValueError:
            Response(status=status.HTTP_400_BAD_REQUEST)

        predictions = MoviePrediction.objects.filter(prediction_user=user.movie_user).filter(movie__in=genre.movies.all())

        n_return_books = 500
        if len(predictions) > 50:
            n_return_books = min(len(predictions), n_return_books)
            books = [pred.book for pred in predictions[:n_return_books]]
        else:
            n_return_books = min(len(genre.books), n_return_books)
            books = genre.books[:n_return_books]

        n_return_movies = 500
        if len(predictions) > 50:
            n_return_movies = min(len(predictions), n_return_movies)
            movies = [pred.movie for pred in predictions[:n_return_movies]]
        else:
            n_return_movies = min(genre.movies.count(), n_return_movies)
            movies = genre.movies[:n_return_movies]

        serializer = MovieSerializer(movies, many=True)
        response = Response(serializer.data)
        return response
