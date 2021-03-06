# Generated by Django 2.2.2 on 2019-07-03 18:05

import django.contrib.postgres.fields
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('media', '0007_auto_20190701_1600'),
    ]

    operations = [
        migrations.CreateModel(
            name='MovieRatingUser',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('movie_ratings', django.contrib.postgres.fields.ArrayField(base_field=models.FloatField(), default=list, size=None)),
                ('movie_rating_ids', models.ManyToManyField(to='media.Movie')),
            ],
        ),
        migrations.CreateModel(
            name='BookRatingUser',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('book_ratings', django.contrib.postgres.fields.ArrayField(base_field=models.FloatField(), default=list, size=None)),
                ('book_rating_ids', models.ManyToManyField(to='media.Book')),
            ],
        ),
    ]
