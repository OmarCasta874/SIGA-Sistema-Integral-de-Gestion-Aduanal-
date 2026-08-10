from django.db import DatabaseError
from django.db.utils import OperationalError
from django.http import JsonResponse


class DatabaseUnavailableMiddleware:

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        try:
            return self.get_response(request)

        except OperationalError:
            return JsonResponse(
                {
                    'error': 'No se pudo conectar con la base de datos',
                    'mensaje': (
                        'El servidor de base de datos no está disponible. '
                        'Intente nuevamente más tarde.'
                    ),
                },
                status=503,
            )

        except DatabaseError:
            return JsonResponse(
                {
                    'error': 'Error en la base de datos',
                    'mensaje': (
                        'Ocurrió un problema al acceder a la base de datos. '
                        'Intente nuevamente más tarde.'
                    ),
                },
                status=503,
            )