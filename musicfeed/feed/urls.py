from django.urls import path
from . import views


urlpatterns = [
    path('', views.home, name='feed-home'),
    path('artists/s/', views.artists, name='feed-release-search'),
    path('artists/', views.artists, name='feed-artists'),
    path('new-group/',views.new_group, name='feed-new-group'),
    path('artists/group-detail/<int:pk>', views.GroupDetailView.as_view(), name='feed-group-detail'),
    path('ajax/add-artist-to-group', views.ajax_add_artist_to_group, name='ajax-add-artist-to-group'),

]
