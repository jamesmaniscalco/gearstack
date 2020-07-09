import pytest
from django.contrib.auth import get_user_model
from ddf import G

@pytest.fixture
def user_authenticated(client, db):
    """
    Create an authenticated user for tests.
    """
    un = 'test_username'
    pw = 'test_password'
    em = 'test_email@dynamicfixture.com'
    user = G(get_user_model(), username=un, email=em)
    user.set_password(pw)
    user.save()
    client.login(username=un, password=pw)
    return user


