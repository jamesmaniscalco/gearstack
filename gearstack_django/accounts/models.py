from django.db import models
from django.contrib.auth.models import AbstractUser

import uuid


# Custom user model with unique email
class User(AbstractUser):
    email = models.EmailField(unique=True)
    uuid = models.UUIDField(default=uuid.uuid4, editable=False)
