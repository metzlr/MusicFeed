from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from . import spotify


def home(request):
    context = {
        'title':'Releases'
    }
    return render(request, 'feed/home.html', context)

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

@login_required
def artists(request):
    context = {
        'title':'Artists'
    }
    groups = request.user.artistgroup_set.all()
    context['groups'] = groups
    return render(request, 'feed/artists.html', context)
   