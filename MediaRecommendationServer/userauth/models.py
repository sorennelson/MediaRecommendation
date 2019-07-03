from django.db import models
from django.contrib.auth.models import AbstractUser

from MediaRecommendationServer import helper


class User(AbstractUser):
    book_uid = models.OneToOneField('ratings.BookRatingUser', on_delete=models.PROTECT, null=True, default=None)
    movie_uid = models.OneToOneField('ratings.MovieRatingUser', on_delete=models.PROTECT, null=True, default=None)

    # TODO: Why?
    hash_id = models.CharField(max_length=32, default=helper.create_hash, unique=True)

