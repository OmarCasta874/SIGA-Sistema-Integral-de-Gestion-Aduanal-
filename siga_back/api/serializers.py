from rest_framework import serializers
from datetime import date
from django.db.models import Sum

from home.models import (
    Usuario, Cliente, Aduana, OperacionAduanera, Pedimento,
    Permiso, Bitacora, CategoriaProductos,
    RegimenAduanero, SemaforoFiscal, TipoImportaciones, TipoExportaciones,
    Pago, Factura, Sancion, Paquete, Producto, EstadoPago, Inspeccion,
)



class UsuarioSerializer(serializers.ModelSerializer):
    nombre_completo = serializers.SerializerMethodField()

    class Meta:
        model = Usuario
        fields = [
            'ID_usuario', 'nombre_usuario', 'nombre_pila',
            'primer_apell', 'seg_apell', 'correo', 'fecha_alta',
            'nombre_completo',
        ]

    def get_nombre_completo(self, obj):
        return obj.get_full_name()


class AduanaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Aduana
        fields = ['codigo', 'ciudad', 'nombre']


class PermisoResumenSerializer(serializers.ModelSerializer):
    vigente = serializers.SerializerMethodField()
    clave   = serializers.CharField(source='clave_numerica')
    tipo    = serializers.CharField(source='tipo_permiso')
    vigencia_fmt = serializers.SerializerMethodField()

    class Meta:
        model = Permiso
        fields = ['clave', 'tipo', 'vigencia', 'vigencia_fmt', 'vigente', 'descripcion']

    def get_vigente(self, obj):
        return obj.vigencia >= date.today()

    def get_vigencia_fmt(self, obj):
        return obj.vigencia.strftime('%d/%m/%Y')


class PermisoListSerializer(serializers.ModelSerializer):
    vigente        = serializers.SerializerMethodField()
    vigencia_fmt   = serializers.SerializerMethodField()
    cliente_nombre = serializers.SerializerMethodField()
    cliente_numero = serializers.IntegerField(source='cliente_id', read_only=True)

    class Meta:
        model  = Permiso
        fields = [
            'clave_numerica', 'tipo_permiso', 'vigencia', 'vigencia_fmt',
            'vigente', 'descripcion', 'cliente_numero', 'cliente_nombre',
        ]

    def get_vigente(self, obj):
        return obj.vigencia >= date.today()

    def get_vigencia_fmt(self, obj):
        return obj.vigencia.strftime('%d/%m/%Y')

    def get_cliente_nombre(self, obj):
        c = obj.cliente
        return f'{c.nombre} {c.primer_apell or ""}'.strip()


class ClienteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cliente
        fields = ['numero', 'nombre', 'primer_apell', 'seg_apell', 'tipo_persona', 'RFC']


class ClienteDetalleSerializer(serializers.ModelSerializer):
    permisos = serializers.SerializerMethodField()

    class Meta:
        model = Cliente
        fields = ['numero', 'nombre', 'primer_apell', 'seg_apell', 'tipo_persona', 'RFC', 'permisos']

    def get_permisos(self, obj):
        hoy = date.today()
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
    class Meta:
        model = Bitacora
        fields = ['numero', 'descripcion', 'fecha', 'hora']


class CategoriaProductosSerializer(serializers.ModelSerializer):
    tipo_arancel_nombre = serializers.CharField(source='tipo_arancel.nombre', read_only=True)

    class Meta:
        model = CategoriaProductos
        fields = ['numero', 'nombre', 'descripcion', 'IGI', 'tipo_arancel', 'tipo_arancel_nombre', 'tipo_permiso_requerido']

class ProductoCategoriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Producto
        fields = ['codigo', 'nombre', 'descripcion', 'peso', 'valor_unitario']


class PedimentoSerializer(serializers.ModelSerializer):
    regimen_adu = RegimenAduaneroSerializer(read_only=True)
    semaforo    = SemaforoFiscalSerializer(read_only=True)

    class Meta:
        model = Pedimento
        fields = [
            'numero_pedimento', 'clave_pedimento', 'fecha_registro',
            'valor_total', 'semaforo', 'regimen_adu',
            'permiso', 'ope_aduanera', 'tipo_exportacion', 'tipo_importacion',
        ]


class OperacionListSerializer(serializers.ModelSerializer):
    cliente = ClienteSerializer(read_only=True)
    aduana  = AduanaSerializer(read_only=True)
    paso    = serializers.SerializerMethodField()

    class Meta:
        model = OperacionAduanera
        fields = [
            'ID_operacion', 'fecha_inicio', 'fecha_final',
            'tipo_operacion', 'cliente', 'aduana', 'paso',
        ]

    def get_paso(self, obj):
        from home.models import Pedimento, Pago
        if not Pedimento.objects.filter(ope_aduanera=obj).exists():
            return 1
        if not Pago.objects.filter(pedimento__ope_aduanera=obj).exists():
            return 2
        return 3


class OperacionDetalleSerializer(serializers.ModelSerializer):
    cliente   = ClienteSerializer(read_only=True)
    aduana    = AduanaSerializer(read_only=True)
    paso      = serializers.SerializerMethodField()
    pedimento = serializers.SerializerMethodField()

    class Meta:
        model = OperacionAduanera
        fields = [
            'ID_operacion', 'fecha_inicio', 'fecha_final',
            'tipo_operacion', 'cliente', 'aduana', 'paso', 'pedimento',
        ]

    def get_paso(self, obj):
        from home.models import Pedimento, Pago
        if not Pedimento.objects.filter(ope_aduanera=obj).exists():
            return 1
        if not Pago.objects.filter(pedimento__ope_aduanera=obj).exists():
            return 2
        return 3

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

    class Meta:
        model = Pago
        fields = [
            'no_transaccion', 'numero_pago', 'concepto',
            'monto', 'saldo_final', 'fecha_pago',
            'pedimento_num', 'estado',
        ]

    def get_estado(self, obj):
        return obj.estado_pago.concepto if obj.estado_pago_id else 'Sin estado'

    def get_pedimento_num(self, obj):
        return obj.pedimento_id or '—'


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
    class Meta:
        model = Producto
        fields = ['codigo', 'nombre', 'descripcion', 'peso', 'valor_unitario', 'cantidad']


class ProductoCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Producto
        fields = ['nombre', 'descripcion', 'peso', 'valor_unitario', 'cantidad', 'paquete']


class PaqueteSerializer(serializers.ModelSerializer):
    numero         = serializers.SerializerMethodField()
    cliente_nombre = serializers.SerializerMethodField()
    pedimento_num  = serializers.SerializerMethodField()
    subtotal       = serializers.SerializerMethodField()
    productos      = ProductoSerializer(many=True, read_only=True)

    class Meta:
        model = Paquete
        fields = [
            'codigo', 'numero', 'peso', 'tipo_embalaje', 'dimensions',
            'cliente', 'cliente_nombre', 'pedimento_num', 'subtotal',
            'productos',
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


class PaqueteCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Paquete
        fields = ['tipo_embalaje', 'peso', 'dimensions', 'cliente']
        
        
class InspeccionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Inspeccion
        fields = ['numero', 'fecha_inspeccion', 'hora_inicio', 'semaforo', 'resultado']