from django.contrib import admin

class GearstackAdminSite(admin.AdminSite):
    site_title = 'Gearstack administration'
    site_header = site_title
    index_title = site_title
