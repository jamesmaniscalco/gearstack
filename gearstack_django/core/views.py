from django.shortcuts import render, redirect
from django.contrib.auth import login as login_builtin, authenticate, logout as logout_builtin
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib.auth.decorators import login_required
from django.contrib import messages

from core.forms import SignupForm


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
    if request.method == 'POST':
        form = AuthenticationForm(data=request.POST)
        if form.is_valid():
            messages.success(request, 'Logged in successfully.')
            username = form.cleaned_data.get('username')
            raw_password = form.cleaned_data.get('password')
            user = authenticate(username=username, password=raw_password)
            login_builtin(request, user)
            return redirect('home')
    else:
        form = AuthenticationForm()
    # handle redirects
    next = ""
    if request.GET:
        if request.GET['next']:
            next = request.GET['next']

    return render(request, 'registration/login.html', {'form':form, 'next':next})


def logout(request):
   logout_builtin(request)
   messages.success(request, 'Logged out successfully.')
   return redirect('index')


# internal helpers
def _already_logged_in_redirect(request):
    if request.user.is_authenticated:
        messages.warning(request, 'Already logged in.')
        return redirect('home')


