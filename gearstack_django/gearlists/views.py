from django.shortcuts import render
from django.core import serializers
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse, JsonResponse

from .models import GearItem, GearList, GearUserProfile


@login_required
def all_gear_items(request):
    gear_items = GearItem.objects.filter(owner=request.user)
    gear_item_list = list(gear_items.values('name','uuid','notes','checked_out','checked_out_list','weight_in_grams'))
    #return JsonResponse({'gear_items':gear_item_list})
    return render(request, 'gearlists/list_of_gear_items.html', {'gear_items':gear_item_list})
