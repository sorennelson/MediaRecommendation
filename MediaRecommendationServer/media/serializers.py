from media.models import Book, Movie
from rest_framework import serializers


class BookSerializer(serializers.ModelSerializer):
    class Meta:
        model = Book
        fields = ('id', 'title', 'author', 'genres', 'year',
                  'average_rating', 'num_watched', 'image_url', 'small_image_url')


class MovieSerializer(serializers.ModelSerializer):
    class Meta:
        model = Movie
        fields = ('id', 'title', 'genres', 'year',
                  'average_rating', 'num_watched', 'image_url')
