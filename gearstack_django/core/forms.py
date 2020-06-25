from django import forms
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib.auth.models import User


# custom field that truncates the string to the set max length.
# see https://stackoverflow.com/a/3460942/866192
class TruncatingCharField(forms.CharField):
    def to_python(self, value):
        value = super().to_python(value) # should return a string
        if value:
            return value[:self.max_length]
        return value


# custom signup form to include email address.
# see https://simpleisbetterthancomplex.com/tutorial/2017/02/18/how-to-create-user-sign-up-view.html
class SignupForm(UserCreationForm):
    next = TruncatingCharField(max_length=254, widget=forms.HiddenInput())
    email = forms.EmailField(max_length=254, help_text='A valid email address is required.')

    class Meta:
        model = User
        fields = ('username', 'email', 'password1', 'password2', )


# handle user login with optional redirect
class AuthenticationWithRedirectForm(AuthenticationForm):
    # redirect URL
    next = TruncatingCharField(max_length=254, widget=forms.HiddenInput())
    

