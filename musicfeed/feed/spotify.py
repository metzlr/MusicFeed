#import operator
import spotipy
from datetime import datetime
from spotipy.client import SpotifyException
from spotipy.oauth2 import SpotifyClientCredentials


sp = spotipy.Spotify(client_credentials_manager=SpotifyClientCredentials())

def artist_search(text):
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

def get_album_datetime(item_dictionary):
    '''Extract datetime string from given dictionary, and return the parsed datetime object'''
    date_str = item_dictionary['release_date']
    if item_dictionary['release_date_precision'] == 'day':
        datetime_obj = datetime.strptime(date_str, '%Y-%m-%d')
    elif item_dictionary['release_date_precision'] == 'year':
        datetime_obj = datetime.strptime(date_str, '%Y')
    elif item_dictionary['release_date_precision'] == 'month':
        datetime_obj = datetime.strptime(date_str, '%Y-%m')
    else:
        print("Unrecognized date precision: "+item_dictionary['release_date_precision'])
        return None
    return datetime_obj

def get_recent_artist_albums(artist_id):
    results = sp.artist_albums(artist_id, country='US', album_type='album,single')
    albums = results['items']
    recent_albums = []
    for album in albums:
        today = datetime.today()
        date_obj = get_album_datetime(album)
        if date_obj is None:
            print("ERROR: Unrecognized date format on album for artist:", artist_id, album['artists'][0]['name'])
            continue
        date_change = today - date_obj
        if date_change.days <= 31:
            recent_albums.append(album)
    return recent_albums

def get_user_followers(token):
    sp = spotipy.Spotify(auth=token)
    results = sp.current_user_followed_artists()
    count = results['artists']['total']
    artist_list = []
    while (count > 0):
        artists = results['artists']['items']
        for artist in artists:
            artist_list.append(artist)
            count -= 1
        if (count > 0):
            results = sp.current_user_followed_artists(after=artist_list[-1]['id'])
    return artist_list


#5INjqkS1o8h1imAzPqGZBb
#get_artist_albums('5INjqkS1o8h1imAzPqGZBb')

'''
results = sp.search(q='weezer', limit=20)
print(results)
for idx, track in enumerate(results['tracks']['items']):
    print(idx, track['name'])
'''