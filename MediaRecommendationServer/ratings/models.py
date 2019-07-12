from django.db import models


class BookRating(models.Model):
    rating_user = models.ForeignKey('userauth.BookUser', on_delete=models.PROTECT, related_name='ratings')
    book = models.ForeignKey('media.Book', on_delete=models.PROTECT)
    rating = models.FloatField(default=0.0)

    class Meta:
        ordering = ['book', 'rating_user']


class MovieRating(models.Model):
    rating_user = models.ForeignKey('userauth.MovieUser', on_delete=models.PROTECT, related_name='ratings')
    movie = models.ForeignKey('media.Movie', on_delete=models.PROTECT)
    rating = models.FloatField(default=0.0)

    class Meta:
        ordering = ['movie', 'rating_user']

