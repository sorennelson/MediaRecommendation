from django.db import models
from django.contrib.postgres.fields import ArrayField
from media.models import Book, Movie


class BookRating(models.Model):
    rating_user = models.ForeignKey('BookRatingUser', on_delete=models.PROTECT, related_name='ratings')
    book = models.ForeignKey('media.Book', on_delete=models.PROTECT)
    rating = models.FloatField(default=0.0)

    class Meta:
        ordering = ['book', 'rating_user']


class BookPrediction(models.Model):
    prediction_user = models.ForeignKey('BookRatingUser', on_delete=models.PROTECT, related_name='predictions')
    book = models.ForeignKey('media.Book', on_delete=models.PROTECT)
    prediction = models.FloatField(default=0.0)

    class Meta:
        ordering = ['prediction', 'prediction_user']


class BookRatingUser(models.Model):
    class Meta:
        ordering = ['id']


class MovieRating(models.Model):
    rating_user = models.ForeignKey('MovieRatingUser', on_delete=models.PROTECT, related_name='ratings')
    movie = models.ForeignKey('media.Movie', on_delete=models.PROTECT)
    rating = models.FloatField(default=0.0)

    class Meta:
        ordering = ['movie', 'rating_user']


class MoviePrediction(models.Model):
    prediction_user = models.ForeignKey('MovieRatingUser', on_delete=models.PROTECT, related_name='predictions')
    movie = models.ForeignKey('media.Movie', on_delete=models.PROTECT)
    prediction = models.FloatField(default=0.0)

    class Meta:
        ordering = ['prediction', 'prediction_user']


class MovieRatingUser(models.Model):
    class Meta:
        ordering = ['id']

