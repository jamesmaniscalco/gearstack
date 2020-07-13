from django.conf.urls import include
from django.contrib import admin
from django.urls import path
from accounts import views as accounts_views

urlpatterns = [
    path('', accounts_views.index, name='index'),
    path('admin/', admin.site.urls),
    path('home/', accounts_views.home, name='home'),
    path('account/login/', accounts_views.login, name='login'),
    path('account/logout/', accounts_views.logout, name='logout'),
    path('account/signup/', accounts_views.signup, name='signup'),
    path('account/password_change/', accounts_views.password_change, name='password_change'),
    path('account/password_reset_request/', accounts_views.password_reset_request, name='password_reset_request'),
    path('account/password_reset/<uidb64>/<token>/', accounts_views.password_reset, name='password_reset'),
]
