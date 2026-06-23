from django.urls import path
from . import views

app_name = 'home'

urlpatterns = [
    path('login/',     views.login_view,     name='login'),
    path('logout/',    views.logout_view,    name='logout'),
    path('dashboard/', views.dashboard_view, name='dashboard'),
    path('operaciones/', views.operaciones_view, name='operaciones'),
    path('pedimentos/', views.pedimentos_view, name='pedimentos'),
    path('aduanas/', views.aduanas_view, name='aduanas'),
    path('categorias/', views.categorias_view, name='categorias'),
    path('fracciones/', views.fracciones_view, name='fracciones'),
]