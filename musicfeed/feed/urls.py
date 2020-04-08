from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='feed-home'),
    path('s/', views.release_search, name='feed-release-search'),
    path('artists/', views.artists, name='feed-artists')
]
