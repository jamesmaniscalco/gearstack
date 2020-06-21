from django.conf.urls import include
from django.contrib import admin
from django.contrib.auth import views as auth_views
from django.urls import path
from core import views as core_views

urlpatterns = [
    path('', core_views.index, name='index'),
    path('admin/', admin.site.urls),
    path('home/', core_views.home, name='home'),
    path('account/login/', core_views.login, name='login'),
    path('account/logout/', core_views.logout, name='logout'),
    path('account/signup/', core_views.signup, name='signup'),
    # manually spell out builtin auth urls (since we defined custom login/out
    path('account/password_change/', auth_views.PasswordChangeView.as_view(), name='password_change'),
    path('account/password_change/done/', auth_views.PasswordChangeDoneView.as_view(), name='password_change_done'),
    path('account/password_reset/', auth_views.PasswordResetView.as_view(), name='password_reset'),
    path('account/password_reset/done/', auth_views.PasswordResetDoneView.as_view(), name='password_reset_done'),
    path('account/reset/<uidb64>/<token>/', auth_views.PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('account/reset/done/', auth_views.PasswordResetCompleteView, name='password_reset_complete'),
    #path('account/', include('django.contrib.auth.urls')),
]
