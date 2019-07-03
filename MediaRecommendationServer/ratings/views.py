from rest_framework import viewsets

from . import serializers
from . import models


class BookRatingUserViewSet(viewsets.ModelViewSet):
    # Fetch all book ratings
    queryset = models.BookRatingUser.objects.all()
    serializer_class = serializers.BookRatingUserSerializer


class MovieRatingUserViewSet(viewsets.ModelViewSet):
    # Fetch all movie ratings
    queryset = models.MovieRatingUser.objects.all()
    serializer_class = serializers.MovieRatingUserSerializer
