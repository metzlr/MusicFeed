from django.db import models

# Create your models here.

class Artist(models.Model):
    name = models.CharField(max_length=100)
    spotify_id = models.CharField(max_length=100)
    img_url = models.URLField(max_length=200)

class ArtistGroup(models.Model):
    name = models.CharField(max_length=50)
    artists = models.ManyToManyField(Artist)
