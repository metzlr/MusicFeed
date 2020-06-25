from django.urls import path, re_path
from . import views
from allauth.account.views import LoginView, SignupView, LogoutView, PasswordChangeView, PasswordSetView, PasswordResetView, PasswordResetDoneView, PasswordResetFromKeyView, PasswordResetFromKeyDoneView, PasswordChangeView, ConfirmEmailView, EmailVerificationSentView
import allauth.socialaccount.providers.spotify.urls as spotify_urls

urlpatterns = [
    path('profile/', views.profile, name='profile'),

    path("signup/", SignupView.as_view(), name="account_signup"),
    path("login/", LoginView.as_view(), name="account_login"),
    path("logout/", LogoutView.as_view(), name="account_logout"),
    path("password/change/", PasswordChangeView.as_view(), name="account_change_password"),
    #path("email/", views.email, name="account_email"),
    #path("confirm-email/", EmailVerificationSentView.as_view(), name="account_email_verification_sent"),
    #re_path(r"^confirm-email/(?P<key>[-:\w]+)/$", ConfirmEmailView.as_view(), name="account_confirm_email"),
    path("password/change/", PasswordChangeView.as_view(), name="account_change_password"),
    path("password/set/", PasswordSetView.as_view(), name="account_set_password"),
    path("password/reset/", PasswordResetView.as_view(), name="account_reset_password"),
    path("password/reset/done/", PasswordResetDoneView.as_view(), name="account_reset_password_done"),
    re_path(r"^password/reset/key/(?P<uidb36>[0-9A-Za-z]+)-(?P<key>.+)/$", PasswordResetFromKeyView.as_view(), name="account_reset_password_from_key"),
    path("password/reset/key/done/", PasswordResetFromKeyDoneView.as_view() , name="account_reset_password_from_key_done"),
    

]

urlpatterns += spotify_urls.urlpatterns