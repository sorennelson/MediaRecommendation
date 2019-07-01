from django.contrib import admin
from django.urls import path, include
from rest_framework import routers

from media.views import BookViewSet, MovieViewSet

router = routers.DefaultRouter()
router.register(r'books', BookViewSet)
router.register(r'movies', MovieViewSet)

urlpatterns = [
    path('', include(router.urls)),
]