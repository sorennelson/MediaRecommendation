from django.db import models


class BookGenre(models.Model):
    name = models.CharField(max_length=300, unique=True)
    count = models.IntegerField(default=0)
    books = models.ManyToManyField('media.Book')

    class Meta:
        ordering = ['name']


class MovieGenre(models.Model):
    name = models.CharField(max_length=300, unique=True)
    count = models.IntegerField(default=0)
    movies = models.ManyToManyField('media.Movie')

    class Meta:
        ordering = ['name']
