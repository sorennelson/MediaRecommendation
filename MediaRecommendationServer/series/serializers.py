from rest_framework import serializers
from series.models import BookSeries, MovieSeries

from media.serializers import BookSerializer, MovieSerializer


class BookSeriesSerializer(serializers.ModelSerializer):
    books = BookSerializer(many=True)
    most_viewed = BookSerializer()

    class Meta:
        model = BookSeries
        fields = ('name', 'books', 'most_viewed')


class MovieSeriesSerializer(serializers.ModelSerializer):
    movies = MovieSerializer(many=True)
    most_viewed = MovieSerializer()

    class Meta:
        model = MovieSeries
        fields = ('name', 'movies', 'most_viewed')
