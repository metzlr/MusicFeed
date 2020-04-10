from django import forms
from .models import ArtistGroup

class ArtistGroupForm(forms.ModelForm):

    class Meta:
        model = ArtistGroup
        fields = ['name']