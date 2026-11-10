"""
Django settings for mirefugio project.
"""

from pathlib import Path
import os

from django.core.exceptions import ImproperlyConfigured
import environ

# --------------------------------------------------------------------------------------
# Paths & env
# --------------------------------------------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent.parent

env = environ.Env()
env_file = BASE_DIR / ".env"
if env_file.exists():
    environ.Env.read_env(str(env_file))

# --------------------------------------------------------------------------------------
# Core
# --------------------------------------------------------------------------------------
DEBUG = env.bool("DEBUG", default=False)
COLLECTSTATIC_BUILD = env.bool("COLLECTSTATIC_BUILD", default=False)

_DEV_FALLBACK_KEY = "django-insecure-local-dev-only-override-via-env"
SECRET_KEY = env("SECRET_KEY", default=_DEV_FALLBACK_KEY if (DEBUG or COLLECTSTATIC_BUILD) else "")
if not DEBUG and not COLLECTSTATIC_BUILD:
    if not SECRET_KEY or SECRET_KEY == _DEV_FALLBACK_KEY:
        raise ImproperlyConfigured(
            "SECRET_KEY debe configurarse con un valor seguro cuando DEBUG=False."
        )
if not SECRET_KEY:
    SECRET_KEY = _DEV_FALLBACK_KEY

ALLOWED_HOSTS = env.list(
    "ALLOWED_HOSTS",
    default=[
        "127.0.0.1",
        "localhost",
        "0.0.0.0",
        "mi-refugio-web.onrender.com",
    ],
)

CSRF_TRUSTED_ORIGINS = env.list(
    "CSRF_TRUSTED_ORIGINS",
    default=[
        "http://127.0.0.1:8000",
        "http://localhost:8000",
        "https://mi-refugio-web.onrender.com",
    ],
)

SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
USE_X_FORWARDED_HOST = True
APPEND_SLASH = True

CONTACT_BYPASS_RECAPTCHA = env.bool("CONTACT_BYPASS_RECAPTCHA", default=False)
RECAPTCHA_SITE_KEY = env("RECAPTCHA_SITE_KEY", default="")
RECAPTCHA_SECRET = env("RECAPTCHA_SECRET", default="")
DONATION_MIN_CLP = env.int("DONATION_MIN_CLP", default=500)

# --------------------------------------------------------------------------------------
# Apps
# --------------------------------------------------------------------------------------
INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "core",
    "payments",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "core.middleware.InputSanitizationMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "core.middleware.StatelessJWTAuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

MESSAGE_STORAGE = "django.contrib.messages.storage.cookie.CookieStorage"

ROOT_URLCONF = "mirefugio.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
                "core.context_processors.project_settings",
            ],
        },
    },
]

WSGI_APPLICATION = "mirefugio.wsgi.application"
ASGI_APPLICATION = "mirefugio.asgi.application"

# --------------------------------------------------------------------------------------
# Database (DATABASE_URL | SQLite local | PostgreSQL)
# --------------------------------------------------------------------------------------
DATABASE_URL = env("DATABASE_URL", default="")
DB_ENGINE = env("DB_ENGINE", default="sqlite" if DEBUG else "postgresql").strip().lower()

if DATABASE_URL:
    DATABASES = {
        "default": env.db("DATABASE_URL"),
    }
    DATABASES["default"].setdefault("CONN_MAX_AGE", env.int("DB_CONN_MAX_AGE", default=60))
    DATABASES["default"].setdefault("CONN_HEALTH_CHECKS", True)
elif DB_ENGINE in {"sqlite", "sqlite3"} or COLLECTSTATIC_BUILD:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": BASE_DIR / env("SQLITE_PATH", default="db.sqlite3"),
            "OPTIONS": {
                "timeout": 20,
            },
        }
    }
else:
    db_host = env("DB_HOST", default="")
    db_name = env("DB_NAME", default="mirefugio")
    db_user = env("DB_USER", default="")
    db_password = env("DB_PASS", default=env("DB_PASSWORD", default=""))

    if not (db_host and db_user):
        raise ImproperlyConfigured(
            "Configura DB_HOST y DB_USER (o DATABASE_URL / DB_ENGINE=sqlite) para conectar la base de datos."
        )

    pg_options = {
        "sslmode": env("DB_SSLMODE", default="disable" if DEBUG else "require"),
    }
    search_path = env("DB_SEARCH_PATH", default="web,core,public").strip()
    if search_path:
        pg_options["options"] = f"-c search_path={search_path}"

    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql",
            "NAME": db_name,
            "USER": db_user,
            "PASSWORD": db_password,
            "HOST": db_host,
            "PORT": env("DB_PORT", default="5432"),
            "OPTIONS": pg_options,
            "CONN_MAX_AGE": env.int("DB_CONN_MAX_AGE", default=60),
            "CONN_HEALTH_CHECKS": True,
        }
    }

# --------------------------------------------------------------------------------------
# Passwords
# --------------------------------------------------------------------------------------
AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

# --------------------------------------------------------------------------------------
# I18N / TZ
# --------------------------------------------------------------------------------------
LANGUAGE_CODE = "es-cl"
TIME_ZONE = "America/Santiago"
USE_I18N = True
USE_TZ = True

# --------------------------------------------------------------------------------------
# Static & Media (Django 5.2 STORAGES + Whitenoise)
# --------------------------------------------------------------------------------------
STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "staticfiles"
STATICFILES_DIRS = [BASE_DIR / "static"]

STORAGES = {
    "default": {
        "BACKEND": "django.core.files.storage.FileSystemStorage",
    },
    "staticfiles": {
        "BACKEND": (
            "django.contrib.staticfiles.storage.StaticFilesStorage"
            if DEBUG
            else "whitenoise.storage.CompressedManifestStaticFilesStorage"
        ),
    },
}

MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR / "media"

# --------------------------------------------------------------------------------------
# Seguridad
# --------------------------------------------------------------------------------------
SESSION_COOKIE_HTTPONLY = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = "DENY"

if not DEBUG:
    SECURE_SSL_REDIRECT = env.bool("SECURE_SSL_REDIRECT", default=True)
    SESSION_COOKIE_SECURE = env.bool("SESSION_COOKIE_SECURE", default=True)
    CSRF_COOKIE_SECURE = env.bool("CSRF_COOKIE_SECURE", default=True)
    SECURE_HSTS_SECONDS = env.int("SECURE_HSTS_SECONDS", default=31536000)
    SECURE_HSTS_INCLUDE_SUBDOMAINS = env.bool("SECURE_HSTS_INCLUDE_SUBDOMAINS", default=True)
    SECURE_HSTS_PRELOAD = env.bool("SECURE_HSTS_PRELOAD", default=True)
    SECURE_REFERRER_POLICY = "strict-origin-when-cross-origin"

# --------------------------------------------------------------------------------------
# Logging
# --------------------------------------------------------------------------------------
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "handlers": {
        "console": {"class": "logging.StreamHandler"},
    },
    "root": {
        "handlers": ["console"],
        "level": "INFO" if not DEBUG else "DEBUG",
    },
}

# --------------------------------------------------------------------------------------
# Transbank (Webpay)
# --------------------------------------------------------------------------------------
TBK_ENV = env("TBK_ENV", default="integration")
TBK_API_KEY_ID = env("TBK_API_KEY_ID", default="597055555532" if TBK_ENV != "production" else "")
TBK_API_KEY_SECRET = env(
    "TBK_API_KEY_SECRET",
    default=(
        "579B532A7440BB0C9079DED94D31EA1615BACEB56610332264630D42D0A36B1C"
        if TBK_ENV != "production"
        else ""
    ),
)
TBK_RETURN_URL = env(
    "TBK_RETURN_URL",
    default=(
        "http://127.0.0.1:8000/donar/retorno/"
        if DEBUG
        else "https://mi-refugio-web.onrender.com/donar/retorno/"
    ),
)

# --------------------------------------------------------------------------------------
# Auth redirects & Stateless JWT
# --------------------------------------------------------------------------------------
LOGIN_REDIRECT_URL = "/"
LOGOUT_REDIRECT_URL = "/"
LOGIN_URL = "login"

JWT_SIGNING_KEY = env("JWT_SIGNING_KEY", default=SECRET_KEY)
JWT_ALGORITHM = "HS256"
JWT_ISSUER = "mi-refugio-web"
JWT_ACCESS_TTL_SECONDS = env.int("JWT_ACCESS_TTL_SECONDS", default=300)
JWT_REFRESH_TTL_SECONDS = env.int("JWT_REFRESH_TTL_SECONDS", default=60 * 60 * 24 * 7)
JWT_REMEMBER_TTL_SECONDS = env.int("JWT_REMEMBER_TTL_SECONDS", default=60 * 60 * 24 * 30)
JWT_ACCESS_COOKIE_NAME = "mr_access_token"
JWT_REFRESH_COOKIE_NAME = "mr_refresh_token"
ASYNC_JOBS_EAGER = env.bool("ASYNC_JOBS_EAGER", default=False)

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
