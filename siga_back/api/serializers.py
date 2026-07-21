from rest_framework import serializers
from datetime import date
from django.db.models import Sum
from django.utils import timezone

from home.models import (
    Usuario, Cliente, Aduana, OperacionAduanera, Pedimento,
    Permiso, Bitacora, CategoriaProductos,
    RegimenAduanero, SemaforoFiscal, TipoImportaciones, TipoExportaciones,
    Pago, Factura, Sancion, Paquete, Producto, EstadoPago, Inspeccion,
    TipoEmbalaje,
)



class UsuarioSerializer(serializers.ModelSerializer):
    nombre_completo = serializers.SerializerMethodField()

    class Meta:
        model = Usuario
        fields = [
            'ID_usuario', 'nombre_usuario', 'nombre_pila',
            'primer_apell', 'seg_apell', 'correo', 'fecha_alta',
            'nombre_completo', 'rol', 'activo',
        ]
        
        read_only_fields = [
            'ID_usuario', 'nombre_usuario', 'fecha_alta', 'nombre_completo','rol', 'activo',
        ]

    def get_nombre_completo(self, obj):
        return obj.get_full_name()


class UsuarioCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)

    class Meta:
        model = Usuario
        fields = ['nombre_pila', 'primer_apell', 'seg_apell', 'correo', 'nombre_usuario', 'password', 'rol']

    def create(self, validated_data):
        password = validated_data.pop('password')
        usuario = Usuario(**validated_data)
        usuario.fecha_alta = timezone.localdate()
        usuario.set_password(password)
        usuario.save()
        return usuario


class UsuarioUpdateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, min_length=6)

    class Meta:
        model = Usuario
        fields = ['nombre_pila', 'primer_apell', 'seg_apell', 'correo', 'nombre_usuario', 'password', 'rol']

    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        if password:
            instance.set_password(password)
        instance.save()
        return instance


class AduanaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Aduana
        fields = ['codigo', 'ciudad', 'nombre']
        read_only_fields = ['codigo']


class PermisoResumenSerializer(serializers.ModelSerializer):
    vigente = serializers.SerializerMethodField()
    clave = serializers.CharField(source='clave_numerica')
    tipo = serializers.CharField(source='tipo_permiso')
    vigencia_fmt = serializers.SerializerMethodField()

    class Meta:
        model = Permiso
        fields = ['clave', 'tipo', 'vigencia', 'vigencia_fmt', 'vigente', 'descripcion']

    def get_vigente(self, obj):
        return obj.vigencia >= timezone.localdate()

    def get_vigencia_fmt(self, obj):
        return obj.vigencia.strftime('%d/%m/%Y')


class PermisoListSerializer(serializers.ModelSerializer):
    vigente = serializers.SerializerMethodField()
    vigencia_fmt = serializers.SerializerMethodField()
    cliente_nombre = serializers.SerializerMethodField()
    cliente_numero = serializers.IntegerField(source='cliente_id', read_only=True)

    class Meta:
        model = Permiso
        fields = [
            'clave_numerica', 'tipo_permiso', 'vigencia', 'vigencia_fmt',
            'vigente', 'descripcion', 'cliente_numero', 'cliente_nombre',
        ]

    def get_vigente(self, obj):
        return obj.vigencia >= timezone.localdate()

    def get_vigencia_fmt(self, obj):
        return obj.vigencia.strftime('%d/%m/%Y')

    def get_cliente_nombre(self, obj):
        c = obj.cliente
        return f'{c.nombre} {c.primer_apell or ""}'.strip()


class ClienteSerializer(serializers.ModelSerializer):
    telefono           = serializers.SerializerMethodField()
    correo_electronico = serializers.SerializerMethodField()

    class Meta:
        model = Cliente
        fields = ['numero', 'nombre', 'primer_apell', 'seg_apell', 'tipo_persona', 'RFC',
                  'curp', 'domicilio', 'activo', 'telefono', 'correo_electronico']

    def get_telefono(self, obj):
        t = obj.telefonos.first()
        return t.numTelefono if t else ''

    def get_correo_electronico(self, obj):
        c = obj.correos.first()
        return c.correoElec if c else ''


class ClienteDetalleSerializer(serializers.ModelSerializer):
    permisos   = serializers.SerializerMethodField()
    telefonos  = serializers.SerializerMethodField()
    correos    = serializers.SerializerMethodField()
    pedimentos = serializers.SerializerMethodField()

    class Meta:
        model = Cliente
        fields = [
            'numero', 'nombre', 'primer_apell', 'seg_apell',
            'tipo_persona', 'RFC', 'curp', 'domicilio', 'activo',
            'permisos', 'telefonos', 'correos', 'pedimentos',
        ]

    def get_permisos(self, obj):
        hoy = timezone.localdate()
        return [
            {
                'clave':       p.clave_numerica,
                'tipo':        p.tipo_permiso,
                'vigencia':    p.vigencia.strftime('%d/%m/%Y'),
                'vigente':     p.vigencia >= hoy,
                'descripcion': p.descripcion or '',
            }
            for p in obj.permisos.all()
        ]

    def get_telefonos(self, obj):
        return [t.numTelefono for t in obj.telefonos.all()]

    def get_correos(self, obj):
        return [c.correoElec for c in obj.correos.all()]

    def get_pedimentos(self, obj):
        pedimentos = []
        for op in obj.operaciones.prefetch_related('pedimentos__semaforo', 'pedimentos__pagos').all():
            for p in op.pedimentos.all():
                pedimentos.append({
                    'numero':   p.numero_pedimento,
                    'fecha':    p.fecha_registro.strftime('%d/%m/%Y'),
                    'semaforo': p.semaforo.resultado if p.semaforo_id else 'Pendiente de pago',
                    'con_pago': p.pagos.exists(),
                })
        return pedimentos


class SemaforoFiscalSerializer(serializers.ModelSerializer):
    class Meta:
        model = SemaforoFiscal
        fields = ['ID', 'hora', 'resultado']


class RegimenAduaneroSerializer(serializers.ModelSerializer):
    class Meta:
        model = RegimenAduanero
        fields = ['num_regimen', 'clave_oficial', 'descripcion']


class TipoImportacionesSerializer(serializers.ModelSerializer):
    class Meta:
        model = TipoImportaciones
        fields = ['tipo_importacion', 'nombre', 'descripcion']


class TipoExportacionesSerializer(serializers.ModelSerializer):
    class Meta:
        model = TipoExportaciones
        fields = ['tipo_exportacion', 'nombre', 'descripcion']


class BitacoraSerializer(serializers.ModelSerializer):
    usuario_nombre = serializers.SerializerMethodField()

    class Meta:
        model = Bitacora
        fields = ['numero', 'descripcion', 'fecha', 'hora', 'modulo', 'tipo_accion', 'usuario_nombre']

    def get_usuario_nombre(self, obj):
        return obj.usuario.get_full_name() if obj.usuario else None


class TipoEmbalajeSerializer(serializers.ModelSerializer):
    class Meta:
        model = TipoEmbalaje
        fields = ['id', 'nombre', 'peso_maximo', 'descripcion']


class CategoriaProductosSerializer(serializers.ModelSerializer):
    tipo_arancel_nombre = serializers.CharField(source='tipo_arancel.nombre', read_only=True)
    fraccion_fmt = serializers.SerializerMethodField()
    embalajes_permitidos = serializers.SerializerMethodField()

    class Meta:
        model = CategoriaProductos
        fields = [
            'numero', 'nombre', 'descripcion', 'IGI',
            'tipo_arancel', 'tipo_arancel_nombre',
            'tipo_permiso_requerido',
            'fraccion_arancelaria', 'fraccion_fmt',
            'embalajes_permitidos',
        ]

    def get_fraccion_fmt(self, obj):
        f = obj.fraccion_arancelaria
        if not f or len(f) < 8:
            return f
        return f'{f[0:4]}.{f[4:6]}.{f[6:8]}.{f[8:10]}'

    def get_embalajes_permitidos(self, obj):
        return list(obj.embalajes.values_list('tipo_embalaje_id', flat=True))

class ProductoCategoriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Producto
        fields = ['codigo', 'nombre', 'descripcion', 'peso', 'valor_unitario']


class PedimentoSerializer(serializers.ModelSerializer):
    regimen_adu    = RegimenAduaneroSerializer(read_only=True)
    semaforo       = SemaforoFiscalSerializer(read_only=True)
    operacion_id   = serializers.IntegerField(source='ope_aduanera_id', read_only=True)
    cliente_rfc    = serializers.SerializerMethodField()
    cliente_nombre = serializers.SerializerMethodField()

    class Meta:
        model = Pedimento
        fields = [
            'numero_pedimento', 'clave_pedimento', 'fecha_registro',
            'valor_total', 'semaforo', 'regimen_adu',
            'permiso', 'ope_aduanera', 'operacion_id',
            'cliente_rfc', 'cliente_nombre',
            'tipo_exportacion', 'tipo_importacion',
            'medio_transporte', 'pais_origen_mercancia', 'pais_destino',
            'incoterm', 'tipo_cambio',
        ]

    def get_cliente_rfc(self, obj):
        op = obj.ope_aduanera
        return op.cliente.RFC if op and op.cliente_id else '—'

    def get_cliente_nombre(self, obj):
        op = obj.ope_aduanera
        if not op or not op.cliente_id:
            return '—'
        c = op.cliente
        return f'{c.nombre} {c.primer_apell or ""}'.strip()


def _calcular_paso(obj):
    from home.models import Pedimento, Pago
    if not Pedimento.objects.filter(ope_aduanera=obj).exists():
        return 1
    if not Pago.objects.filter(pedimento__ope_aduanera=obj).exists():
        return 2
    return 3


class OperacionListSerializer(serializers.ModelSerializer):
    cliente = ClienteSerializer(read_only=True)
    aduana = AduanaSerializer(read_only=True)
    paso = serializers.SerializerMethodField()
    estado_nombre = serializers.SerializerMethodField()

    class Meta:
        model = OperacionAduanera
        fields = [
            'ID_operacion', 'fecha_inicio', 'fecha_final',
            'tipo_operacion', 'cliente', 'aduana', 'paso', 'estado_nombre',
        ]

    def get_paso(self, obj):
        return _calcular_paso(obj)

    def get_estado_nombre(self, obj):
        return obj.estado_ope_aduanera.descripcion if obj.estado_ope_aduanera_id else '—'


class OperacionDetalleSerializer(serializers.ModelSerializer):
    cliente = ClienteSerializer(read_only=True)
    aduana = AduanaSerializer(read_only=True)
    paso = serializers.SerializerMethodField()
    estado_nombre = serializers.SerializerMethodField()
    pedimento = serializers.SerializerMethodField()

    class Meta:
        model = OperacionAduanera
        fields = [
            'ID_operacion', 'fecha_inicio', 'fecha_final',
            'tipo_operacion', 'cliente', 'aduana', 'paso', 'estado_nombre', 'pedimento',
        ]

    def get_paso(self, obj):
        return _calcular_paso(obj)

    def get_estado_nombre(self, obj):
        return obj.estado_ope_aduanera.descripcion if obj.estado_ope_aduanera_id else '—'

    def get_pedimento(self, obj):
        ped = (
            Pedimento.objects
            .filter(ope_aduanera=obj)
            .select_related('semaforo', 'regimen_adu')
            .first()
        )
        return PedimentoSerializer(ped).data if ped else None


class PagoSerializer(serializers.ModelSerializer):
    estado = serializers.SerializerMethodField()
    pedimento_num = serializers.SerializerMethodField()
    operacion_id = serializers.SerializerMethodField()
    cliente_nombre = serializers.SerializerMethodField()

    class Meta:
        model = Pago
        fields = [
            'no_transaccion', 'numero_pago', 'concepto',
            'monto', 'saldo_final', 'fecha_pago',
            'pedimento_num', 'operacion_id', 'cliente_nombre', 'estado',
        ]

    def get_estado(self, obj):
        return obj.estado_pago.concepto if obj.estado_pago_id else 'Sin estado'

    def get_pedimento_num(self, obj):
        return obj.pedimento_id or '—'

    def get_operacion_id(self, obj):
        if obj.pedimento_id and obj.pedimento.ope_aduanera_id:
            return obj.pedimento.ope_aduanera_id
        return None

    def get_cliente_nombre(self, obj):
        if obj.pedimento_id and obj.pedimento.ope_aduanera_id:
            c = obj.pedimento.ope_aduanera.cliente
            if c:
                return f'{c.nombre} {c.primer_apell or ""}'.strip()
        return '—'


class FacturaSerializer(serializers.ModelSerializer):
    operacion_id = serializers.IntegerField(source='ID_operacion_id', read_only=True)

    class Meta:
        model = Factura
        fields = [
            'codigo', 'folio_fiscal', 'fecha_factura',
            'subtotal', 'IVA', 'total', 'operacion_id',
        ]

class SancionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Sancion
        fields = [
            'num_sancion',
            'monto_multa',
            'fundamento_legal',
            'incidencia',
        ]


class ProductoSerializer(serializers.ModelSerializer):
    igi_importe = serializers.SerializerMethodField()

    class Meta:
        model = Producto
        fields = ['codigo', 'nombre', 'descripcion', 'peso', 'valor_unitario', 'cantidad', 'igi_importe']

    def get_igi_importe(self, obj):
        rel = obj.categorias_rel.select_related('categorias').first()
        if rel and rel.categorias.IGI:
            return float(obj.valor_unitario * rel.categorias.IGI / 100)
        return 0.0


class ProductoCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Producto
        fields = ['nombre', 'descripcion', 'peso', 'valor_unitario', 'cantidad', 'paquete']


class InspeccionSerializer(serializers.ModelSerializer):
    semaforo_resultado = serializers.SerializerMethodField()

    class Meta:
        model = Inspeccion
        fields = ['numero', 'fecha_inspeccion', 'hora_inicio', 'semaforo', 'semaforo_resultado', 'resultado']

    def get_semaforo_resultado(self, obj):
        return obj.semaforo.resultado if obj.semaforo_id else None


class PaqueteSerializer(serializers.ModelSerializer):
    numero = serializers.SerializerMethodField()
    cliente_nombre = serializers.SerializerMethodField()
    pedimento_num = serializers.SerializerMethodField()
    subtotal = serializers.SerializerMethodField()
    peso_ocupado = serializers.SerializerMethodField()
    peso_disponible = serializers.SerializerMethodField()
    peso_porcentaje = serializers.SerializerMethodField()
    productos = ProductoSerializer(many=True, read_only=True)
    inspeccion = InspeccionSerializer(read_only=True)
    tipo_embalaje = TipoEmbalajeSerializer(read_only=True)

    class Meta:
        model = Paquete
        fields = [
            'codigo', 'numero', 'peso', 'tipo_embalaje', 'dimensions',
            'cliente', 'cliente_nombre', 'pedimento_num', 'subtotal',
            'peso_ocupado', 'peso_disponible', 'peso_porcentaje',
            'inspeccion', 'productos',
        ]

    def get_numero(self, obj):
        return f'PQ-{obj.codigo:05d}'

    def get_cliente_nombre(self, obj):
        c = obj.cliente
        return f'{c.nombre} {c.primer_apell or ""}'.strip()

    def get_pedimento_num(self, obj):
        return obj.pedimento_id or '—'

    def get_subtotal(self, obj):
        total = obj.productos.aggregate(total=Sum('valor_unitario'))['total']
        return float(total) if total else 0.0

    def _calc_peso_ocupado(self, obj):
        # usa el prefetch cache de productos — sin query extra
        return sum(float(p.peso) * p.cantidad for p in obj.productos.all())

    def get_peso_ocupado(self, obj):
        return round(self._calc_peso_ocupado(obj), 2)

    def get_peso_disponible(self, obj):
        peso_max = float(obj.tipo_embalaje.peso_maximo) if obj.tipo_embalaje else 0.0
        return round(peso_max - self._calc_peso_ocupado(obj), 2)

    def get_peso_porcentaje(self, obj):
        peso_max = float(obj.tipo_embalaje.peso_maximo) if obj.tipo_embalaje else 0.0
        if peso_max == 0:
            return 0
        return min(round((self._calc_peso_ocupado(obj) / peso_max) * 100, 1), 100)


class PaqueteCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Paquete
        fields = ['tipo_embalaje', 'peso', 'dimensions', 'cliente', 'inspeccion']
        extra_kwargs = {
            'inspeccion':    {'required': False, 'allow_null': True},
            'tipo_embalaje': {'required': True},
        }