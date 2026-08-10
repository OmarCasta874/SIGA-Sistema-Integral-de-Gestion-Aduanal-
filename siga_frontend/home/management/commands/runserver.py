from django.core.management.commands.runserver import Command as RunserverCommand
from django.db import DatabaseError
from django.db.utils import OperationalError


class Command(RunserverCommand):
    """Permite arrancar el servidor aunque la base de datos no esté disponible."""

    def check_migrations(self):
        try:
            super().check_migrations()
        except (OperationalError, DatabaseError) as exc:
            self.stdout.write(
                self.style.WARNING(
                    'Advertencia: no se pudieron validar las migraciones porque la base de datos no está disponible. '
                    f'Error: {exc}'
                )
            )
