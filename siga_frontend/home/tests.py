from django.db.utils import OperationalError
from django.test import RequestFactory, SimpleTestCase

from .middleware import DatabaseUnavailableMiddleware


class DatabaseUnavailableMiddlewareTests(SimpleTestCase):
    def setUp(self):
        self.factory = RequestFactory()

    def test_returns_friendly_response_when_database_is_unavailable(self):
        request = self.factory.get('/clientes/')

        def raise_database_error(request):
            raise OperationalError("Can't connect to server")

        middleware = DatabaseUnavailableMiddleware(raise_database_error)
        response = middleware(request)

        self.assertEqual(response.status_code, 503)
        self.assertIn(b'No se pudo conectar con la base de datos', response.content)
        self.assertIn(b'Intente nuevamente m\xc3\xa1s tarde', response.content)

    def test_returns_friendly_response_when_any_unexpected_error_occurs(self):
        request = self.factory.get('/clientes/')

        def raise_unexpected_error(request):
            raise RuntimeError('boom')

        middleware = DatabaseUnavailableMiddleware(raise_unexpected_error)
        response = middleware(request)

        self.assertEqual(response.status_code, 500)
        self.assertIn(b'Ha ocurrido un error inesperado', response.content)
