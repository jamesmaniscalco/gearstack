from django.forms import ModelForm
from .models import GearItem, GearList, GearUserProfile

class GearItemForm(ModelForm):
    class Meta:
        model = GearItem
        fields = ['name','weight_in_grams','notes']
        labels = {
            'name':'Item name',
            'weight_in_grams':'Item weight',
            'notes':'Item notes/description',
        }


class GearListForm(ModelForm):
    class Meta:
        model = GearList
        fields = ['name','notes']
        labels = {
            'name':'Stack name',
            'notes':'Stack notes/description',
        }


class GearUserProfileForm(ModelForm):
    class Meta:
        model = GearUserProfile
        fields = ['weight_unit','time_zone']
        labels = {
            'weight_unit':'Preferred weight unit',
            'time_zone':'Preferred time zone',
        }
        

