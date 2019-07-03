from django.contrib import admin

from ratings.models import BookRatingUser, MovieRatingUser

admin.site.register(BookRatingUser)
admin.site.register(MovieRatingUser)