from rest_framework import viewsets

from . import serializers
from . import models


class BookPredictionViewSet(viewsets.ModelViewSet):
    queryset = models.BookPrediction.objects.all()
    serializer_class = serializers.BookPredictionSerializer


class MoviePredictionViewSet(viewsets.ModelViewSet):
    queryset = models.MoviePrediction.objects.all()
    serializer_class = serializers.MoviePredictionSerializer
