from django.db.models import Case, When

from rest_framework import status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import action

from media.serializers import BookSerializer, MovieSerializer
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
        """Gets all the Books for a given Genre.

        :param request: /books/genres/get_genre_media/ -- 'name': string (genre name)
        :return: Response with the serialized [Books]
        """
        try:
            genre = models.BookGenre.objects.get(name=request.GET['name'])
        except genre.DoesNotExist or ValueError:
            Response(status=status.HTTP_400_BAD_REQUEST)

        serializer = BookSerializer(genre.books, many=True)
        response = Response(serializer.data)
        print(response.content)
        return response


class MovieGenreViewSet(viewsets.ModelViewSet):
    queryset = models.MovieGenre.objects.order_by(
        Case(When(name='All', then=0), default=1),
        'name'
    )
    serializer_class = serializers.MovieGenreSerializer

    @action(detail=False)
    def get_genre_media(self, request):
        """Gets all the Movies for a given Genre.

        :param request: /movies/genres/get_genre_media/ -- 'name': string (genre name)
        :return: Response with the serialized [Movies]
        """
        try:
            genre = models.MovieGenre.objects.get(name=request.GET['name'])
        except genre.DoesNotExist or ValueError:
            Response(status=status.HTTP_400_BAD_REQUEST)

        serializer = MovieSerializer(genre.movies, many=True)
        response = Response(serializer.data)
        return response
