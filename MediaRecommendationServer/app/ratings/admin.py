from django.contrib import admin

from ratings.models import BookRating, MovieRating

admin.site.register(BookRating)
admin.site.register(MovieRating)
