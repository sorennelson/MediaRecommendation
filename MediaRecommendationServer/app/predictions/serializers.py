from rest_framework import serializers
from . import models


class BookPredictionSerializer(serializers.ModelSerializer):
    prediction_user = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    book = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    prediction = serializers.FloatField()

    class Meta:
        model = models.BookPrediction
        fields = ('prediction_user', 'book', 'prediction',)


class MoviePredictionSerializer(serializers.ModelSerializer):
    prediction_user = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    movie = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    prediction = serializers.FloatField()

    class Meta:
        model = models.MoviePrediction
        fields = ('prediction_user', 'movie', 'prediction',)
