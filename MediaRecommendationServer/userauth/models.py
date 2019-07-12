from django.db import models
from django.contrib.auth.models import AbstractUser

from MediaRecommendationServer import helper


class User(AbstractUser):
    book_user = models.OneToOneField('BookUser', on_delete=models.CASCADE, null=True, default=None)
    movie_user = models.OneToOneField('MovieUser', on_delete=models.CASCADE, null=True, default=None)

    # TODO: Why?
    hash_id = models.CharField(max_length=32, default=helper.create_hash, unique=True)


class BookUser(models.Model):
    class Meta:
        ordering = ['id']
        # ALTER SEQUENCE userauth_bookuser RESTART WITH 13123;


class MovieUser(models.Model):
    class Meta:
        ordering = ['id']

