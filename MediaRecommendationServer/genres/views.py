from rest_framework import viewsets
from genres.models import BookGenre, MovieGenre
from genres.serializers import BookGenreSerializer, MovieGenreSerializer


class BookGenreViewSet(viewsets.ModelViewSet):
    queryset = BookGenre.objects.all()
    serializer_class = BookGenreSerializer


class MovieGenreViewSet(viewsets.ModelViewSet):
    queryset = MovieGenre.objects.all()
    serializer_class = MovieGenreSerializer
