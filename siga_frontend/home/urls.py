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
    path('api/categoria/<int:pk>/productos/', views.api_categoria_productos, name='api_categoria_productos'),
    path('api/cliente/<int:pk>/', views.api_cliente_detalle, name='api_cliente_detalle'),
    path('api/cliente/<int:pk>/permiso/<str:clave>/eliminar/', views.api_permiso_eliminar, name='api_permiso_eliminar'),
    path('aduanas/', views.aduanas_view, name='aduanas'),
    path('categorias/', views.categorias_view, name='categorias'),
    path('bitacora/', views.bitacora_view, name='bitacora'),
    path('api/operacion/', views.api_datos_operacion,  name='api_operacion'),
    path('pagos/', views.pagos_view, name='pagos'),
    path('facturas/', views.facturas_view, name='facturas'),
    path('permisos/', views.permisos_view, name='permisos'),
    path('usuarios/', views.usuarios_view, name='usuarios'),
    path('perfilusuario', views.perfilusuario_view, name='perfilusuario'),
    path('pagos', views.pagos_view, name='pagos'),
    path('facturas', views.facturas_view, name='facturas'),
    path('perfilusuario/', views.perfilusuario_view, name='perfilusuario'),
    path('semaforofiscal/', views.semaforofiscal_view, name='semaforo_fiscal'),
    path('inspecciones/', views.inspecciones_view, name='inspecciones'),
    path('sanciones/', views.sanciones_view, name='sanciones'),
    path('paquetes/', views.paquetes_view, name='paquetes'),
    path('paquetes/<int:pk>/', views.paquete_detalle_view, name='paquete_detalle'),
]