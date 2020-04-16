from django.urls import path
from . import views


urlpatterns = [
    path('', views.home, name='feed-home'),
    path('artists/s/', views.artists, name='feed-release-search'),
    path('artists/', views.artists, name='feed-artists'),
    path('new-group/',views.new_group, name='feed-new-group'),
    path('artists/group-detail/<int:pk>', views.GroupDetailView.as_view(), name='feed-group-detail'),
    path('ajax/add-artist-to-group', views.ajax_add_artist_to_group, name='feed-ajax-add-artist-to-group'),
    path('releases/', views.releases, name='feed-releases'),
    path('releases/get/', views.get_releases, name='feed-get-releases'),
    path('ajax/get-artists', views.ajax_get_artists, name='feed-ajax-get-artists'),

]
