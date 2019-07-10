from django.db import models
from django.contrib.postgres.fields import ArrayField


class BookRatingUser(models.Model):
    book_rating_ids = models.ManyToManyField('media.Book')
    book_ratings = ArrayField(base_field=models.FloatField(), default=list)
    models.ManyToManyField('media.Book', related_name='ordered_predictions')


class MovieRatingUser(models.Model):
    movie_rating_ids = models.ManyToManyField('media.Movie')
    movie_ratings = ArrayField(base_field=models.FloatField(), default=list)
    predictions = models.ManyToManyField('media.Movie', related_name='ordered_predictions')
