from django.db import models
from django.contrib.auth.models import AbstractUser
from django.contrib.postgres.fields import ArrayField

from MediaRecommendationServer import helper


class User(AbstractUser):
    """Extend functionality of user"""
    book_rating_ids = models.ManyToManyField('media.Book')
    book_ratings = ArrayField(base_field=models.FloatField(), default=list)

    movie_rating_ids = models.ManyToManyField('media.Movie')
    movie_ratings = ArrayField(base_field=models.FloatField(), default=list)

    # book_uid = models.IntegerField(unique=True, editable=False, default=helper.create_book_uid())
    # movie_uid = models.IntegerField(unique=True, editable=False, default=helper.create_movie_uid())

    # TODO: Why?
    hash_id = models.CharField(max_length=32, default=helper.create_hash, unique=True)
