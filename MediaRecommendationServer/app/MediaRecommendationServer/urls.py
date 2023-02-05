"""MediaRecommendationServer URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework import routers

from media.views import BookViewSet, MovieViewSet
from ratings.views import BookRatingViewSet, MovieRatingViewSet
from predictions.views import BookPredictionViewSet, MoviePredictionViewSet
from genres.views import BookGenreViewSet, MovieGenreViewSet
from series.views import BookSeriesViewSet, MovieSeriesViewSet

router = routers.DefaultRouter()
router.register(r'books/all', BookViewSet)
router.register(r'books/ratings', BookRatingViewSet)
router.register(r'books/predictions', BookPredictionViewSet)
router.register(r'books/genres', BookGenreViewSet)
router.register(r'books/series', BookSeriesViewSet)

router.register(r'movies/all', MovieViewSet)
router.register(r'movies/ratings', MovieRatingViewSet)
router.register(r'movies/predictions', MoviePredictionViewSet)
router.register(r'movies/genres', MovieGenreViewSet)
router.register(r'movies/series', MovieSeriesViewSet)


urlpatterns = [
    path('admin/', admin.site.urls),
    # path('^/', include('rest_framework.urls', namespace='rest_framework')),
    path('', include('userauth.urls')),
    path('', include(router.urls)),
]