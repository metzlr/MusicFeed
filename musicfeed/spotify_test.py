#import operator
import spotipy
from datetime import datetime
from spotipy.client import SpotifyException
from spotipy.oauth2 import SpotifyClientCredentials


sp = spotipy.Spotify(client_credentials_manager=SpotifyClientCredentials())

def artist_search(text):
    print("Searching")
    q = text+'*'
    search_results = sp.search(q, type='artist')
    artists = []
    # Do artist lookup in case text is a valid spotify URI or URL
    try:
        id_results = sp.artist(text)
        artists.append(id_results)
    except SpotifyException:
        print('Search text wasn\'t an ID')

    artists += search_results['artists']['items']
    #print(artists)
    return artists


result = artist_search("tame impala")
print(result)