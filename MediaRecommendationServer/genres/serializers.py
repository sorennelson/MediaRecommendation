from rest_framework import serializers
from genres.models import BookGenre, MovieGenre


class BookGenreSerializer(serializers.ModelSerializer):
    books = serializers.PrimaryKeyRelatedField(many=True, read_only=True)

    class Meta:
        model = BookGenre
        fields = ('name', 'books_count', 'books',)


class MovieGenreSerializer(serializers.ModelSerializer):
    movies = serializers.PrimaryKeyRelatedField(many=True, read_only=True)

    class Meta:
        model = MovieGenre
        fields = ('name', 'movies_count', 'movies',)
