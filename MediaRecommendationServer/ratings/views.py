from rest_framework import viewsets

from . import serializers
from . import models


class BookRatingViewSet(viewsets.ModelViewSet):
    # Fetch all book ratings
    queryset = models.BookRating.objects.all()
    serializer_class = serializers.BookRatingSerializer


class MovieRatingViewSet(viewsets.ModelViewSet):
    # Fetch all movie ratings
    queryset = models.MovieRating.objects.all()
    serializer_class = serializers.MovieRatingSerializer
