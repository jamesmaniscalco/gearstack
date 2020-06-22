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
    _already_logged_in_redirect(request)
    if request.method == 'POST':
        form = SignupForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Account created successfully.')
            username = form.cleaned_data.get('username')
            raw_password = form.cleaned_data.get('password1')
            user = authenticate(username=username, password=raw_password)
            login_builtin(request, user)
            return redirect('home')
    else:
        form = SignupForm()
    return render(request, 'registration/signup.html', {'form':form})


def login(request):
    _already_logged_in_redirect(request)
    # if POST, process user input.
    if request.method == 'POST':
        form = AuthenticationWithRedirectForm(data=request.POST)
        # if the form is valid, process it. Else nothing - continue to final return statement.
        if form.is_valid():
            messages.success(request, 'Logged in successfully.')
            username = form.cleaned_data.get('username')
            raw_password = form.cleaned_data.get('password')
            user = authenticate(username=username, password=raw_password)
            login_builtin(request, user)
            # process the redirect
            next = form.cleaned_data.get('next')
            if next and _is_safe_redirect_url(next):
                # don't use the redirect shortcut because we don't want to allow hijacking the path name reverse method.
                return HttpResponseRedirect(next)
            else:
                return redirect('home')
    # if GET, make sure to maintain redirect.
    else:
        if not request.GET or not request.GET['next'] or not _is_safe_redirect_url(request.GET['next']):
            form = AuthenticationWithRedirectForm()
        else:
            form = AuthenticationWithRedirectForm(initial={'next':request.GET['next']})
    # if GET or failed authentication, render the login page.
    return render(request, 'registration/login.html', {'form':form})


def logout(request):
   logout_builtin(request)
   messages.success(request, 'Logged out successfully.')
   return redirect('index')


# internal helpers
def _already_logged_in_redirect(request):
    if request.user.is_authenticated:
        messages.warning(request, 'Already logged in.')
        return redirect('home')

def _is_safe_redirect_url(url):
    return url_has_allowed_host_and_scheme(url, allowed_hosts=SITE_URL)

