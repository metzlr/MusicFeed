from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib import messages
from django.views.generic import DetailView
from . import spotify
from .models import Artist, ArtistGroup
from .forms import ArtistGroupForm, AddArtistToGroupForm


def home(request):
    context = {
        'title':'Home'
    }
    return render(request, 'feed/home.html', context)

'''
def release_search(request):
    context = {
        'title':'Releases'
    }
    try:
        q = request.GET.get('q')
    except:
        q = None
    if q:
        results = spotify.artist_search(q)
        context['artists'] = results
    
    return render(request, 'feed/artist_search.html', context)
'''

@login_required
def artists(request):
    groups = request.user.artistgroup_set.all()

    form_add = AddArtistToGroupForm(user=request.user)
    context = {
        'title':'Artists',
        'groups': groups,
        'form_add': form_add,
        'artists': None
    }
    if request.method == 'POST':
        print(request.POST)
        if 'save_add_artist' in request.POST:
            form_add = AddArtistToGroupForm(request.POST, user=request.user)
            print(form_add.errors)
            if form_add.is_valid():
                artist_data = form_add.cleaned_data['artist_metadata']
                artist = Artist(name=artist_data['name'], spotify_id = artist_data['id'], img_url = artist_data['images'][-1])
                artist.save()
                selected_groups = form_add.cleaned_data['groups']
                for g in selected_groups:
                    group = groups.filter(id=g).first()
                    group.artists.add(artist)
                    artist.artist_groups.add(group)
                
                return redirect('feed-artists')
    else:
        try:
            q = request.GET.get('q')
        except:
            q = None
        if q:
            results = spotify.artist_search(q)
            context['artists'] = results

    return render(request, 'feed/artists.html', context)

@login_required
def new_group(request):
    if request.method == 'POST':
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

'''
def group_edit(request, pk):
    group = get_object_or_404(ArtistGroup, pk)

    if request.method == 'POST':
'''


class GroupDetailView(LoginRequiredMixin, DetailView):
    context_object_name = 'group_data'
    model = ArtistGroup

    def get_context_data(self, **kwargs):
        # Call the base implementation first to get a context
        context = super().get_context_data(**kwargs)
        # Add in the group
        self.group = get_object_or_404(ArtistGroup, id=self.kwargs['pk'])
        context['group'] = self.group
        context['artists'] = self.group.artists.all()
        return context
