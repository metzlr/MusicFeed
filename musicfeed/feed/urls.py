from django.urls import path
from . import views


urlpatterns = [
    path('', views.home, name='feed-home'),
    #path('artists/s/', views.artists, name='feed-release-search'),
    #path('artists/', views.artists, name='feed-artists'),
    #path('new-group/',views.new_group, name='feed-new-group'),
    path('releases/saved/<int:pk>/', views.GroupDetailView.as_view(), name='feed-saved-search-detail'),
    path('ajax/add-artist-to-group/', views.ajax_add_artist_to_group, name='feed-ajax-add-artist-to-group'),
    path('releases/', views.releases, name='feed-releases'),
    path('ajax/get-releases/', views.ajax_get_releases, name='feed-ajax-get-releases'),
    #path('releases/get/', views.get_releases, name='feed-get-releases'),
    path('ajax/get-artists/', views.ajax_get_artists, name='feed-ajax-get-artists'),
    path('ajax/save-artist-search/', views.ajax_save_artist_search, name='feed-ajax-save-artist-search'),
    path('ajax/spotify-artist-search/', views.ajax_spotify_artist_search, name='feed-ajax-spotify-artist-search'),

]
