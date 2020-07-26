from django.urls import path
from . import views

urlpatterns = [
    path('', views.all_gear_items, name='all_gear'),
]