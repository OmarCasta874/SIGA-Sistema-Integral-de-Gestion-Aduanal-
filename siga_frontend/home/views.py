import datetime

from django.contrib import messages
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
    NuevoPedimentoForm,
    NuevoPermisoForm,
)


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
                    request.session['api_token'] = resp.json().get('token', '')
            except Exception:
                pass
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


@login_required
def dashboard_view(request):
    return render(request, 'home/dashboard.html')


# ── Clientes ───────────────────────────────────────────────────────────────────

@login_required
def clientes_view(request):
    if request.method == 'POST':
        accion = request.POST.get('accion', '')

        if accion in ('', 'nuevo_cliente'):
            form = NuevoClienteForm(request.POST)
            if form.is_valid():
                resp = api.post(request, '/clientes/', form.cleaned_data)
                if resp.status_code == 201:
                    messages.success(request, 'Cliente registrado correctamente.')
                else:
                    messages.error(request, f'Error al registrar cliente: {api.safe_json(resp).get("RFC", resp.text)}')
            else:
                messages.error(request, 'Revisa los campos del formulario.')
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
        q        = query.lower()
        clientes = [
            c for c in clientes
            if q in c.get('nombre', '').lower()
            or q in (c.get('primer_apell') or '').lower()
            or q in c.get('RFC', '').lower()
        ]

    paginador          = Paginator(clientes, 5)
    clientes_paginados = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/clientes.html', {
        'clientes':       clientes_paginados,
        'total_clientes': len(clientes),
        'form':           form,
        'query':          query,
        'hoy':            datetime.date.today(),
    })


# ── API proxy para JS del template de clientes ─────────────────────────────────

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
            'permisos':     data.get('permisos', []),
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

@login_required
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
        {'op': _build_op_ctx(o), 'paso': o.get('paso', 1)}
        for o in ops_raw
    ]

    paginador = Paginator(ops_con_estado, 8)

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

    return render(request, 'home/operaciones.html', {
        'operaciones':       paginador.get_page(request.GET.get('pagina', 1)),
        'total_operaciones': len(ops_raw),
        'query':             query,
        'clientes':          clientes,
        'tipos_importacion': tipos_importacion,
        'tipos_exportacion': tipos_exportacion,
        'regimenes':         regimenes,
        'hoy':               datetime.date.today(),
    })


@login_required
def operacion_nueva_view(request):
    if request.method == 'POST':
        form = NuevaOperacionForm(request.POST)
        if form.is_valid():
            resp = api.post(request, '/operaciones/', form.cleaned_data)
            if resp.status_code == 201:
                pk = resp.json().get('ID_operacion')
                messages.success(request, 'Operación abierta correctamente. Ahora completa el pedimento.')
                return redirect('home:operacion_detalle', pk=pk)
            else:
                messages.error(request, f'Error al crear operación: {resp.text}')
        else:
            messages.error(request, 'Revisa los campos del formulario.')
    return redirect('home:operaciones')


@login_required
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

    pedimento = data.get('pedimento')
    return render(request, 'home/operacion_detalle.html', {
        'op':        data,
        'paso':      data.get('paso', 1),
        'pedimento': pedimento,
    })


@login_required
def operacion_pedimento_view(request, pk):
    try:
        resp_op = api.get(request, f'/operaciones/{pk}/')
        if resp_op.status_code != 200:
            return redirect('home:operaciones')
        op = resp_op.json()
    except Exception:
        return redirect('home:operaciones')

    if op.get('pedimento'):
        messages.warning(request, 'Esta operación ya tiene un pedimento generado.')
        return redirect('home:operacion_detalle', pk=pk)

    if request.method == 'POST':
        resp = api.post(request, f'/operaciones/{pk}/pedimento/', {
            'clave_pedimento':  request.POST.get('clave_pedimento', ''),
            'regimen_adu':      request.POST.get('regimen_adu'),
            'permiso':          request.POST.get('permiso'),
            'tipo_importacion': request.POST.get('tipo_importacion') or None,
            'tipo_exportacion': request.POST.get('tipo_exportacion') or None,
        })
        if resp.status_code == 201:
            data = resp.json()
            messages.success(
                request,
                f'Pedimento {data["numero_pedimento"]} generado. '
                f'Semáforo: {data["semaforo_resultado"]}'
            )
            return redirect('home:operacion_detalle', pk=pk)
        else:
            messages.error(request, f'Error al generar pedimento: {resp.text}')

    try:
        regimenes = api.safe_json(api.get(request, '/regimenes/'), [])
        permisos  = api.safe_json(
            api.get(request, f'/clientes/{op["cliente"]["numero"]}/permisos/'), []
        )
        tipos_importacion = api.safe_json(api.get(request, '/tipos-importacion/'), [])
        tipos_exportacion = api.safe_json(api.get(request, '/tipos-exportacion/'), [])
    except Exception:
        regimenes = permisos = tipos_importacion = tipos_exportacion = []

    form = NuevoPedimentoForm()
    return render(request, 'home/operacion_pedimento.html', {
        'op':               op,
        'form':             form,
        'paso':             2,
        'regimenes':        regimenes,
        'permisos':         permisos,
        'tipos_importacion': tipos_importacion,
        'tipos_exportacion': tipos_exportacion,
    })


# ── Pedimentos ─────────────────────────────────────────────────────────────────

@login_required
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
        ]

    paginador            = Paginator(pedimentos, 5)
    pedimentos_paginados = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/pedimentos.html', {
        'pedimentos': pedimentos_paginados,
        'query':      query,
    })


# ── Aduanas ────────────────────────────────────────────────────────────────────

@login_required
def aduanas_view(request):
    try:
        resp    = api.get(request, '/aduanas/')
        aduanas = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        aduanas = []
        messages.error(request, 'No fue posible conectar con la API.')

    return render(request, 'home/aduanas.html', {
        'aduanas':       aduanas,
        'total_aduanas': len(aduanas),
    })


# ── Categorías ─────────────────────────────────────────────────────────────────

@login_required
def categorias_view(request):
    try:
        resp       = api.get(request, '/categorias/')
        categorias = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        categorias = []
        messages.error(request, 'No fue posible obtener las categorías.')

    return render(request, 'home/categorias.html', {
        'categorias':       categorias,
        'total_categorias': len(categorias),
    })


# ── Bitácora ───────────────────────────────────────────────────────────────────

@login_required
def bitacora_view(request):
    try:
        resp     = api.get(request, '/bitacora/')
        entradas = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        entradas = []
        messages.error(request, 'No fue posible obtener la bitácora.')

    paginador = Paginator(entradas, 15)
    return render(request, 'home/bitacora.html', {
        'entradas': paginador.get_page(request.GET.get('pagina', 1)),
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

@login_required
def usuarios_view(request):
    try:
        resp     = api.get(request, '/usuarios/')
        usuarios = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        usuarios = []
    return render(request, 'home/usuarios.html', {'usuarios': usuarios})


@login_required
def pagos_view(request):
    try:
        resp  = api.get(request, '/pagos/')
        pagos = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        pagos = []
    return render(request, 'home/pagos.html', {'pagos': pagos})


@login_required
def facturas_view(request):
    try:
        resp     = api.get(request, '/facturas/')
        facturas = api.safe_json(resp, []) if resp.status_code == 200 else []
    except Exception:
        facturas = []
    return render(request, 'home/facturas.html', {'facturas': facturas})


@login_required
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

    paginador          = Paginator(permisos, 10)
    permisos_paginados = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/permisos.html', {
        'permisos':          permisos_paginados,
        'total_permisos':    len(permisos),
        'tipos_disponibles': tipos_disponibles,
        'tipo_filtro':       tipo_filtro,
        'query':             query,
    })


@login_required
def perfilusuario_view(request):
    return render(request, 'home/perfil_usuario.html')
