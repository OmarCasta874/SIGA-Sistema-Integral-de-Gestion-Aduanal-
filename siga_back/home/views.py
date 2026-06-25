from django.contrib.auth import login as auth_login, logout as auth_logout
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.shortcuts import render, redirect
from django.core.paginator import Paginator
from django.http import JsonResponse

from .forms import LoginForm
from .forms import LoginForm, NuevoClienteForm, NuevoPedimentoForm

from .models import Cliente
from .models import Aduana
from .models import Pedimento
from .models import SemaforoFiscal
from .models import OperacionAduanera 
from .models import Paquete 
from .models import Producto

from datetime import date
from datetime import datetime
import random

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
def operaciones_view(request):
    return render(request, 'home/operaciones.html')


def generar_numero_pedimento(codigo_aduana):
    hoy          = date.today()
    anio_2d      = str(hoy.year)[-2:]      
    ultimo_digito = str(hoy.year)[-1:]     
    patente      = '3991'                 
    cod_aduana = str(codigo_aduana).zfill(2)
    total = Pedimento.objects.count() + 1
    consecutivo = str(total).zfill(6)
    numero = f"{anio_2d} {cod_aduana} {patente} {ultimo_digito} {consecutivo}"
    return numero

def generar_semaforo():
    resultado = random.choices(
        ['Verde - Desaduanamiento libre', 'Rojo - Reconocimiento aduanero'],
        weights=[70, 30],
        k=1
    )[0]

    semaforo = SemaforoFiscal.objects.create(
        hora=datetime.now().time(),
        resultado=resultado
    )
    return semaforo

@login_required
def pedimentos_view(request):
    if request.method == 'POST':
        form = NuevoPedimentoForm(request.POST)
        if form.is_valid():
            pedimento = form.save(commit=False)

            # 1. Tomar datos de la operación seleccionada
            op = pedimento.ope_aduanera

            # 2. Generar semáforo automático
            pedimento.semaforo = generar_semaforo()

            # 3. Generar número de pedimento automático
            pedimento.numero_pedimento = generar_numero_pedimento(op.aduana_id)

            # 4. Fecha de registro automática
            pedimento.fecha_registro = date.today()

            pedimento.save()
            messages.success(
                request,
                f'Pedimento {pedimento.numero_pedimento} registrado. '
                f'Semáforo: {pedimento.semaforo.resultado}'
            )
            return redirect('home:pedimentos')
        else:
            messages.error(request, 'Revisa los campos del formulario.')
    else:
        form = NuevoPedimentoForm()

    query = request.GET.get('q', '')
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

    paginador = Paginator(pedimentos, 5)
    pagina_actual = request.GET.get('pagina', 1)
    pedimentos_paginados = paginador.get_page(pagina_actual)

    return render(request, 'home/pedimentos.html', {
        'pedimentos': pedimentos_paginados,
        'form': form,
        'query': query,
    })

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
    total_clientes = clientes.count()

    return render(request, 'home/clientes.html', {
        'clientes': clientes,
        'total_clientes': total_clientes,
        'form': form,
    })

@login_required
def aduanas_view(request):
    aduanas = Aduana.objects.all()
    total_aduanas = aduanas.count()
    
    return render(
        request, 
        'home/aduanas.html',
        {
            'aduanas': aduanas,
            'total_aduanas': total_aduanas
        }
    )

@login_required
def categorias_view(request):
    return render(request, 'home/categorias.html')

@login_required
def fracciones_view(request):
    return render(request, 'home/fracciones.html')

@login_required
def bitacora_view(request):
    return render(request, 'home/bitacora.html')

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

    paquetes = Paquete.objects.filter(ope_aduanera=op)
    valor_total = 0
    for paquete in paquetes:
        productos = Producto.objects.filter(paquete=paquete)
        for producto in productos:
            valor_total += float(producto.valor_unitario)

    return JsonResponse({
        'tipo_operacion': op.tipo_operacion,
        'valor_total':    round(valor_total, 2),
        'aduana_codigo':  op.aduana_id,
        'aduana_nombre':  op.aduana.nombre,
    })