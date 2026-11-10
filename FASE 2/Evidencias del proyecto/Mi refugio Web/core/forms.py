from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User

from .models import Cliente
from .sanitizers import detect_sqli_payload, sanitize_email, sanitize_plain_text
from .validators import normalize_rut


class RegisterForm(UserCreationForm):
    """Formulario de registro con sanitizacion estricta, RUT y correo unicos."""

    email = forms.EmailField(required=True, label="Correo electronico")
    rut = forms.CharField(required=True, label="RUT", max_length=14)

    class Meta(UserCreationForm.Meta):
        model = User
        fields = ("username", "email", "rut", "password1", "password2")

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            css_class = field.widget.attrs.get("class", "")
            field.widget.attrs["class"] = f"{css_class} form-control".strip()

    def clean_username(self):
        raw = self.cleaned_data.get("username") or ""
        if detect_sqli_payload(raw):
            raise forms.ValidationError("Nombre de usuario no valido.")
        cleaned = sanitize_plain_text(raw, multiline=False, max_length=150)
        if not cleaned:
            raise forms.ValidationError("Ingresa un nombre de usuario valido.")
        if User.objects.filter(username__iexact=cleaned).exists():
            raise forms.ValidationError("Este nombre de usuario ya esta en uso.")
        return cleaned

    def clean_rut(self):
        value = sanitize_plain_text(self.cleaned_data.get("rut") or "", multiline=False, max_length=14)
        rut = normalize_rut(value)
        if Cliente.objects.filter(rut=rut).exists():
            raise forms.ValidationError("Este RUT ya esta registrado.")
        return rut

    def clean_email(self):
        raw_email = self.cleaned_data.get("email") or ""
        if detect_sqli_payload(raw_email):
            raise forms.ValidationError("Correo electronico no valido.")
        email = sanitize_email(raw_email)
        if User.objects.filter(email__iexact=email).exists():
            raise forms.ValidationError("Este correo ya esta registrado.")
        return email

    def save(self, commit=True):
        user = super().save(commit=False)
        user.email = self.cleaned_data["email"]
        if commit:
            user.save()
        return user
