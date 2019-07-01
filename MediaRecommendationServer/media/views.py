from rest_framework import viewsets
from media.models import Book, Movie
from media.serializers import BookSerializer, MovieSerializer


class BookViewSet(viewsets.ModelViewSet):
    # Fetch all books
    queryset = Book.objects.all()
    serializer_class = BookSerializer


class MovieViewSet(viewsets.ModelViewSet):
    # Fetch all movies
    queryset = Movie.objects.all()
    serializer_class = MovieSerializer

