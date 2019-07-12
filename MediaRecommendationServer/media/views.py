from rest_framework import status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import action
from django.contrib.auth.decorators import login_required

from media.models import Book, Movie
from media.serializers import BookSerializer, MovieSerializer

from predictions.models import BookPrediction, MoviePrediction
from predictions.serializers import BookPredictionSerializer, MoviePredictionSerializer


class BookViewSet(viewsets.ModelViewSet):
    # Fetch all books
    queryset = Book.objects.all()
    serializer_class = BookSerializer


class MovieViewSet(viewsets.ModelViewSet):
    # Fetch all movies
    queryset = Movie.objects.all()
    serializer_class = MovieSerializer

    @login_required
    @action(detail=False)
    def get_top_recommendations(self, request, start, end):
        predictions = MoviePrediction.objects.filter(prediction_user=request.user)[start:end]

        movies = []
        for prediction in predictions:
            movies.append(prediction.movie)
        serializer = MoviePredictionSerializer(movies, many=True)

        return Response(serializer.data)




