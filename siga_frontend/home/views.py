import datetime
import json

from django.contrib import messages
from django.utils import timezone
from django.contrib.auth import login as auth_login, logout as auth_logout
from django.contrib.auth.decorators import login_required
from django.core.paginator import Paginator
from django.http import JsonResponse
from django.shortcuts import redirect, render

from . import api_client as api
from .forms import (
    LoginForm,
    NuevoClienteForm,
    NuevaOperacionForm,
    NuevoPermisoForm,
    CLAVES_PEDIMENTO,
    AduanaForm,
)

import requests
from functools import wraps


# ── Control de acceso por rol ──────────────────────────────────────────────────

def solo_admin(view_func):
    """Redirige a inspecciones si el usuario logueado es Inspector."""
    @wraps(view_func)
    @login_required
    def wrapper(request, *args, **kwargs):
        if getattr(request.user, 'rol', '') == 'Inspector':
            return redirect('home:inspecciones')
        return view_func(request, *args, **kwargs)
    return wrapper


# ── Helpers de conversión para compatibilidad con templates ────────────────────

def _to_date(value):
    """Convierte string ISO 'YYYY-MM-DD' a datetime.date para filtros de template."""
    if isinstance(value, str):
        try:
            return datetime.date.fromisoformat(value)
        except ValueError:
            return value
    return value


def _build_op_ctx(op: dict) -> dict:
    op = dict(op)
    if isinstance(op.get('aduana'), dict):
        op['aduana'] = op['aduana']['nombre']
    op['fecha_inicio'] = _to_date(op.get('fecha_inicio', ''))
    op['pk']           = op.get('ID_operacion')
    return op


# ── Auth ───────────────────────────────────────────────────────────────────────

def login_view(request):
    if request.user.is_authenticated:
        return redirect('home:dashboard')

    if request.method == 'POST':
        form = LoginForm(request, data=request.POST)
        if form.is_valid():
            # 1) Sesión Django (para @login_required)
            auth_login(request, form.get_user())
            # 2) Token API para todas las llamadas posteriores
            try:
                resp = api.post(request, '/auth/login/', {
                    'correo':    request.POST.get('correo', ''),
                    'contrasena': request.POST.get('contrasena', ''),
                })
                if resp.status_code == 200:
                    data = resp.json()
                    request.session['api_token']    = data.get('token', '')
                    usuario_data = data.get('usuario', {})
                    request.session['usuario_rol']   = usuario_data.get('rol', 'Administrador')
                    request.session['usuario_activo'] = usuario_data.get('activo', True)
            except Exception:
                pass
            if getattr(form.get_user(), 'rol', '') == 'Inspector':
                return redirect('home:inspecciones')
            return redirect('home:dashboard')
    else:
        form = LoginForm(request)

    return render(request, 'home/login.html', {'form': form})


@login_required
def logout_view(request):
    try:
        api.post(request, '/auth/logout/')
    except Exception:
        pass
    request.session.pop('api_token', None)
    auth_logout(request)
    return redirect('home:login')


@solo_admin
def dashboard_view(request):
    try:
        response = api.get(request, '/dashboard/')
        response.raise_for_status()
        
        dashboard = response.json()
    except requests.RequestException:
        dashboard = {}
        
    return render(
        request, 
        'home/dashboard.html',
        {
            "dashboard": dashboard
        }
    )


# ── Clientes ───────────────────────────────────────────────────────────────────

@solo_admin
def clientes_view(request):
    if request.method == 'POST':
        accion = request.POST.get('accion', '')

        if accion in ('', 'nuevo_cliente'):
            form = NuevoClienteForm(request.POST)
            if form.is_valid():
                payload = dict(form.cleaned_data)
                payload['telefono']           = request.POST.get('telefono', '').strip()
                payload['correo_electronico'] = request.POST.get('correo_electronico', '').strip()
                payload['curp']               = form.cleaned_data.get('curp', '') or None
                payload['domicilio']          = form.cleaned_data.get('domicilio', '') or None
                resp = api.post(request, '/clientes/', payload)
                if resp.status_code == 201:
                    messages.success(request, 'Cliente registrado correctamente.')
                else:
                    messages.error(request, f'Error al registrar cliente: {api.safe_json(resp).get("RFC", resp.text)}')
            else:
                messages.error(request, 'Revisa los campos del formulario.')
            return redirect('home:clientes')

        if accion == 'editar_contacto':
            cliente_id = request.POST.get('cliente_id')
            payload = {
                'telefono':          request.POST.get('telefono', '').strip(),
                'correo_electronico': request.POST.get('correo_electronico', '').strip(),
            }
            resp = api.post(request, f'/clientes/{cliente_id}/contacto/', payload)
            if resp.status_code == 200:
                messages.success(request, 'Contacto actualizado correctamente.')
            else:
                messages.error(request, f'Error al actualizar contacto: {api.safe_json(resp)}')
            return redirect('home:clientes')

        if accion == 'toggle_activo_cliente':
            cliente_id = request.POST.get('cliente_id')
            resp = api.post(request, f'/clientes/{cliente_id}/toggle-activo/')
            if resp.status_code == 200:
                nuevo = 'activado' if api.safe_json(resp).get('activo') else 'desactivado'
                messages.success(request, f'Cliente {nuevo} correctamente.')
            else:
                messages.error(request, 'Error al cambiar estado del cliente.')
            return redirect('home:clientes')

        if accion == 'agregar_permiso':
            cliente_id  = request.POST.get('cliente_id')
            tipo_permiso = request.POST.get('tipo_permiso', '')
            vigencia    = request.POST.get('vigencia', '')
            descripcion  = request.POST.get('descripcion', '')

            resp = api.post(request, f'/clientes/{cliente_id}/permisos/', {
                'tipo_permiso': tipo_permiso,
                'vigencia':     vigencia,
                'descripcion':  descripcion,
            })
            if resp.status_code in (200, 201):
                data  = api.safe_json(resp)
                folio = data.get('folio', '')
                if data.get('renovado'):
                    messages.success(request, f'Permiso {folio} renovado correctamente.')
                else:
                    messages.success(request, f'Permiso registrado con folio: {folio}')
            else:
                error = api.safe_json(resp).get('error', resp.text)
                messages.error(request, error)
            return redirect('home:clientes')

    form  = NuevoClienteForm()
    query = request.GET.get('q', '')

    try:
        resp     = api.get(request, '/clientes/')
        clientes = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        clientes = []
        messages.error(request, 'No fue posible obtener la lista de clientes.')

    if query:
        q = query.lower()
        clientes = [
            c for c in clientes
            if q in c.get('nombre', '').lower()
            or q in (c.get('primer_apell') or '').lower()
            or q in c.get('RFC', '').lower()
            or q in f"{c.get('nombre', '')} {c.get('primer_apell') or ''}".lower()
            or q in c.get('telefono', '').lower()
            or q in c.get('correo_electronico', '').lower()
        ]

    paginador          = Paginator(clientes, 5)
    clientes_paginados = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/clientes.html', {
        'clientes':       clientes_paginados,
        'total_clientes': len(clientes),
        'form':           form,
        'query':          query,
        'hoy':            timezone.localdate(),
    })


# ── API proxy para JS del template de clientes ─────────────────────────────────

@login_required
def api_categoria_productos(request, pk):
    try:
        resp = api.get(request, f'/categorias/{pk}/productos/')
        if resp.status_code == 200:
            return JsonResponse(resp.json(), safe=False)
    except Exception:
        pass
    return JsonResponse([], safe=False)


@login_required
def api_cliente_detalle(request, pk):
    resp = api.get(request, f'/clientes/{pk}/')
    if resp.status_code == 200:
        data = resp.json()
        return JsonResponse({
            'numero':       data.get('numero'),
            'nombre':       data.get('nombre'),
            'primer_apell': data.get('primer_apell') or '',
            'seg_apell':    data.get('seg_apell') or '',
            'tipo_persona': data.get('tipo_persona'),
            'RFC':          data.get('RFC'),
            'activo':       data.get('activo', True),
            'permisos':     data.get('permisos', []),
            'telefonos':    data.get('telefonos', []),
            'correos':      data.get('correos', []),
            'pedimentos':   data.get('pedimentos', []),
        })
    return JsonResponse({'error': 'No encontrado'}, status=resp.status_code)


@login_required
def api_permiso_eliminar(request, pk, clave):
    if request.method == 'POST':
        resp = api.delete(request, f'/clientes/{pk}/permisos/{clave}/')
        ok   = resp.status_code in (200, 204)
        return JsonResponse({'ok': ok})
    return JsonResponse({'ok': False}, status=405)


# ── Operaciones ────────────────────────────────────────────────────────────────

@solo_admin
def operaciones_view(request):
    query = request.GET.get('q', '')

    try:
        resp_ops = api.get(request, '/operaciones/')
        ops_raw  = api.safe_json(resp_ops, []) if resp_ops.status_code == 200 else []
    except Exception:
        ops_raw = []
        messages.error(request, 'No fue posible obtener las operaciones.')

    if query:
        q       = query.lower()
        ops_raw = [
            o for o in ops_raw
            if q in o.get('tipo_operacion', '').lower()
            or q in (o.get('cliente') or {}).get('nombre', '').lower()
        ]

    ops_con_estado = [
        {'op': _build_op_ctx(o), 'paso': o.get('paso', 1), 'estado_nombre': o.get('estado_nombre', '—')}
        for o in ops_raw
    ]

    paginador = Paginator(ops_con_estado, 5)

    try:
        clientes = api.safe_json(api.get(request, '/clientes/'), [])
    except Exception:
        clientes = []

    try:
        tipos_importacion = api.safe_json(api.get(request, '/tipos-importacion/'), [])
        tipos_exportacion = api.safe_json(api.get(request, '/tipos-exportacion/'), [])
        regimenes         = api.safe_json(api.get(request, '/regimenes/'), [])
    except Exception:
        tipos_importacion = tipos_exportacion = regimenes = []

    try:
        aduanas = api.safe_json(api.get(request, '/aduanas/'), [])
    except Exception:
        aduanas = []

    return render(request, 'home/operaciones.html', {
        'operaciones':       paginador.get_page(request.GET.get('pagina', 1)),
        'total_operaciones': len(ops_raw),
        'query':             query,
        'clientes':          clientes,
        'aduanas':           aduanas,
        'tipos_importacion': tipos_importacion,
        'tipos_exportacion': tipos_exportacion,
        'regimenes':         regimenes,
        'hoy':               timezone.localdate(),
    })


@solo_admin
def operacion_nueva_view(request):
    if request.method == 'POST':
        form = NuevaOperacionForm(request.POST)
        if form.is_valid():
            resp = api.post(request, '/operaciones/', form.cleaned_data)
            if resp.status_code == 201:
                pk = resp.json().get('ID_operacion')
                messages.success(request, 'Operación abierta correctamente. Ahora completa el pedimento.')
                from django.urls import reverse
                return redirect(f"{reverse('home:operacion_detalle', args=[pk])}?nuevo=1")
            else:
                error = api.safe_json(resp).get('error', resp.text)
                messages.error(request, error)
        else:
            messages.error(request, 'Revisa los campos del formulario.')
    return redirect('home:operaciones')


@solo_admin
def operacion_detalle_view(request, pk):
    try:
        resp = api.get(request, f'/operaciones/{pk}/')
        if resp.status_code != 200:
            messages.error(request, 'Operación no encontrada.')
            return redirect('home:operaciones')
        data = resp.json()
    except Exception:
        messages.error(request, 'No se pudo conectar con la API.')
        return redirect('home:operaciones')

    cliente_id = (data.get('cliente') or {}).get('numero')
    pedimento  = data.get('pedimento')
    paso       = data.get('paso', 1)

    estado_pedimento = None
    if pedimento:
        estado_pedimento = 'Pagado' if paso >= 3 else 'Generado'
    try:
        paquetes = api.safe_json(api.get(request, f'/paquetes/?cliente={cliente_id}'), [])
    except Exception:
        paquetes = []

    peso_bruto     = round(sum(float(p.get('peso', 0) or 0)     for p in paquetes), 2)
    valor_estimado = round(sum(float(p.get('subtotal', 0) or 0) for p in paquetes), 2)
    igi_total      = round(sum(
        float(prod.get('igi_importe', 0))
        for p in paquetes
        for prod in p.get('productos', [])
    ), 2)
    dta_estimado   = round(valor_estimado * 0.008, 2)
    iva_estimado   = round(valor_estimado * 0.16, 2)
    total_estimado = round(valor_estimado + dta_estimado + igi_total + iva_estimado, 2)

    try:
        regimenes = api.safe_json(api.get(request, '/regimenes/'), [])
        permisos_raw = api.safe_json(api.get(request, f'/clientes/{cliente_id}/permisos/'), {}) if cliente_id else {}
        if isinstance(permisos_raw, list):
            permisos = permisos_raw
        elif isinstance(permisos_raw, dict):
            permisos = permisos_raw.get('permisos', [])
        else:
            permisos = []
    except Exception:
        regimenes = []
        permisos  = []

    try:
        all_peds  = api.safe_json(api.get(request, '/pedimentos/'), [])
        ped_count = len(all_peds) if isinstance(all_peds, list) else 0
    except Exception:
        ped_count = 0

    hoy_view       = timezone.localdate()
    anio_2d        = str(hoy_view.year)[-2:]
    ultimo_digito  = str(hoy_view.year)[-1:]
    cod_aduana     = str((data.get('aduana') or {}).get('codigo', '00')).zfill(2)
    consecutivo    = str(ped_count + 1).zfill(6)
    next_num_ped   = f'{anio_2d}  {cod_aduana}  3991  {ultimo_digito}  {consecutivo}'

    tipo_op = data.get('tipo_operacion', '')
    auto_pais_destino = 'México' if tipo_op == 'Importación' else ''
    auto_pais_origen  = 'México' if tipo_op == 'Exportación' else ''
    abrir_modal = 'nuevo' in request.GET and not pedimento
    return render(request, 'home/operacion_detalle.html', {
        'op':               data,
        'paso':             paso,
        'pedimento':        pedimento,
        'estado_pedimento': estado_pedimento,
        'paquetes':         paquetes,
        'peso_bruto':       peso_bruto,
        'valor_estimado':   valor_estimado,
        'igi_total':        igi_total,
        'dta_estimado':     dta_estimado,
        'iva_estimado':     iva_estimado,
        'total_estimado':   total_estimado,
        'regimenes':        regimenes,
        'regimenes_json':   json.dumps(regimenes, ensure_ascii=False),
        'permisos':         permisos,
        'claves_pedimento': CLAVES_PEDIMENTO,
        'next_num_ped':     next_num_ped,
        'auto_pais_destino': auto_pais_destino,
        'auto_pais_origen':  auto_pais_origen,
        'abrir_modal':      abrir_modal,
    })


@solo_admin
def operacion_pedimento_view(request, pk):
    from django.http import JsonResponse
    if request.method != 'POST':
        return redirect('home:operacion_detalle', pk=pk)

    es_ajax = request.headers.get('X-Requested-With') == 'XMLHttpRequest'

    resp = api.post(request, f'/operaciones/{pk}/pedimento/', {
        'clave_pedimento':       request.POST.get('clave_pedimento', ''),
        'regimen_adu':           request.POST.get('regimen_adu'),
        'permiso':               request.POST.get('permiso'),
        'medio_transporte':      request.POST.get('medio_transporte') or None,
        'pais_origen_mercancia': request.POST.get('pais_origen_mercancia') or None,
        'pais_destino':          request.POST.get('pais_destino') or None,
        'incoterm':              request.POST.get('incoterm') or None,
        'tipo_cambio':           request.POST.get('tipo_cambio') or None,
    })

    if es_ajax:
        if resp.status_code == 201:
            return JsonResponse(resp.json(), status=201)
        error = api.safe_json(resp).get('error', resp.text)
        return JsonResponse({'error': error}, status=resp.status_code)

    if resp.status_code == 201:
        data = resp.json()
        messages.success(request, f'Pedimento {data["numero_pedimento"]} generado.')
    else:
        error = api.safe_json(resp).get('error', resp.text)
        messages.error(request, f'Error al generar pedimento: {error}')

    return redirect('home:operacion_detalle', pk=pk)


@login_required
def factura_pdf_view(request, codigo):
    from django.http import HttpResponse
    resp = api.get(request, f'/facturas/{codigo}/pdf/')
    if resp.status_code == 200:
        http_resp = HttpResponse(resp.content, content_type='application/pdf')
        http_resp['Content-Disposition'] = resp.headers.get(
            'Content-Disposition', f'attachment; filename="factura_{codigo}.pdf"'
        )
        return http_resp
    return HttpResponse(status=resp.status_code)


@login_required
def factura_crear_view(request):
    import json
    from django.http import JsonResponse
    if request.method != 'POST':
        return JsonResponse({'error': 'Método no permitido.'}, status=405)
    try:
        body = json.loads(request.body)
    except Exception:
        return JsonResponse({'error': 'JSON inválido.'}, status=400)
    resp = api.post(request, '/facturas/crear/', body)
    return JsonResponse(resp.json(), status=resp.status_code)


@login_required
def pago_crear_view(request):
    from django.http import JsonResponse
    if request.method != 'POST':
        return JsonResponse({'error': 'Método no permitido.'}, status=405)

    resp = api.post(request, '/pagos/', {
        'pedimento': request.POST.get('pedimento'),
        'monto':     request.POST.get('monto'),
        'concepto':  request.POST.get('concepto') or 'Pago de pedimento',
    })

    if resp.status_code == 201:
        return JsonResponse(resp.json(), status=201)
    error = api.safe_json(resp).get('error', resp.text)
    return JsonResponse({'error': error}, status=resp.status_code)


# ── Pedimentos ─────────────────────────────────────────────────────────────────

@solo_admin
def pedimento_detalle_view(request, operacion_id):
    try:
        op_resp = api.get(request, f'/operaciones/{operacion_id}/')
        if op_resp.status_code != 200:
            messages.error(request, 'Operación no encontrada.')
            return redirect('home:pedimentos')
        op = api.safe_json(op_resp, {})
    except Exception:
        messages.error(request, 'Error al obtener el pedimento.')
        return redirect('home:pedimentos')

    pedimento = op.get('pedimento') or {}
    if not pedimento:
        messages.error(request, 'Esta operación no tiene pedimento generado.')
        return redirect('home:pedimentos')

    paquetes = []
    permisos = []
    cliente_id = (op.get('cliente') or {}).get('numero')
    if cliente_id:
        try:
            paquetes = api.safe_json(api.get(request, f'/paquetes/?cliente={cliente_id}'), [])
        except Exception:
            pass
        try:
            permisos_raw = api.safe_json(api.get(request, f'/clientes/{cliente_id}/permisos/'), {})
            permisos = permisos_raw if isinstance(permisos_raw, list) else permisos_raw.get('permisos', [])
        except Exception:
            pass

    peso_bruto     = round(sum(float(p.get('peso', 0) or 0)     for p in paquetes), 2)
    valor_estimado = round(sum(float(p.get('subtotal', 0) or 0) for p in paquetes), 2)
    igi_total      = round(sum(
        float(prod.get('igi_importe', 0))
        for p in paquetes
        for prod in p.get('productos', [])
    ), 2)
    dta_estimado   = round(valor_estimado * 0.008, 2)
    iva_estimado   = round(valor_estimado * 0.16,  2)
    total_estimado = round(valor_estimado + dta_estimado + igi_total + iva_estimado, 2)

    return render(request, 'home/pedimento_detalle.html', {
        'pedimento':      pedimento,
        'op':             op,
        'paquetes':       paquetes,
        'permisos':       permisos,
        'peso_bruto':     peso_bruto,
        'valor_estimado': valor_estimado,
        'igi_total':      igi_total,
        'dta_estimado':   dta_estimado,
        'iva_estimado':   iva_estimado,
        'total_estimado': total_estimado,
    })


@solo_admin
def pedimentos_view(request):
    query = request.GET.get('q', '')

    try:
        resp      = api.get(request, '/pedimentos/')
        pedimentos = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        pedimentos = []
        messages.error(request, 'No fue posible obtener los pedimentos.')

    if query:
        q          = query.lower()
        pedimentos = [
            p for p in pedimentos
            if q in p.get('numero_pedimento', '').lower()
            or q in (p.get('regimen_adu') or {}).get('descripcion', '').lower()
            or q in p.get('clave_pedimento', '').lower()
            or q in p.get('cliente_rfc', '').lower()
            or q in p.get('cliente_nombre', '').lower()
        ]

    paginador            = Paginator(pedimentos, 5)
    pedimentos_paginados = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/pedimentos.html', {
        'pedimentos': pedimentos_paginados,
        'query':      query,
    })


# ── Aduanas ────────────────────────────────────────────────────────────────────

@solo_admin
def aduanas_view(request):
    if request.method == "POST":
        form = AduanaForm(request.POST)
        
        if form.is_valid():
            data = {
                "nombre": form.cleaned_data["nombre"],
                "ciudad": form.cleaned_data["ciudad"],
            }
            
            if not data["nombre"] or not data["ciudad"]:
                messages.error(request, "Todos los campos son obligatorios. ")
                return redirect("home:aduanas")
                
            try:
                response = api.post(request, "/aduanas/", data)
                
                if response.status_code == 201:
                    messages.success(request, "La aduana fue creada correctamente. ")
                    return redirect("home:aduanas")
                else:
                    try:
                        error = response.json()
                    except Exception:
                        error = response.text
                        
                    messages.error(request, f"Error al crear la aduana: {error}")
                    
            except Exception:
                messages.error(request, "No fue posible conectar con la API.")
                
            return redirect("home:aduanas")
        
    query = request.GET.get('q', '')
    try:
        resp    = api.get(request, '/aduanas/')
        aduanas = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        aduanas = []
        messages.error(request, 'No fue posible conectar con la API.')

    if query:
        q       = query.lower()
        aduanas = [a for a in aduanas if q in a.get('nombre', '').lower() or q in a.get('ciudad', '').lower()]

    paginador        = Paginator(aduanas, 5)
    aduanas_paginadas = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/aduanas.html', {
        'aduanas':       aduanas_paginadas,
        'total_aduanas': paginador.count,
        'query':         query,
    })

@solo_admin
def detalle_aduana(request, codigo):
    
    try:
        response = api.get(request, f"/aduanas/{codigo}")
        
        if response.status_code == 200:
            return JsonResponse(api.safe_json(response, {}))
        
        return JsonResponse(
            {"error": "No se encontró la aduana. "},
            status=response.status_code
        )
        
    except Exception:
        return JsonResponse(
            {"error": "No fue posible conectar con la API. "},
            status=500
        )
        
@solo_admin
def editar_aduana(request, codigo):
    if request.method != "POST":
        return JsonResponse({"error": "Método no permitido."}, status=405)
    
    data = {
        "nombre": request.POST.get("nombre", "").strip(),
        "ciudad": request.POST.get("ciudad", "").strip(),
    }
    
    try:
        response = api.put(request, f"/aduanas/{codigo}/", data)
        
        if response.status_code == 200:
            return JsonResponse({"success": True})
        
        return JsonResponse(api.safe_json(response, {}), status=response.status_code)
    
    except Exception:
        return JsonResponse(
            {"error": "No fue posible conectar con la API. "},
            status=500
        )

# ── Categorías ─────────────────────────────────────────────────────────────────

@solo_admin
def categorias_view(request):
    query = request.GET.get('q', '')
    try:
        resp       = api.get(request, '/categorias/')
        categorias = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        categorias = []
        messages.error(request, 'No fue posible obtener las categorías.')

    if query:
        q          = query.lower()
        categorias = [c for c in categorias if q in c.get('nombre', '').lower() or q in (c.get('descripcion') or '').lower()]

    paginador          = Paginator(categorias, 5)
    categorias_paginadas = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/categorias.html', {
        'categorias':       categorias_paginadas,
        'total_categorias': paginador.count,
        'query':            query,
    })


# ── Bitácora ───────────────────────────────────────────────────────────────────

@solo_admin
def bitacora_view(request):
    query = request.GET.get('q', '')
    try:
        resp     = api.get(request, '/bitacora/')
        entradas = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        entradas = []
        messages.error(request, 'No fue posible obtener la bitácora.')

    if query:
        q        = query.lower()
        entradas = [e for e in entradas if q in e.get('descripcion', '').lower()]

    paginador = Paginator(entradas, 5)
    return render(request, 'home/bitacora.html', {
        'entradas': paginador.get_page(request.GET.get('pagina', 1)),
        'query':    query,
    })


# ── API proxy: datos de operación para el formulario de pedimento ──────────────

@login_required
def api_datos_operacion(request):
    operacion_id = request.GET.get('id')
    if not operacion_id:
        return JsonResponse({'error': 'ID requerido'}, status=400)

    resp = api.get(request, f'/operaciones/{operacion_id}/')
    if resp.status_code != 200:
        return JsonResponse({'error': 'No encontrada'}, status=404)

    data    = resp.json()
    aduana  = data.get('aduana') or {}
    cliente = data.get('cliente') or {}

    return JsonResponse({
        'tipo_operacion': data.get('tipo_operacion'),
        'aduana_codigo':  aduana.get('codigo'),
        'aduana_nombre':  aduana.get('nombre'),
        'cliente_nombre': f"{cliente.get('nombre', '')} {cliente.get('primer_apell', '')}".strip(),
    })


# ── Secciones stub ─────────────────────────────────────────────────────────────

@solo_admin
def usuarios_view(request):
    if request.method == 'POST':
        accion = request.POST.get('accion', '')

        if accion == 'nuevo':
            payload = {
                'nombre_pila':    request.POST.get('nombre_pila', '').strip(),
                'primer_apell':   request.POST.get('primer_apell', '').strip(),
                'seg_apell':      request.POST.get('seg_apell', '').strip() or None,
                'correo':         request.POST.get('correo', '').strip(),
                'nombre_usuario': request.POST.get('nombre_usuario', '').strip(),
                'password':       request.POST.get('password', ''),
                'rol':            request.POST.get('rol', 'Administrador'),
            }
            resp = api.post(request, '/usuarios/', payload)
            if resp.status_code == 201:
                messages.success(request, 'Usuario creado correctamente.')
            else:
                error = api.safe_json(resp)
                messages.error(request, f'Error al crear usuario: {error}')
            return redirect('home:usuarios')

        if accion == 'editar':
            uid = request.POST.get('usuario_id')
            payload = {
                'nombre_pila':    request.POST.get('nombre_pila', '').strip(),
                'primer_apell':   request.POST.get('primer_apell', '').strip(),
                'seg_apell':      request.POST.get('seg_apell', '').strip() or None,
                'correo':         request.POST.get('correo', '').strip(),
                'nombre_usuario': request.POST.get('nombre_usuario', '').strip(),
                'rol':            request.POST.get('rol', 'Administrador'),
            }
            password = request.POST.get('password', '').strip()
            if password:
                payload['password'] = password
            resp = api.patch(request, f'/usuarios/{uid}/', payload)
            if resp.status_code == 200:
                messages.success(request, 'Usuario actualizado correctamente.')
            else:
                messages.error(request, f'Error al editar usuario: {api.safe_json(resp)}')
            return redirect('home:usuarios')

        if accion == 'toggle_activo':
            uid = request.POST.get('usuario_id')
            resp = api.post(request, f'/usuarios/{uid}/toggle-activo/')
            if resp.status_code == 200:
                nuevo_estado = 'activado' if api.safe_json(resp).get('activo') else 'desactivado'
                messages.success(request, f'Usuario {nuevo_estado} correctamente.')
            else:
                messages.error(request, 'Error al cambiar estado del usuario.')
            return redirect('home:usuarios')

    query = request.GET.get('q', '')
    try:
        resp     = api.get(request, '/usuarios/')
        usuarios = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        usuarios = []
        messages.error(request, 'No fue posible obtener los usuarios.')

    if query:
        q        = query.lower()
        usuarios = [
            u for u in usuarios
            if q in u.get('nombre_usuario', '').lower()
            or q in u.get('nombre_pila', '').lower()
            or q in (u.get('primer_apell') or '').lower()
            or q in u.get('correo', '').lower()
        ]

    paginador         = Paginator(usuarios, 5)
    usuarios_paginados = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/usuarios.html', {
        'usuarios': usuarios_paginados,
        'query':    query,
    })


@solo_admin
def pagos_view(request):
    query = request.GET.get('q', '')
    try:
        resp  = api.get(request, '/pagos/')
        pagos = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        pagos = []
        messages.error(request, 'No fue posible obtener los pagos.')

    if query:
        q     = query.lower()
        pagos = [
            p for p in pagos
            if q in p.get('no_transaccion', '').lower()
            or q in p.get('concepto', '').lower()
            or q in p.get('estado', '').lower()
            or q in (p.get('pedimento_num') or '').lower()
            or q in (p.get('cliente_nombre') or '').lower()
        ]

    paginador      = Paginator(pagos, 5)
    pagos_paginados = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/pagos.html', {
        'pagos':  pagos_paginados,
        'query':  query,
    })


@solo_admin
def facturas_view(request):
    query = request.GET.get('q', '')
    try:
        resp     = api.get(request, '/facturas/')
        facturas = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        facturas = []
        messages.error(request, 'No fue posible obtener las facturas.')

    if query:
        q        = query.lower()
        facturas = [
            f for f in facturas
            if q in f.get('folio_fiscal', '').lower()
            or q in f.get('fecha_factura', '').lower()
        ]

    paginador         = Paginator(facturas, 5)
    facturas_paginadas = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/facturas.html', {
        'facturas': facturas_paginadas,
        'query':    query,
    })


@solo_admin
def permisos_view(request):
    query       = request.GET.get('q', '')
    tipo_filtro = request.GET.get('tipo', '')

    try:
        resp      = api.get(request, '/permisos/')
        todos     = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        todos = []
        messages.error(request, 'No fue posible obtener los permisos.')

    tipos_disponibles = sorted({p.get('tipo_permiso', '') for p in todos if p.get('tipo_permiso')})

    permisos = todos
    if tipo_filtro:
        permisos = [p for p in permisos if p.get('tipo_permiso') == tipo_filtro]
    if query:
        q        = query.lower()
        permisos = [
            p for p in permisos
            if q in p.get('clave_numerica', '').lower()
            or q in p.get('tipo_permiso', '').lower()
            or q in p.get('cliente_nombre', '').lower()
        ]

    from django.utils import timezone as tz
    from datetime import date as _date
    hoy = tz.localdate()
    for p in permisos:
        try:
            vigencia_date = _date.fromisoformat(p['vigencia'])
            dias = (vigencia_date - hoy).days
            p['dias_restantes'] = dias
            p['por_vencer']     = 0 <= dias <= 30
        except Exception:
            p['dias_restantes'] = None
            p['por_vencer']     = False

    paginador          = Paginator(permisos, 5)
    permisos_paginados = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/permisos.html', {
        'permisos':          permisos_paginados,
        'total_permisos':    len(permisos),
        'tipos_disponibles': tipos_disponibles,
        'tipo_filtro':       tipo_filtro,
        'query':             query,
    })


@solo_admin
def perfilusuario_view(request):
    if request.method == "POST":
        datos = {
            "nombre_pila": request.POST.get("nombre_pila"),
            "primer_apell": request.POST.get("primer_apell"),
            "seg_apell": request.POST.get("seg_apell"),
            "correo": request.POST.get("correo"),
        }
        respuesta = api.put(request, "/perfil/", datos)
        
        if respuesta.status_code == 200:
            messages.success(
                request,
                "Perfil actualizado correctamente. "
            )
        else:
            print(respuesta.status_code)
            print(respuesta.text)
            messages.error(
                request,
                f"Error: {respuesta.text}"
            )
    
    try:
        usuario = api.get(request, "/perfil/").json()
        
    except Exception as e:
        usuario = None
        messages.error(request, f"Error al obtener el perfil: {e}")
        
    return render(request, 'home/perfil_usuario.html', {
        'usuario': usuario,
    })
    


@solo_admin
def semaforofiscal_view(request):
    try:
        response = api.get(request, "/semaforos/")
        response.raise_for_status()
        semaforos = response.json()

        for semaforo in semaforos:
            resultado = semaforo["resultado"].lower()
            
            if resultado.startswith("verde"):
                semaforo["clase_css"] = "pill-aprobada"
            elif resultado.startswith("amarillo"):
                semaforo["clase_css"] = "pill-revision"
            elif resultado.startswith("rojo"):
                semaforo["clase_css"] = "pill-restringida"
            else:
                semaforo["clase_css"] = ""
    except Exception as e:
        print(f"Error al obtener semáforos: {e}")
        semaforos = []
        
    paginador = Paginator(semaforos, 5)
    context = {
        "semaforos":        paginador.get_page(request.GET.get('pagina', 1)),
        "total_semaforos":  len(semaforos),
    }

    return render(request, 'home/semaforo_fiscal.html', context)

@solo_admin
def sanciones_view(request):
    query = request.GET.get('q', '')
    try:
        resp      = api.get(request, '/sanciones/')
        sanciones = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        sanciones = []
        messages.error(request, 'No fue posible obtener las sanciones.')

    if query:
        q         = query.lower()
        sanciones = [s for s in sanciones if q in s.get('fundamento_legal', '').lower()]

    paginador          = Paginator(sanciones, 5)
    sanciones_paginadas = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/sanciones.html', {
        'sanciones': sanciones_paginadas,
        'query':     query,
    })

@solo_admin
def paquetes_view(request):
    if request.method == 'POST':
        resp = api.post(request, '/paquetes/', {
            'tipo_embalaje': request.POST.get('tipo_embalaje', '').strip(),
            'peso':          request.POST.get('peso', '').strip(),
            'dimensions':    request.POST.get('dimensions', '').strip(),
            'cliente':       request.POST.get('cliente_id', '').strip(),
        })
        if resp.status_code == 201:
            messages.success(request, 'Paquete registrado correctamente.')
        else:
            messages.error(request, 'Error al registrar el paquete.')
        return redirect('home:paquetes')

    try:
        resp     = api.get(request, '/paquetes/')
        paquetes = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        paquetes = []
        messages.error(request, 'No fue posible obtener los paquetes.')

    try:
        resp_c   = api.get(request, '/clientes/')
        clientes = api.safe_json(resp_c, []) if resp_c.status_code == 200 else []
    except Exception:
        clientes = []

    query = request.GET.get('q', '')
    if query:
        q        = query.lower()
        paquetes = [
            p for p in paquetes
            if q in p.get('cliente_nombre', '').lower()
            or q in p.get('tipo_embalaje', '').lower()
            or q in p.get('numero', '').lower()
        ]

    total           = len(paquetes)
    con_pedimento   = sum(1 for p in paquetes if p.get('pedimento_num') not in ('—', None, ''))
    sin_pedimento   = total - con_pedimento
    con_inspeccion  = sum(1 for p in paquetes if p.get('inspeccion'))

    paginador         = Paginator(paquetes, 5)
    paquetes_paginados = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/paquetes.html', {
        'paquetes':        paquetes_paginados,
        'clientes':        clientes,
        'total':           total,
        'con_pedimento':   con_pedimento,
        'sin_pedimento':   sin_pedimento,
        'con_inspeccion':  con_inspeccion,
        'query':           query,
    })


@solo_admin
def paquete_detalle_view(request, pk):
    if request.method == 'POST':
        resp = api.post(request, f'/paquetes/{pk}/productos/', {
            'nombre':         request.POST.get('nombre', '').strip(),
            'descripcion':    request.POST.get('descripcion', '').strip(),
            'peso':           request.POST.get('peso', '').strip(),
            'valor_unitario': request.POST.get('valor_unitario', '').strip(),
            'cantidad':       request.POST.get('cantidad', 1),
            'categoria':      request.POST.get('categoria', '').strip(),
            'paquete':        pk,
        })
        if resp.status_code == 201:
            messages.success(request, 'Producto agregado correctamente.')
        else:
            messages.error(request, 'Error al agregar el producto.')
        return redirect('home:paquete_detalle', pk=pk)

    resp = api.get(request, f'/paquetes/{pk}/')
    if resp.status_code != 200:
        messages.error(request, 'Paquete no encontrado.')
        return redirect('home:paquetes')

    paquete = api.safe_json(resp, {})

    # Categorías con su permiso requerido
    try:
        r_cat = api.get(request, '/categorias/')
        categorias = api.safe_json(r_cat, []) if r_cat.status_code == 200 else []
    except Exception:
        categorias = []

    # Tipos de permiso vigentes del cliente dueño del paquete
    permisos_cliente = set()
    cliente_id = paquete.get('cliente')
    if cliente_id:
        try:
            r_perm = api.get(request, f'/clientes/{cliente_id}/permisos/')
            if r_perm.status_code == 200:
                permisos_cliente = {
                    p['tipo']
                    for p in api.safe_json(r_perm, [])
                    if p.get('vigente')
                }
        except Exception:
            pass

    return render(request, 'home/paquete_detalle.html', {
        'paquete':          paquete,
        'categorias':       categorias,
        'permisos_cliente': list(permisos_cliente),
    })


@login_required
def inspecciones_view(request):
    try:
        response = api.get(request, "/inspecciones/")
        inspecciones = api.safe_json(response, []) if response.status_code == 200 else []
    except Exception:
        inspecciones = []
        messages.error(request, 'No fue posible obtener las inspecciones.')

    q = request.GET.get('q', '').lower()
    if q:
        inspecciones = [i for i in inspecciones if
                        q in str(i.get('numero', '')).lower() or
                        q in (i.get('pedimento_num') or '').lower() or
                        q in (i.get('cliente_nombre') or '').lower()]

    total           = len(inspecciones)
    en_revision     = sum(1 for i in inspecciones if not i.get('resultado'))
    con_incidencias = sum(1 for i in inspecciones if i.get('resultado') == 'Con incidencias')
    segunda_sol     = sum(1 for i in inspecciones if i.get('resultado') == 'Segunda inspección solicitada')

    import json as _json
    paginador = Paginator(inspecciones, 10)
    page      = paginador.get_page(request.GET.get('pagina', 1))
    return render(
        request,
        'home/inspecciones.html',
        {
            "inspecciones":       page,
            "inspecciones_json":  _json.dumps(list(page.object_list)),
            "total_inspecciones": total,
            "en_revision":        en_revision,
            "con_incidencias":    con_incidencias,
            "segunda_sol":        segunda_sol,
            "query":              request.GET.get('q', ''),
            "rol":                request.user.rol,
            "es_inspector":       request.user.rol == 'Inspector',
            "es_admin":           request.user.rol == 'Administrador',
        }
    )


@login_required
def api_inspeccion_resultado(request, pk):
    import json
    if request.method != 'PATCH':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        body = json.loads(request.body)
        resp = api.patch(request, f'/inspecciones/{pk}/resultado/', body)
        return JsonResponse(resp.json(), status=resp.status_code)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)


@login_required
def api_inspeccion_incidencias(request, pk):
    import json
    if request.method == 'GET':
        try:
            resp = api.get(request, f'/inspecciones/{pk}/incidencias/')
            return JsonResponse(resp.json(), safe=False, status=resp.status_code)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    elif request.method == 'POST':
        try:
            body = json.loads(request.body)
            resp = api.post(request, f'/inspecciones/{pk}/incidencias/', body)
            return JsonResponse(resp.json(), status=resp.status_code)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    return JsonResponse({'error': 'Método no permitido'}, status=405)


@login_required
def api_incidencia_sancion(request, pk):
    import json
    if request.method != 'POST':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        body = json.loads(request.body)
        resp = api.post(request, f'/incidencias/{pk}/sancion/', body)
        return JsonResponse(resp.json(), status=resp.status_code)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)


@login_required
def api_segunda_inspeccion(request, pk):
    if request.method != 'POST':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        resp = api.post(request, f'/inspecciones/{pk}/segunda-inspeccion/', {})
        return JsonResponse(resp.json(), status=resp.status_code)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)