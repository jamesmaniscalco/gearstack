from django.contrib.admin.apps import AdminConfig

class GearstackAdminConfig(AdminConfig):
    default_site = 'config.admin.GearstackAdminSite'
    