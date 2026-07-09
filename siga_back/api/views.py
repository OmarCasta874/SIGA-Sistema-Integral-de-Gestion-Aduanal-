import datetime
from datetime import date, datetime
import random

from django.contrib.auth import authenticate
from django.shortcuts import get_object_or_404

from rest_framework import viewsets, status
from rest_framework.authentication import TokenAuthentication
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.authtoken.models import Token

from home.models import (
    Usuario, Cliente, Aduana, OperacionAduanera, Pedimento,
    Permiso, Bitacora, CategoriaProductos, CategoriasProductosRel,
    RegimenAduanero, SemaforoFiscal, TipoImportaciones, TipoExportaciones,
    Paquete, Producto, EstadoPago, Pago, Factura, Sancion,
    EstadoOpeAduanera,
)
from .serializers import (
    UsuarioSerializer,
    ClienteSerializer, ClienteDetalleSerializer,
    AduanaSerializer,
    OperacionListSerializer, OperacionDetalleSerializer,
    PedimentoSerializer,
    BitacoraSerializer, CategoriaProductosSerializer,
    RegimenAduaneroSerializer,
    TipoImportacionesSerializer, TipoExportacionesSerializer,
    PagoSerializer, FacturaSerializer,
    PermisoListSerializer, SancionSerializer,
    PaqueteSerializer, PaqueteCreateSerializer, ProductoCreateSerializer,
    ProductoCategoriaSerializer, SemaforoFiscalSerializer,
)


# ── Helpers ────────────────────────────────────────────────────────────────────

def _estado_operacion(op):
    if not Pedimento.objects.filter(ope_aduanera=op).exists():
        return 1
    if not EstadoPago.objects.filter(pago__isnull=False).exists():
        return 2
    return 3


def _generar_semaforo():
    resultado = random.choices(
        ['Verde - Desaduanamiento libre', 'Rojo - Reconocimiento aduanero'],
        weights=[70, 30],
        k=1,
    )[0]
    return SemaforoFiscal.objects.create(hora=datetime.now().time(), resultado=resultado)


def _parse_date(value):
    if isinstance(value, datetime):
        return value.date()
    if isinstance(value, date):
        return value
    if isinstance(value, str):
        return date.fromisoformat(value[:10])
    raise ValueError(f'No se puede convertir a fecha: {value!r}')


def _generar_folio_permiso(autoridad):
    anio    = date.today().year
    prefijo = f'PERM-{autoridad}-{anio}-'
    claves  = Permiso.objects.filter(tipo_permiso=autoridad).values_list('clave_numerica', flat=True)
    max_num = 0
    for clave in claves:
        if clave.startswith(prefijo):
            try:
                max_num = max(max_num, int(clave[len(prefijo):]))
            except (ValueError, IndexError):
                pass
    return f'{prefijo}{str(max_num + 1).zfill(3)}'


def _generar_numero_pedimento(codigo_aduana):
    hoy           = date.today()
    anio_2d       = str(hoy.year)[-2:]
    ultimo_digito = str(hoy.year)[-1:]
    patente       = '3991'
    cod           = str(codigo_aduana).zfill(2)
    consecutivo   = str(Pedimento.objects.count() + 1).zfill(6)
    return f'{anio_2d} {cod} {patente} {ultimo_digito} {consecutivo}'


# ── Auth ───────────────────────────────────────────────────────────────────────

class AuthLoginView(APIView):
    permission_classes     = [AllowAny]
    authentication_classes = []

    def post(self, request):
        correo    = request.data.get('correo', '')
        contrasena = request.data.get('contrasena', '')
        user = authenticate(request, username=correo, password=contrasena)
        if user is None:
            return Response(
                {'error': 'Correo o contraseña incorrectos.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        token, _ = Token.objects.get_or_create(user=user)
        return Response({
            'token':   token.key,
            'usuario': UsuarioSerializer(user).data,
        })


class AuthLogoutView(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]

    def post(self, request):
        request.user.auth_token.delete()
        return Response({'ok': True})


class AuthMeView(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]

    def get(self, request):
        return Response(UsuarioSerializer(request.user).data)


# ── Clientes ───────────────────────────────────────────────────────────────────

class ClienteViewSet(viewsets.ModelViewSet):
    queryset               = Cliente.objects.all()
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return ClienteDetalleSerializer
        return ClienteSerializer

    @action(detail=True, methods=['get', 'post'], url_path='permisos')
    def permisos(self, request, pk=None):
        cliente = self.get_object()

        if request.method == 'GET':
            hoy  = date.today()
            data = []
            for p in cliente.permisos.all():
                vig = _parse_date(p.vigencia)
                data.append({
                    'clave':       p.clave_numerica,
                    'tipo':        p.tipo_permiso,
                    'vigencia':    vig.strftime('%d/%m/%Y'),
                    'vigente':     vig >= hoy,
                    'descripcion': p.descripcion or '',
                })
            return Response(data)

        # ── POST: registrar nuevo permiso ──────────────────────────────────
        autoridad   = request.data.get('tipo_permiso', '').strip()
        vigencia_raw = request.data.get('vigencia', '').strip()
        descripcion  = request.data.get('descripcion', '').strip()

        if not autoridad:
            return Response({'error': 'El tipo de permiso es obligatorio.'}, status=status.HTTP_400_BAD_REQUEST)

        if not vigencia_raw:
            return Response({'error': 'La fecha de vigencia es obligatoria.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            vigencia_date = _parse_date(vigencia_raw)
        except (ValueError, TypeError):
            return Response({'error': 'Fecha de vigencia inválida. Use el formato YYYY-MM-DD.'}, status=status.HTTP_400_BAD_REQUEST)

        existente = Permiso.objects.filter(cliente=cliente, tipo_permiso=autoridad).first()
        if existente:
            existente.vigencia    = vigencia_date
            existente.descripcion = descripcion
            existente.save(update_fields=['vigencia', 'descripcion'])
            hoy = date.today()
            return Response(
                {
                    'clave':       existente.clave_numerica,
                    'tipo':        existente.tipo_permiso,
                    'vigencia':    vigencia_date.strftime('%d/%m/%Y'),
                    'vigente':     vigencia_date >= hoy,
                    'descripcion': existente.descripcion or '',
                    'folio':       existente.clave_numerica,
                    'renovado':    True,
                },
                status=status.HTTP_200_OK,
            )

        folio   = _generar_folio_permiso(autoridad)
        Permiso.objects.create(
            clave_numerica=folio,
            tipo_permiso=autoridad,
            vigencia=vigencia_date,
            descripcion=descripcion,
            cliente=cliente,
        )
        hoy = date.today()
        return Response(
            {
                'clave':       folio,
                'tipo':        autoridad,
                'vigencia':    vigencia_date.strftime('%d/%m/%Y'),
                'vigente':     vigencia_date >= hoy,
                'descripcion': descripcion,
                'folio':       folio,
                'renovado':    False,
            },
            status=status.HTTP_201_CREATED,
        )


class PermisoDeleteView(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]

    def delete(self, request, pk, clave):
        cliente = get_object_or_404(Cliente, numero=pk)
        permiso = get_object_or_404(Permiso, clave_numerica=clave, cliente=cliente)
        permiso.delete()
        return Response({'ok': True}, status=status.HTTP_204_NO_CONTENT)

    def post(self, request, pk, clave):
        return self.delete(request, pk, clave)


# ── Aduanas ────────────────────────────────────────────────────────────────────

class AduanaViewSet(viewsets.ReadOnlyModelViewSet):
    queryset               = Aduana.objects.all()
    serializer_class       = AduanaSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]


# ── Operaciones ────────────────────────────────────────────────────────────────

class OperacionViewSet(viewsets.ModelViewSet):
    queryset               = OperacionAduanera.objects.select_related('cliente', 'aduana').order_by('-ID_operacion')
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return OperacionDetalleSerializer
        return OperacionListSerializer

    def create(self, request, *args, **kwargs):
        tipo_operacion = request.data.get('tipo_operacion', '')
        cliente_id     = request.data.get('cliente')
        aduana_id      = request.data.get('aduana')

        cliente = get_object_or_404(Cliente, numero=cliente_id)
        aduana  = get_object_or_404(Aduana, codigo=aduana_id)
        estado  = get_object_or_404(EstadoOpeAduanera, codigo=1)  # "En proceso"

        bitacora = Bitacora.objects.create(
            descripcion=f'Apertura de operación aduanera | Tipo: {tipo_operacion} | Cliente: {cliente}',
            fecha=date.today(),
            hora=datetime.now().time(),
        )
        op = OperacionAduanera.objects.create(
            tipo_operacion=tipo_operacion,
            cliente=cliente,
            aduana=aduana,
            usuario=request.user,
            bitacora=bitacora,
            fecha_inicio=date.today(),
            estado_ope_aduanera=estado,
        )
        return Response(
            OperacionDetalleSerializer(op).data,
            status=status.HTTP_201_CREATED,
        )

    @action(detail=True, methods=['get', 'post'], url_path='pedimento')
    def pedimento(self, request, pk=None):
        op = self.get_object()

        if request.method == 'GET':
            ped = (
                Pedimento.objects
                .filter(ope_aduanera=op)
                .select_related('semaforo', 'regimen_adu')
                .first()
            )
            return Response(PedimentoSerializer(ped).data if ped else None)

        if Pedimento.objects.filter(ope_aduanera=op).exists():
            return Response(
                {'error': 'Esta operación ya tiene un pedimento.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        semaforo         = _generar_semaforo()
        numero_pedimento = _generar_numero_pedimento(op.aduana_id)

        paquetes    = Paquete.objects.filter(cliente=op.cliente)
        valor_total = sum(
            float(prod.valor_unitario)
            for paq in paquetes
            for prod in Producto.objects.filter(paquete=paq)
        )

        clave_pedimento    = request.data.get('clave_pedimento', '')
        regimen_adu_id     = request.data.get('regimen_adu')
        permiso_clave      = request.data.get('permiso')
        tipo_importacion_id = request.data.get('tipo_importacion')
        tipo_exportacion_id = request.data.get('tipo_exportacion')

        regimen   = get_object_or_404(RegimenAduanero, num_regimen=regimen_adu_id) if regimen_adu_id else None
        permiso   = get_object_or_404(Permiso, clave_numerica=permiso_clave) if permiso_clave else None
        tipo_imp  = TipoImportaciones.objects.filter(tipo_importacion=tipo_importacion_id).first()
        tipo_exp  = TipoExportaciones.objects.filter(tipo_exportacion=tipo_exportacion_id).first()

        ped = Pedimento.objects.create(
            numero_pedimento=numero_pedimento,
            clave_pedimento=clave_pedimento,
            fecha_registro=date.today(),
            valor_total=valor_total,
            semaforo=semaforo,
            regimen_adu=regimen,
            permiso=permiso,
            ope_aduanera=op,
            tipo_importacion=tipo_imp,
            tipo_exportacion=tipo_exp,
        )
        return Response(
            {
                'numero_pedimento':  ped.numero_pedimento,
                'semaforo_resultado': semaforo.resultado,
                'valor_total':       float(ped.valor_total),
            },
            status=status.HTTP_201_CREATED,
        )


# ── Pedimentos ─────────────────────────────────────────────────────────────────

class PedimentoViewSet(viewsets.ReadOnlyModelViewSet):
    queryset               = Pedimento.objects.select_related('regimen_adu', 'semaforo', 'ope_aduanera').all()
    serializer_class       = PedimentoSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]


# ── Catálogos (read-only) ──────────────────────────────────────────────────────

class BitacoraViewSet(viewsets.ReadOnlyModelViewSet):
    queryset               = Bitacora.objects.all().order_by('-fecha', '-hora')
    serializer_class       = BitacoraSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]


class CategoriaViewSet(viewsets.ReadOnlyModelViewSet):
    queryset               = CategoriaProductos.objects.all().order_by('numero')
    serializer_class       = CategoriaProductosSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]

    @action(detail=True, methods=['get'], url_path='productos')
    def productos(self, request, pk=None):
        categoria = self.get_object()
        rels = (CategoriasProductosRel.objects
                .filter(categorias=categoria)
                .select_related('productos')
                .order_by('productos__codigo'))
        seen, unique = set(), []
        for rel in rels:
            p = rel.productos
            if p.nombre not in seen:
                seen.add(p.nombre)
                unique.append(p)
        return Response(ProductoCategoriaSerializer(unique, many=True).data)


class RegimenViewSet(viewsets.ReadOnlyModelViewSet):
    queryset               = RegimenAduanero.objects.all()
    serializer_class       = RegimenAduaneroSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]


class TipoImportacionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset               = TipoImportaciones.objects.all()
    serializer_class       = TipoImportacionesSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]


class TipoExportacionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset               = TipoExportaciones.objects.all()
    serializer_class       = TipoExportacionesSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]


class UsuarioViewSet(viewsets.ReadOnlyModelViewSet):
    queryset               = Usuario.objects.all()
    serializer_class       = UsuarioSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]


class PermisoViewSet(viewsets.ReadOnlyModelViewSet):
    queryset               = Permiso.objects.select_related('cliente').order_by('tipo_permiso', 'clave_numerica')
    serializer_class       = PermisoListSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]
    lookup_field           = 'clave_numerica'


# ── Pagos ──────────────────────────────────────────────────────────────────────

class PagoViewSet(viewsets.ReadOnlyModelViewSet):
    queryset               = Pago.objects.select_related('estado_pago').order_by('-fecha_pago')
    serializer_class       = PagoSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]


# ── Facturas ───────────────────────────────────────────────────────────────────

class FacturaViewSet(viewsets.ReadOnlyModelViewSet):
    queryset               = Factura.objects.select_related('ID_operacion').order_by('-fecha_factura')
    serializer_class       = FacturaSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]

# -- Dashboard ------------------------------------------------------------------
class DashboardAPIView(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        pedimentos_recientes = Pedimento.objects.select_related(
                "ope_aduanera__cliente",
                "regimen_adu",
                "semaforo",
            ).order_by("-fecha_registro")[:5]
    
        pedimentos = []
        
        for p in pedimentos_recientes:
            pedimentos.append({
                "numero": p.numero_pedimento,
                "cliente": str(p.ope_aduanera.cliente),
                "regimen": str(p.regimen_adu),
                "estado": p.ope_aduanera.tipo_operacion,
                "semaforo": p.semaforo.resultado,
            })
            
        bitacora_reciente = Bitacora.objects.order_by("-fecha", "-hora")[:5]
        bitacora = BitacoraSerializer(bitacora_reciente, many=True).data
            
        data = {
            "total_pedimentos": Pedimento.objects.count(),
            "total_pagos": Pago.objects.count(),
            "total_clientes": Cliente.objects.count(),
            "total_operaciones": OperacionAduanera.objects.count(),
            "total_aduanas": Aduana.objects.count(),
            "pedimentos": pedimentos,
            "bitacora": bitacora,
        }
        
        return Response(data)
    
# -- Sanción --------------------------------------------------------------------
class SancionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Sancion.objects.select_related(
        'incidencia'
    ).order_by('-num_sancion')

    serializer_class = SancionSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]


class PaqueteViewSet(viewsets.ModelViewSet):
    queryset               = Paquete.objects.select_related('cliente', 'pedimento').prefetch_related('productos').order_by('codigo')
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]

    def get_serializer_class(self):
        if self.action in ('create', 'update', 'partial_update'):
            return PaqueteCreateSerializer
        return PaqueteSerializer

    @action(detail=True, methods=['post'], url_path='productos')
    def agregar_producto(self, request, pk=None):
        paquete = self.get_object()
        data    = {**request.data, 'paquete': paquete.codigo}
        ser     = ProductoCreateSerializer(data=data)
        if ser.is_valid():
            producto     = ser.save()
            categoria_id = request.data.get('categoria')
            if categoria_id:
                try:
                    cat = CategoriaProductos.objects.get(pk=categoria_id)
                    CategoriasProductosRel.objects.create(categorias=cat, productos=producto)
                except CategoriaProductos.DoesNotExist:
                    pass
            return Response(ser.data, status=status.HTTP_201_CREATED)
        return Response(ser.errors, status=status.HTTP_400_BAD_REQUEST)


class SemaforoFiscalViewSet(viewsets.ModelViewSet):
    queryset               = SemaforoFiscal.objects.all().order_by('ID')
    serializer_class       = SemaforoFiscalSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes     = [IsAuthenticated]
