from django.shortcuts import render
from .models import GearItem, GearList, GearUserProfile


# @login_required
# def all_gear_items(request):
#     gear_items = GearItem.objects.get(owner=request.user)
#     return 
