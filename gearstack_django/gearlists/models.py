from django.db import models
from django.db.models import F
from django.conf import settings

import pytz


# weight unit constants (should these live somewhere else?)
GRAMS = 'GR'
KILOGRAMS = 'KG'
OUNCES = 'OZ'
POUNDS = 'LB'
WEIGHT_UNIT_NAMES = {
    GRAMS:'grams',
    KILOGRAMS:'kilograms',
    OUNCES:'ounces',
    POUNDS:'pounds',
}
WEIGHT_UNIT_CONVERSION_FACTORS = {
    GRAMS:1,
    KILOGRAMS:0.001,
    OUNCES:0.035273961,
    POUNDS:0.002204623,
}
WEIGHT_UNIT_SYMBOLS = {
    GRAMS:'g',
    KILOGRAMS:'kg',
    OUNCES:'oz',
    POUNDS:'lb',
}


# manager for GearItems
class GearItemManager(models.Manager):
    # class methods
    def check_out(self):
        return self.update(checked_out=True)

    def check_out_in_list(self, gear_list):
        return self.check_out().update(checked_out_list=gear_list)

    def check_in(self):
        return self.update(checked_out=False,checked_out_list=None)


# Gear item
class GearItem(models.Model):
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    name = models.CharField(verbose_name='item name', max_length=127)
    notes = models.TextField(max_length=1000, blank=True)
    created_datetime = models.DateTimeField(auto_now_add=True)
    modified_datetime = models.DateTimeField(auto_now=True)
    weight_in_grams = models.DecimalField(max_digits=10,decimal_places=3)
    checked_out = models.BooleanField(default=False)
    checked_out_list = models.ForeignKey('GearList', blank=True, null=True, on_delete=models.SET_NULL)

    objects = GearItemManager()

    def __str__(self):
        return self.name


# Gear list
class GearList(models.Model):
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    name = models.CharField(max_length=127)
    notes = models.TextField(max_length=1000, blank=True)
    created_datetime = models.DateTimeField(auto_now_add=True)
    modified_datetime = models.DateTimeField(auto_now=True)
    gear_items = models.ManyToManyField(
        GearItem, 
        through='GearListMembership',
        through_fields=('gear_list','gear_item'),
        )

    def __str__(self):
        return self.name


# 'Through' class for GearItem-GearList ManyToMany relationship
class GearListMembership(models.Model):
    gear_item = models.ForeignKey('GearItem', on_delete=models.CASCADE)
    gear_list = models.ForeignKey('GearList', on_delete=models.CASCADE)
    created_datetime = models.DateTimeField(auto_now_add=True)
    modified_datetime = models.DateTimeField(auto_now=True)
    sort_index = models.PositiveIntegerField()

    def __str__(self):
        return self.gear_list.name + ' - ' + self.gear_item.name

    class Meta:
        constraints = [         # prevent ambiguous sorting
            models.UniqueConstraint(fields=['gear_list', 'sort_index'], name='unique_sort_index'),
        ]


# User preferences profile
class GearUserProfile(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    WEIGHT_UNIT_CHOICES = [(k,v) for k,v in WEIGHT_UNIT_NAMES.items()]
    weight_unit = models.CharField(verbose_name='preferred weight unit', max_length=2, choices=WEIGHT_UNIT_CHOICES, default=GRAMS)
    TIME_ZONE_CHOICES = tuple(zip(pytz.common_timezones, pytz.common_timezones))
    time_zone = models.CharField(verbose_name='preferred time zone', max_length=32, choices=TIME_ZONE_CHOICES, default='UTC')

    def __str__(self):
        return self.user.username + '\'s gear user profile'




