from rest_framework import viewsets

from . import serializers
from . import models


class BookSeriesViewSet(viewsets.ModelViewSet):
    queryset = models.BookSeries.objects.all()[:60]
    serializer_class = serializers.BookSeriesSerializer


class MovieSeriesViewSet(viewsets.ModelViewSet):
    queryset = models.MovieSeries.objects.all()[:60]
    serializer_class = serializers.MovieSeriesSerializer

