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
    path('account/password_change/', core_views.password_change, name='password_change'),
    path('account/password_reset_request/', core_views.password_reset_request, name='password_reset_request'),
    path('account/password_reset/<uidb64>/<token>/', core_views.password_reset, name='password_reset'),
]
