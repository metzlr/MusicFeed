from django.db import models
from django.contrib.auth.models import User
from django.dispatch import receiver

# Create your models here.
'''
class UserApiInfo(models.Model):
    pass
'''

class Artist(models.Model):
    name = models.CharField(max_length=100)
    spotify_id = models.CharField(max_length=100)
    img_url = models.URLField(max_length=200)
    artist_groups = models.ManyToManyField('ArtistGroup')
    spotify_profile_url = models.URLField(max_length=200)


class ArtistGroup(models.Model):
    name = models.CharField(max_length=25)
    artists = models.ManyToManyField(Artist)
    author = models.ForeignKey(User, on_delete=models.CASCADE)

    def __str__(self):
        return self.name


@receiver(models.signals.pre_delete, sender=ArtistGroup)
def pre_delete_group(sender, instance, **kwargs):
    for artist in instance.artists.all():
        if artist.artist_groups.count() == 1:
            print("DELETING",artist.name)
            # instance is the only ArtistGroup the Artist is in, so delete it
            artist.delete()