from django import forms
#from django.contrib.postgres.forms.jsonb import JSONField
from .models import ArtistGroup, Artist


class ArtistGroupForm(forms.ModelForm):

    class Meta:
        model = ArtistGroup
        fields = ['name']

'''
class AddArtistToGroupForm(forms.ModelForm):
    
    class Meta:
        model = Artist
        exclude = ['name', 'spotify_id', 'img_url']
'''

class AddArtistToGroupForm(forms.Form):

    artist_metadata = forms.CharField(widget=forms.HiddenInput, required=True)
    #artist_metadata = JSONField(widget=forms.HiddenInput())
    
    def __init__(self, *args, **kwargs):
        self.user = kwargs.pop('user')
        super(AddArtistToGroupForm, self).__init__(*args, **kwargs)
        
        artistgroups = self.user.artistgroup_set.all()
        self.fields['groups'] = forms.MultipleChoiceField(widget=forms.CheckboxSelectMultiple(), choices=[(x.id, x.name) for x in artistgroups])
        self.fields['groups'].label = "Select Groups"
        