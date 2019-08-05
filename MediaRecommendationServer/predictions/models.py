from django.db import models


class BookPrediction(models.Model):
    prediction_user = models.ForeignKey('userauth.BookUser', on_delete=models.PROTECT, related_name='predictions')
    book = models.ForeignKey('media.Book', on_delete=models.PROTECT)
    prediction = models.FloatField(default=0.0)

    class Meta:
        unique_together=['prediction_user', 'book']
        ordering = ['-prediction', 'prediction_user']


class MoviePrediction(models.Model):
    prediction_user = models.ForeignKey('userauth.MovieUser', on_delete=models.PROTECT, related_name='predictions')
    movie = models.ForeignKey('media.Movie', on_delete=models.PROTECT)
    prediction = models.FloatField(default=0.0)

    class Meta:
        unique_together = ['prediction_user', 'movie']
        ordering = ['-prediction', 'prediction_user']
