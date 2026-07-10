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

import requests


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
        q = query.lower()
        clientes = [
            c for c in clientes
            if q in c.get('nombre', '').lower()
            or q in (c.get('primer_apell') or '').lower()
            or q in c.get('RFC', '').lower()
            or q in f"{c.get('nombre', '')} {c.get('primer_apell') or ''}".lower()
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
def api_categoria_productos(request, pk):
    try:
        resp = api.get(request, f'/categorias/{pk}/productos/')
        if resp.status_code == 200:
            return JsonResponse(resp.json(), safe=False)
    except Exception:
        pass
    return JsonResponse([], safe=False)


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


# ── Categorías ─────────────────────────────────────────────────────────────────

@login_required
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

@login_required
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

@login_required
def usuarios_view(request):
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


@login_required
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
        ]

    paginador      = Paginator(pagos, 5)
    pagos_paginados = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/pagos.html', {
        'pagos':  pagos_paginados,
        'query':  query,
    })


@login_required
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

@login_required
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
        
    context = {
        "semaforos": semaforos,
        "total_semaforos": len(semaforos),
    }

    return render(request, 'home/semaforo_fiscal.html', context)

@login_required
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

@login_required
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

    total         = len(paquetes)
    con_pedimento = sum(1 for p in paquetes if p.get('pedimento_num') not in ('—', None, ''))
    sin_pedimento = total - con_pedimento

    paginador         = Paginator(paquetes, 5)
    paquetes_paginados = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/paquetes.html', {
        'paquetes':       paquetes_paginados,
        'clientes':       clientes,
        'total':          total,
        'con_pedimento':  con_pedimento,
        'sin_pedimento':  sin_pedimento,
        'query':          query,
    })


@login_required
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
            r_perm = api.get(request, '/permisos/')
            todos = api.safe_json(r_perm, []) if r_perm.status_code == 200 else []
            from datetime import date
            hoy = date.today().isoformat()
            permisos_cliente = {
                p['tipo_permiso']
                for p in todos
                if str(p.get('cliente_numero')) == str(cliente_id)
                and p.get('vigencia', '0000-00-00') >= hoy
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
        inspecciones = response.json()
    except Exception as e:
        print(e)
        inspecciones = []
        
    return render(
        request,
        'home/inspecciones.html',
        {
            "inspecciones": inspecciones,
            "total_inspecciones": len(inspecciones)
        }
    )