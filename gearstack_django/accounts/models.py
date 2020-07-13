from django.db import models
from django.contrib.auth.models import AbstractUser

# Custom user model with unique email
class User(AbstractUser):
    email = models.EmailField(unique=True)
