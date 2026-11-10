import json
import logging

from django.contrib.auth.models import AnonymousUser
from django.core.exceptions import ValidationError
from django.http import HttpResponseBadRequest, JsonResponse

from .jwt_auth import authenticate_request_stateless, set_auth_cookies
from .sanitizers import (
    SENSITIVE_AUTH_FIELDS,
    detect_sqli_payload,
    sanitize_json_payload,
    sanitize_plain_text,
    strip_null_and_control,
)

logger = logging.getLogger(__name__)


def _is_json_request(request) -> bool:
    content_type = request.META.get("CONTENT_TYPE", "")
    accept = request.META.get("HTTP_ACCEPT", "")
    return (
        request.path.startswith("/api/")
        or request.path.startswith("/donar/api/")
        or "application/json" in content_type
        or "application/json" in accept
        or request.headers.get("X-Requested-With") == "fetch"
    )


def _reject_unsafe_input(request, detail: str):
    logger.warning("Entrada rechazada por sanitizacion en %s: %s", request.path, detail)
    if _is_json_request(request):
        return JsonResponse({"error": detail, "code": "unsafe_input"}, status=400)
    return HttpResponseBadRequest(detail)


class InputSanitizationMiddleware:
    """
    Sanitiza de forma estricta todos los parametros GET, POST y cuerpos JSON entrantes
    para prevenir ataques XSS y bloquear patrones de SQLi antes de llegar a los controladores.
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.path.startswith("/static/") or request.path.startswith("/media/"):
            return self.get_response(request)

        if request.GET:
            mutable_get = request.GET.copy()
            for key in list(mutable_get.keys()):
                values = mutable_get.getlist(key)
                clean_values = []
                for val in values:
                    if detect_sqli_payload(val):
                        return _reject_unsafe_input(request, "Parametro rechazado por seguridad.")
                    clean_values.append(sanitize_plain_text(val, multiline=False))
                mutable_get.setlist(key, clean_values)
            request.GET = mutable_get

        content_type = request.META.get("CONTENT_TYPE", "")
        request.sanitized_json = None

        if request.method in {"POST", "PUT", "PATCH", "DELETE"}:
            if "application/json" in content_type and request.body:
                try:
                    raw_json = json.loads(request.body.decode("utf-8"))
                    request.sanitized_json = sanitize_json_payload(raw_json)
                except (UnicodeDecodeError, json.JSONDecodeError):
                    return _reject_unsafe_input(request, "Cuerpo JSON invalido.")
                except ValidationError as exc:
                    return _reject_unsafe_input(request, exc.message)
            elif not request.path.startswith("/admin/") and request.POST:
                mutable_post = request.POST.copy()
                for key in list(mutable_post.keys()):
                    values = mutable_post.getlist(key)
                    clean_values = []
                    for val in values:
                        if key in SENSITIVE_AUTH_FIELDS:
                            clean_values.append(strip_null_and_control(val))
                            continue
                        if detect_sqli_payload(val):
                            return _reject_unsafe_input(request, "Entrada rechazada por seguridad.")
                        multiline = key in {"mensaje", "message"}
                        clean_values.append(sanitize_plain_text(val, multiline=multiline))
                    mutable_post.setlist(key, clean_values)
                request.POST = mutable_post

        return self.get_response(request)


class StatelessJWTAuthenticationMiddleware:
    """
    Resuelve la identidad del usuario de manera completamente stateless mediante JWT
    (Authorization Bearer o cookies HttpOnly de acceso y refresco), ignorando sesiones DB.
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.path.startswith("/admin/") or request.path.startswith("/static/") or request.path.startswith("/media/"):
            return self.get_response(request)

        user, rotated_tokens = authenticate_request_stateless(request)
        request.user = user if user is not None else AnonymousUser()
        request.auth_stateless = True

        response = self.get_response(request)
        if rotated_tokens is not None and not getattr(request, "_auth_cookies_modified", False):
            access_token, refresh_token, refresh_ttl = rotated_tokens
            set_auth_cookies(response, access_token, refresh_token, refresh_ttl)
        return response

