from rest_framework import viewsets

from . import serializers
from . import models


class BookRatingViewSet(viewsets.ModelViewSet):
    queryset = models.BookRating.objects.all()
    serializer_class = serializers.BookRatingSerializer


class MovieRatingViewSet(viewsets.ModelViewSet):
    queryset = models.MovieRating.objects.all()
    serializer_class = serializers.MovieRatingSerializer
