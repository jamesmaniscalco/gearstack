from django import urls
from django.http import HttpResponse
from django.contrib import auth
from django.core import mail
from django.utils.encoding import force_bytes
from django.utils.http import urlsafe_base64_encode
from django.conf import settings

from accounts import views

import pytest

from bs4 import BeautifulSoup

import re


### INDEX
class TestIndex:
    def test_index(self, client):
        """
        Verify that the index url renders the landing page
        """
        url = urls.reverse('index')
        response = client.get(url)
        assert response.status_code == 200
        assert b'Gearstack' in response.content

### HOME
class TestHome:
    @pytest.mark.django_db
    def test_home_visible_when_logged_in(self, user_authenticated, client):
        """
        Verify that home page loads successfully for logged in user
        """
        url = urls.reverse('home')
        response = client.get(url)
        assert response.status_code == 200
        assert b'Welcome' in response.content

    def test_home_auth_protected(self, client):
        """
        Verify that home page is protected
        """
        url = urls.reverse('home')
        response = client.get(url)
        assert response.status_code == 302
        assert response.url == urls.reverse('login') + '?next=' + url   # check redirect with GET param 'next'

### SIGNUP
class TestSignup:
    @pytest.mark.django_db
    def test_signup_redirect_when_logged_in(self, user_authenticated, client):
        """
        Verify that signup redirects the user if they are already logged in.
        """
        url = urls.reverse('signup')
        response = client.get(url)
        assert response.status_code == 302
        assert response.url == urls.reverse('home')

    # TODO - This would be better with an auth protected page
    @pytest.mark.django_db
    def test_signup_redirect_when_logged_in_with_redirect(self, user_authenticated, client):
        """
        Verify that signup redirects the user if they are already logged in.
        """
        url = urls.reverse('signup') + '?next=' + urls.reverse('index')
        response = client.get(url)
        assert response.status_code == 302
        assert response.url == urls.reverse('index')

    def test_signup_get_when_not_logged_in(self, client):
        """
        Verify that signup page is visible when not logged in.
        """
        url = urls.reverse('signup')
        response = client.get(url)
        assert response.status_code == 200
        assert b'Sign up' in response.content

    def test_signup_fails_for_duplicate_username(self, user_authenticated, client):
        """
        Verify that signup flow fails if we try to submit a duplicate username.
        """
        client.logout() # first log the authenticated user out
        form_data = {
            'username':user_authenticated.username,
            'email':'test_email@email.com',
            'password1':'testpassword',
            'password2':'testpassword',
        }
        response = client.post(urls.reverse('signup'), form_data)   # POST the form
        assert response.status_code == 200   # we should be served the form again, not a redirect.
        assert b'Sign up' in response.content

    def test_signup_fails_for_duplicate_email(self, user_authenticated, client):
        """
        Verify that signup flow fails if we try to submit a duplicate email.
        """
        client.logout() # first log the authenticated user out
        form_data = {
            'username':'another_test_username',
            'email':user_authenticated.email,
            'password1':'testpassword',
            'password2':'testpassword',
        }
        response = client.post(urls.reverse('signup'), form_data)   # POST the form
        assert response.status_code == 200   # we should be served the form again, not a redirect.
        assert b'Sign up' in response.content    

    def test_signup_next_param_in_form(self, client):
        """
        Verify that the 'next' parameter in GET yields a signup form with a 'next' POST param in the form.
        """
        response = client.get(urls.reverse('signup') + '?next=/redirect_url/')
        assert b'name="next" value="/redirect_url/"' in response.content

    @pytest.mark.django_db
    def test_signup_maintains_next_parameter_on_fail(self, client):
        """
        Verify that the 'next' redirect parameter is maintained when signup fails.
        """
        form_data = {
            'username':'another_test_username',
            'email':'test@email.com',
            'password1':'testpassword',
            'password2':'differentpassword',
            'next':'/redirect_url/',
        }
        response = client.post(urls.reverse('signup'), form_data)
        assert b'name="next" value="/redirect_url/"' in response.content

    @pytest.mark.django_db
    def test_signup_works(self, client):
        """
        Verify that signup works with valid credentials and redirects to home
        """
        test_username = 'another_test_username'
        test_password = 'testpassword'
        form_data = {
            'username':test_username,
            'email':'test@email.com',
            'password1':test_password,
            'password2':test_password,
        }
        response = client.post(urls.reverse('signup'), form_data)
        assert auth.get_user(client).check_password(test_password)
        assert response.url == urls.reverse('home')

    # TODO - this should have a different auth-protected redirect url
    @pytest.mark.django_db
    def test_signup_works_with_redirect(self, client):
        """
        Verify that signup works with valid credentials
        """
        form_data = {
            'username':'another_test_username',
            'email':'test@email.com',
            'password1':'testpassword',
            'password2':'testpassword',
            'next':urls.reverse('index'),
        }
        response = client.post(urls.reverse('signup'), form_data)
        assert response.url == form_data['next']

### LOGIN
class TestLogin:
    def test_login_get_when_not_logged_in(self, client):
        """
        Verify that login page is visible to anonymous users.
        """
        response = client.get(urls.reverse('login'))
        assert response.status_code == 200
        assert b'Log in' in response.content

    @pytest.mark.django_db
    def test_login_works(self, user_authenticated, client):
        """
        Verify that POSTing to login works with good credentials
        """
        client.logout()
        test_password = 'my_test_password'
        user_authenticated.set_password(test_password)
        user_authenticated.save()
        form_data = {
            'username':user_authenticated.username,
            'password':test_password,
        }
        response = client.post(urls.reverse('login'), form_data)
        assert auth.get_user(client).is_authenticated
        assert response.status_code == 302
        assert response.url == urls.reverse('home')

    @pytest.mark.django_db
    def test_login_works_with_redirect(self, user_authenticated, client):
        """
        Verify that login page redirects properly on successful login.
        """
        client.logout()
        test_password = 'my_test_password'
        user_authenticated.set_password(test_password)
        user_authenticated.save()
        redirect_url = urls.reverse('index')
        form_data = {
            'username':user_authenticated.username,
            'password':test_password,
            'next':redirect_url,
        }
        response = client.post(urls.reverse('login'), form_data)
        assert auth.get_user(client).is_authenticated
        assert response.status_code == 302
        assert response.url == redirect_url

    @pytest.mark.django_db
    def test_login_redirect_when_logged_in(self, user_authenticated, client):
        """
        Verify that GET on login page redirects to user home
        """
        response = client.get(urls.reverse('login'))
        assert response.status_code == 302
        assert response.url == urls.reverse('home')

    # TODO - should have an auth protected view to redirect
    @pytest.mark.django_db
    def test_login_redirect_when_logged_in_with_redirect(self, user_authenticated, client):
        """
        Verify that GET on login page with 'next' param does the redirect.
        """
        redirect_url = urls.reverse('index')
        response = client.get(urls.reverse('login') + '?next=' + redirect_url)
        assert response.status_code == 302
        assert response.url == redirect_url

    def test_login_next_param_in_form(self, client):
        """
        Verify that the 'next' parameter in GET yields a login form with a 'next' POST param in the form.
        """
        response = client.get(urls.reverse('login') + '?next=/redirect_url/')
        assert b'name="next" value="/redirect_url/"' in response.content

    @pytest.mark.django_db
    def test_signup_maintains_next_parameter_on_fail(self, client, user_authenticated):
        """
        Verify that the 'next' redirect parameter is maintained when login fails.
        """
        client.logout()
        test_password = 'my_test_password'
        user_authenticated.set_password(test_password)
        user_authenticated.save()
        redirect_url = '/redirect_url/'
        form_data = {
            'username':user_authenticated.username,
            'password':test_password + '_typo',
            'next':redirect_url,
        }
        response = client.post(urls.reverse('login'), form_data)
        assert b'name="next" value="%s"' % str.encode(redirect_url) in response.content

### LOGOUT
class TestLogout:
    @pytest.mark.django_db
    def test_logout_works(self, user_authenticated, client):
        """
        Verify that POSTing to the logout URL works and redirects to index.
        """
        response = client.post(urls.reverse('logout'))#, form_data)
        assert not auth.get_user(client).is_authenticated
        assert response.status_code == 302
        assert response.url == urls.reverse('index')

    @pytest.mark.django_db
    def test_logout_is_POST_only(self, user_authenticated, client):
        """
        Verify that GET requests don't log the user out.
        """
        client.get(urls.reverse('logout'))#, form_data)
        assert auth.get_user(client).is_authenticated
    
### PASSWORD CHANGE
class TestPasswordChange:
    def test_password_change_is_auth_protected(self, client):
        """
        Verify that the password change page is only accessible to logged in users.
        """
        url = urls.reverse('password_change')
        response = client.get(url)
        assert response.status_code == 302
        assert response.url == urls.reverse('login') + '?next=' + url

    @pytest.mark.django_db
    def test_password_change_is_visible_to_authed_users(self, user_authenticated, client):
        """
        Verify that password change form is visible when logged in.
        """
        response = client.get(urls.reverse('password_change'))
        assert response.status_code == 200
        assert b'Old password:' in response.content

    @pytest.mark.django_db
    def test_password_change_fails_with_bad_current_password(self, user_authenticated, client):
        """
        Verify that password change form fails if the 'current password' is wrong.
        """
        wrong_old_password = 'wrong_password'
        new_password = 'something_new'
        form_data = {
            'old_password':wrong_old_password,
            'new_password1':new_password,
            'new_password2':new_password,
        }
        response = client.post(urls.reverse('password_change'), form_data)
        assert not user_authenticated.check_password(new_password)
        assert b'Old password:' in response.content

    @pytest.mark.django_db
    def test_password_change_fails_with_mismatched_new_password(self, user_authenticated, client):
        """
        Verify that password change form fails if the 'new password' has a typo.
        """
        old_password = 'old_password'
        user_authenticated.set_password(old_password)
        user_authenticated.save()
        client.login(username=user_authenticated.username, password=old_password)
        new_password = 'something_new'
        new_password_typo = 'something_new_two'
        form_data = {
            'old_password':old_password,
            'new_password1':new_password,
            'new_password2':new_password_typo,
        }
        response = client.post(urls.reverse('password_change'), form_data)
        assert not user_authenticated.check_password(new_password)
        assert not user_authenticated.check_password(new_password_typo)
        assert b'Old password:' in response.content

    @pytest.mark.django_db
    def test_password_change_works(self, user_authenticated, client):
        """
        Verify that password change form works if there are no errors.
        """
        old_password = 'old_password'
        user_authenticated.set_password(old_password)
        user_authenticated.save()
        client.login(username=user_authenticated.username, password=old_password)
        new_password = 'something_new'
        form_data = {
            'old_password':old_password,
            'new_password1':new_password,
            'new_password2':new_password,
        }
        response = client.post(urls.reverse('password_change'), form_data)
        assert auth.get_user(client).check_password(new_password)
        assert response.status_code == 302
        assert response.url == urls.reverse('home')

### PASSWORD RESET
class TestPasswordReset:
    def test_password_reset_request_form_visible(self, client):
        """
        Verify that the password reset request form is visible.
        """
        response = client.get(urls.reverse('password_reset_request'))
        assert response.status_code == 200
        assert b'Reset password' in response.content

    @pytest.mark.django_db
    def test_password_reset_request_fails_silently_with_phony_username(self, client):
        """
        Verify that the password request form sends no email but doesn't present any error if the username does not exist.
        """
        form_data = {'username':'phony_username'}
        response = client.post(urls.reverse('password_reset_request'), form_data)
        assert len(mail.outbox) == 0
        assert response.status_code == 200
        assert b'request submitted' in response.content

    @pytest.mark.django_db
    def test_password_reset_request_works(self, user_authenticated, client):
        """
        Verify that the password reset request form sends email with link when a good username is put in.
        """
        client.logout()
        form_data = {'username':user_authenticated.username}
        response = client.post(urls.reverse('password_reset_request'), form_data)
        uidb64 = urlsafe_base64_encode(force_bytes(user_authenticated.pk))
        url_fragment = urls.reverse('password_reset', kwargs={'uidb64':uidb64, 'token':'123'})[0:-4]   # trim the fake token to get just up to the PK
        assert len(mail.outbox) == 1
        assert url_fragment in mail.outbox[0].body
        assert response.status_code == 200
        assert b'request submitted' in response.content

    @pytest.mark.django_db
    def test_password_reset_form_not_visible_with_invalid_link(self, user_authenticated, client):
        """
        Verify that the password reset form does not render if the link is invalid.
        """
        client.logout()
        form_data = {'username':user_authenticated.username}
        response = client.post(urls.reverse('password_reset_request'), form_data)   # submit a password reset request
        uidb64 = urlsafe_base64_encode(force_bytes(user_authenticated.pk))
        url_fragment = urls.reverse('password_reset', kwargs={'uidb64':uidb64, 'token':'123'})[0:-4]
        reset_url = re.search(url_fragment + '.*/', mail.outbox[0].body)[0]         # pull the link out of the email
        bad_reset_url = reset_url[0:-2] + chr(ord(reset_url[-2])+1) + reset_url[-1] # make an invalid token
        response = client.get(bad_reset_url)
        assert response.status_code == 200
        assert b'invalid' in response.content

    @pytest.mark.django_db
    def test_password_reset_form_visible_with_valid_link(self, user_authenticated, client):
        """
        Verify that the password reset form does not render if the link is invalid.
        """
        client.logout()
        form_data = {'username':user_authenticated.username}
        response = client.post(urls.reverse('password_reset_request'), form_data)   # submit a password reset request
        uidb64 = urlsafe_base64_encode(force_bytes(user_authenticated.pk))
        url_fragment = urls.reverse('password_reset', kwargs={'uidb64':uidb64, 'token':'123'})[0:-4]
        reset_url = re.search(url_fragment + '.*/', mail.outbox[0].body)[0]         # pull the link out of the email
        response = client.get(reset_url)
        assert response.status_code == 302
        assert response.url == urls.reverse('password_reset', kwargs={'uidb64':uidb64, 'token':'reset_password'})
        response = client.get(reset_url, follow=True)
        assert b'Reset password' in response.content

    @pytest.mark.django_db
    def test_password_reset_fails_with_mismatched_new_passwords(self, user_authenticated, client):
        """
        Verify that password reset fails if the new passwords don't match.
        """
        client.logout()
        # set the password and prepare new password entries
        old_password = 'old_test_password'
        new_password = 'new_test_password'
        new_password_typo = 'new_test_password_with_typo'
        user_authenticated.set_password(old_password)
        user_authenticated.save()
        # get a valid password reset form and token
        form_data = {'username':user_authenticated.username}
        client.post(urls.reverse('password_reset_request'), form_data)      # submit a password reset request
        uidb64 = urlsafe_base64_encode(force_bytes(user_authenticated.pk))
        url_fragment = urls.reverse('password_reset', kwargs={'uidb64':uidb64, 'token':'123'})[0:-4]
        reset_url = re.search(url_fragment + '.*/', mail.outbox[0].body)[0] # pull the link out of the email
        client.get(reset_url, follow=True)
        # POST password reset form with bad data
        form_data = {
            'new_password1':new_password,
            'new_password2':new_password_typo,
        }
        reset_post_url = urls.reverse('password_reset', kwargs={'uidb64':uidb64, 'token':'reset_password'})
        response = client.post(reset_post_url, form_data)
        assert response.status_code == 200
        assert b'Reset password' in response.content
        client.login(username=user_authenticated.username, password=old_password)
        assert auth.get_user(client).check_password(old_password)
        assert not auth.get_user(client).check_password(new_password)
        assert not auth.get_user(client).check_password(new_password_typo)
        
    @pytest.mark.django_db
    def test_password_reset_succeeds(self, user_authenticated, client):
        """
        Verify that password reset succeeds with valid data.
        """
        client.logout()
        old_password = 'old_test_password'
        new_password = 'new_test_password'
        user_authenticated.set_password(old_password)
        user_authenticated.save()
        # get a valid password reset form and token
        form_data = {'username':user_authenticated.username}
        client.post(urls.reverse('password_reset_request'), form_data)      # submit a password reset request
        uidb64 = urlsafe_base64_encode(force_bytes(user_authenticated.pk))
        url_fragment = urls.reverse('password_reset', kwargs={'uidb64':uidb64, 'token':'123'})[0:-4]
        reset_url = re.search(url_fragment + '.*/', mail.outbox[0].body)[0] # pull the link out of the email
        client.get(reset_url, follow=True)
        # POST password reset form with bad data
        form_data = {
            'new_password1':new_password,
            'new_password2':new_password,
        }
        reset_post_url = urls.reverse('password_reset', kwargs={'uidb64':uidb64, 'token':'reset_password'})
        response = client.post(reset_post_url, form_data)
        client.login(username=user_authenticated.username, password=new_password)
        assert auth.get_user(client).is_authenticated
        print(response.content)
        assert response.url == urls.reverse('login')
        assert not auth.get_user(client).check_password(old_password)
        assert auth.get_user(client).check_password(new_password)

### HELPERS
class TestHelpers:
    def test_is_safe_redirect_url(self):
        """
        Verify that the we can identify safe relative and absolute urls
        """
        good_relative_url = urls.reverse('home')
        good_absolute_url = settings.SITE_URL + good_relative_url
        bad_url = 'https://www.github.com/'
        assert views._is_safe_redirect_url(good_relative_url)
        assert views._is_safe_redirect_url(good_absolute_url)
        assert not views._is_safe_redirect_url(bad_url)

    def test_signup_or_login_fails_with_invalid_params(self):
        """
        Verify correct error handling on this helper function.
        """
        with pytest.raises(ValueError):
            views._signup_or_login(request={}, signup_or_login='something_else')


