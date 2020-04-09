from django.shortcuts import render
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

def artists(request):
    context = {
        'title':'Artists'
    }
    return render(request, 'feed/artists.html', context)
   