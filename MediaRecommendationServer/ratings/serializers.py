from rest_framework import serializers
from . import models


class BookRatingSerializer(serializers.ModelSerializer):
    book = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    rating = serializers.FloatField()

    class Meta:
        model = models.BookRating
        fields = ('book', 'rating',)


class MovieRatingSerializer(serializers.ModelSerializer):
    movie = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    rating = serializers.FloatField()

    class Meta:
        model = models.MovieRating
        fields = ('movie', 'rating',)
