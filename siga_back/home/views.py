from django.contrib.auth import login as auth_login, logout as auth_logout
from django.contrib.auth.decorators import login_required
from django.shortcuts import render, redirect
from .forms import LoginForm


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
def aduanas_view(request):
    return render(request, 'home/aduanas.html')

@login_required
def categorias_view(request):
    return render(request, 'home/categorias.html')

@login_required
def fracciones_view(request):
    return render(request, 'home/fracciones.html')