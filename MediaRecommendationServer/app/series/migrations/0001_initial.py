# Generated by Django 4.1.3 on 2022-11-19 20:14

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ("media", "0001_initial"),
    ]

    operations = [
        migrations.CreateModel(
            name="MovieSeries",
            fields=[
                ("name", models.CharField(max_length=300)),
                ("tmdb_id", models.IntegerField(primary_key=True, serialize=False)),
                ("avg_rating", models.FloatField(default=0.0)),
                (
                    "most_viewed",
                    models.ForeignKey(
                        null=True,
                        on_delete=django.db.models.deletion.PROTECT,
                        related_name="Most_Viewed",
                        to="media.movie",
                    ),
                ),
                ("movies", models.ManyToManyField(to="media.movie")),
            ],
            options={"ordering": ["-avg_rating"],},
        ),
        migrations.CreateModel(
            name="BookSeries",
            fields=[
                ("name", models.CharField(max_length=300)),
                (
                    "goodreads_id",
                    models.IntegerField(primary_key=True, serialize=False),
                ),
                ("avg_rating", models.FloatField(default=0.0)),
                ("books", models.ManyToManyField(to="media.book")),
                (
                    "most_viewed",
                    models.ForeignKey(
                        null=True,
                        on_delete=django.db.models.deletion.PROTECT,
                        related_name="Most_Viewed",
                        to="media.book",
                    ),
                ),
            ],
            options={"ordering": ["-avg_rating"],},
        ),
    ]