from django.contrib import admin

from genres.models import BookGenre, MovieGenre

admin.site.register(BookGenre)
admin.site.register(MovieGenre)
