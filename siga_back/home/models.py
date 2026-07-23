from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager
from django.db import models

# ──────────────────────────────────────────────────────────────────
# Modelo USUARIO
# ──────────────────────────────────────────────────────────────────
class UsuarioManager(BaseUserManager):
    def create_user(self, correo, nombre_usuario, password=None, **extra_fields):
        if not correo:
            raise ValueError('El correo es obligatorio.')
        correo = self.normalize_email(correo)
        usuario = self.model(correo=correo, nombre_usuario=nombre_usuario, **extra_fields)
        usuario.set_password(password)
        usuario.save(using=self._db)
        return usuario

    def create_superuser(self, correo, nombre_usuario, password=None, **extra_fields):
        return self.create_user(correo, nombre_usuario, password, **extra_fields)


class Usuario(AbstractBaseUser):
    ROL_ADMINISTRADOR = 'Administrador'
    ROL_INSPECTOR = 'Inspector'
    ROLES = [
        (ROL_ADMINISTRADOR, 'Administrador'),
        (ROL_INSPECTOR, 'Inspector'),
    ]

    ID_usuario = models.AutoField(primary_key=True, db_column='ID_usuario')
    nombre_usuario = models.CharField(max_length=50, unique=True, db_column='nombre_usuario')
    nombre_pila = models.CharField(max_length=40, db_column='nombre_pila')
    primer_apell = models.CharField(max_length=40, db_column='primer_apell')
    seg_apell = models.CharField(max_length=40, blank=True, null=True, db_column='seg_apell')
    fecha_alta = models.DateField(db_column='fecha_alta')
    correo = models.EmailField(max_length=80, unique=True, db_column='correo')
    contrasena = models.CharField(max_length=100, db_column='contrasena')
    bitacora = models.IntegerField(db_column='bitacora', null=True, blank=True)
    rol = models.CharField(max_length=20, choices=ROLES, default=ROL_ADMINISTRADOR, db_column='rol')
    activo = models.BooleanField(default=True, db_column='activo')

    objects = UsuarioManager()

    USERNAME_FIELD = 'correo'
    REQUIRED_FIELDS = ['nombre_usuario']

    @property
    def password(self):
        return self.contrasena

    @password.setter
    def password(self, value):
        self.contrasena = value

    @property
    def is_active(self):    return self.activo
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
        managed = False       
        db_table = 'usuario' 

# ──────────────────────────────────────────────────────────────────
# Modelo CLIENTE
# ──────────────────────────────────────────────────────────────────
class Cliente(models.Model):
    numero = models.AutoField(primary_key=True, db_column='numero')
    nombre = models.CharField(max_length=80, db_column='nombre')
    primer_apell = models.CharField(max_length=40, blank=True, null=True, db_column='primer_apell')
    seg_apell = models.CharField(max_length=40, blank=True, null=True, db_column='seg_apell')
    tipo_persona = models.CharField(max_length=20, db_column='tipo_persona')
    RFC = models.CharField(max_length=13, unique=True, db_column='RFC')
    curp = models.CharField(max_length=18, blank=True, null=True, db_column='curp')
    domicilio = models.CharField(max_length=250, blank=True, null=True, db_column='domicilio')
    activo = models.BooleanField(default=True, db_column='activo')

    class Meta:
        managed = False
        db_table = 'cliente'
        verbose_name = 'Cliente'
        verbose_name_plural = 'Clientes'

    def __str__(self):
        return f'{self.nombre} {self.primer_apell or ""}'.strip()


# ──────────────────────────────────────────────────────────────────
# Modelo REGIMEN_ADUANERO
# ──────────────────────────────────────────────────────────────────
class RegimenAduanero(models.Model):
    num_regimen = models.AutoField(primary_key=True, db_column='num_regimen')
    clave_oficial = models.CharField(max_length=10, unique=True, db_column='clave_oficial')
    descripcion = models.CharField(max_length=200, db_column='descripcion')

    class Meta:
        managed = False
        db_table = 'regimen_aduanero'
        verbose_name = 'Régimen aduanero'
        verbose_name_plural = 'Regímenes aduaneros'

    def __str__(self):
        return f'{self.clave_oficial} — {self.descripcion}'


# ──────────────────────────────────────────────────────────────────
# Modelo SEMAFORO_FISCAL
# ──────────────────────────────────────────────────────────────────
class SemaforoFiscal(models.Model):
    ID = models.AutoField(primary_key=True, db_column='ID')
    hora = models.TimeField(db_column='hora')
    resultado = models.CharField(max_length=100, db_column='resultado')

    class Meta:
        managed = False
        db_table = 'semaforo_fiscal'
        verbose_name = 'Semáforo fiscal'
        verbose_name_plural = 'Semáforos fiscales'

    def __str__(self):
        return f'Semáforo {self.ID} — {self.resultado}'


# ──────────────────────────────────────────────────────────────────
# Modelo INSPECCION
# ──────────────────────────────────────────────────────────────────
class Inspeccion(models.Model):
    numero = models.AutoField(primary_key=True, db_column='numero')
    fecha_inspeccion = models.DateField(db_column='fecha_inspeccion')
    hora_inicio = models.TimeField(db_column='hora_inicio')
    resultado = models.CharField(max_length=100, blank=True, null=True, db_column='resultado')
    motivo_segunda = models.CharField(max_length=500, blank=True, null=True, db_column='motivo_segunda')
    semaforo = models.ForeignKey(
        SemaforoFiscal, on_delete=models.CASCADE,
        db_column='semaforo', related_name='inspecciones'
    )

    class Meta:
        managed = False
        db_table = 'inspeccion'
        verbose_name = 'Inspección'
        verbose_name_plural = 'Inspecciones'

    def __str__(self):
        return f'Inspección {self.numero} — {self.fecha_inspeccion}'


# ──────────────────────────────────────────────────────────────────
# Modelo SEGUNDA_INSPECCION
# ──────────────────────────────────────────────────────────────────
class SegundaInspeccion(models.Model):
    ID_revision = models.AutoField(primary_key=True, db_column='ID_revision')
    inspeccion_FK = models.ForeignKey(
        Inspeccion, on_delete=models.CASCADE,
        db_column='inspeccion', related_name='segundas_inspecciones'
    )
    fecha_inspeccion = models.DateField(db_column='fecha_inspeccion')
    hora_inicio = models.TimeField(db_column='hora_inicio')
    resultado = models.CharField(max_length=100, blank=True, null=True, db_column='resultado')

    class Meta:
        managed = False
        db_table = 'segunda_inspeccion'
        verbose_name = 'Segunda inspección'
        verbose_name_plural = 'Segundas inspecciones'

    def __str__(self):
        return f'Segunda inspección {self.ID_revision} (de inspección {self.inspeccion_FK_id})'


# ──────────────────────────────────────────────────────────────────
# Modelo INSPECTOR_ADUANERO
# ──────────────────────────────────────────────────────────────────
class InspectorAduanero(models.Model):
    matricula = models.CharField(max_length=20, primary_key=True, db_column='matricula')
    no_gafete = models.CharField(max_length=25, unique=True, db_column='no_gafete')
    nombre_pila = models.CharField(max_length=40, db_column='nombre_pila')
    primer_apell = models.CharField(max_length=40, db_column='primer_apell')
    seg_apell = models.CharField(max_length=40, blank=True, null=True, db_column='seg_apell')

    class Meta:
        managed = False
        db_table = 'inspector_aduanero'
        verbose_name = 'Inspector aduanero'
        verbose_name_plural = 'Inspectores aduaneros'

    def __str__(self):
        return f'{self.nombre_pila} {self.primer_apell} ({self.matricula})'


# ──────────────────────────────────────────────────────────────────
# Modelo TIPO_EXPORTACIONES
# ──────────────────────────────────────────────────────────────────
class TipoExportaciones(models.Model):
    tipo_exportacion = models.AutoField(primary_key=True, db_column='tipo_exportacion')
    nombre = models.CharField(max_length=50, db_column='nombre')
    descripcion = models.CharField(max_length=200, blank=True, null=True, db_column='descripcion')

    class Meta:
        managed = False
        db_table = 'tipo_exportaciones'
        verbose_name = 'Tipo de exportación'
        verbose_name_plural = 'Tipos de exportación'

    def __str__(self):
        return self.nombre


# ──────────────────────────────────────────────────────────────────
# Modelo TIPO_IMPORTACIONES
# ──────────────────────────────────────────────────────────────────
class TipoImportaciones(models.Model):
    tipo_importacion = models.AutoField(primary_key=True, db_column='tipo_importacion')
    nombre = models.CharField(max_length=50, db_column='nombre')
    descripcion = models.CharField(max_length=200, blank=True, null=True, db_column='descripcion')

    class Meta:
        managed = False
        db_table = 'tipo_importaciones'
        verbose_name = 'Tipo de importación'
        verbose_name_plural = 'Tipos de importación'

    def __str__(self):
        return self.nombre


# ──────────────────────────────────────────────────────────────────
# Modelo ADUANA
# ──────────────────────────────────────────────────────────────────
class Aduana(models.Model):
    codigo = models.AutoField(primary_key=True, db_column='codigo')
    ciudad = models.CharField(max_length=60, db_column='ciudad')
    nombre = models.CharField(max_length=100, db_column='nombre')

    class Meta:
        managed = False
        db_table = 'aduana'
        verbose_name = 'Aduana'
        verbose_name_plural = 'Aduanas'

    def __str__(self):
        return self.nombre


# ──────────────────────────────────────────────────────────────────
# Modelo BITACORA
# ──────────────────────────────────────────────────────────────────
class Bitacora(models.Model):
    MODULOS = [
        ('Login', 'Login'), ('Clientes', 'Clientes'), ('Operaciones', 'Operaciones'),
        ('Pedimentos', 'Pedimentos'), ('Pagos', 'Pagos'), ('Permisos', 'Permisos'),
        ('Paquetes', 'Paquetes'), ('Facturas', 'Facturas'), ('Inspecciones', 'Inspecciones'),
        ('Sanciones', 'Sanciones'), ('Categorias', 'Categorías'), ('Usuarios', 'Usuarios'),
    ]
    TIPOS_ACCION = [
        ('Creación', 'Creación'), ('Edición', 'Edición'),
        ('Eliminación', 'Eliminación'), ('Login', 'Login'),
    ]

    numero = models.AutoField(primary_key=True, db_column='numero')
    descripcion = models.CharField(max_length=250, db_column='descripcion')
    fecha = models.DateField(db_column='fecha')
    hora = models.TimeField(db_column='hora')
    usuario = models.ForeignKey(
        'Usuario', on_delete=models.SET_NULL, null=True, blank=True,
        db_column='usuario_id', related_name='bitacoras',
    )
    modulo = models.CharField(max_length=50, choices=MODULOS, default='', db_column='modulo')
    tipo_accion = models.CharField(max_length=20, choices=TIPOS_ACCION, default='', db_column='tipo_accion')

    class Meta:
        managed = False
        db_table = 'bitacora'
        verbose_name = 'Bitácora'
        verbose_name_plural = 'Bitácoras'

    def __str__(self):
        return f'Bitácora {self.numero} — {self.fecha}'


# ──────────────────────────────────────────────────────────────────
# Modelo TELEFONO
# ──────────────────────────────────────────────────────────────────
class Telefono(models.Model):
    numero = models.AutoField(primary_key=True, db_column='numero')
    numTelefono = models.CharField(max_length=20, db_column='numTelefono')
    cliente = models.ForeignKey(
        Cliente, on_delete=models.CASCADE,
        db_column='cliente', related_name='telefonos'
    )

    class Meta:
        managed = False
        db_table = 'telefono'
        verbose_name = 'Teléfono'
        verbose_name_plural = 'Teléfonos'

    def __str__(self):
        return self.numTelefono


# ──────────────────────────────────────────────────────────────────
# Modelo CORREO_ELECTRONICO
# ──────────────────────────────────────────────────────────────────
class CorreoElectronico(models.Model):
    numero = models.AutoField(primary_key=True, db_column='numero')
    correoElec = models.CharField(max_length=80, db_column='correoElec')
    cliente = models.ForeignKey(
        Cliente, on_delete=models.CASCADE,
        db_column='cliente', related_name='correos'
    )
    usuario = models.ForeignKey(
        Usuario, on_delete=models.CASCADE,
        db_column='usuario', related_name='correos'
    )

    class Meta:
        managed = False
        db_table = 'correo_electronico'
        verbose_name = 'Correo electrónico'
        verbose_name_plural = 'Correos electrónicos'

    def __str__(self):
        return self.correoElec


# ──────────────────────────────────────────────────────────────────
# Modelo PERMISO
# ──────────────────────────────────────────────────────────────────
class Permiso(models.Model):
    clave_numerica = models.CharField(max_length=30, primary_key=True, db_column='clave_numerica')
    tipo_permiso = models.CharField(max_length=50, db_column='tipo_permiso')
    vigencia = models.DateField(db_column='vigencia')
    descripcion = models.CharField(max_length=250, blank=True, null=True, db_column='descripcion')
    cliente = models.ForeignKey(
        Cliente, on_delete=models.CASCADE,
        db_column='cliente', related_name='permisos'
    )

    class Meta:
        managed = False
        db_table = 'permiso'
        verbose_name = 'Permiso'
        verbose_name_plural = 'Permisos'

    def __str__(self):
        return f'{self.clave_numerica} — {self.tipo_permiso}'


# ──────────────────────────────────────────────────────────────────
# Modelo TIPO_PERMISO
# ──────────────────────────────────────────────────────────────────
class TipoPermiso(models.Model):
    id_tipo_permiso = models.AutoField(primary_key=True, db_column='id_tipo_permiso')
    tipo = models.CharField(max_length=50, db_column='tipo')
    descripcion = models.CharField(max_length=200, blank=True, null=True, db_column='descripcion')
    permiso = models.ForeignKey(
        Permiso, on_delete=models.CASCADE,
        db_column='permiso', related_name='tipos_permiso'
    )

    class Meta:
        managed = False
        db_table = 'tipo_permiso'
        verbose_name = 'Tipo de permiso'
        verbose_name_plural = 'Tipos de permiso'

    def __str__(self):
        return self.tipo


# ──────────────────────────────────────────────────────────────────
# Modelo INCIDENCIA
# ──────────────────────────────────────────────────────────────────
class Incidencia(models.Model):
    codigo = models.AutoField(primary_key=True, db_column='codigo')
    gravedad = models.CharField(max_length=30, db_column='gravedad')
    descripcion = models.CharField(max_length=250, db_column='descripcion')
    inspeccion = models.ForeignKey(
        Inspeccion, on_delete=models.CASCADE,
        db_column='inspeccion', related_name='incidencias'
    )

    class Meta:
        managed = False
        db_table = 'incidencia'
        verbose_name = 'Incidencia'
        verbose_name_plural = 'Incidencias'

    def __str__(self):
        return f'Incidencia {self.codigo} — {self.gravedad}'


# ──────────────────────────────────────────────────────────────────
# Modelo OPERACION_ADUANERA
# ──────────────────────────────────────────────────────────────────
class EstadoOpeAduanera(models.Model):
    codigo = models.AutoField(primary_key=True, db_column='codigo')
    descripcion = models.CharField(max_length=100, db_column='descripcion')

    class Meta:
        managed = False
        db_table = 'estado_opeaduanera'

    def __str__(self):
        return self.descripcion


class OperacionAduanera(models.Model):
    ID_operacion = models.AutoField(primary_key=True, db_column='ID_operacion')
    fecha_inicio = models.DateField(db_column='fecha_inicio')
    fecha_final = models.DateField(blank=True, null=True, db_column='fecha_final')
    tipo_operacion = models.CharField(max_length=20, db_column='tipo_operacion')
    estado_ope_aduanera = models.ForeignKey(
        EstadoOpeAduanera, on_delete=models.PROTECT,
        db_column='estado_ope_aduanera', related_name='operaciones'
    )
    cliente = models.ForeignKey(
        Cliente, on_delete=models.CASCADE,
        db_column='cliente', related_name='operaciones'
    )
    usuario = models.ForeignKey(
        Usuario, on_delete=models.CASCADE,
        db_column='usuario', related_name='operaciones'
    )
    bitacora = models.ForeignKey(
        Bitacora, on_delete=models.CASCADE,
        db_column='bitacora', related_name='operaciones'
    )
    aduana = models.ForeignKey(
        Aduana, on_delete=models.CASCADE,
        db_column='aduana', related_name='operaciones'
    )

    class Meta:
        managed = False
        db_table = 'operacion_aduanera'
        verbose_name = 'Operación aduanera'
        verbose_name_plural = 'Operaciones aduaneras'

    def __str__(self):
        return f'Operación {self.ID_operacion} — {self.tipo_operacion}'


# ──────────────────────────────────────────────────────────────────
# Modelo PAGO
# ──────────────────────────────────────────────────────────────────
class Pago(models.Model):
    no_transaccion = models.CharField(max_length=50, primary_key=True, db_column='no_transaccion')
    numero_pago = models.IntegerField(db_column='numero_pago')
    concepto = models.CharField(max_length=100, db_column='concepto')
    saldo_final = models.DecimalField(max_digits=12, decimal_places=2, db_column='saldo_final')
    monto = models.DecimalField(max_digits=12, decimal_places=2, db_column='monto')
    fecha_pago = models.DateField(db_column='fecha_pago')
    pedimento = models.ForeignKey(
        'Pedimento', on_delete=models.SET_NULL,
        db_column='pedimento', related_name='pagos',
        blank=True, null=True,
    )
    estado_pago = models.ForeignKey(
        'EstadoPago', on_delete=models.PROTECT,
        db_column='estado_pago', related_name='pagos',
    )

    class Meta:
        managed = False
        db_table = 'pago'
        verbose_name = 'Pago'
        verbose_name_plural = 'Pagos'

    def __str__(self):
        return f'{self.no_transaccion} — ${self.monto}'


# ──────────────────────────────────────────────────────────────────
# Modelo SANCION
# ──────────────────────────────────────────────────────────────────
class Sancion(models.Model):
    num_sancion = models.AutoField(primary_key=True, db_column='num_sancion')
    monto_multa = models.DecimalField(max_digits=12, decimal_places=2, db_column='monto_multa')
    fundamento_legal = models.CharField(max_length=250, db_column='fundamento_legal')
    incidencia = models.ForeignKey(
        Incidencia, on_delete=models.CASCADE,
        db_column='incidencia', related_name='sanciones'
    )

    class Meta:
        managed = False
        db_table = 'sancion'
        verbose_name = 'Sanción'
        verbose_name_plural = 'Sanciones'

    def __str__(self):
        return f'Sanción {self.num_sancion} — ${self.monto_multa}'


# ──────────────────────────────────────────────────────────────────
# Modelo INSPECCION_INSPECTOR
# ──────────────────────────────────────────────────────────────────
class InspeccionInspector(models.Model):
    inspeccion = models.ForeignKey(
        Inspeccion, on_delete=models.CASCADE,
        db_column='inspeccion', related_name='inspectores_asignados'
    )
    inspector_adu = models.ForeignKey(
        InspectorAduanero, on_delete=models.CASCADE,
        db_column='inspector_adu', related_name='inspecciones_realizadas'
    )
    observaciones = models.CharField(max_length=250, blank=True, null=True, db_column='observaciones')

    class Meta:
        managed = False
        db_table = 'inspeccion_inspector'
        verbose_name = 'Inspección - Inspector'
        verbose_name_plural = 'Inspecciones - Inspectores'
        unique_together = (('inspeccion', 'inspector_adu'),)

    def __str__(self):
        return f'Inspección {self.inspeccion_id} — Inspector {self.inspector_adu_id}'


# ──────────────────────────────────────────────────────────────────
# Modelo SEGUNDA_INSPECCION_INSPECTOR 
# ──────────────────────────────────────────────────────────────────
class SegundaInspeccionInspector(models.Model):
    segunda_ins = models.ForeignKey(
        SegundaInspeccion, on_delete=models.CASCADE,
        db_column='segunda_ins', related_name='inspectores_asignados'
    )
    inspector_adu = models.ForeignKey(
        InspectorAduanero, on_delete=models.CASCADE,
        db_column='inspector_adu', related_name='segundas_inspecciones_realizadas'
    )
    observaciones = models.CharField(max_length=250, blank=True, null=True, db_column='observaciones')

    class Meta:
        managed = False
        db_table = 'segunda_inspeccion_inspector'
        verbose_name = 'Segunda inspección - Inspector'
        verbose_name_plural = 'Segundas inspecciones - Inspectores'
        unique_together = (('segunda_ins', 'inspector_adu'),)

    def __str__(self):
        return f'Segunda inspección {self.segunda_ins_id} — Inspector {self.inspector_adu_id}'
    

# ──────────────────────────────────────────────────────────────────
# Modelo FACTURA
# ──────────────────────────────────────────────────────────────────
class Factura(models.Model):
    codigo = models.AutoField(primary_key=True, db_column='codigo')
    IVA = models.DecimalField(max_digits=12, decimal_places=2, db_column='IVA')
    subtotal = models.DecimalField(max_digits=12, decimal_places=2, db_column='subtotal')
    total = models.DecimalField(max_digits=12, decimal_places=2, db_column='total')
    folio_fiscal = models.CharField(max_length=50, unique=True, db_column='folio_fiscal')
    fecha_factura = models.DateField(db_column='fecha_factura')
    ID_operacion = models.ForeignKey(
        OperacionAduanera, on_delete=models.CASCADE,
        db_column='ID_operacion', related_name='facturas'
    )

    class Meta:
        managed = False
        db_table = 'factura'
        verbose_name = 'Factura'
        verbose_name_plural = 'Facturas'

    def __str__(self):
        return f'Factura {self.codigo} — {self.folio_fiscal}'


# ──────────────────────────────────────────────────────────────────
# Modelo PEDIMENTO
# ──────────────────────────────────────────────────────────────────
class Pedimento(models.Model):
    numero_pedimento = models.CharField(max_length=30, primary_key=True, db_column='numero_pedimento')
    clave_pedimento = models.CharField(max_length=10, db_column='clave_pedimento')
    fecha_registro = models.DateField(db_column='fecha_registro')
    valor_total = models.DecimalField(max_digits=12, decimal_places=2, db_column='valor_total')
    semaforo = models.ForeignKey(
        SemaforoFiscal, on_delete=models.CASCADE,
        db_column='semaforo', related_name='pedimentos',
        null=True, blank=True
    )
    regimen_adu = models.ForeignKey(
        RegimenAduanero, on_delete=models.CASCADE,
        db_column='regimen_adu', related_name='pedimentos'
    )
    permiso = models.ForeignKey(
        Permiso, on_delete=models.CASCADE,
        db_column='permiso', related_name='pedimentos'
    )
    ope_aduanera = models.ForeignKey(
        OperacionAduanera, on_delete=models.CASCADE,
        db_column='ope_aduanera', related_name='pedimentos'
    )
    tipo_exportacion = models.ForeignKey(
        TipoExportaciones, on_delete=models.SET_NULL,
        db_column='tipo_exportacion', related_name='pedimentos',
        blank=True, null=True
    )
    tipo_importacion = models.ForeignKey(
        TipoImportaciones, on_delete=models.SET_NULL,
        db_column='tipo_importacion', related_name='pedimentos',
        blank=True, null=True
    )
    medio_transporte = models.CharField(max_length=20, blank=True, null=True, db_column='medio_transporte')
    pais_origen_mercancia = models.CharField(max_length=60, blank=True, null=True, db_column='pais_origen_mercancia')
    pais_destino = models.CharField(max_length=60, blank=True, null=True, db_column='pais_destino')
    incoterm = models.CharField(max_length=10, blank=True, null=True, db_column='incoterm')
    tipo_cambio = models.DecimalField(max_digits=10, decimal_places=4, blank=True, null=True, db_column='tipo_cambio')
    fecha_limite = models.DateTimeField(blank=True, null=True, db_column='fecha_limite')

    class Meta:
        managed = False
        db_table = 'pedimento'
        verbose_name = 'Pedimento'
        verbose_name_plural = 'Pedimentos'

    def __str__(self):
        return self.numero_pedimento


# ──────────────────────────────────────────────────────────────────
# Modelo ESTADO_PAGO
# ──────────────────────────────────────────────────────────────────
class EstadoPago(models.Model):
    codigo = models.AutoField(primary_key=True, db_column='codigo')
    concepto = models.CharField(max_length=100, db_column='concepto')
    descripcion = models.CharField(max_length=200, blank=True, null=True, db_column='descripcion')

    class Meta:
        managed = False
        db_table = 'estado_pago'
        verbose_name = 'Estado de pago'
        verbose_name_plural = 'Estados de pago'

    def __str__(self):
        return self.concepto


# ──────────────────────────────────────────────────────────────────
# Modelo TIPO_ARANCEL
# ──────────────────────────────────────────────────────────────────
class TipoArancel(models.Model):
    numero = models.AutoField(primary_key=True, db_column='numero')
    nombre = models.CharField(max_length=50, db_column='nombre')
    descripcion = models.CharField(max_length=200, blank=True, null=True, db_column='descripcion')
    fecha_actualizacion = models.DateField(db_column='fecha_actualizacion')

    class Meta:
        managed = False
        db_table = 'tipo_arancel'
        verbose_name = 'Tipo de arancel'
        verbose_name_plural = 'Tipos de arancel'

    def __str__(self):
        return self.nombre


# ──────────────────────────────────────────────────────────────────
# Modelo ARANCEL
# ──────────────────────────────────────────────────────────────────
class Arancel(models.Model):
    numero = models.AutoField(primary_key=True, db_column='numero')
    subtotal = models.DecimalField(max_digits=12, decimal_places=2, db_column='subtotal')
    descripcion = models.CharField(max_length=200, blank=True, null=True, db_column='descripcion')
    IGI = models.DecimalField(max_digits=5, decimal_places=2, db_column='IGI')
    tasa_interes = models.DecimalField(max_digits=5, decimal_places=2, db_column='tasa_interes')
    Tipo_Arancel = models.ForeignKey(
        TipoArancel, on_delete=models.CASCADE,
        db_column='Tipo_Arancel', related_name='aranceles'
    )
    pedimento = models.ForeignKey(
        Pedimento, on_delete=models.CASCADE,
        db_column='pedimento', related_name='aranceles'
    )
    categoria = models.ForeignKey(
        'CategoriaProductos', on_delete=models.PROTECT,
        db_column='categoria', related_name='aranceles'
    )

    class Meta:
        managed = False
        db_table = 'arancel'
        verbose_name = 'Arancel'
        verbose_name_plural = 'Aranceles'

    def __str__(self):
        return f'Arancel {self.numero} — IGI {self.IGI}%'


# ──────────────────────────────────────────────────────────────────
# Modelo TIPO_EMBALAJE
# ──────────────────────────────────────────────────────────────────
class TipoEmbalaje(models.Model):
    id = models.AutoField(primary_key=True, db_column='id')
    nombre = models.CharField(max_length=50, unique=True, db_column='nombre')
    peso_maximo = models.DecimalField(max_digits=10, decimal_places=2, db_column='peso_maximo')
    descripcion = models.CharField(max_length=200, blank=True, null=True, db_column='descripcion')

    class Meta:
        managed = False
        db_table = 'tipo_embalaje'
        verbose_name = 'Tipo de embalaje'
        verbose_name_plural = 'Tipos de embalaje'

    def __str__(self):
        return self.nombre


# ──────────────────────────────────────────────────────────────────
# Modelo PAQUETE
# ──────────────────────────────────────────────────────────────────
class Paquete(models.Model):
    codigo = models.AutoField(primary_key=True, db_column='codigo')
    peso = models.DecimalField(max_digits=10, decimal_places=2, db_column='peso')
    tipo_embalaje = models.ForeignKey(
        TipoEmbalaje, on_delete=models.PROTECT,
        db_column='tipo_embalaje_id', related_name='paquetes'
    )
    dimensions = models.CharField(max_length=50, blank=True, null=True, db_column='dimensiones')
    cliente = models.ForeignKey(
        Cliente, on_delete=models.CASCADE,
        db_column='cliente', related_name='paquetes'
    )
    pedimento = models.ForeignKey(
        Pedimento, on_delete=models.SET_NULL,
        db_column='pedimento', related_name='paquetes',
        blank=True, null=True,
    )
    inspeccion = models.ForeignKey(
        Inspeccion, on_delete=models.SET_NULL,
        db_column='inspeccion', related_name='paquetes',
        blank=True, null=True,
    )

    class Meta:
        managed = False
        db_table = 'paquete'
        verbose_name = 'Paquete'
        verbose_name_plural = 'Paquetes'

    def __str__(self):
        return f'Paquete {self.codigo} — {self.tipo_embalaje}'


# ──────────────────────────────────────────────────────────────────
# Modelo CATEGORIA_PRODUCTOS
# ──────────────────────────────────────────────────────────────────
class CategoriaProductos(models.Model):
    numero = models.AutoField(primary_key=True, db_column='numero')
    nombre = models.CharField(max_length=50, db_column='nombre')
    descripcion = models.CharField(max_length=200, blank=True, null=True, db_column='descripcion')
    IGI = models.DecimalField(max_digits=5, decimal_places=2, default=0, db_column='IGI')
    tipo_arancel = models.ForeignKey(
        TipoArancel, on_delete=models.PROTECT,
        db_column='tipo_arancel', related_name='categorias'
    )
    tipo_permiso_requerido = models.CharField(
        max_length=50, blank=True, null=True,
        db_column='tipo_permiso_requerido',
    )
    fraccion_arancelaria = models.CharField(
        max_length=10, blank=True, null=True,
        db_column='fraccion_arancelaria',
    )

    class Meta:
        managed = False
        db_table = 'categoria_productos'
        verbose_name = 'Categoría de productos'
        verbose_name_plural = 'Categorías de productos'

    def __str__(self):
        return self.nombre


# ──────────────────────────────────────────────────────────────────
# Modelo PRODUCTO
# ──────────────────────────────────────────────────────────────────
class Producto(models.Model):
    codigo = models.AutoField(primary_key=True, db_column='codigo')
    nombre = models.CharField(max_length=100, db_column='nombre')
    descripcion = models.CharField(max_length=200, blank=True, null=True, db_column='descripcion')
    peso = models.DecimalField(max_digits=10, decimal_places=2, db_column='peso')
    valor_unitario = models.DecimalField(max_digits=12, decimal_places=2, db_column='valor_unitario')
    cantidad = models.IntegerField(default=1, db_column='cantidad')
    paquete = models.ForeignKey(
        Paquete, on_delete=models.CASCADE,
        db_column='paquete', related_name='productos'
    )

    class Meta:
        managed = False
        db_table = 'producto'
        verbose_name = 'Producto'
        verbose_name_plural = 'Productos'

    def __str__(self):
        return self.nombre


# ──────────────────────────────────────────────────────────────────
# Modelo CATEGORIA_EMBALAJE
# ──────────────────────────────────────────────────────────────────
class CategoriaEmbalaje(models.Model):
    id = models.AutoField(primary_key=True, db_column='id')
    categoria = models.ForeignKey(
        CategoriaProductos, on_delete=models.CASCADE,
        db_column='categoria_id', related_name='embalajes'
    )
    tipo_embalaje = models.ForeignKey(
        TipoEmbalaje, on_delete=models.CASCADE,
        db_column='tipo_embalaje_id', related_name='categorias'
    )

    class Meta:
        managed = False
        db_table = 'categoria_embalaje'
        verbose_name = 'Categoría - Embalaje'
        verbose_name_plural = 'Categorías - Embalajes'
        unique_together = (('categoria', 'tipo_embalaje'),)

    def __str__(self):
        return f'{self.categoria} → {self.tipo_embalaje}'


# ──────────────────────────────────────────────────────────────────
# Modelo CATEGORIAS_PRODUCTOS_REL
# ──────────────────────────────────────────────────────────────────
class CategoriasProductosRel(models.Model):
    categorias = models.ForeignKey(
        CategoriaProductos, on_delete=models.CASCADE,
        db_column='categorias', related_name='productos_rel'
    )
    productos = models.ForeignKey(
        Producto, on_delete=models.CASCADE,
        db_column='productos', related_name='categorias_rel'
    )

    class Meta:
        managed = False
        db_table = 'categorias_productos_rel'
        verbose_name = 'Categoría - Producto'
        verbose_name_plural = 'Categorías - Productos'
        unique_together = (('categorias', 'productos'),)

    def __str__(self):
        return f'Categoría {self.categorias_id} — Producto {self.productos_id}'