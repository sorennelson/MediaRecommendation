# Generated by Django 2.2.2 on 2019-08-04 20:34

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('media', '0010_book_work_id'),
    ]

    operations = [
        migrations.AddField(
            model_name='movie',
            name='tmdb_id',
            field=models.IntegerField(default=0),
        ),
    ]
