from rest_framework import serializers
from . import models


class MovieRatingUserSerializer(serializers.ModelSerializer):
    movie_rating_ids = serializers.PrimaryKeyRelatedField(many=True, read_only=True)
    movie_ratings = serializers.ListField(child=serializers.FloatField())

    class Meta:
        model = models.MovieRatingUser
        fields = ('id', 'movie_rating_ids', 'movie_ratings')


class BookRatingUserSerializer(serializers.ModelSerializer):
    book_rating_ids = serializers.PrimaryKeyRelatedField(many=True, read_only=True)
    book_ratings = serializers.ListField(child=serializers.FloatField())

    class Meta:
        model = models.MovieRatingUser
        fields = ('id', 'book_rating_ids', 'book_ratings')