from django import forms
from django.contrib.auth import authenticate

from .models import Cliente
from .models import Pedimento, RegimenAduanero, SemaforoFiscal, Permiso, OperacionAduanera, TipoImportaciones, TipoExportaciones

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
class NuevoPedimentoForm(forms.ModelForm):
    class Meta:
        model = Pedimento
        fields = [
            'clave_pedimento', 'fecha_registro',
            'valor_total', 'semaforo', 'regimen_adu', 'permiso',
            'ope_aduanera', 'tipo_importacion', 'tipo_exportacion'
        ]
        labels = {
            'numero_pedimento': 'Número de pedimento',
            'clave_pedimento':  'Clave (Anexo 22)',
            'fecha_registro':   'Fecha de registro',
            'valor_total':      'Valor total (MXN)',
            'semaforo':         'Semáforo fiscal',
            'regimen_adu':      'Régimen aduanero',
            'permiso':          'Permiso',
            'ope_aduanera':     'Operación aduanera',
            'tipo_importacion': 'Tipo de importación',
            'tipo_exportacion': 'Tipo de exportación',
        }
        widgets = {
            'numero_pedimento': forms.TextInput(attrs={'class': 'form-input', 'placeholder': 'Ej. 24 40 3991 4001254'}),
            'clave_pedimento':  forms.TextInput(attrs={'class': 'form-input', 'placeholder': 'Ej. A1'}),
            'fecha_registro':   forms.DateInput(attrs={'class': 'form-input', 'type': 'date'}),
            'valor_total':      forms.NumberInput(attrs={'class': 'form-input', 'placeholder': '0.00'}),
            'semaforo':         forms.Select(attrs={'class': 'form-input'}),
            'regimen_adu':      forms.Select(attrs={'class': 'form-input'}),
            'permiso':          forms.Select(attrs={'class': 'form-input'}),
            'ope_aduanera':     forms.Select(attrs={'class': 'form-input'}),
            'tipo_importacion': forms.Select(attrs={'class': 'form-input'}),
            'tipo_exportacion': forms.Select(attrs={'class': 'form-input'}),
        }