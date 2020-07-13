from django.apps import AppConfig


class GearListsConfig(AppConfig):
    name = 'gearlists'

    def ready(self):
        from . import signals
