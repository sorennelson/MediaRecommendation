from django.contrib import admin

from predictions.models import BookPrediction, MoviePrediction

admin.site.register(BookPrediction)
admin.site.register(MoviePrediction)
