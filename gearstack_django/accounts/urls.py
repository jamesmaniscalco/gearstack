from django.urls import path
from . import views

urlpatterns = [
    path('home/', views.home, name='home'),
    path('login/', views.login, name='login'),
    path('logout/', views.logout, name='logout'),
    path('signup/', views.signup, name='signup'),
    path('password_change/', views.password_change, name='password_change'),
    path('password_reset_request/', views.password_reset_request, name='password_reset_request'),
    path('password_reset/<uidb64>/<token>/', views.password_reset, name='password_reset'),
]
