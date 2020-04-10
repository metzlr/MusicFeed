from django.urls import path
from . import views


urlpatterns = [
    path('', views.home, name='feed-home'),
    path('s/', views.release_search, name='feed-release-search'),
    path('artists/', views.artists, name='feed-artists'),
    path('new-group/',views.new_group, name='feed-new-group'),
    path('artists/group-detail/<int:pk>', views.GroupDetailView.as_view(template_name='feed/group_detail.html'), name='feed-group-detail')
]
