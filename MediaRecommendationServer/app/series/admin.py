from django.contrib import admin

from . import models

admin.site.register(models.BookSeries)
admin.site.register(models.MovieSeries)
