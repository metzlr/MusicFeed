from django import forms
#from django.contrib.postgres.forms.jsonb import JSONField
from .models import ArtistGroup, Artist
from django.core.exceptions import ObjectDoesNotExist
from django.utils.translation import gettext as _
import json

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

    artist_metadata = forms.CharField(widget=forms.HiddenInput(), required=True)
    #artist_metadata = JSONField(widget=forms.HiddenInput())
    
    def __init__(self, *args, **kwargs):
        self.user = kwargs.pop('user')
        super(AddArtistToGroupForm, self).__init__(*args, **kwargs)
        
        artistgroups = self.user.artistgroup_set.all()
        self.fields['groups'] = forms.MultipleChoiceField(widget=forms.CheckboxSelectMultiple(), choices=[(x.id, x.name) for x in artistgroups])
        self.fields['groups'].label = "Select Groups"
    
    def clean(self):
        cleaned_data = super().clean()
        selected_groups = cleaned_data.get('groups')
        artist_data = json.loads(cleaned_data['artist_metadata'])
        invalid_groups = []

        for group_str in selected_groups:
            group = self.user.artistgroup_set.filter(id=group_str).first()
            try: 
                group.artists.get(spotify_id__exact=artist_data['id'])
                invalid_groups.append(group.name)
            except ObjectDoesNotExist:
                continue
        
        if len(invalid_groups) > 0:
            error_str = ''
            for g in invalid_groups:
                error_str += (g+', ')
            raise forms.ValidationError(
                _('The following groups already contain that artist: %(value)s'),
                code='invalid',
                params={'value': error_str},
            )
        
        return cleaned_data

class RenameGroupForm(forms.ModelForm):
    class Meta:
        model = ArtistGroup
        fields = ['name']
