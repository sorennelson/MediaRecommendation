# Generated by Django 4.1.3 on 2022-12-18 04:27

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("genres", "0001_initial"),
    ]

    operations = [
        migrations.AlterField(
            model_name="bookgenre", name="count", field=models.IntegerField(default=0),
        ),
        migrations.AlterField(
            model_name="moviegenre", name="count", field=models.IntegerField(default=0),
        ),
    ]
