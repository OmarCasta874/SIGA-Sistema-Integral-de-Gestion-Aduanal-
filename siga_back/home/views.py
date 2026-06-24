from django.contrib.auth import login as auth_login, logout as auth_logout
from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect
from .forms import LoginForm
from .models import Cliente
from .models import Aduana


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

@login_required
def pedimentos_view(request):
    return render(request, 'home/pedimentos.html')

@login_required
def clientes_view(request):
    clientes = Cliente.objects.all()
    total_clientes = clientes.count()
    
    return render(
        request, 
        'home/clientes.html',
        {
            'clientes': clientes,
            'total_clientes': total_clientes
        }
    )

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