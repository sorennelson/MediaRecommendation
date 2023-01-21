# Generated by Django 4.1.3 on 2022-11-19 20:14

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ("media", "0001_initial"),
    ]

    operations = [
        migrations.CreateModel(
            name="MovieGenre",
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
                ("name", models.CharField(max_length=300, unique=True)),
                ("count", models.IntegerField()),
                ("movies", models.ManyToManyField(to="media.movie")),
            ],
            options={"ordering": ["name"],},
        ),
        migrations.CreateModel(
            name="BookGenre",
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
                ("name", models.CharField(max_length=300, unique=True)),
                ("count", models.IntegerField()),
                ("books", models.ManyToManyField(to="media.book")),
            ],
            options={"ordering": ["name"],},
        ),
    ]
