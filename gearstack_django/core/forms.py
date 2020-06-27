from django import forms
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm, UsernameField
from django.contrib.auth.models import User
from django.core.mail import EmailMultiAlternatives
from django.template import loader
from django.utils.encoding import force_bytes
from django.utils.http import urlsafe_base64_encode
from django.contrib.auth.tokens import default_token_generator

from config.settings import SITE_DOMAIN, SITE_NAME


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
    next = TruncatingCharField(max_length=254, widget=forms.HiddenInput(), required=False)
    email = forms.EmailField(max_length=254, help_text='A valid email address is required.')

    class Meta:
        model = User
        fields = ('username', 'email', 'password1', 'password2', )


# form to send password reset email. Checks that username is valid.
# It would be nice to inherit from auth.PasswordResetForm, 
# but that takes an email address, and here we want to take username only.
class PasswordResetRequestForm(forms.Form):
    username = UsernameField(widget=forms.TextInput(attrs={'autofocus': True}))

    # copied from auth.forms.PasswordResetForm
    def send_mail(self, subject_template_name, email_template_name,
                  context, from_email, to_email, html_email_template_name=None):
        """
        Send a django.core.mail.EmailMultiAlternatives to `to_email`.
        """
        subject = loader.render_to_string(subject_template_name, context)
        # Email subject *must not* contain newlines
        subject = ''.join(subject.splitlines())
        body = loader.render_to_string(email_template_name, context)

        email_message = EmailMultiAlternatives(subject, body, from_email, [to_email])
        if html_email_template_name is not None:
            html_email = loader.render_to_string(html_email_template_name, context)
            email_message.attach_alternative(html_email, 'text/html')

        email_message.send()

    # given the username passed to the form, return the corresponding user, or None if invalid.
    def get_user(self):
        try:
            user = User.objects.get(username=self.cleaned_data.get('username'))
        except User.DoesNotExist:
            user = None
        return user

    # generate a one-time use token for password reset and send the email.
    def save(self,
             subject_template_name='registration/password_reset_subject.txt',
             email_template_name='registration/password_reset_email.html',
             use_https=False, token_generator=default_token_generator,
             from_email=None, request=None, html_email_template_name=None,
             extra_email_context=None):
        
        user = self.get_user()
        if user:
            context = {
                'email': user.email,
                'domain': SITE_DOMAIN,
                'site_name': SITE_NAME,
                'uid': urlsafe_base64_encode(force_bytes(user.pk)),
                'user': user,
                'token': token_generator.make_token(user),
                'protocol': 'https' if use_https else 'http',
                **(extra_email_context or {}),
            }
            self.send_mail(
                subject_template_name, email_template_name, context, from_email,
                user.email, html_email_template_name=html_email_template_name,
            )


# handle user login with optional redirect
class AuthenticationWithRedirectForm(AuthenticationForm):
    # redirect URL
    next = TruncatingCharField(max_length=254, widget=forms.HiddenInput(), required=False)
    

