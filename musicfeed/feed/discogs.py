import requests
import os

KEY = os.environ.get("PUBLIC_KEY")
SECRET = os.environ.get("SECRET_KEY")

class Discogs():
    key = 'fQXVpgMFqbiLfDealdgX'
    secret = 'eoArwwbzmveIXLsjjFYhYLGyhqJnuxJo'
    
    @classmethod
    def artist_search(cls, query):
        return cls.__search(query, search_type='artist')
    

    @classmethod
    def get_artist_releases(cls, id):
        pass

    @classmethod
    def __search(cls, query, search_type):
        p = {
            'query': query,
            'type': search_type
        }
        h = {'Authorization':'Discogs key={}, secret={}'.format(KEY,SECRET)}
        
        try:
            r = requests.get('https://api.discogs.com/database/search?', params=p, headers=h, timeout=5)
            r.raise_for_status()
        except requests.exceptions.HTTPError as errh:
            print ("Http Error:",errh)
           
        except requests.exceptions.ConnectionError as errc:
            print ("Error Connecting:",errc)
            
        except requests.exceptions.Timeout as errt:
            print ("Timeout Error:",errt)
        
        except requests.exceptions.RequestException as err:
            print ("General Error:",err)

        else:
            data = r.json()
            return data.get('results')
    

