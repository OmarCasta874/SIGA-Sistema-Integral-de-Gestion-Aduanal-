from django import forms
from django.contrib.auth import authenticate

from .models import Cliente
from .models import Pedimento
from .models import RegimenAduanero
from .models import SemaforoFiscal
from .models import Permiso
from .models import OperacionAduanera
from .models import Aduana
from .models import TipoImportaciones
from .models import TipoExportaciones


class LoginForm(forms.Form):
    correo = forms.EmailField(
        label='Correo electrónico',
        widget=forms.EmailInput(attrs={'class': 'siga-input', 'autofocus': True})
    )
    contrasena = forms.CharField(
        label='Contraseña',
        widget=forms.PasswordInput(attrs={'class': 'siga-input'})
    )

    def __init__(self, request=None, *args, **kwargs):
        self.request = request
        self.user_cache = None
        super().__init__(*args, **kwargs)

    def clean(self):
        cleaned = super().clean()
        correo = cleaned.get('correo')
        contrasena = cleaned.get('contrasena')

        if correo and contrasena:
            self.user_cache = authenticate(self.request, username=correo, password=contrasena)
            if self.user_cache is None:
                raise forms.ValidationError('Correo o contraseña incorrectos.')
        return cleaned

    def get_user(self):
        return self.user_cache
    
# ──────────────────────────────────────────────────────────────────
# Formulario Nuevo cliente
# ──────────────────────────────────────────────────────────────────
class NuevoClienteForm(forms.ModelForm):
    class Meta:
        model = Cliente
        fields = ['nombre', 'primer_apell', 'seg_apell', 'tipo_persona', 'RFC']
        labels = {
            'nombre': 'Nombre / Razón social',
            'primer_apell': 'Primer apellido',
            'seg_apell': 'Segundo apellido',
            'tipo_persona': 'Tipo de persona',
            'RFC': 'RFC',
        }
        widgets = {
            'nombre':       forms.TextInput(attrs={'class': 'form-input', 'placeholder': 'Ej. Carlos o Importaciones del Norte SA de CV'}),
            'primer_apell': forms.TextInput(attrs={'class': 'form-input', 'placeholder': 'Opcional para persona moral'}),
            'seg_apell':    forms.TextInput(attrs={'class': 'form-input', 'placeholder': 'Opcional'}),
            'tipo_persona': forms.Select(attrs={'class': 'form-input'},
                            choices=[('', 'Selecciona...'), ('Física', 'Física'), ('Moral', 'Moral')]),
            'RFC':          forms.TextInput(attrs={'class': 'form-input', 'placeholder': 'Ej. MALC850312HBC', 'maxlength': '13'}),
        }


# ──────────────────────────────────────────────────────────────────
# Formulario Nuevo pedimento
# ──────────────────────────────────────────────────────────────────
CLAVES_PEDIMENTO = [
    ('', 'Selecciona una clave...'),
    ('A1', 'A1 — Importación definitiva'),
    ('A2', 'A2 — Importación definitiva de franja o región fronteriza'),
    ('B1', 'B1 — Importación temporal de residente en el extranjero'),
    ('B2', 'B2 — Importación temporal para elaboración, transformación o reparación (IMMEX)'),
    ('B3', 'B3 — Importación temporal por habitante en franja o región fronteriza'),
    ('C1', 'C1 — Retorno de importación temporal al extranjero en el mismo estado'),
    ('D1', 'D1 — Importación mediante el régimen de depósito fiscal'),
    ('E1', 'E1 — Tránsito interno'),
    ('F1', 'F1 — Tránsito internacional'),
    ('G1', 'G1 — Extracción de depósito fiscal para importación definitiva'),
    ('H1', 'H1 — Extracción de depósito fiscal para exportación definitiva'),
    ('IN', 'IN — Importación con franja o región fronteriza'),
    ('RT', 'RT — Retorno de mercancías al extranjero'),
    ('V1', 'V1 — Exportación definitiva'),
    ('V2', 'V2 — Exportación definitiva de franja o región fronteriza'),
    ('X1', 'X1 — Exportación temporal para retornar al país en el mismo estado'),
    ('X2', 'X2 — Exportación temporal para elaboración, transformación o reparación'),
    ('ZZ', 'ZZ — Pedimento consolidado'),
]
class NuevoPedimentoForm(forms.ModelForm):
    class Meta:
        model = Pedimento
        fields = [
            'clave_pedimento',
            'regimen_adu',
            'permiso',
            'ope_aduanera',
            'tipo_importacion',
            'tipo_exportacion',
            'valor_total',
        ]
        labels = {
            'clave_pedimento':  'Clave (Anexo 22)',
            'regimen_adu':      'Régimen aduanero',
            'permiso':          'Permiso',
            'ope_aduanera':     'Operación aduanera',
            'tipo_importacion': 'Tipo de importación',
            'tipo_exportacion': 'Tipo de exportación',
            'valor_total':      'Valor total (MXN)',
        }
        widgets = {
            'clave_pedimento': forms.Select(
                choices=CLAVES_PEDIMENTO,
                attrs={'class': 'form-input'}
            ),
            'regimen_adu':      forms.Select(attrs={'class': 'form-input'}),
            'permiso':          forms.Select(attrs={'class': 'form-input'}),
            'ope_aduanera':     forms.Select(attrs={
                'class': 'form-input',
                'id': 'id_ope_aduanera'
            }),
            'tipo_importacion': forms.Select(attrs={
                'class': 'form-input',
                'id': 'id_tipo_importacion'
            }),
            'tipo_exportacion': forms.Select(attrs={
                'class': 'form-input',
                'id': 'id_tipo_exportacion'
            }),
            'valor_total': forms.NumberInput(attrs={
                'class': 'form-input',
                'id': 'id_valor_total',
                'readonly': True,
                'style': 'background:#f9fafb; color:#6b7280; cursor:not-allowed;',
                'step': '0.01'
            }),
        }


# ──────────────────────────────────────────────────────────────────
# Formulario Nueva Operacion Aduanera
# ──────────────────────────────────────────────────────────────────
class NuevaOperacionForm(forms.ModelForm):
    class Meta:
        model = OperacionAduanera
        fields = ['tipo_operacion', 'cliente', 'aduana']
        labels = {
            'tipo_operacion': 'Tipo de operación',
            'cliente':        'Cliente asociado',
            'aduana':         'Aduana de despacho',
        }
        widgets = {
            'tipo_operacion': forms.Select(
                choices=[
                    ('', 'Selecciona...'),
                    ('Importación', 'Importación'),
                    ('Exportación', 'Exportación'),
                    ('Tránsito', 'Tránsito'),
                ],
                attrs={'class': 'form-input'}
            ),
            'cliente': forms.Select(attrs={'class': 'form-input'}),
            'aduana':  forms.Select(attrs={'class': 'form-input'}),
        }

# ──────────────────────────────────────────────────────────────────
# Formulario Permiso
# ──────────────────────────────────────────────────────────────────
from .models import Permiso

TIPOS_PERMISO = [
    ('', 'Selecciona la autoridad...'),
    ('COFEPRIS', 'COFEPRIS — Alimentos, medicamentos y dispositivos médicos'),
    ('SENASICA', 'SENASICA — Sanidad animal y vegetal'),
    ('SEMARNAT', 'SEMARNAT — Medio ambiente y recursos naturales'),
    ('SADER', 'SADER — Agricultura y desarrollo rural'),
    ('SEDENA', 'SEDENA — Materiales y equipos militares'),
    ('SE', 'SE — Secretaría de Economía (cupos y fracciones)'),
    ('SAT-IMMEX', 'SAT — Programa IMMEX (maquila)'),
    ('CRE', 'CRE — Comisión Reguladora de Energía'),
    ('PROFEPA', 'PROFEPA — Certificado CITES (flora y fauna)'),
    ('Otro', 'Otro permiso regulatorio'),
]


class NuevoPermisoForm(forms.ModelForm):
    class Meta:
        model = Permiso
        fields = ['clave_numerica', 'tipo_permiso', 'vigencia', 'descripcion']
        labels = {
            'clave_numerica': 'Clave / Folio del permiso',
            'tipo_permiso':   'Autoridad reguladora',
            'vigencia':       'Fecha de vigencia',
            'descripcion':    'Descripción (opcional)',
        }
        widgets = {
            'clave_numerica': forms.TextInput(attrs={
                'class': 'form-input',
                'placeholder': 'Ej. PERM-COFEPRIS-2024-001'
            }),
            'tipo_permiso': forms.Select(
                choices=TIPOS_PERMISO,
                attrs={'class': 'form-input'}
            ),
            'vigencia': forms.DateInput(attrs={
                'class': 'form-input',
                'type':  'date'
            }),
            'descripcion': forms.Textarea(attrs={
                'class': 'form-input',
                'rows':  2,
                'placeholder': 'Descripción breve del permiso...'
            }),
        }