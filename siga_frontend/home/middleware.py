from django.db import DatabaseError
from django.db.utils import OperationalError
from django.shortcuts import render


class DatabaseUnavailableMiddleware:
    """Devuelve una respuesta amigable cuando la base de datos no está disponible."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        try:
            return self.get_response(request)

        except OperationalError:
            return render(
                request,
                'home/error.html',
                {
                    'titulo': 'No se pudo conectar con la base de datos',
                    'mensaje': (
                        'No fue posible establecer conexión con la base de datos. '
                        'Verifique que el servidor de MySQL esté disponible '
                        'e intente nuevamente.'
                    ),
                },
                status=503,
            )

        except DatabaseError:
            return render(
                request,
                'home/error.html',
                {
                    'titulo': 'Error en la base de datos',
                    'mensaje': (
                        'Ocurrió un problema al acceder a la base de datos. '
                        'Intente nuevamente más tarde.'
                    ),
                },
                status=503,
            )