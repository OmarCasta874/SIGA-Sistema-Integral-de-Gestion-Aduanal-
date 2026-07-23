from django import forms
from django.contrib.auth import authenticate


TIPO_PERSONA_CHOICES = [
    ('',       'Selecciona...'),
    ('Física', 'Física'),
    ('Moral',  'Moral'),
]

TIPO_OPERACION_CHOICES = [
    ('',            'Selecciona...'),
    ('Importación', 'Importación'),
    ('Exportación', 'Exportación'),
    ('Tránsito',    'Tránsito'),
]

CLAVES_PEDIMENTO = [
    ('',   'Selecciona una clave...'),
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

TIPOS_PERMISO = [
    ('',          'Selecciona la autoridad...'),
    ('COFEPRIS',  'COFEPRIS — Alimentos, medicamentos y dispositivos médicos'),
    ('SENASICA',  'SENASICA — Sanidad animal y vegetal'),
    ('SEMARNAT',  'SEMARNAT — Medio ambiente y recursos naturales'),
    ('SADER',     'SADER — Agricultura y desarrollo rural'),
    ('SEDENA',    'SEDENA — Materiales y equipos militares'),
    ('SE',        'SE — Secretaría de Economía (cupos y fracciones)'),
    ('SAT-IMMEX', 'SAT — Programa IMMEX (maquila)'),
    ('CRE',       'CRE — Comisión Reguladora de Energía'),
    ('PROFEPA',   'PROFEPA — Certificado CITES (flora y fauna)'),
    ('Otro',      'Otro permiso regulatorio'),
]


# ── Login ──────────────────────────────────────────────────────────────────────

class LoginForm(forms.Form):
    correo    = forms.EmailField(
        label='Correo electrónico',
        widget=forms.EmailInput(attrs={'class': 'siga-input', 'autofocus': True}),
    )
    contrasena = forms.CharField(
        label='Contraseña',
        widget=forms.PasswordInput(attrs={'class': 'siga-input'}),
    )

    def __init__(self, request=None, *args, **kwargs):
        self.request    = request
        self.user_cache = None
        super().__init__(*args, **kwargs)

    def clean(self):
        cleaned    = super().clean()
        correo     = cleaned.get('correo')
        contrasena = cleaned.get('contrasena')
        if correo and contrasena:
            self.user_cache = authenticate(self.request, username=correo, password=contrasena)
            if self.user_cache is None:
                raise forms.ValidationError('Correo o contraseña incorrectos.')
        return cleaned

    def get_user(self):
        return self.user_cache


# ── Cliente ────────────────────────────────────────────────────────────────────

class NuevoClienteForm(forms.Form):
    tipo_persona = forms.ChoiceField(
        label='Tipo de persona',
        choices=TIPO_PERSONA_CHOICES,
        widget=forms.Select(attrs={'class': 'form-input'}),
    )
    nombre = forms.CharField(
        max_length=80,
        label='Nombre / Razón social',
        widget=forms.TextInput(attrs={
            'class': 'form-input',
            'placeholder': 'Ej. Carlos o Importaciones del Norte SA de CV',
        }),
    )
    primer_apell = forms.CharField(
        max_length=40,
        required=False,
        label='Primer apellido',
        widget=forms.TextInput(attrs={
            'class': 'form-input',
            'placeholder': 'Opcional para persona moral',
        }),
    )
    seg_apell = forms.CharField(
        max_length=40,
        required=False,
        label='Segundo apellido',
        widget=forms.TextInput(attrs={'class': 'form-input', 'placeholder': 'Opcional'}),
    )
    RFC = forms.CharField(
        max_length=13,
        label='RFC',
        widget=forms.TextInput(attrs={
            'class': 'form-input',
            'placeholder': 'Ej. MALC850312HBC',
            'maxlength': '13',
        }),
    )
    curp = forms.CharField(
        max_length=18,
        required=False,
        label='CURP',
        widget=forms.TextInput(attrs={
            'class': 'form-input',
            'placeholder': 'Ej. MALC850312HBCRMN05',
            'maxlength': '18',
        }),
    )
    domicilio = forms.CharField(
        max_length=250,
        required=False,
        label='Domicilio fiscal',
        widget=forms.TextInput(attrs={
            'class': 'form-input',
            'placeholder': 'Calle, número, colonia, ciudad, C.P.',
        }),
    )


# ── Operación ──────────────────────────────────────────────────────────────────

class NuevaOperacionForm(forms.Form):
    tipo_operacion = forms.ChoiceField(
        label='Tipo de operación',
        choices=TIPO_OPERACION_CHOICES,
        widget=forms.Select(attrs={'class': 'form-input'}),
    )
    cliente = forms.IntegerField(
        label='Cliente asociado',
        widget=forms.HiddenInput(),
    )
    aduana = forms.IntegerField(
        label='Aduana de despacho',
        widget=forms.HiddenInput(),
    )


# ── Pedimento ──────────────────────────────────────────────────────────────────

class NuevoPedimentoForm(forms.Form):
    clave_pedimento = forms.ChoiceField(
        label='Clave (Anexo 22)',
        choices=CLAVES_PEDIMENTO,
        widget=forms.Select(attrs={'class': 'form-input'}),
    )
    regimen_adu = forms.CharField(
        label='Régimen aduanero',
        required=False,
        widget=forms.Select(attrs={'class': 'form-input'}),
    )
    permiso = forms.CharField(
        max_length=30,
        label='Permiso',
        required=False,
        widget=forms.Select(attrs={'class': 'form-input'}),
    )
    tipo_importacion = forms.CharField(
        label='Tipo de importación',
        required=False,
        widget=forms.Select(attrs={'class': 'form-input', 'id': 'id_tipo_importacion'}),
    )
    tipo_exportacion = forms.CharField(
        label='Tipo de exportación',
        required=False,
        widget=forms.Select(attrs={'class': 'form-input', 'id': 'id_tipo_exportacion'}),
    )


# ── Permiso ────────────────────────────────────────────────────────────────────

class NuevoPermisoForm(forms.Form):
    tipo_permiso = forms.ChoiceField(
        label='Autoridad reguladora',
        choices=TIPOS_PERMISO,
        widget=forms.Select(attrs={'class': 'form-input'}),
    )
    vigencia = forms.DateField(
        label='Fecha de vigencia',
        widget=forms.DateInput(attrs={'class': 'form-input', 'type': 'date'}),
    )
    descripcion = forms.CharField(
        label='Descripción (opcional)',
        required=False,
        widget=forms.Textarea(attrs={
            'class': 'form-input',
            'rows': 2,
            'placeholder': 'Descripción breve del permiso...',
        }),
    )
    
class AduanaForm(forms.Form):
    nombre = forms.CharField(
        label="Nombre",
        max_length=100,
        widget=forms.TextInput(attrs={
            "class": "form-control",
            "placeholder": "Nombre de la aduana",
        })
    )
    
    ciudad = forms.CharField(
        label="Ciudad",
        max_length=60,
        widget=forms.TextInput(attrs={
            "class": "form-control",
            "placeholder": "Nombre de la ciudad",
        })
    )