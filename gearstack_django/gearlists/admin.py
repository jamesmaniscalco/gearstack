from django.contrib import admin
from .models import GearItem, GearList, GearListMembership, GearUserProfile

admin.site.register(GearItem)
admin.site.register(GearList)
admin.site.register(GearListMembership)
admin.site.register(GearUserProfile)
