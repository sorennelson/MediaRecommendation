from rest_framework import status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import action
# from django.contrib.auth.decorators import login_required

from media.models import Book, Movie
from media.serializers import BookSerializer, MovieSerializer

from predictions.models import BookPrediction, MoviePrediction
from predictions.serializers import BookPredictionSerializer, MoviePredictionSerializer

from userauth.models import User


class BookViewSet(viewsets.ModelViewSet):
    queryset = Book.objects.all()
    serializer_class = BookSerializer

    @action(detail=False)
    def get_top_recommendations(self, request):
        """Get the top book recommendations from the given [start index, end index) for the User with the given ID

        :param request: /books/all/get_top_recommendations/ -- 'start': int, 'end': int, 'id': int (user id)
        :return: Response with the serialized [Book]
        """
        try:
            start = int(request.GET['start'])
            end = int(request.GET['end'])
            user = User.objects.get(pk=request.GET['id'])
        except User.DoesNotExist or ValueError:
            Response(status=status.HTTP_400_BAD_REQUEST)

        book_user = user.book_user
        predictions = BookPrediction.objects.filter(prediction_user=book_user)
        predictions = predictions[start:end]

        books = []
        for prediction in predictions:
            books.append(prediction.book)
        serializer = BookSerializer(books, many=True)

        return Response(serializer.data)


class MovieViewSet(viewsets.ModelViewSet):
    queryset = Movie.objects.all()
    serializer_class = MovieSerializer

    @action(detail=False)
    def get_top_recommendations(self, request):
        """Get the top movie recommendations from the given [start index, end index) for the User with the given ID

        :param request: /movies/all/get_top_recommendations/ -- 'start': int, 'end': int, 'id': int (user id)
        :return: Response with the serialized [Movie]
        """
        try:
            start = int(request.GET['start'])
            end = int(request.GET['end'])
            user = User.objects.get(pk=request.GET['id'])
        except User.DoesNotExist or ValueError:
            Response(status=status.HTTP_400_BAD_REQUEST)

        print(user.id)
        print(user.book_user.id)
        print(user.movie_user.id)
        movie_user = user.movie_user
        predictions = MoviePrediction.objects.filter(prediction_user=movie_user)
        predictions = predictions[start:end]

        movies = []
        for prediction in predictions:
            movies.append(prediction.movie)
        serializer = MovieSerializer(movies, many=True)

        return Response(serializer.data)




