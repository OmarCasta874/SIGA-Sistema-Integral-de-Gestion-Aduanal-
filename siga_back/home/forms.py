from django import forms
from django.contrib.auth import authenticate


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