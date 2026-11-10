import hashlib
import hmac
import time
import uuid

import jwt
from django.conf import settings
from django.contrib.auth import get_user_model

User = get_user_model()


def _jwt_key() -> str:
    return getattr(settings, "JWT_SIGNING_KEY", settings.SECRET_KEY)


def _jwt_algorithm() -> str:
    return getattr(settings, "JWT_ALGORITHM", "HS256")


def _jwt_issuer() -> str:
    return getattr(settings, "JWT_ISSUER", "mi-refugio-web")


def access_ttl_seconds() -> int:
    return int(getattr(settings, "JWT_ACCESS_TTL_SECONDS", 300))


def refresh_ttl_seconds(remember: bool = False) -> int:
    if remember:
        return int(getattr(settings, "JWT_REMEMBER_TTL_SECONDS", 60 * 60 * 24 * 30))
    return int(getattr(settings, "JWT_REFRESH_TTL_SECONDS", 60 * 60 * 24 * 7))


def password_fingerprint(user) -> str:
    """Huella corta del hash de contrasena para invalidacion stateless al cambiar clave."""
    raw = (getattr(user, "password", "") or "").encode("utf-8")
    return hashlib.sha256(raw).hexdigest()[:16]


def issue_token_pair(user, *, remember: bool = False) -> tuple[str, str, int]:
    """Genera par (access_token corto, refresh_token, ttl_refresh_seg) sin estado en servidor."""
    now = int(time.time())
    access_ttl = access_ttl_seconds()
    refresh_ttl = refresh_ttl_seconds(remember=remember)
    ver = password_fingerprint(user)
    issuer = _jwt_issuer()
    key = _jwt_key()
    alg = _jwt_algorithm()

    access_payload = {
        "iss": issuer,
        "sub": str(user.pk),
        "username": user.username,
        "token_type": "access",
        "ver": ver,
        "iat": now,
        "exp": now + access_ttl,
        "jti": uuid.uuid4().hex,
    }
    refresh_payload = {
        "iss": issuer,
        "sub": str(user.pk),
        "token_type": "refresh",
        "remember": bool(remember),
        "ver": ver,
        "iat": now,
        "exp": now + refresh_ttl,
        "jti": uuid.uuid4().hex,
    }

    access_token = jwt.encode(access_payload, key, algorithm=alg)
    refresh_token = jwt.encode(refresh_payload, key, algorithm=alg)
    return access_token, refresh_token, refresh_ttl


def decode_token(token: str, *, expected_type: str) -> dict | None:
    """Decodifica y valida firma, emisor, expiracion y tipo de token JWT."""
    if not token:
        return None
    try:
        payload = jwt.decode(
            token,
            _jwt_key(),
            algorithms=[_jwt_algorithm()],
            issuer=_jwt_issuer(),
            options={"require": ["exp", "iat", "sub", "token_type", "ver"]},
        )
    except jwt.PyJWTError:
        return None

    if payload.get("token_type") != expected_type:
        return None
    return payload


def resolve_user_from_payload(payload: dict):
    """Obtiene el usuario activo si la huella de credenciales sigue vigente."""
    if not payload:
        return None
    try:
        user_id = int(payload["sub"])
    except (KeyError, TypeError, ValueError):
        return None

    user = User.objects.filter(pk=user_id, is_active=True).first()
    if user is None:
        return None

    if not hmac.compare_digest(password_fingerprint(user), str(payload.get("ver", ""))):
        return None
    return user


def set_auth_cookies(response, access_token: str, refresh_token: str, refresh_ttl: int) -> None:
    """Almacena access y refresh tokens en cookies HttpOnly seguras."""
    secure_cookie = bool(getattr(settings, "SESSION_COOKIE_SECURE", not settings.DEBUG))
    access_cookie = getattr(settings, "JWT_ACCESS_COOKIE_NAME", "mr_access_token")
    refresh_cookie = getattr(settings, "JWT_REFRESH_COOKIE_NAME", "mr_refresh_token")

    response.set_cookie(
        access_cookie,
        access_token,
        max_age=access_ttl_seconds(),
        httponly=True,
        secure=secure_cookie,
        samesite="Lax",
        path="/",
    )
    response.set_cookie(
        refresh_cookie,
        refresh_token,
        max_age=refresh_ttl,
        httponly=True,
        secure=secure_cookie,
        samesite="Lax",
        path="/",
    )


def clear_auth_cookies(response) -> None:
    """Elimina las cookies JWT de acceso y refresco."""
    access_cookie = getattr(settings, "JWT_ACCESS_COOKIE_NAME", "mr_access_token")
    refresh_cookie = getattr(settings, "JWT_REFRESH_COOKIE_NAME", "mr_refresh_token")
    response.delete_cookie(access_cookie, path="/", samesite="Lax")
    response.delete_cookie(refresh_cookie, path="/", samesite="Lax")


def extract_bearer_token(request) -> str | None:
    """Extrae el token Bearer del encabezado Authorization cuando esta presente."""
    auth_header = request.META.get("HTTP_AUTHORIZATION", "").strip()
    if not auth_header:
        return None
    parts = auth_header.split(None, 1)
    if len(parts) == 2 and parts[0].lower() == "bearer":
        return parts[1].strip()
    return None


def authenticate_request_stateless(request):
    """
    Autentica la peticion de manera 100% stateless:
    1) Authorization: Bearer <access_token> o cookie HttpOnly mr_access_token.
    2) Si el access token expiro o falta, intenta rotar usando la cookie HttpOnly mr_refresh_token.
    Devuelve (user | None, rotated_tokens_tuple | None).
    """
    access_cookie = getattr(settings, "JWT_ACCESS_COOKIE_NAME", "mr_access_token")
    refresh_cookie = getattr(settings, "JWT_REFRESH_COOKIE_NAME", "mr_refresh_token")

    bearer = extract_bearer_token(request)
    access_token = bearer or request.COOKIES.get(access_cookie)
    if access_token:
        payload = decode_token(access_token, expected_type="access")
        user = resolve_user_from_payload(payload)
        if user is not None:
            return user, None

    refresh_token = request.COOKIES.get(refresh_cookie)
    if refresh_token:
        refresh_payload = decode_token(refresh_token, expected_type="refresh")
        user = resolve_user_from_payload(refresh_payload)
        if user is not None:
            remember = bool(refresh_payload.get("remember", False))
            rotated = issue_token_pair(user, remember=remember)
            return user, rotated

    return None, None

