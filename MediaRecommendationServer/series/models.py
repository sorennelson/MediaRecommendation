from django.db import models


class BookSeries(models.Model):
    name = models.CharField(max_length=300)
    goodreads_id = models.IntegerField(primary_key=True)
    avg_rating = models.FloatField(default=0.0)
    most_viewed = models.ForeignKey('media.Book', null=True, on_delete=models.PROTECT, related_name='Most_Viewed')
    books = models.ManyToManyField('media.Book')

    class Meta:
        ordering = ['-avg_rating']


class MovieSeries(models.Model):
    name = models.CharField(max_length=300)
    tmdb_id = models.IntegerField(primary_key=True)
    avg_rating = models.FloatField(default=0.0)
    most_viewed = models.ForeignKey('media.Movie', null=True, on_delete=models.PROTECT, related_name='Most_Viewed')
    movies = models.ManyToManyField('media.Movie')

    class Meta:
        ordering = ['-avg_rating']
