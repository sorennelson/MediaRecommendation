from rest_framework import serializers
from . import models


class BookRatingSerializer(serializers.ModelSerializer):
    rating_user = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    book = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    rating = serializers.FloatField()

    class Meta:
        model = models.BookRating
        fields = ('rating_user', 'book', 'rating',)


class MovieRatingSerializer(serializers.ModelSerializer):
    rating_user = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    movie = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    rating = serializers.FloatField()

    class Meta:
        model = models.MovieRating
        fields = ('rating_user', 'movie', 'rating',)
