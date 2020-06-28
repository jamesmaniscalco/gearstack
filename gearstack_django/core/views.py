from django.shortcuts import render, redirect
from django.contrib.auth import login as login_builtin, authenticate, logout as logout_builtin, update_session_auth_hash
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm, PasswordChangeForm, SetPasswordForm
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.utils.http import url_has_allowed_host_and_scheme, urlsafe_base64_encode, urlsafe_base64_decode
from django.http import HttpResponseRedirect
from django.contrib.auth.tokens import default_token_generator
from django.views.decorators.http import require_POST

from core.forms import SignupForm, AuthenticationWithRedirectForm, PasswordResetRequestForm
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


@require_POST
def logout(request):
    # protect against CSRF attacks, as recommended by https://www.squarefree.com/securitytips/web-developers.html#CSRF
    logout_builtin(request)
    messages.success(request, 'Logged out successfully.')
    return redirect('index')



@login_required
def password_change(request):
    if request.method == 'POST':
        form = PasswordChangeForm(user=request.user,data=request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Password changed successfully.')
            update_session_auth_hash(request, form.user)
            return redirect('home')
    else:  # if the request was GET, prepare the form here
        form = PasswordChangeForm(request.user)
    # if GET or failed POST, serve the form.
    return render(request, 'registration/password_change.html', {'form':form})


def password_reset_request(request):
    # process and/or serve password reset request form
    if request.method == 'POST':
        form = PasswordResetRequestForm(data=request.POST)
        if form.is_valid():
            form.save()
            return render(request, 'registration/password_reset_request_done.html')
    else:
        form = PasswordResetRequestForm()
    # if GET or failed POST, serve the form.
    return render(request, 'registration/password_reset_request.html', {'form':form})


def password_reset(request, *args, **kwargs):
    # process and/or serve the password reset form
    # if any error is raised, it's because the link used was invalid in some way.
    validlink = False
    reset_url_token = 'reset_password'
    internal_reset_session_token = '_password_reset_token'
    token_generator=default_token_generator
    try:
        # check that expected parameters have been passed in
        assert 'uidb64' in kwargs and 'token' in kwargs
        # urlsafe_base64_decode() decodes to bytestring
        uid = urlsafe_base64_decode(kwargs.get('uidb64')).decode()
        user = User.objects.get(pk=uid)

        # if the user id matches a user in the database, verify the token
        if user is not None:
            token = kwargs.get('token')
            if token == reset_url_token:
                session_token = request.session.get(internal_reset_session_token)
                if token_generator.check_token(user, session_token):
                    # If the token is valid, display the password reset form (continue with view logic)
                    validlink = True
            else:
                if token_generator.check_token(user, token):
                    # Store the token in the session and redirect to the
                    # password reset form at a URL without the token. That
                    # avoids the possibility of leaking the token in the
                    # HTTP Referer header.
                    request.session[internal_reset_session_token] = token
                    redirect_url = request.path.replace(token, reset_url_token)
                    return HttpResponseRedirect(redirect_url)

        if request.method == 'POST':
            form = SetPasswordForm(user=user, data=request.POST)
            if form.is_valid():
                user = form.save()
                del request.session[internal_reset_session_token]
                messages.success(request, 'Password changed successfully.')
                return redirect('login')
        else:
            form = SetPasswordForm(user=user)

    except:
        validlink = False
        form = None

    return render(request, 'registration/password_reset.html', {'form':form, 'validlink':validlink})


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
        print(form)
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

