import json

from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import login, logout
from django.contrib.auth import authenticate

from rest_framework import status

from . import serializers
from . import models


@csrf_exempt
def auth_login(request):
    """Client attempts to login

     - Check for username and password
     - Return serialized user data
    """
    email = request.POST['email']
    password = request.POST['password']
    user = authenticate(email=email, password=password)

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
    if models.User.objects.filter(email=request.POST['email']).exists():
        return HttpResponse(status=403)
    else:
        u = models.User(email=request.POST['email'])
        u.set_password(request.POST['password'])
        u.save()
        login(request, u)
        serializer = serializers.UserSerializer(u)
        return JsonResponse(serializer.data)


def auth_logout(request):
    """Clears the session """
    logout(request)
    return HttpResponse(status=200)






