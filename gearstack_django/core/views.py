from django.shortcuts import render, redirect
from django.contrib.auth import login as login_builtin, authenticate, logout as logout_builtin
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.utils.http import url_has_allowed_host_and_scheme
from django.http import HttpResponseRedirect

from core.forms import SignupForm, AuthenticationWithRedirectForm
from config.settings import SITE_URL


def index(request):
    return render(request, 'index.html')


@login_required
def home(request):
    return render(request, 'core/home.html')


def signup(request):
    return _signup_or_login(request, 'signup')


def login(request):
    return _signup_or_login(request, 'login')


def logout(request):
   logout_builtin(request)
   messages.success(request, 'Logged out successfully.')
   return redirect('index')


# internal helpers
def _is_safe_redirect_url(url):
    return url_has_allowed_host_and_scheme(url, allowed_hosts=SITE_URL)

def _already_logged_in_redirect(request):
    if request.user.is_authenticated:
        messages.warning(request, 'Already logged in.')
        if request.GET and request.GET.get('next'):
            return HttpResponseRedirect(request.GET.get('next'))
        elif request.POST and request.POST.get('next'):
            return HttpResponseRedirect(request.POST.get('next'))
        else:
            return redirect('home')
    else:
        return None

def _signup_or_login(request, signup_or_login):
    if signup_or_login == 'signup':
        form_class = SignupForm
        password_field = 'password1'
        save_form = True
        template = 'registration/signup.html'
    elif signup_or_login == 'login':
        form_class = AuthenticationWithRedirectForm
        password_field = 'password'
        save_form = False
        template = 'registration/login.html'
    else:
        raise Exception('Unrecoginzed option. Use "signup" or "login".')

    logged_in_redirect = _already_logged_in_redirect(request)
    if logged_in_redirect:
        return logged_in_redirect
    # if POST, process user input.
    if request.method == 'POST':
        form = form_class(data=request.POST)
        # if the form is valid, process it. Else nothing - continue to final return statement.
        if form.is_valid():
            if save_form: # this only runs if we are doing a signup.
                form.save()
            # handle the login and redirect (next param if present, else 'home')
            return _login_user_and_redirect(request, form, password_field)
    # if GET, make sure to maintain redirect.
    else:
        form = _prepare_form_and_preserve_redirect(request, form_class)
    # if GET or failed authentication, render the login page.
    return render(request, template, {'form':form})
    

def _login_user_and_redirect(request, form, password_field):
    messages.success(request, 'Logged in successfully.')
    username = form.cleaned_data.get('username')
    raw_password = form.cleaned_data.get(password_field)
    user = authenticate(username=username, password=raw_password)
    login_builtin(request, user)
    # process the redirect
    next = form.cleaned_data.get('next')
    if next and _is_safe_redirect_url(next):
        # don't use the redirect shortcut because we don't want to allow hijacking the path name reverse method.
        return HttpResponseRedirect(next)
    else:
        return redirect('home')

def _prepare_form_and_preserve_redirect(request, form_class):
    if not request.GET or not request.GET['next'] or not _is_safe_redirect_url(request.GET['next']):
        form = form_class()
    else:
        form = form_class(initial={'next':request.GET['next']})
    return form

