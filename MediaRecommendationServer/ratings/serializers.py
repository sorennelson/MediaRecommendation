from rest_framework import serializers
from . import models


# PRAGMA: Books
class BookRatingSerializer(serializers.ModelSerializer):
    rating_user = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    book = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    rating = serializers.FloatField()

    class Meta:
        model = models.MovieRatingUser
        fields = ('rating_user', 'book', 'rating',)


class BookPredictionSerializer(serializers.ModelSerializer):
    rating_user = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    book = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    prediction = serializers.FloatField()

    class Meta:
        model = models.MovieRatingUser
        fields = ('rating_user', 'book', 'prediction',)


class BookRatingUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.BookRatingUser
        fields = ('id',)


# PRAGMA: Movies
class MovieRatingSerializer(serializers.ModelSerializer):
    rating_user = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    movie = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    rating = serializers.FloatField()

    class Meta:
        model = models.MovieRatingUser
        fields = ('rating_user', 'movie', 'rating',)


class MoviePredictionSerializer(serializers.ModelSerializer):
    rating_user = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    movie = serializers.PrimaryKeyRelatedField(many=False, read_only=True)
    prediction = serializers.FloatField()

    class Meta:
        model = models.MovieRatingUser
        fields = ('rating_user', 'movie', 'prediction',)


class MovieRatingUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.MovieRatingUser
        fields = ('id',)
