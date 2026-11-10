import html
import re
import unicodedata

import nh3
from django.core.exceptions import ValidationError

SENSITIVE_AUTH_FIELDS = frozenset(
    {
        "password",
        "password1",
        "password2",
        "old_password",
        "new_password1",
        "new_password2",
        "csrfmiddlewaretoken",
        "token_ws",
        "TBK_TOKEN",
        "g-recaptcha-response",
    }
)

_CONTROL_CHARS_RE = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]")
_DANGEROUS_URI_RE = re.compile(r"(?i)(?:javascript|vbscript|data\s*:\s*text/html)\s*:")
_SQLI_PATTERNS = (
    re.compile(r"(?i)\bunion\b(?:\s+all)?\s+\bselect\b"),
    re.compile(r"(?i)(?:'|\"|;)\s*(?:\bor\b|\band\b)\s+[\w'\"]+\s*=\s*[\w'\"]+"),
    re.compile(r"(?i);\s*(?:drop|delete|truncate|alter|insert|update|exec|execute|xp_cmdshell)\b"),
    re.compile(
        r"(?i)\b(?:waitfor\s+delay|benchmark\s*\(|sleep\s*\(|pg_sleep\s*\(|"
        r"into\s+(?:outfile|dumpfile)|load_file\s*\()"
    ),
    re.compile(r"(?i)(?:'|\")\s*(?:--|#)"),
    re.compile(r"(?is)/\*.*\*/.*\b(?:select|union|drop|insert|update|delete)\b"),
)
_XSS_HINT_RE = re.compile(
    r"(?i)<\s*(?:script|iframe|object|embed|svg|style)\b|on[a-z]{2,15}\s*=|(?:javascript|vbscript)\s*:"
)

ALLOWED_IMAGE_EXTENSIONS = frozenset({"jpg", "jpeg", "png", "webp"})


def strip_null_and_control(value: str) -> str:
    """Normaliza Unicode NFKC y remueve caracteres de control peligrosos."""
    normalized = unicodedata.normalize("NFKC", value or "")
    return _CONTROL_CHARS_RE.sub("", normalized)


def detect_sqli_payload(value: str) -> bool:
    """Detecta patrones de inyeccion SQL de alta confianza."""
    if not value:
        return False
    cleaned = strip_null_and_control(value)
    return any(pattern.search(cleaned) for pattern in _SQLI_PATTERNS)


def detect_xss_payload(value: str) -> bool:
    """Detecta vectores explicitos de XSS antes de sanitizar."""
    if not value:
        return False
    return bool(_XSS_HINT_RE.search(strip_null_and_control(value)))


def sanitize_plain_text(
    value: str,
    *,
    multiline: bool = False,
    max_length: int | None = None,
) -> str:
    """
    Sanitiza texto eliminando etiquetas HTML/JS y esquemas peligrosos
    sin doble-escapar texto plano valido en espanol.
    """
    cleaned = strip_null_and_control(value)
    cleaned = nh3.clean(cleaned, tags=set())
    cleaned = html.unescape(cleaned)
    cleaned = cleaned.replace("<", "").replace(">", "")
    cleaned = _DANGEROUS_URI_RE.sub("", cleaned)

    if multiline:
        lines = [re.sub(r"[ \t]+", " ", line).strip() for line in cleaned.splitlines()]
        cleaned = "\n".join(lines).strip()
    else:
        cleaned = re.sub(r"\s+", " ", cleaned).strip()

    if max_length is not None and max_length > 0:
        cleaned = cleaned[:max_length]
    return cleaned


def sanitize_email(value: str, max_length: int = 254) -> str:
    """Sanitiza y normaliza una direccion de correo electronico."""
    return sanitize_plain_text(value, multiline=False, max_length=max_length).lower()


def sanitize_json_payload(payload):
    """Sanitiza recursivamente cadenas dentro de objetos JSON y valida SQLi."""
    if isinstance(payload, dict):
        sanitized = {}
        for key, val in payload.items():
            key_str = str(key)
            if detect_sqli_payload(key_str):
                raise ValidationError("Nombre de campo no permitido.")
            if key_str in SENSITIVE_AUTH_FIELDS and isinstance(val, str):
                sanitized[key_str] = strip_null_and_control(val)
            else:
                sanitized[key_str] = sanitize_json_payload(val)
        return sanitized
    if isinstance(payload, list):
        return [sanitize_json_payload(item) for item in payload]
    if isinstance(payload, str):
        if detect_sqli_payload(payload):
            raise ValidationError("Entrada rechazada por politica de seguridad (SQLi).")
        return sanitize_plain_text(payload, multiline=True)
    return payload


def validate_uploaded_image(uploaded_file, max_bytes: int = 2 * 1024 * 1024) -> None:
    """Valida tamano, extension y firma binaria (magic bytes) de imagenes subidas."""
    if uploaded_file is None:
        return

    if uploaded_file.size > max_bytes:
        raise ValidationError("La imagen supera el limite permitido de 2 MB.")

    name = (getattr(uploaded_file, "name", "") or "").rsplit(".", 1)
    ext = name[-1].lower() if len(name) == 2 else ""
    if ext not in ALLOWED_IMAGE_EXTENSIONS:
        raise ValidationError("Formato de imagen no soportado. Usa JPG, PNG o WEBP.")

    pos = uploaded_file.tell() if hasattr(uploaded_file, "tell") else 0
    header = uploaded_file.read(16)
    if hasattr(uploaded_file, "seek"):
        uploaded_file.seek(pos)

    is_jpeg = header.startswith(b"\xff\xd8\xff")
    is_png = header.startswith(b"\x89PNG\r\n\x1a\n")
    is_webp = len(header) >= 12 and header[:4] == b"RIFF" and header[8:12] == b"WEBP"

    if not (is_jpeg or is_png or is_webp):
        raise ValidationError("El contenido del archivo no corresponde a una imagen valida.")

