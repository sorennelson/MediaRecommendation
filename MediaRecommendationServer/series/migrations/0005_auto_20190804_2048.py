# Generated by Django 2.2.2 on 2019-08-04 20:48

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('series', '0004_bookseries_avg_rating'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='bookseries',
            options={'ordering': ['-avg_rating']},
        ),
    ]
