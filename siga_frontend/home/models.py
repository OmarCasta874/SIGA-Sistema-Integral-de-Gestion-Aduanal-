from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager
from django.db import models


class UsuarioManager(BaseUserManager):
    def create_user(self, correo, nombre_usuario, password=None, **extra_fields):
        if not correo:
            raise ValueError('El correo es obligatorio.')
        correo  = self.normalize_email(correo)
        usuario = self.model(correo=correo, nombre_usuario=nombre_usuario, **extra_fields)
        usuario.set_password(password)
        usuario.save(using=self._db)
        return usuario

    def create_superuser(self, correo, nombre_usuario, password=None, **extra_fields):
        return self.create_user(correo, nombre_usuario, password, **extra_fields)


class Usuario(AbstractBaseUser):
    ID_usuario     = models.AutoField(primary_key=True, db_column='ID_usuario')
    nombre_usuario = models.CharField(max_length=50, unique=True, db_column='nombre_usuario')
    nombre_pila    = models.CharField(max_length=40, db_column='nombre_pila')
    primer_apell   = models.CharField(max_length=40, db_column='primer_apell')
    seg_apell      = models.CharField(max_length=40, blank=True, null=True, db_column='seg_apell')
    fecha_alta     = models.DateField(db_column='fecha_alta')
    correo         = models.EmailField(max_length=80, unique=True, db_column='correo')
    contrasena     = models.CharField(max_length=100, db_column='contrasena')
    bitacora       = models.IntegerField(db_column='bitacora', null=True, blank=True)
    rol            = models.CharField(max_length=20, default='Administrador', db_column='rol')
    activo         = models.BooleanField(default=True, db_column='activo')

    objects = UsuarioManager()

    USERNAME_FIELD  = 'correo'
    REQUIRED_FIELDS = ['nombre_usuario']

    @property
    def password(self):
        return self.contrasena

    @password.setter
    def password(self, value):
        self.contrasena = value

    @property
    def is_active(self):    return True
    @property
    def is_staff(self):     return True
    @property
    def is_superuser(self): return True

    def has_perm(self, perm, obj=None): return True
    def has_module_perms(self, app_label): return True

    def get_short_name(self): return self.nombre_pila
    def get_full_name(self):
        return f'{self.nombre_pila} {self.primer_apell} {self.seg_apell or ""}'.strip()

    class Meta:
        managed  = False
        db_table = 'usuario'
