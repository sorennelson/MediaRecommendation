from django.db import models
from django.contrib.postgres.fields import ArrayField


class Book(models.Model):
    # id primary key is implicit
    title = models.CharField(max_length=300)
    author = models.CharField(max_length=200)
    genres = ArrayField(base_field=models.CharField(max_length=50))
    year = models.IntegerField()
    goodreads_id = models.IntegerField(unique=True)
    work_id = models.IntegerField(default=0)
    average_rating = models.FloatField(default=0.0)
    num_watched = models.IntegerField(default=0)
    # TODO: Is this just goodreads_id
    # # Non Goodbooks data: goodbooks_id = -1
    # goodbooks_id = models.IntegerField(unique=False, default=-1)
    image_url = models.URLField(null=True)
    small_image_url = models.URLField(null=True)

    class Meta:
        ordering = ['-average_rating', '-num_watched', 'title']


class Movie(models.Model):
    # id primary key is implicit
    title = models.CharField(max_length=300)
    genres = ArrayField(base_field=models.CharField(max_length=20))
    year = models.PositiveSmallIntegerField()
    imdb_id = models.IntegerField(unique=True)
    tmdb_id = models.IntegerField(unique=False, default=-1)
    average_rating = models.FloatField(default=0.0)
    num_watched = models.IntegerField(default=0)
    # Non MovieLens data: movielens_id = -1
    movielens_id = models.IntegerField(unique=False, default=-1)
    image_url = models.URLField(null=True)

    class Meta:
        ordering = ['-average_rating', '-num_watched', 'title']

#     \copy media_book FROM '/users/solosoren/desktop/new_books.csv' DELIMITER ',' CSV;
