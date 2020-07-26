from django.conf.urls import include
from django.contrib import admin
from django.urls import path

import accounts
from marketing import views as marketing_views


urlpatterns = [
    path('', marketing_views.index, name='index'),
    path('admin/', admin.site.urls),
    path('account/', include('accounts.urls')),
    path('gear/', include('gearlists.urls')),
]
