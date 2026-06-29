from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ClienteViewSet, AduanaViewSet
from . import views

router = DefaultRouter()
router.register(r'clientes', ClienteViewSet, basename='clientes')
router.register(r'aduanas', AduanaViewSet, basename='aduanas')

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
    path('api/cliente/<int:pk>/', views.api_cliente_detalle, name='api_cliente_detalle'),
    path('api/cliente/<int:pk>/permiso/<str:clave>/eliminar/', views.api_permiso_eliminar, name='api_permiso_eliminar'),
    path('aduanas/', views.aduanas_view, name='aduanas'),
    path('categorias/', views.categorias_view, name='categorias'),
    path('bitacora/', views.bitacora_view, name='bitacora'),
    path('api/operacion/', views.api_datos_operacion,  name='api_operacion'),
]

urlpatterns += [
    path('api/', include(router.urls)),
]