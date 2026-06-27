from django.urls import path
from . import views

app_name = 'home'

urlpatterns = [
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('dashboard/', views.dashboard_view, name='dashboard'),
    path('operaciones/', views.operaciones_view, name='operaciones'),
    path('operaciones/nueva/', views.operacion_nueva_view,      name='operacion_nueva'),
    path('operaciones/<int:pk>/', views.operacion_detalle_view,    name='operacion_detalle'),
    path('operaciones/<int:pk>/pedimento/', views.operacion_pedimento_view,  name='operacion_pedimento'),
    path('pedimentos/', views.pedimentos_view, name='pedimentos'),
    path('clientes/', views.clientes_view, name='clientes'),
    path('clientes/<int:pk>/', views.cliente_detalle_view, name='cliente_detalle'),
    path('clientes/<int:pk>/permiso/', views.cliente_permiso_view, name='cliente_permiso'),
    path('clientes/<int:pk>/permiso/<str:clave>/eliminar/', views.cliente_permiso_eliminar_view, name='cliente_permiso_eliminar'),
    path('aduanas/', views.aduanas_view, name='aduanas'),
    path('categorias/', views.categorias_view, name='categorias'),
    path('bitacora/', views.bitacora_view, name='bitacora'),
    path('api/operacion/', views.api_datos_operacion,  name='api_operacion'),
]