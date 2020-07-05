from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_POST
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib import messages
from django.views.generic import DetailView
from . import spotify
from .models import Artist, ArtistGroup
from .forms import ArtistGroupForm, AddArtistToGroupForm, RenameGroupForm
import json
from django.http import JsonResponse
from django.core import serializers
from allauth.socialaccount.models import SocialToken
from django.utils import timezone
from datetime import timedelta
import spotipy

def get_spotify_account_token(user):
    account = user.socialaccount_set.filter(provider='spotify').first()
    if account:
        token_obj = account.socialtoken_set.first()
        expires = token_obj.expires_at
        if expires <= timezone.now():
            token_secret = token_obj.token_secret
            spotify_oauth = spotipy.oauth2.SpotifyOAuth(client_id=spotify.SPOTIPY_CLIENT_ID, client_secret=spotify.SPOTIPY_CLIENT_SECRET, redirect_uri=spotify.SPOTIPY_REDIRECT_URI)
            new_token = spotify_oauth.refresh_access_token(token_secret)
            token_obj.token = new_token['access_token']
            token_obj.token_secret = new_token['refresh_token']
            token_obj.expires_at = timezone.now()+timedelta(seconds=3575)
            token_obj.save()
        return token_obj.token
    else:
        return None


def home(request):
    context = {
        'title':'Home'
    }
    return render(request, 'feed/home.html', context)

def featured(request):
    context = {
        'title':'Featured',
        'releases': []
    }
    context['releases'] = spotify.featured_releases(50)
    if context['releases'] == None:
        context['releases_error'] = "Whoops. There was an error fetching featured releases."
    else:
        # Create a comma seperated string with artists' names for each release
        for release in context['releases']:
            release['album_type'] = release['album_type'].capitalize()
            artists_str = ''
            for artist in release['artists']:
                artists_str += artist['name'] + ", "
            artists_str = artists_str[:-2]
            release['artists_str'] = artists_str
        
    return render(request, 'feed/featured.html', context)

def ajax_get_artists(request):
    data = {}
    if request.method == 'GET':
        data_type = request.GET.get('type')
        
        if data_type == 'artist_group':
            group_id = request.GET.get('id')
            try:
                group = ArtistGroup.objects.get(pk=group_id)
            except ArtistGroup.DoesNotExist:
                error = 'Error: Ajax tried to get an artist group that does not exist'
                data['error'] = error
                print(error)
                return JsonResponse(data)

            serialized_artists = serializers.serialize('json', group.artists.all())
            data['artists'] = serialized_artists
        
    else:
        data['error'] = 'Not a GET request'
    return JsonResponse(data)

def ajax_spotify_artist_search(request):
    data = {}
    if request.method == 'GET':
        try:
            q = request.GET.get('q')
        except:
            q = None
            data['error'] = 'No search query value in request'
        if q:
            results = spotify.artist_search(q)
            data['artists'] = results
    else:
        data['error'] = 'Not a GET request'
    return JsonResponse(data)


@require_POST
def ajax_get_releases(request):
    response_data = {
        'releases': [],
        'error': 'Unknown error. Try again later.'
    }
    artist_json = request.POST.get('artists', None)
    time_frame = request.POST.get('timeFrame', None)
    artist_data = json.loads(artist_json)
    for artist in artist_data:
        albums = spotify.get_recent_artist_albums(artist['spotify_id'], time_frame)
        response_data['releases'].extend(albums)
    #Sort releases by date
    response_data['releases'].sort(key=spotify.get_album_datetime, reverse=True)
    return JsonResponse(response_data)

def ajax_get_followers(request):
    data = {'error': 'Unknown error. Try again later.'}
    if request.method == 'GET':
        token = get_spotify_account_token(request.user)
        if token:
            data['followers'] = spotify.get_user_followers(token)
            if data['followers'] is None:
                data['error'] = 'Error fetching Spotify followers'
                response = JsonResponse(data)
                response.status_code = 500
                return response
        else:
            data['error'] = 'Error: Account not connected to Spotify'
    return JsonResponse(data)

def releases(request):
    context = {
        'title':'Releases',
        'new_group_form': ArtistGroupForm(),
        'spotify_connected': False
    }
    if request.user.is_authenticated:
        context['artistgroups'] = request.user.artistgroup_set.all()
        if get_spotify_account_token(request.user):
            context['spotify_connected'] = True
            #context['spotify_followers'] = spotify.get_user_followers(token)

    return render(request, 'feed/releases.html', context)
    

@require_POST
def ajax_save_artist_search(request):
    artists_json = request.POST.get('artists_json', None)
    name = request.POST.get('name','New save')
    artist_data = json.loads(artists_json)
    response_data = {}
    if artist_data:
        group = ArtistGroup()
        group.author = request.user
        group.name = name
        group.save()
        for a in artist_data:
            artist = Artist(name=a['name'], spotify_id = a['spotify_id'], img_url = a['img_url'], spotify_profile_url = a['spotify_profile_url'])
            artist.save()
            group.artists.add(artist)
            artist.artist_groups.add(group)
        #serialized_group = serializers.serialize('json', group)
        response_data['success'] = "Successfully saved artist search!"
        print(group.name)
        response_data['group'] = {
            'name': group.name,
            'id': group.id,
        }
        #response_data['group'] = group
    else:
        response_data['error'] = "Error saving artist search"

    print(response_data)
    return JsonResponse(response_data)
    

'''
@login_required
def artists(request):
    groups = request.user.artistgroup_set.all()

    form_add = AddArtistToGroupForm(user=request.user)
    form_delete_group = DeleteGroupForm()
    context = {
        'title':'Artists',
        'groups': groups,
        'form_add': form_add,
        'form_delete_group':form_delete_group,
        'artists': None
    }
    
    if request.method == 'POST':
        if 'delete_group' in request.POST:
            form_delete_group = DeleteGroupForm(request.POST)
            context['form_delete_group'] = form_delete_group
            if form_delete_group.is_valid():
                g = form_delete_group.cleaned_data['group_id']
                group = groups.filter(id=g).first()
                ArtistGroup.delete(group)
                groups = request.user.artistgroup_set.all()
                messages.success(request, f'Group deleted!')
            else:
                print(form_delete_group.errors)
    else:
        try:
            q = request.GET.get('q')
        except:
            q = None
        if q:
            results = spotify.artist_search(q)
            context['artists'] = results

    return render(request, 'feed/artists.html', context)
'''

@require_POST
def ajax_add_artist_to_group(request):
    data = {}

    groups = request.user.artistgroup_set.all()
    print(request.POST)
    form_add = AddArtistToGroupForm(request.POST, user=request.user)
    if form_add.is_valid():
        artist_data = json.loads(form_add.cleaned_data['artist_metadata'])
        artist = Artist(name=artist_data['name'], spotify_id = artist_data['id'], img_url = artist_data['images'][-1]['url'], spotify_profile_url = artist_data['external_urls']['spotify'])
        artist.save()
        selected_groups = form_add.cleaned_data['groups']
        for g in selected_groups:
            group = groups.filter(id=g).first()
            group.artists.add(artist)
            artist.artist_groups.add(group)
        data['success'] = "Successfully added artists to selected groups"
        data['message'] = 'Successfully added Artist to selected groups!'

    else:
        data['error'] = form_add.errors
    print("returning")
    return JsonResponse(data)


@login_required
def new_group(request):
    if request.method == 'POST':
        print(request.POST)
        form = ArtistGroupForm(request.POST)
        if form.is_valid():
            obj = form.save(commit=False)
            obj.author = request.user
            obj.save()
            messages.success(request, f'Artist group created!')
            return redirect('feed-artists')
    else:
        form = ArtistGroupForm()

    context = {
        'title':'New Group',
        'form':form
    }
    return render(request, 'feed/new_group.html', context)
    

class GroupDetailView(LoginRequiredMixin, DetailView):
    template_name = 'feed/group_detail.html'
    context_object_name = 'group_data'
    model = ArtistGroup

    def get_context_data(self, object, **kwargs):
        # Call the base implementation first to get a context
        context = super().get_context_data(**kwargs)
        # Add in the artists
        #self.group = get_object_or_404(ArtistGroup, id=self.kwargs['pk'])
        context['artists'] = object.artists.all()
        return context
    
    def get(self, request, *args, **kwargs):
        self.object = self.get_object()
        
        # Make sure users can only access their own groups
        if self.object not in request.user.artistgroup_set.all():
            return redirect('feed-releases')
        
        form = RenameGroupForm(instance=self.object)
        context = self.get_context_data(object=self.object)

        context['form_rename_group'] = form
        return render(request, self.template_name, context)

    def post(self, request, *args, **kwargs):
        self.object = self.get_object()
        if 'rename_group' in request.POST:
            prev_name = self.object.name
            form = RenameGroupForm(request.POST, instance=self.object)
            print(form.errors)
            if form.is_valid():
                form.save()
                new_name = form.cleaned_data['name']
                messages.success(request, f'Successfully renamed "{prev_name}" to "{new_name}"')
                return redirect('feed-releases')

        elif 'delete_artists' in request.POST:
            for value in request.POST.getlist('artist_checkbox'):
                artist = Artist.objects.get(id=value)
                self.object.artists.remove(artist)
                artist.artist_groups.remove(self.object)

        elif 'delete_group' in request.POST:
            ArtistGroup.delete(self.object)
            messages.success(request, f'Saved Search successfully deleted!')
            return redirect('feed-releases')

        context = self.get_context_data(object=self.object)

        rename_form = RenameGroupForm(instance=self.object)
        context['form_rename_group'] = rename_form

        return render(request, self.template_name, context)

