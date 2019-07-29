from rest_framework import status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import action

from . import serializers
from . import models

from userauth.models import User


class BookRatingViewSet(viewsets.ModelViewSet):
    queryset = models.BookRating.objects.all()
    serializer_class = serializers.BookRatingSerializer

    @action(detail=False)
    def set_user_ratings(self, request):
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