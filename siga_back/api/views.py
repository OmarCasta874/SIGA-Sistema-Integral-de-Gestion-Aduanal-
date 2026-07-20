import datetime
from datetime import date, datetime, timedelta
import random

from django.contrib.auth import authenticate
from django.shortcuts import get_object_or_404
from django.utils import timezone

from django.db import models
from rest_framework import viewsets, status
from rest_framework.authentication import TokenAuthentication
from rest_framework.decorators import action, api_view, authentication_classes, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.authtoken.models import Token

from home.models import (
    Usuario, Cliente, Aduana, OperacionAduanera, Pedimento,
    Permiso, Bitacora, CategoriaProductos, CategoriasProductosRel,
    RegimenAduanero, SemaforoFiscal, TipoImportaciones, TipoExportaciones,
    Paquete, Producto, Pago, Factura, Sancion,
    EstadoOpeAduanera, EstadoPago, Inspeccion, TipoEmbalaje,
    Telefono, CorreoElectronico,
)
from .serializers import (
    UsuarioSerializer, UsuarioCreateSerializer, UsuarioUpdateSerializer,
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
    ProductoCategoriaSerializer, SemaforoFiscalSerializer, InspeccionSerializer,
    TipoEmbalajeSerializer,
)


# ── Helpers ────────────────────────────────────────────────────────────────────

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
    anio = timezone.localdate().year
    prefijo = f'PERM-{autoridad}-{anio}-'
    claves = Permiso.objects.filter(tipo_permiso=autoridad).values_list('clave_numerica', flat=True)
    max_num = 0
    for clave in claves:
        if clave.startswith(prefijo):
            try:
                max_num = max(max_num, int(clave[len(prefijo):]))
            except (ValueError, IndexError):
                pass
    return f'{prefijo}{str(max_num + 1).zfill(3)}'


def _generar_numero_pedimento(codigo_aduana):
    hoy = timezone.localdate()
    anio_2d = str(hoy.year)[-2:]
    ultimo_digito = str(hoy.year)[-1:]
    patente = '3991'
    cod = str(codigo_aduana).zfill(2)
    consecutivo = str(Pedimento.objects.count() + 1).zfill(6)
    return f'{anio_2d} {cod} {patente} {ultimo_digito} {consecutivo}'


# ── Auth ───────────────────────────────────────────────────────────────────────

def _registrar_bitacora(usuario, modulo, tipo_accion, descripcion):
    Bitacora.objects.create(
        descripcion=descripcion,
        fecha=timezone.localdate(),
        hora=datetime.now().time(),
        usuario=usuario,
        modulo=modulo,
        tipo_accion=tipo_accion,
    )


class AuthLoginView(APIView):
    permission_classes = [AllowAny]
    authentication_classes = []

    def post(self, request):
        correo = request.data.get('correo', '')
        contrasena = request.data.get('contrasena', '')
        user = authenticate(request, username=correo, password=contrasena)
        if user is None:
            return Response(
                {'error': 'Correo o contraseña incorrectos.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        if not user.activo:
            return Response(
                {'error': 'Tu cuenta está desactivada. Contacta al administrador.'},
                status=status.HTTP_403_FORBIDDEN,
            )
        Token.objects.filter(user=user).delete()
        token = Token.objects.create(user=user)
        _registrar_bitacora(
            usuario=user,
            modulo='Login',
            tipo_accion='Login',
            descripcion=f'Inicio de sesión: {user.get_full_name()} ({user.correo})',
        )
        return Response({
            'token':   token.key,
            'usuario': UsuarioSerializer(user).data,
        })


class AuthLogoutView(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request):
        request.user.auth_token.delete()
        return Response({'ok': True})


class AuthMeView(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(UsuarioSerializer(request.user).data)


# ── Clientes ───────────────────────────────────────────────────────────────────

class ClienteViewSet(viewsets.ModelViewSet):
    queryset = Cliente.objects.prefetch_related('telefonos', 'correos').order_by('-numero')
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return ClienteDetalleSerializer
        return ClienteSerializer

    def create(self, request, *args, **kwargs):
        telefono = request.data.get('telefono', '').strip()
        correo   = request.data.get('correo_electronico', '').strip()
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        cliente = serializer.save()
        if telefono:
            Telefono.objects.create(numTelefono=telefono, cliente=cliente)
        if correo:
            CorreoElectronico.objects.create(
                correoElec=correo, cliente=cliente, usuario=request.user
            )
        _registrar_bitacora(
            usuario=request.user, modulo='Clientes', tipo_accion='Creación',
            descripcion=f'Cliente creado: {cliente}',
        )
        return Response(self.get_serializer(cliente).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['post'], url_path='contacto')
    def contacto(self, request, pk=None):
        cliente  = self.get_object()
        telefono = request.data.get('telefono', '').strip()
        correo   = request.data.get('correo_electronico', '').strip()

        if telefono:
            tel = cliente.telefonos.first()
            if tel:
                tel.numTelefono = telefono
                tel.save()
            else:
                Telefono.objects.create(numTelefono=telefono, cliente=cliente)

        if correo:
            cor = cliente.correos.first()
            if cor:
                cor.correoElec = correo
                cor.save()
            else:
                CorreoElectronico.objects.create(
                    correoElec=correo, cliente=cliente, usuario=request.user
                )

        _registrar_bitacora(
            usuario=request.user, modulo='Clientes', tipo_accion='Edición',
            descripcion=f'Contacto actualizado: {cliente}',
        )
        return Response({'ok': True})

    @action(detail=True, methods=['post'], url_path='toggle-activo')
    def toggle_activo(self, request, pk=None):
        cliente = self.get_object()
        cliente.activo = not cliente.activo
        cliente.save()
        estado = 'activado' if cliente.activo else 'desactivado'
        _registrar_bitacora(
            usuario=request.user,
            modulo='Clientes',
            tipo_accion='Edición',
            descripcion=f'Cliente {estado}: {cliente}',
        )
        return Response({'activo': cliente.activo})

    @action(detail=True, methods=['get', 'post'], url_path='permisos')
    def permisos(self, request, pk=None):
        cliente = self.get_object()

        if request.method == 'GET':
            hoy = timezone.localdate()
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
        autoridad = request.data.get('tipo_permiso', '').strip()
        vigencia_raw = request.data.get('vigencia', '').strip()
        descripcion = request.data.get('descripcion', '').strip()

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
            existente.vigencia = vigencia_date
            existente.descripcion = descripcion
            existente.save(update_fields=['vigencia', 'descripcion'])
            hoy = timezone.localdate()
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

        folio = _generar_folio_permiso(autoridad)
        Permiso.objects.create(
            clave_numerica=folio,
            tipo_permiso=autoridad,
            vigencia=vigencia_date,
            descripcion=descripcion,
            cliente=cliente,
        )
        hoy = timezone.localdate()
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
    permission_classes = [IsAuthenticated]

    def delete(self, request, pk, clave):
        cliente = get_object_or_404(Cliente, numero=pk)
        permiso = get_object_or_404(Permiso, clave_numerica=clave, cliente=cliente)
        permiso.delete()
        return Response({'ok': True}, status=status.HTTP_204_NO_CONTENT)

    def post(self, request, pk, clave):
        return self.delete(request, pk, clave)


# ── Aduanas ────────────────────────────────────────────────────────────────────

class AduanaViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Aduana.objects.all().order_by('-codigo')
    serializer_class = AduanaSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]


# ── Operaciones ────────────────────────────────────────────────────────────────

class OperacionViewSet(viewsets.ModelViewSet):
    queryset = OperacionAduanera.objects.select_related('cliente', 'aduana', 'estado_ope_aduanera').order_by('-ID_operacion')
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return OperacionDetalleSerializer
        return OperacionListSerializer

    def create(self, request, *args, **kwargs):
        tipo_operacion = request.data.get('tipo_operacion', '')
        cliente_id = request.data.get('cliente')
        aduana_id = request.data.get('aduana')

        cliente = get_object_or_404(Cliente, numero=cliente_id)
        aduana = get_object_or_404(Aduana, codigo=aduana_id)
        estado = get_object_or_404(EstadoOpeAduanera, codigo=1)  # "En proceso"

        if not Paquete.objects.filter(cliente=cliente).exists():
            return Response(
                {'error': f'El cliente {cliente} no tiene paquetes registrados. Registra al menos un paquete antes de crear una operación.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        bitacora = Bitacora.objects.create(
            descripcion=f'Apertura de operación aduanera | Tipo: {tipo_operacion} | Cliente: {cliente}',
            fecha=timezone.localdate(),
            hora=datetime.now().time(),
            usuario=request.user,
            modulo='Operaciones',
            tipo_accion='Creación',
        )
        op = OperacionAduanera.objects.create(
            tipo_operacion=tipo_operacion,
            cliente=cliente,
            aduana=aduana,
            usuario=request.user,
            bitacora=bitacora,
            fecha_inicio=timezone.localdate(),
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

        clave_pedimento    = request.data.get('clave_pedimento', '')
        regimen_adu_id     = request.data.get('regimen_adu')
        permiso_clave      = request.data.get('permiso')
        medio_transporte   = request.data.get('medio_transporte') or None
        pais_origen        = request.data.get('pais_origen_mercancia') or None
        pais_destino       = request.data.get('pais_destino') or None
        incoterm           = request.data.get('incoterm') or None
        tipo_cambio        = request.data.get('tipo_cambio') or None

        if not regimen_adu_id:
            return Response({'error': 'El régimen aduanero es obligatorio.'}, status=status.HTTP_400_BAD_REQUEST)
        if not permiso_clave:
            return Response({'error': 'El permiso es obligatorio.'}, status=status.HTTP_400_BAD_REQUEST)

        regimen = get_object_or_404(RegimenAduanero, num_regimen=regimen_adu_id)
        permiso = get_object_or_404(Permiso, clave_numerica=permiso_clave)

        numero_pedimento = _generar_numero_pedimento(op.aduana_id)

        valor_total = (
            Producto.objects
            .filter(paquete__cliente=op.cliente)
            .aggregate(total=models.Sum('valor_unitario'))['total'] or 0
        )

        ped = Pedimento.objects.create(
            numero_pedimento=numero_pedimento,
            clave_pedimento=clave_pedimento,
            fecha_registro=timezone.localdate(),
            valor_total=valor_total,
            regimen_adu=regimen,
            permiso=permiso,
            ope_aduanera=op,
            medio_transporte=medio_transporte,
            pais_origen_mercancia=pais_origen,
            pais_destino=pais_destino,
            incoterm=incoterm,
            tipo_cambio=tipo_cambio,
        )

        # RF31: actualizar estado de operación a "Pendiente de pago"
        estado_pendiente = get_object_or_404(EstadoOpeAduanera, codigo=4)
        op.estado_ope_aduanera = estado_pendiente
        op.save(update_fields=['estado_ope_aduanera'])

        return Response(
            {
                'numero_pedimento': ped.numero_pedimento,
                'valor_total':      float(ped.valor_total),
            },
            status=status.HTTP_201_CREATED,
        )


# ── Pedimentos ─────────────────────────────────────────────────────────────────

class PedimentoViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Pedimento.objects.select_related('regimen_adu', 'semaforo', 'ope_aduanera').order_by('-fecha_registro')
    serializer_class = PedimentoSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]


# ── Catálogos (read-only) ──────────────────────────────────────────────────────

class BitacoraViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Bitacora.objects.all().order_by('-fecha', '-hora')
    serializer_class = BitacoraSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]


class CategoriaViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = CategoriaProductos.objects.all().order_by('-numero')
    serializer_class = CategoriaProductosSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

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
    queryset = RegimenAduanero.objects.all()
    serializer_class = RegimenAduaneroSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]


class TipoImportacionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = TipoImportaciones.objects.all()
    serializer_class = TipoImportacionesSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]


class TipoExportacionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = TipoExportaciones.objects.all()
    serializer_class = TipoExportacionesSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]


class UsuarioViewSet(viewsets.ModelViewSet):
    queryset = Usuario.objects.all().order_by('-ID_usuario')
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get_serializer_class(self):
        if self.action == 'create':
            return UsuarioCreateSerializer
        if self.action in ('update', 'partial_update'):
            return UsuarioUpdateSerializer
        return UsuarioSerializer

    def perform_create(self, serializer):
        usuario = serializer.save()
        _registrar_bitacora(
            usuario=self.request.user,
            modulo='Usuarios',
            tipo_accion='Creación',
            descripcion=f'Usuario creado: {usuario.get_full_name()} ({usuario.correo})',
        )

    def perform_update(self, serializer):
        usuario = serializer.save()
        _registrar_bitacora(
            usuario=self.request.user,
            modulo='Usuarios',
            tipo_accion='Edición',
            descripcion=f'Usuario editado: {usuario.get_full_name()} ({usuario.correo})',
        )

    @action(detail=True, methods=['post'], url_path='toggle-activo')
    def toggle_activo(self, request, pk=None):
        usuario = self.get_object()
        usuario.activo = not usuario.activo
        usuario.save()
        estado = 'activado' if usuario.activo else 'desactivado'
        _registrar_bitacora(
            usuario=request.user,
            modulo='Usuarios',
            tipo_accion='Edición',
            descripcion=f'Usuario {estado}: {usuario.get_full_name()} ({usuario.correo})',
        )
        return Response({'activo': usuario.activo})


class PermisoViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Permiso.objects.select_related('cliente').order_by('-vigencia')
    serializer_class = PermisoListSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    lookup_field = 'clave_numerica'


# ── Pagos ──────────────────────────────────────────────────────────────────────

class PagoViewSet(viewsets.ModelViewSet):
    queryset = Pago.objects.select_related('estado_pago', 'pedimento__ope_aduanera__cliente').order_by('-fecha_pago')
    serializer_class = PagoSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    http_method_names = ['get', 'post', 'head', 'options']

    def create(self, request, *args, **kwargs):
        import uuid
        pedimento_num = request.data.get('pedimento')
        monto         = request.data.get('monto')
        concepto      = request.data.get('concepto', 'Pago de pedimento')

        if not pedimento_num:
            return Response({'error': 'El número de pedimento es obligatorio.'}, status=status.HTTP_400_BAD_REQUEST)
        if not monto:
            return Response({'error': 'El monto es obligatorio.'}, status=status.HTTP_400_BAD_REQUEST)

        ped = get_object_or_404(Pedimento, numero_pedimento=pedimento_num)

        if ped.pagos.exists():
            return Response({'error': 'Este pedimento ya tiene un pago registrado.'}, status=status.HTTP_400_BAD_REQUEST)

        # RF33: generar semáforo al registrar el pago
        semaforo = _generar_semaforo()
        ped.semaforo = semaforo
        ped.save(update_fields=['semaforo'])

        # RF51: si semáforo rojo → generar inspección automática
        if 'Rojo' in semaforo.resultado:
            Inspeccion.objects.create(
                fecha_inspeccion=timezone.localdate(),
                hora_inicio=datetime.now().time(),
                semaforo=semaforo,
            )

        estado_pagado = get_object_or_404(EstadoPago, codigo=1)
        num_pago      = Pago.objects.count() + 1
        no_transaccion = f'TXN-{uuid.uuid4().hex[:10].upper()}'

        pago = Pago.objects.create(
            no_transaccion=no_transaccion,
            numero_pago=num_pago,
            concepto=concepto,
            monto=monto,
            saldo_final=0,
            fecha_pago=timezone.localdate(),
            pedimento=ped,
            estado_pago=estado_pagado,
        )

        # RF40: Verde → Completada. Rojo → sigue En proceso (va a inspección)
        op = ped.ope_aduanera
        if 'Verde' in semaforo.resultado:
            estado_completada = get_object_or_404(EstadoOpeAduanera, codigo=2)
            op.estado_ope_aduanera = estado_completada
            op.fecha_final = timezone.localdate()
            op.save(update_fields=['estado_ope_aduanera', 'fecha_final'])

        return Response(
            {
                'no_transaccion':    pago.no_transaccion,
                'numero_pedimento':  ped.numero_pedimento,
                'semaforo_resultado': semaforo.resultado,
                'inspeccion_creada': 'Rojo' in semaforo.resultado,
            },
            status=status.HTTP_201_CREATED,
        )


# ── Facturas ───────────────────────────────────────────────────────────────────

@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def factura_crear(request):
    import uuid as _uuid
    no_transaccion = request.data.get('no_transaccion')
    if not no_transaccion:
        return Response({'error': 'El número de transacción es obligatorio.'}, status=status.HTTP_400_BAD_REQUEST)

    pago = get_object_or_404(
        Pago.objects.select_related('pedimento__ope_aduanera'),
        no_transaccion=no_transaccion,
    )

    if not pago.pedimento_id or not pago.pedimento.ope_aduanera_id:
        return Response({'error': 'El pago no tiene una operación aduanera asociada.'}, status=status.HTTP_400_BAD_REQUEST)

    op = pago.pedimento.ope_aduanera
    existente = op.facturas.first()
    if existente:
        return Response(FacturaSerializer(existente).data, status=status.HTTP_200_OK)

    total    = float(pago.monto)
    iva      = round(total * 0.16 / 1.16, 2)
    subtotal = round(total - iva, 2)

    factura = Factura.objects.create(
        IVA=iva,
        subtotal=subtotal,
        total=total,
        folio_fiscal=str(_uuid.uuid4()).upper(),
        fecha_factura=timezone.localdate(),
        ID_operacion=op,
    )

    return Response(FacturaSerializer(factura).data, status=status.HTTP_201_CREATED)


@api_view(['GET'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def factura_pdf(request, codigo):
    from io import BytesIO
    from django.http import HttpResponse
    from reportlab.lib import colors
    from reportlab.lib.pagesizes import A4
    from reportlab.lib.units import cm
    from reportlab.lib.styles import ParagraphStyle
    from reportlab.lib.enums import TA_CENTER, TA_RIGHT, TA_LEFT
    from reportlab.platypus import (
        SimpleDocTemplate, Table, TableStyle,
        Paragraph, Spacer, HRFlowable
    )

    factura = get_object_or_404(
        Factura.objects.select_related('ID_operacion__cliente'),
        codigo=codigo,
    )
    op      = factura.ID_operacion
    cliente = op.cliente if op else None

    ped  = op.pedimentos.first() if op else None
    pago = ped.pagos.first() if ped else None

    PRIMARY    = colors.HexColor('#1e3a5f')
    ACCENT     = colors.HexColor('#2563eb')
    LIGHT_BG   = colors.HexColor('#eff6ff')
    GRAY_LINE  = colors.HexColor('#e5e7eb')
    GRAY_TEXT  = colors.HexColor('#6b7280')
    WHITE      = colors.white
    BLACK      = colors.HexColor('#111827')

    def style(name, **kw):
        base = {'fontName': 'Helvetica', 'fontSize': 10, 'textColor': BLACK, 'leading': 14}
        base.update(kw)
        return ParagraphStyle(name, **base)

    S_HEADER    = style('header',    fontSize=20, textColor=WHITE,     fontName='Helvetica-Bold', alignment=TA_LEFT,   leading=24)
    S_SUB       = style('sub',       fontSize=9,  textColor=colors.HexColor('#93c5fd'), alignment=TA_LEFT,   leading=12)
    S_FOLIO     = style('folio',     fontSize=8,  textColor=GRAY_TEXT, alignment=TA_LEFT,   leading=11, fontName='Helvetica')
    S_FOLIO_VAL = style('foliov',    fontSize=8,  textColor=BLACK,     alignment=TA_LEFT,   leading=11, fontName='Helvetica-Bold')
    S_LABEL     = style('label',     fontSize=8,  textColor=GRAY_TEXT, alignment=TA_LEFT,   leading=11)
    S_VALUE     = style('value',     fontSize=9,  textColor=BLACK,     alignment=TA_LEFT,   leading=13, fontName='Helvetica-Bold')
    S_TH        = style('th',        fontSize=9,  textColor=WHITE,     alignment=TA_CENTER, leading=12, fontName='Helvetica-Bold')
    S_TD        = style('td',        fontSize=9,  textColor=BLACK,     alignment=TA_LEFT,   leading=12)
    S_TD_R      = style('tdr',       fontSize=9,  textColor=BLACK,     alignment=TA_RIGHT,  leading=12)
    S_TOTAL_LBL = style('totlbl',    fontSize=10, textColor=GRAY_TEXT, alignment=TA_RIGHT,  leading=14)
    S_TOTAL_VAL = style('totval',    fontSize=10, textColor=BLACK,     alignment=TA_RIGHT,  leading=14, fontName='Helvetica-Bold')
    S_GRAND_LBL = style('grandlbl',  fontSize=12, textColor=WHITE,     alignment=TA_RIGHT,  leading=16, fontName='Helvetica-Bold')
    S_GRAND_VAL = style('grandval',  fontSize=14, textColor=WHITE,     alignment=TA_RIGHT,  leading=18, fontName='Helvetica-Bold')
    S_FOOTER    = style('footer',    fontSize=7,  textColor=GRAY_TEXT, alignment=TA_CENTER, leading=10)

    PAGE_W = A4[0] - 4 * cm
    buffer  = BytesIO()
    doc     = SimpleDocTemplate(
        buffer, pagesize=A4,
        topMargin=0, bottomMargin=2*cm,
        leftMargin=2*cm, rightMargin=2*cm,
    )

    story = []

    # ── Cabecera azul ────────────────────────────────────────────────
    nombre_cliente = ''
    rfc_cliente    = '—'
    if cliente:
        nombre_cliente = f'{cliente.nombre} {cliente.primer_apell or ""}'.strip()
        rfc_cliente    = cliente.RFC or '—'

    num_visible = pago.numero_pago if pago else factura.codigo

    header_data = [[
        Paragraph('SIGA', S_HEADER),
        Paragraph(
            f'<b>FACTURA ELECTRÓNICA</b><br/>'
            f'<font color="#93c5fd" size="8">No. {num_visible}</font>',
            ParagraphStyle('hr', fontSize=14, textColor=WHITE, fontName='Helvetica-Bold',
                           alignment=TA_RIGHT, leading=20),
        ),
    ]]
    sub_data = [[
        Paragraph('Sistema Integral de Gestión Aduanal', S_SUB),
        Paragraph(
            f'<font color="#93c5fd">Fecha:</font> '
            f'<font color="white">{factura.fecha_factura.strftime("%d/%m/%Y")}</font>',
            ParagraphStyle('ds', fontSize=9, textColor=WHITE, alignment=TA_RIGHT, leading=12),
        ),
    ]]

    header_tbl = Table(header_data, colWidths=[PAGE_W * 0.5, PAGE_W * 0.5])
    header_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), PRIMARY),
        ('TOPPADDING',    (0, 0), (-1, -1), 18),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING',   (0, 0), (-1, -1), 16),
        ('RIGHTPADDING',  (0, 0), (-1, -1), 16),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    sub_tbl = Table(sub_data, colWidths=[PAGE_W * 0.5, PAGE_W * 0.5])
    sub_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), PRIMARY),
        ('TOPPADDING',    (0, 0), (-1, -1), 0),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 16),
        ('LEFTPADDING',   (0, 0), (-1, -1), 16),
        ('RIGHTPADDING',  (0, 0), (-1, -1), 16),
    ]))
    story += [header_tbl, sub_tbl, Spacer(1, 0.5*cm)]

    # ── Folio fiscal ────────────────────────────────────────────────
    folio_data = [[
        Paragraph('FOLIO FISCAL (UUID)', S_FOLIO),
        Paragraph(factura.folio_fiscal, S_FOLIO_VAL),
    ]]
    folio_tbl = Table(folio_data, colWidths=[PAGE_W * 0.28, PAGE_W * 0.72])
    folio_tbl.setStyle(TableStyle([
        ('BACKGROUND',    (0, 0), (-1, -1), LIGHT_BG),
        ('TOPPADDING',    (0, 0), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('LEFTPADDING',   (0, 0), (-1, -1), 12),
        ('RIGHTPADDING',  (0, 0), (-1, -1), 12),
        ('ROUNDEDCORNERS', [6]),
    ]))
    story += [folio_tbl, Spacer(1, 0.5*cm)]

    # ── Emisor / Receptor ───────────────────────────────────────────
    def info_block(title, rows):
        items = [Paragraph(f'<b>{title}</b>', ParagraphStyle(
            'blk', fontSize=8, textColor=ACCENT, fontName='Helvetica-Bold',
            leading=12, spaceBefore=0, spaceAfter=4,
        ))]
        for lbl, val in rows:
            items.append(Paragraph(lbl, S_LABEL))
            items.append(Paragraph(val or '—', S_VALUE))
        return items

    emisor_rows   = [('Razón social', 'SIGA Agencia Aduanal S.A. de C.V.'),
                     ('RFC Emisor',   'SAA000101XXX')]
    receptor_rows = [('Razón social', nombre_cliente or '—'),
                     ('RFC Receptor', rfc_cliente)]

    emit_col = Table([[p] for p in info_block('EMISOR', emisor_rows)],
                     colWidths=[PAGE_W * 0.45])
    recv_col = Table([[p] for p in info_block('RECEPTOR', receptor_rows)],
                     colWidths=[PAGE_W * 0.45])
    emit_col.setStyle(TableStyle([('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),0),
                                   ('TOPPADDING',(0,0),(-1,-1),2),('BOTTOMPADDING',(0,0),(-1,-1),2)]))
    recv_col.setStyle(TableStyle([('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),0),
                                   ('TOPPADDING',(0,0),(-1,-1),2),('BOTTOMPADDING',(0,0),(-1,-1),2)]))

    two_col = Table([[emit_col, recv_col]], colWidths=[PAGE_W * 0.5, PAGE_W * 0.5])
    two_col.setStyle(TableStyle([
        ('VALIGN',        (0, 0), (-1, -1), 'TOP'),
        ('LEFTPADDING',   (0, 0), (-1, -1), 0),
        ('RIGHTPADDING',  (0, 0), (-1, -1), 0),
        ('LINEAFTER',     (0, 0), (0, -1),  0.5, GRAY_LINE),
    ]))
    story += [two_col, Spacer(1, 0.5*cm),
              HRFlowable(width='100%', thickness=1, color=GRAY_LINE), Spacer(1, 0.4*cm)]

    # ── Tabla de conceptos ──────────────────────────────────────────
    concepto_texto = (pago.concepto if pago else None) or f'Servicios de despacho aduanal — Pedimento {ped.numero_pedimento if ped else "—"}'
    pedimento_num  = ped.numero_pedimento if ped else '—'

    thead = [Paragraph(t, S_TH) for t in ['DESCRIPCIÓN', 'PEDIMENTO', 'IMPORTE']]
    trow  = [
        Paragraph(concepto_texto, S_TD),
        Paragraph(pedimento_num,  ParagraphStyle('mono', fontSize=8, fontName='Helvetica',
                                                  leading=11, alignment=TA_LEFT)),
        Paragraph(f'${float(factura.subtotal):,.2f}', S_TD_R),
    ]
    concept_tbl = Table([thead, trow],
                        colWidths=[PAGE_W * 0.50, PAGE_W * 0.28, PAGE_W * 0.22])
    concept_tbl.setStyle(TableStyle([
        ('BACKGROUND',    (0, 0), (-1, 0), ACCENT),
        ('ROWBACKGROUNDS',(0, 1), (-1, -1), [WHITE, LIGHT_BG]),
        ('TOPPADDING',    (0, 0), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('LEFTPADDING',   (0, 0), (-1, -1), 10),
        ('RIGHTPADDING',  (0, 0), (-1, -1), 10),
        ('GRID',          (0, 0), (-1, -1), 0.5, GRAY_LINE),
        ('ALIGN',         (2, 0), (2, -1), 'RIGHT'),
    ]))
    story += [concept_tbl, Spacer(1, 0.4*cm)]

    # ── Totales ─────────────────────────────────────────────────────
    totals_data = [
        [Paragraph('Subtotal', S_TOTAL_LBL), Paragraph(f'${float(factura.subtotal):,.2f}', S_TOTAL_VAL)],
        [Paragraph('IVA (16%)', S_TOTAL_LBL), Paragraph(f'${float(factura.IVA):,.2f}', S_TOTAL_VAL)],
    ]
    totals_tbl = Table(totals_data, colWidths=[PAGE_W * 0.78, PAGE_W * 0.22])
    totals_tbl.setStyle(TableStyle([
        ('TOPPADDING',    (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING',   (0, 0), (-1, -1), 8),
        ('RIGHTPADDING',  (0, 0), (-1, -1), 10),
        ('LINEBELOW',     (0, -1), (-1, -1), 0.5, GRAY_LINE),
    ]))

    grand_data = [[
        Paragraph('TOTAL', S_GRAND_LBL),
        Paragraph(f'${float(factura.total):,.2f}', S_GRAND_VAL),
    ]]
    grand_tbl = Table(grand_data, colWidths=[PAGE_W * 0.78, PAGE_W * 0.22])
    grand_tbl.setStyle(TableStyle([
        ('BACKGROUND',    (0, 0), (-1, -1), PRIMARY),
        ('TOPPADDING',    (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 10),
        ('LEFTPADDING',   (0, 0), (-1, -1), 8),
        ('RIGHTPADDING',  (0, 0), (-1, -1), 10),
    ]))

    # right-align totals block
    totals_wrap = Table([[totals_tbl]], colWidths=[PAGE_W])
    totals_wrap.setStyle(TableStyle([('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),0),
                                      ('TOPPADDING',(0,0),(-1,-1),0),('BOTTOMPADDING',(0,0),(-1,-1),0)]))
    grand_wrap = Table([[grand_tbl]], colWidths=[PAGE_W])
    grand_wrap.setStyle(TableStyle([('LEFTPADDING',(0,0),(-1,-1),0),('RIGHTPADDING',(0,0),(-1,-1),0),
                                     ('TOPPADDING',(0,0),(-1,-1),0),('BOTTOMPADDING',(0,0),(-1,-1),0)]))

    story += [totals_wrap, grand_wrap, Spacer(1, 1*cm)]

    # ── Footer ──────────────────────────────────────────────────────
    story.append(HRFlowable(width='100%', thickness=0.5, color=GRAY_LINE))
    story.append(Spacer(1, 0.3*cm))
    story.append(Paragraph(
        'Este documento es una representación impresa de un Comprobante Fiscal Digital por Internet (CFDI). '
        f'Folio fiscal: {factura.folio_fiscal}',
        S_FOOTER,
    ))

    doc.build(story)
    buffer.seek(0)

    primer_nombre = (nombre_cliente.split()[0] if nombre_cliente else 'cliente').encode('ascii', 'ignore').decode() or 'cliente'
    filename      = f'factura-{primer_nombre}-{num_visible}.pdf'

    http_resp = HttpResponse(buffer.read(), content_type='application/pdf')
    http_resp['Content-Disposition'] = f'attachment; filename="{filename}"'
    return http_resp


class FacturaViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Factura.objects.select_related('ID_operacion').order_by('-fecha_factura')
    serializer_class = FacturaSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

# -- Dashboard ------------------------------------------------------------------
class DashboardAPIView(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        from django.utils import timezone

        pedimentos_recientes = Pedimento.objects.select_related(
                "ope_aduanera__cliente",
                "regimen_adu",
                "semaforo",
            ).order_by("-fecha_registro")[:5]

        ahora = timezone.now()
        limite_48h = ahora + timedelta(hours=48)

        pedimentos = []
        for p in pedimentos_recientes:
            por_vencer = (
                p.fecha_limite is not None
                and ahora <= p.fecha_limite <= limite_48h
            )
            pedimentos.append({
                "numero": p.numero_pedimento,
                "cliente": str(p.ope_aduanera.cliente),
                "regimen": str(p.regimen_adu),
                "estado": p.ope_aduanera.tipo_operacion,
                "semaforo": p.semaforo.resultado if p.semaforo_id else 'Pendiente de pago',
                "fecha_limite": p.fecha_limite,
                "por_vencer": por_vencer,
            })

        bitacora_reciente = Bitacora.objects.order_by("-fecha", "-hora")[:5]
        bitacora = BitacoraSerializer(bitacora_reciente, many=True).data

        total_verde = SemaforoFiscal.objects.filter(resultado__icontains="Verde").count()
        total_amarillo = SemaforoFiscal.objects.filter(resultado__icontains="Amarillo").count()
        total_rojo = SemaforoFiscal.objects.filter(resultado__icontains="Rojo").count()
        total_semaforos = total_verde + total_amarillo + total_rojo

        porcentaje_verde    = round((total_verde    / total_semaforos) * 100) if total_semaforos else 0
        porcentaje_amarillo = round((total_amarillo / total_semaforos) * 100) if total_semaforos else 0
        porcentaje_rojo     = round((total_rojo     / total_semaforos) * 100) if total_semaforos else 0

        # RF09 — pedimentos con pago registrado
        pedimentos_completados = Pedimento.objects.filter(pagos__isnull=False).distinct().count()

        # RF10 — pedimentos con semáforo verde
        pedimentos_liberados = Pedimento.objects.filter(
            semaforo__resultado__icontains="Verde"
        ).count()

        # RF11 — pedimentos que vencen en menos de 48 horas
        pedimentos_por_vencer = Pedimento.objects.filter(
            fecha_limite__isnull=False,
            fecha_limite__gte=ahora,
            fecha_limite__lte=limite_48h,
        ).count()

        data = {
            "total_pedimentos": Pedimento.objects.count(),
            "total_pagos": Pago.objects.count(),
            "total_clientes": Cliente.objects.count(),
            "total_operaciones": OperacionAduanera.objects.count(),
            "total_aduanas": Aduana.objects.count(),
            "pedimentos_completados": pedimentos_completados,
            "pedimentos_liberados": pedimentos_liberados,
            "pedimentos_por_vencer": pedimentos_por_vencer,
            "pedimentos": pedimentos,
            "bitacora": bitacora,
            "semaforo": {
                "total": total_semaforos,
                "verde": total_verde,
                "amarillo": total_amarillo,
                "rojo": total_rojo,
                "porcentaje_verde": porcentaje_verde,
                "porcentaje_amarillo": porcentaje_amarillo,
                "porcentaje_rojo": porcentaje_rojo,
            },
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


class TipoEmbalajeViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = TipoEmbalaje.objects.all().order_by('id')
    serializer_class = TipoEmbalajeSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]


class PaqueteViewSet(viewsets.ModelViewSet):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = Paquete.objects.select_related(
            'cliente', 'pedimento', 'tipo_embalaje',
            'inspeccion', 'inspeccion__semaforo',
        ).prefetch_related('productos').order_by('-codigo')
        cliente_id = self.request.query_params.get('cliente')
        if cliente_id:
            qs = qs.filter(cliente_id=cliente_id)
        operacion_id = self.request.query_params.get('operacion')
        if operacion_id:
            qs = qs.filter(pedimento__ope_aduanera_id=operacion_id)
        return qs

    def get_serializer_class(self):
        if self.action in ('create', 'update', 'partial_update'):
            return PaqueteCreateSerializer
        return PaqueteSerializer

    @action(detail=True, methods=['post'], url_path='productos')
    def agregar_producto(self, request, pk=None):
        paquete = self.get_object()

        # Validar capacidad de peso antes de guardar
        try:
            peso_unitario = float(request.data.get('peso', 0))
            cantidad = int(request.data.get('cantidad', 1))
            peso_nuevo = peso_unitario * cantidad
        except (ValueError, TypeError):
            peso_nuevo = 0

        if peso_nuevo > 0 and paquete.tipo_embalaje:
            from django.db.models import Sum, F, ExpressionWrapper, DecimalField as Df
            ocupado = paquete.productos.aggregate(
                total=Sum(ExpressionWrapper(F('peso') * F('cantidad'), output_field=Df(max_digits=12, decimal_places=2)))
            )['total'] or 0
            peso_max = float(paquete.tipo_embalaje.peso_maximo)
            disponible = round(peso_max - float(ocupado), 2)
            if peso_nuevo > disponible:
                return Response(
                    {'error': f'Sin espacio: el producto ocupa {peso_nuevo:.2f} kg pero el paquete solo tiene {disponible:.2f} kg disponibles.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        data = {**request.data, 'paquete': paquete.codigo}
        ser = ProductoCreateSerializer(data=data)
        if ser.is_valid():
            producto = ser.save()
            categoria_id = request.data.get('categoria')
            if categoria_id:
                try:
                    cat = CategoriaProductos.objects.get(pk=categoria_id)
                    CategoriasProductosRel.objects.create(categorias=cat, productos=producto)
                except Exception:
                    pass
            return Response(ser.data, status=status.HTTP_201_CREATED)
        return Response(ser.errors, status=status.HTTP_400_BAD_REQUEST)
    
class SemaforoFiscalViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = SemaforoFiscal.objects.all().order_by('-ID')
    serializer_class = SemaforoFiscalSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

class InspeccionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Inspeccion.objects.all().order_by('-numero')
    serializer_class = InspeccionSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    
class PerfilAPIView(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        serializer = UsuarioSerializer(request.user)
        return Response(serializer.data)
    
    def put(self, request):
        serializer = UsuarioSerializer(
            request.user,
            data=request.data,
            partial=True
        )
        if serializer.is_valid():
            serializer.save()
            return Response(
                UsuarioSerializer(request.user).data,
                status=status.HTTP_200_OK
            )
        
        print(serializer.errors)
        
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )