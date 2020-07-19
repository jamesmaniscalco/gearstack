from django import urls

import pytest

from marketing import views


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
