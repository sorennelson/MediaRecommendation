from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import login, logout
from django.contrib.auth import authenticate
from threading import Thread

from . import serializers
from . import models
from predictions.views import MoviePredictionViewSet, BookPredictionViewSet


@csrf_exempt
def auth_login(request):
    """Client attempts to login

     - Check for username and password
     - Return serialized user data
    """
    username = request.POST['username']
    password = request.POST['password']
    user = authenticate(username=username, password=password)

    if user:
        login(request, user)
        serializer = serializers.UserSerializer(user)
        return JsonResponse(serializer.data)
    return HttpResponse(status=401)


@csrf_exempt
def signup(request):
    """Client attempts to sign up

     - If username does not already exist we create and authenticate new account
     - Otherwise return 403
    """
    if models.User.objects.filter(username=request.POST['username']).exists():
        return HttpResponse(status=403)
    else:
        book_user = models.BookUser()
        book_user.save()
        movie_user = models.MovieUser()
        movie_user.save()

        u = models.User(username=request.POST['username'], book_user=book_user, movie_user=movie_user)
        u.set_password(request.POST['password'])
        u.save()
        login(request, u)
        serializer = serializers.UserSerializer(u)

        # Predict on movies - run on daemon background thread 
        # MoviePredictionViewSet.predict_movies_for_user(user=u)
        thread = Thread(target=MoviePredictionViewSet.predict_movies_for_user, 
                        args=[u], 
                        daemon=True)
        thread.start()

        # Predict on Books - run on daemon background thread 
        # BookPredictionViewSet.predict_books_for_user(user=u)
        thread = Thread(target=BookPredictionViewSet.predict_books_for_user, 
                        args=[u], 
                        daemon=True)
        thread.start()

        return JsonResponse(serializer.data)


def auth_logout(request):
    """Clears the session """
    logout(request)
    return HttpResponse(status=200)


