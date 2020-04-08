import spotipy
from spotipy.oauth2 import SpotifyClientCredentials

sp = spotipy.Spotify(client_credentials_manager=SpotifyClientCredentials())

def artist_search(text):
    q = text+'*'
    results = sp.search(q, type='artist')
    artists = results['artists']['items']
    print(artists)
    return artists

def get_artist_albums(artist_id):
    results = sp.artist_albums(artist_id, country='US', limit=5)
    albums = results['items']
    return albums

#5INjqkS1o8h1imAzPqGZBb
#get_artist_albums('5INjqkS1o8h1imAzPqGZBb')

'''
results = sp.search(q='weezer', limit=20)
print(results)
for idx, track in enumerate(results['tracks']['items']):
    print(idx, track['name'])
'''