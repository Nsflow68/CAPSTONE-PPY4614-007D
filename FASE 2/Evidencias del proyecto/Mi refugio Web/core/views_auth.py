import json
import logging

from django.contrib import messages
from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth.views import PasswordChangeView
from django.db import transaction
from django.http import HttpResponseNotAllowed, JsonResponse
from django.shortcuts import redirect, render
from django.utils.decorators import method_decorator
from django.utils.http import url_has_allowed_host_and_scheme
from django.views.decorators.csrf import csrf_protect

from .forms import RegisterForm
from .jwt_auth import (
    access_ttl_seconds,
    clear_auth_cookies,
    decode_token,
    issue_token_pair,
    resolve_user_from_payload,
    set_auth_cookies,
)
from .models import Cliente
from .sanitizers import detect_sqli_payload, sanitize_plain_text

logger = logging.getLogger(__name__)
User = get_user_model()


def _user_summary(user) -> dict:
    return {
        "id": user.pk,
        "username": user.username,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
    }


def _safe_next_url(request, default: str = "/") -> str:
    candidate = (request.POST.get("next") or request.GET.get("next") or "").strip()
    if candidate and url_has_allowed_host_and_scheme(
        url=candidate,
        allowed_hosts={request.get_host()},
        require_https=request.is_secure(),
    ):
        return candidate
    return default


def _authenticate_identifier(request, identifier: str, password: str):
    """Permite autenticar por nombre de usuario o correo electronico."""
    clean_id = sanitize_plain_text(identifier or "", multiline=False, max_length=254)
    if not clean_id or not password or detect_sqli_payload(clean_id):
        return None

    user = authenticate(request, username=clean_id, password=password)
    if user is not None:
        return user

    matched = User.objects.filter(email__iexact=clean_id, is_active=True).first()
    if matched is not None:
        return authenticate(request, username=matched.username, password=password)
    return None


def _parse_json_or_post(request) -> dict:
    sanitized_json = getattr(request, "sanitized_json", None)
    if isinstance(sanitized_json, dict):
        return sanitized_json
    if "application/json" in request.META.get("CONTENT_TYPE", "") and request.body:
        try:
            data = json.loads(request.body.decode("utf-8"))
            if isinstance(data, dict):
                return data
        except (UnicodeDecodeError, json.JSONDecodeError):
            return {}
    return request.POST


@csrf_protect
def login_view(request):
    """Vista web de login completamente stateless basada en JWT en cookies HttpOnly."""
    if request.user.is_authenticated:
        return redirect("home")

    if request.method == "POST":
        identifier = request.POST.get("username", "")
        password = request.POST.get("password", "")
        remember = request.POST.get("remember") == "on"
        user = _authenticate_identifier(request, identifier, password)

        if user is not None and user.is_active:
            access_token, refresh_token, refresh_ttl = issue_token_pair(user, remember=remember)
            response = redirect(_safe_next_url(request, "/"))
            set_auth_cookies(response, access_token, refresh_token, refresh_ttl)
            request._auth_cookies_modified = True
            return response

        form = AuthenticationForm(request, data=request.POST)
        form.add_error(None, "Credenciales invalidas.")
    else:
        form = AuthenticationForm(request)

    return render(
        request,
        "registration/login.html",
        {"form": form, "next": request.GET.get("next", "")},
    )


@csrf_protect
def register(request):
    """Registra usuario y Cliente asociado emitiendo JWT stateless en cookies HttpOnly."""
    if request.method == "POST":
        form = RegisterForm(request.POST)
        if form.is_valid():
            with transaction.atomic():
                user = form.save()
                user.is_staff = False
                user.is_superuser = False
                user.save(update_fields=["is_staff", "is_superuser"])
                Cliente.objects.create(user=user, rut=form.cleaned_data["rut"])
            access_token, refresh_token, refresh_ttl = issue_token_pair(user, remember=False)
            messages.success(request, "Registro completado. Bienvenido.")
            response = redirect("home")
            set_auth_cookies(response, access_token, refresh_token, refresh_ttl)
            request._auth_cookies_modified = True
            return response
        messages.error(request, "No pudimos crear tu cuenta. Revisa los datos.")
    else:
        form = RegisterForm()
    return render(request, "registration/register.html", {"form": form})


def logout_then_home(request):
    """Cierra la sesion stateless limpiando las cookies HttpOnly JWT."""
    messages.success(request, "Sesion cerrada correctamente.")
    response = redirect("home")
    clear_auth_cookies(response)
    request._auth_cookies_modified = True
    return response


@method_decorator(csrf_protect, name="dispatch")
class StatelessPasswordChangeView(PasswordChangeView):
    """Actualiza la contrasena y rota las cookies JWT sin usar sesiones DB."""

    template_name = "registration/password_change_form.html"

    def form_valid(self, form):
        form.save()
        access_token, refresh_token, refresh_ttl = issue_token_pair(form.user, remember=False)
        response = redirect(self.get_success_url())
        set_auth_cookies(response, access_token, refresh_token, refresh_ttl)
        self.request._auth_cookies_modified = True
        return response


@csrf_protect
def api_auth_login(request):
    """Endpoint stateless de autenticacion: retorna access_token corto y guarda refresh en cookie HttpOnly."""
    if request.method != "POST":
        return HttpResponseNotAllowed(["POST"])

    data = _parse_json_or_post(request)
    identifier = str(data.get("username") or data.get("email") or "")
    password = str(data.get("password") or "")
    remember_raw = data.get("remember", False)
    remember = remember_raw in {True, "true", "True", "1", "on", 1}

    user = _authenticate_identifier(request, identifier, password)
    if user is None or not user.is_active:
        return JsonResponse({"error": "Credenciales invalidas."}, status=401)

    access_token, refresh_token, refresh_ttl = issue_token_pair(user, remember=remember)
    response = JsonResponse(
        {
            "access_token": access_token,
            "token_type": "Bearer",
            "expires_in": access_ttl_seconds(),
            "user": _user_summary(user),
        },
        status=200,
    )
    set_auth_cookies(response, access_token, refresh_token, refresh_ttl)
    request._auth_cookies_modified = True
    return response


@csrf_protect
def api_auth_register(request):
    """Registro stateless de usuario que emite access_token y refresh token en cookie HttpOnly."""
    if request.method != "POST":
        return HttpResponseNotAllowed(["POST"])

    data = _parse_json_or_post(request)
    form = RegisterForm(data)
    if not form.is_valid():
        return JsonResponse({"error": "Datos invalidos.", "details": form.errors}, status=400)

    with transaction.atomic():
        user = form.save()
        user.is_staff = False
        user.is_superuser = False
        user.save(update_fields=["is_staff", "is_superuser"])
        Cliente.objects.create(user=user, rut=form.cleaned_data["rut"])

    access_token, refresh_token, refresh_ttl = issue_token_pair(user, remember=False)
    response = JsonResponse(
        {
            "access_token": access_token,
            "token_type": "Bearer",
            "expires_in": access_ttl_seconds(),
            "user": _user_summary(user),
        },
        status=201,
    )
    set_auth_cookies(response, access_token, refresh_token, refresh_ttl)
    request._auth_cookies_modified = True
    return response


@csrf_protect
def api_auth_refresh(request):
    """Rota el access_token y refresh_token leyendo exclusivamente la cookie HttpOnly."""
    if request.method != "POST":
        return HttpResponseNotAllowed(["POST"])

    from django.conf import settings

    refresh_cookie = getattr(settings, "JWT_REFRESH_COOKIE_NAME", "mr_refresh_token")
    refresh_token = request.COOKIES.get(refresh_cookie)
    payload = decode_token(refresh_token or "", expected_type="refresh")
    user = resolve_user_from_payload(payload)
    if user is None:
        response = JsonResponse({"error": "Refresh token ausente o invalido."}, status=401)
        clear_auth_cookies(response)
        request._auth_cookies_modified = True
        return response

    remember = bool(payload.get("remember", False))
    new_access, new_refresh, refresh_ttl = issue_token_pair(user, remember=remember)
    response = JsonResponse(
        {
            "access_token": new_access,
            "token_type": "Bearer",
            "expires_in": access_ttl_seconds(),
            "user": _user_summary(user),
        },
        status=200,
    )
    set_auth_cookies(response, new_access, new_refresh, refresh_ttl)
    request._auth_cookies_modified = True
    return response


@csrf_protect
def api_auth_logout(request):
    """Cierra la sesion stateless limpiando las cookies HttpOnly JWT."""
    if request.method != "POST":
        return HttpResponseNotAllowed(["POST"])
    response = JsonResponse({"ok": True}, status=200)
    clear_auth_cookies(response)
    request._auth_cookies_modified = True
    return response


def api_auth_me(request):
    """Devuelve el usuario autenticado mediante JWT stateless (Bearer o cookie HttpOnly)."""
    if request.method != "GET":
        return HttpResponseNotAllowed(["GET"])
    if not request.user.is_authenticated:
        return JsonResponse({"error": "No autenticado."}, status=401)
    return JsonResponse({"authenticated": True, "user": _user_summary(request.user)}, status=200)
