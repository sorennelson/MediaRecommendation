from django.db import models


class BookGenre(models.Model):
    name = models.CharField(max_length=300)
    books_count = models.IntegerField()
    books = models.ManyToManyField('media.Book')

    class Meta:
        ordering = ['name']


class MovieGenre(models.Model):
    name = models.CharField(max_length=300)
    movies_count = models.IntegerField()
    movies = models.ManyToManyField('media.Movie')

    class Meta:
        ordering = ['name']
