from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views
from .views import DashboardAPIView

router = DefaultRouter()
router.register(r'clientes',          views.ClienteViewSet,         basename='cliente')
router.register(r'aduanas',           views.AduanaViewSet,          basename='aduana')
router.register(r'operaciones',       views.OperacionViewSet,       basename='operacion')
router.register(r'pedimentos',        views.PedimentoViewSet,       basename='pedimento')
router.register(r'bitacora',          views.BitacoraViewSet,        basename='bitacora')
router.register(r'categorias',        views.CategoriaViewSet,       basename='categoria')
router.register(r'regimenes',         views.RegimenViewSet,         basename='regimen')
router.register(r'tipos-importacion', views.TipoImportacionViewSet, basename='tipo-importacion')
router.register(r'tipos-exportacion', views.TipoExportacionViewSet, basename='tipo-exportacion')
router.register(r'usuarios',          views.UsuarioViewSet,         basename='usuario')
router.register(r'permisos',          views.PermisoViewSet,         basename='permiso')
router.register(r'pagos',            views.PagoViewSet,            basename='pago')
router.register(r'facturas',         views.FacturaViewSet,         basename='factura')
router.register(r'sanciones',        views.SancionViewSet,         basename='sancion')
router.register(r'paquetes',         views.PaqueteViewSet,         basename='paquete')
router.register(r'semaforos',         views.SemaforoFiscalViewSet, basename='semaforos')
router.register(r'inspecciones',      views.InspeccionViewSet,     basename='inspeccion')

urlpatterns = [
    path('auth/login/',  views.AuthLoginView.as_view(),  name='api-auth-login'),
    path('auth/logout/', views.AuthLogoutView.as_view(), name='api-auth-logout'),
    path('auth/me/',     views.AuthMeView.as_view(),     name='api-auth-me'),
    path(
        'clientes/<int:pk>/permisos/<str:clave>/',
        views.PermisoDeleteView.as_view(),
        name='api-permiso-delete',
    ),
    path('dashboard/', DashboardAPIView.as_view(), name='dashboard'),
    path('', include(router.urls)),
]
