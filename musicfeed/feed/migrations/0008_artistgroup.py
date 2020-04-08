# Generated by Django 3.0.3 on 2020-04-06 03:24

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('feed', '0007_delete_artistgroup'),
    ]

    operations = [
        migrations.CreateModel(
            name='ArtistGroup',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50)),
                ('artists', models.ManyToManyField(to='feed.Artist')),
            ],
        ),
    ]