from django.contrib.auth import login as auth_login, logout as auth_logout
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.shortcuts import render, redirect, get_object_or_404
from django.core.paginator import Paginator
from django.http import JsonResponse

from .forms import LoginForm
from .forms import NuevoClienteForm
from .forms import NuevoPedimentoForm
from .forms import NuevaOperacionForm
from .forms import NuevoPermisoForm

from .models import Cliente
from .models import Aduana
from .models import Pedimento
from .models import SemaforoFiscal
from .models import OperacionAduanera 
from .models import Paquete 
from .models import Producto
from .models import CategoriaProductos
from .models import Permiso
from .models import Bitacora
from .models import RegimenAduanero
from .models import EstadoPago
from .models import Pago

from datetime import date
from datetime import datetime
import random

def generar_numero_pedimento(codigo_aduana):
    hoy           = date.today()
    anio_2d       = str(hoy.year)[-2:]
    ultimo_digito = str(hoy.year)[-1:]
    patente       = '3991'
    cod_aduana    = str(codigo_aduana).zfill(2)
    total         = Pedimento.objects.count() + 1
    consecutivo   = str(total).zfill(6)
    return f"{anio_2d} {cod_aduana} {patente} {ultimo_digito} {consecutivo}"

def generar_semaforo():
    resultado = random.choices(
        ['Verde - Desaduanamiento libre', 'Rojo - Reconocimiento aduanero'],
        weights=[70, 30],
        k=1
    )[0]
    return SemaforoFiscal.objects.create(
        hora=datetime.now().time(),
        resultado=resultado
    )

def estado_operacion(op):
    tiene_pedimento = Pedimento.objects.filter(ope_aduanera=op).exists()
    if not tiene_pedimento:
        return 1

    tiene_pago = EstadoPago.objects.filter(pago__isnull=False).exists()
    if not tiene_pago:
        return 2
    return 3

def login_view(request):
    if request.user.is_authenticated:
        return redirect('home:dashboard')
    if request.method == 'POST':
        form = LoginForm(request, data=request.POST)
        if form.is_valid():
            auth_login(request, form.get_user())
            return redirect('home:dashboard')
    else:
        form = LoginForm(request)
    return render(request, 'home/login.html', {'form': form})

@login_required
def logout_view(request):
    auth_logout(request)
    return redirect('home:login')

@login_required
def dashboard_view(request):
    return render(request, 'home/dashboard.html')

@login_required
def clientes_view(request):
    if request.method == 'POST':
        form = NuevoClienteForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Cliente registrado correctamente.')
            return redirect('home:clientes')
        else:
            messages.error(request, 'Revisa los campos del formulario.')
    else:
        form = NuevoClienteForm()

    clientes = Cliente.objects.all()

    paginador = Paginator(clientes, 5)   # 5 clientes por página
    clientes_paginados = paginador.get_page(
        request.GET.get('pagina', 1)
    )

    return render(request, 'home/clientes.html', {
        'clientes': clientes_paginados,
        'total_clientes': clientes.count(),
        'form': form,
    })

@login_required
def cliente_detalle_view(request, pk):
    cliente  = get_object_or_404(Cliente, numero=pk)
    permisos = Permiso.objects.filter(cliente=cliente)
    hoy      = date.today()

    return render(request, 'home/cliente_detalle.html', {
        'cliente':  cliente,
        'permisos': permisos,
        'hoy':      hoy,
    })

@login_required
def cliente_permiso_view(request, pk):
    cliente = get_object_or_404(Cliente, numero=pk)

    if request.method == 'POST':
        form = NuevoPermisoForm(request.POST)
        if form.is_valid():
            permiso         = form.save(commit=False)
            permiso.cliente = cliente
            permiso.save()
            messages.success(
                request,
                f'Permiso {permiso.clave_numerica} registrado correctamente.'
            )
            return redirect('home:cliente_detalle', pk=pk)
        else:
            messages.error(request, 'Revisa los campos del formulario.')
    else:
        form = NuevoPermisoForm()

    return render(request, 'home/cliente_permiso.html', {
        'cliente': cliente,
        'form':    form,
    })

@login_required
def cliente_permiso_eliminar_view(request, pk, clave):
    cliente = get_object_or_404(Cliente, numero=pk)
    permiso = get_object_or_404(Permiso, clave_numerica=clave, cliente=cliente)

    if request.method == 'POST':
        permiso.delete()
        messages.success(request, 'Permiso eliminado correctamente.')

    return redirect('home:cliente_detalle', pk=pk)

@login_required
def operaciones_view(request):
    query = request.GET.get('q', '')
    operaciones = OperacionAduanera.objects.select_related(
        'cliente', 'aduana'
    ).all().order_by('-ID_operacion')

    if query:
        operaciones = operaciones.filter(
            cliente__nombre__icontains=query
        ) | operaciones.filter(
            tipo_operacion__icontains=query
        ) | operaciones.filter(
            aduana__nombre__icontains=query
        )

    ops_con_estado = []
    for op in operaciones:
        ops_con_estado.append({
            'op':    op,
            'paso':  estado_operacion(op),
        })

    paginador = Paginator(ops_con_estado, 8)
    pagina    = request.GET.get('pagina', 1)

    return render(request, 'home/operaciones.html', {
        'operaciones':       paginador.get_page(pagina),
        'total_operaciones': operaciones.count(),
        'query':             query,
    })

@login_required
def operacion_nueva_view(request):
    if request.method == 'POST':
        form = NuevaOperacionForm(request.POST)
        if form.is_valid():
            op = form.save(commit=False)
            op.fecha_inicio = date.today()
            op.usuario      = request.user
            op.bitacora     = Bitacora.objects.create(
                descripcion=f'Apertura de operación aduanera | '
                            f'Tipo: {op.tipo_operacion} | '
                            f'Cliente: {op.cliente}',
                fecha=date.today(),
                hora=datetime.now().time()
            )
            op.save()
            messages.success(
                request,
                f'Operación abierta correctamente. Ahora completa el pedimento.'
            )
            return redirect('home:operacion_detalle', pk=op.ID_operacion)
        else:
            messages.error(request, 'Revisa los campos del formulario.')
    else:
        form = NuevaOperacionForm()
    return render(request, 'home/operacion_nueva.html', {'form': form})

@login_required
def operacion_detalle_view(request, pk):
    op   = get_object_or_404(OperacionAduanera, ID_operacion=pk)
    paso = estado_operacion(op)

    pedimento = Pedimento.objects.filter(ope_aduanera=op).first()

    return render(request, 'home/operacion_detalle.html', {
        'op':        op,
        'paso':      paso,
        'pedimento': pedimento,
    })

@login_required
def operacion_pedimento_view(request, pk):
    op = get_object_or_404(OperacionAduanera, ID_operacion=pk)
    if Pedimento.objects.filter(ope_aduanera=op).exists():
        messages.warning(request, 'Esta operación ya tiene un pedimento generado.')
        return redirect('home:operacion_detalle', pk=pk)
    if request.method == 'POST':
        form = NuevoPedimentoForm(request.POST)
        if form.is_valid():
            pedimento                  = form.save(commit=False)
            pedimento.ope_aduanera     = op
            pedimento.semaforo         = generar_semaforo()
            pedimento.numero_pedimento = generar_numero_pedimento(op.aduana_id)
            pedimento.fecha_registro   = date.today()
            paquetes = Paquete.objects.filter(ope_aduanera=op)
            pedimento.valor_total = sum(
                float(prod.valor_unitario)
                for paq in paquetes
                for prod in Producto.objects.filter(paquete=paq)
            )
            pedimento.save()
            messages.success(
                request,
                f'Pedimento {pedimento.numero_pedimento} generado. '
                f'Semáforo: {pedimento.semaforo.resultado}'
            )
            return redirect('home:operacion_detalle', pk=pk)
        else:
            messages.error(request, 'Revisa los campos del formulario.')
    else:
        initial = {'ope_aduanera': op}
        if op.tipo_operacion == 'Importación':
            initial['tipo_exportacion'] = None
        else:
            initial['tipo_importacion'] = None
        form = NuevoPedimentoForm(initial=initial)
    return render(request, 'home/operacion_pedimento.html', {
        'op':   op,
        'form': form,
        'paso': 2,
    })

@login_required
def pedimentos_view(request):
    query     = request.GET.get('q', '')
    pedimentos = Pedimento.objects.select_related(
        'regimen_adu', 'semaforo', 'ope_aduanera'
    ).all()

    if query:
        pedimentos = pedimentos.filter(
            numero_pedimento__icontains=query
        ) | pedimentos.filter(
            regimen_adu__descripcion__icontains=query
        ) | pedimentos.filter(
            clave_pedimento__icontains=query
        )

    paginador          = Paginator(pedimentos, 5)
    pedimentos_paginados = paginador.get_page(request.GET.get('pagina', 1))

    return render(request, 'home/pedimentos.html', {
        'pedimentos': pedimentos_paginados,
        'query':      query,
    })

@login_required
def aduanas_view(request):
    aduanas = Aduana.objects.all()
    return render(request, 'home/aduanas.html', {
        'aduanas':       aduanas,
        'total_aduanas': aduanas.count(),
    })

@login_required
def categorias_view(request):
    categorias = CategoriaProductos.objects.all().order_by('numero')
    return render(request, 'home/categorias.html', {
        'categorias':       categorias,
        'total_categorias': categorias.count(),
    })

@login_required
def bitacora_view(request):
    entradas = Bitacora.objects.all().order_by('-fecha', '-hora')
    paginador = Paginator(entradas, 15)
    return render(request, 'home/bitacora.html', {
        'entradas': paginador.get_page(request.GET.get('pagina', 1)),
    })

@login_required
def api_datos_operacion(request):
    operacion_id = request.GET.get('id')
    if not operacion_id:
        return JsonResponse({'error': 'ID requerido'}, status=400)
    try:
        op = OperacionAduanera.objects.select_related('aduana').get(
            ID_operacion=operacion_id
        )
    except OperacionAduanera.DoesNotExist:
        return JsonResponse({'error': 'No encontrada'}, status=404)

    paquetes    = Paquete.objects.filter(ope_aduanera=op)
    valor_total = sum(
        float(prod.valor_unitario)
        for paq in paquetes
        for prod in Producto.objects.filter(paquete=paq)
    )

    return JsonResponse({
        'tipo_operacion': op.tipo_operacion,
        'valor_total':    round(valor_total, 2),
        'aduana_codigo':  op.aduana_id,
        'aduana_nombre':  op.aduana.nombre,
    })