from rest_framework import serializers

from . import models
from media.serializers import BookSerializer, MovieSerializer


class BookRatingSerializer(serializers.ModelSerializer):
    book = BookSerializer()
    rating = serializers.FloatField()

    class Meta:
        model = models.BookRating
        fields = ('book', 'rating',)


class MovieRatingSerializer(serializers.ModelSerializer):
    movie = MovieSerializer()
    rating = serializers.FloatField()

    class Meta:
        model = models.MovieRating
        fields = ('movie', 'rating',)
