from django.db import models
from django.contrib.auth.models import AbstractUser

from MediaRecommendationServer import helper


class User(AbstractUser):
    book_user = models.OneToOneField('BookUser', on_delete=models.CASCADE, null=True, default=None)
    movie_user = models.OneToOneField('MovieUser', on_delete=models.CASCADE, null=True, default=None)


class BookUser(models.Model):
    embedding_id = models.IntegerField(unique=False, default=0)
    class Meta:
        ordering = ['id']


class MovieUser(models.Model):
    embedding_id = models.IntegerField(unique=False, default=0)
    class Meta:
        ordering = ['id']

