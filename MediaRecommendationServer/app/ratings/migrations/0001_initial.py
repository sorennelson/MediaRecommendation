# Generated by Django 4.1.3 on 2022-11-19 20:24

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ("userauth", "0001_initial"),
        ("media", "0001_initial"),
    ]

    operations = [
        migrations.CreateModel(
            name="MovieRating",
            fields=[
                (
                    "id",
                    models.AutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("rating", models.FloatField(default=0.0)),
                (
                    "movie",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.PROTECT, to="media.movie"
                    ),
                ),
                (
                    "rating_user",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.PROTECT,
                        related_name="ratings",
                        to="userauth.movieuser",
                    ),
                ),
            ],
            options={"ordering": ["movie", "rating_user"],},
        ),
        migrations.CreateModel(
            name="BookRating",
            fields=[
                (
                    "id",
                    models.AutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("rating", models.FloatField(default=0.0)),
                (
                    "book",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.PROTECT, to="media.book"
                    ),
                ),
                (
                    "rating_user",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.PROTECT,
                        related_name="ratings",
                        to="userauth.bookuser",
                    ),
                ),
            ],
            options={"ordering": ["book", "rating_user"],},
        ),
    ]
