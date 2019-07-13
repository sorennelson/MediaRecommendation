from rest_framework import status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import action
# from django.contrib.auth.decorators import login_required

from media.models import Book, Movie
from media.serializers import BookSerializer, MovieSerializer

from predictions.models import BookPrediction, MoviePrediction
from predictions.serializers import BookPredictionSerializer, MoviePredictionSerializer

from userauth.models import User, BookUser, MovieUser


class BookViewSet(viewsets.ModelViewSet):
    # Fetch all books
    queryset = Book.objects.all()
    serializer_class = BookSerializer


class MovieViewSet(viewsets.ModelViewSet):
    # Fetch all movies
    queryset = Movie.objects.all()
    serializer_class = MovieSerializer

    @action(detail=False)
    def get_top_recommendations(self, request):
        start = request.GET['start']
        end = request.GET['end']
        uid = request.GET['id']
        print(type(start))
        print(type(end))

        try:
            start = int(start)
            end = int(end)
            user = User.objects.get(pk=uid)
        except User.DoesNotExist or ValueError:
            Response(status=status.HTTP_400_BAD_REQUEST)

        movie_user = user.movie_user
        predictions = MoviePrediction.objects.filter(prediction_user=movie_user)
        print(predictions)
        predictions = predictions[start:end]

        movies = []
        for prediction in predictions:
            movies.append(prediction.movie)
        serializer = MoviePredictionSerializer(movies, many=True)

        return Response(serializer.data)




