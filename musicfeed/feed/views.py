from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_POST
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib import messages
from django.views.generic import DetailView
from . import spotify
from .models import Artist, ArtistGroup
from .forms import ArtistGroupForm, AddArtistToGroupForm, DeleteGroupForm, RenameGroupForm
import json
from django.http import JsonResponse



def home(request):
    context = {
        'title':'Home'
    }
    return render(request, 'feed/home.html', context)


def releases(request):
    context = {
        'title':'Releases'
    }
    return render(request, 'feed/releases.html', context)


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
        if 'save_add_artist' in request.POST:
            form_add = AddArtistToGroupForm(request.POST, user=request.user)
            context['form_add'] = form_add
            if form_add.is_valid():
                artist_data = json.loads(form_add.cleaned_data['artist_metadata'])
                artist = Artist(name=artist_data['name'], spotify_id = artist_data['id'], img_url = artist_data['images'][-1]['url'], spotify_profile_url = artist_data['external_urls']['spotify'])
                artist.save()
                selected_groups = form_add.cleaned_data['groups']
                for g in selected_groups:
                    group = groups.filter(id=g).first()
                    group.artists.add(artist)
                    artist.artist_groups.add(group)

                return redirect('feed-artists')
            else:
                print(request.POST)
                print(form_add.errors)

        elif 'delete_group' in request.POST:
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


@require_POST
def ajax_add_artist_to_group(request):
    data = {}

    groups = request.user.artistgroup_set.all()
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
    template_name='feed/group_detail.html'
    form_class = RenameGroupForm
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
            return redirect('feed-artists')
        
        form = self.form_class(instance=self.object)
        context = self.get_context_data(object=self.object)
        context['form_rename_group'] = form
        return render(request, self.template_name, context)

    def post(self, request, *args, **kwargs):
        self.object = self.get_object()
        prev_name = self.object.name
        form = self.form_class(request.POST, instance=self.object)
        print(form.errors)
        if form.is_valid():
            form.save()
            new_name = form.cleaned_data['name']
            messages.success(request, f'Successfully renamed "{prev_name}" to "{new_name}"')
            return redirect('feed-artists')
        context = self.get_context_data(object=self.object)
        context['form_rename_group'] = form
        return render(request, self.template_name, context)

