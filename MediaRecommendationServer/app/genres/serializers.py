from rest_framework import serializers
from genres.models import BookGenre, MovieGenre


class BookGenreSerializer(serializers.ModelSerializer):
    class Meta:
        model = BookGenre
        fields = ('name', 'count')


class MovieGenreSerializer(serializers.ModelSerializer):
    class Meta:
        model = MovieGenre
        fields = ('name', 'count')
