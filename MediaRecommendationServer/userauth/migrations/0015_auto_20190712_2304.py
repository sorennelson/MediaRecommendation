# Generated by Django 2.2.2 on 2019-07-12 23:04

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('userauth', '0014_auto_20190712_2054'),
    ]

    operations = [
        migrations.AlterField(
            model_name='user',
            name='book_user',
            field=models.OneToOneField(default=None, null=True, on_delete=django.db.models.deletion.CASCADE, to='userauth.BookUser'),
        ),
        migrations.AlterField(
            model_name='user',
            name='movie_user',
            field=models.OneToOneField(default=None, null=True, on_delete=django.db.models.deletion.CASCADE, to='userauth.MovieUser'),
        ),
    ]