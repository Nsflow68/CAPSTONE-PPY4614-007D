import pathlib
import re
import time

import jwt
from django.conf import settings
from django.contrib.auth import get_user_model
from django.contrib.sessions.models import Session
from django.core.cache import cache
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase, override_settings
from django.urls import reverse

from core.jwt_auth import issue_token_pair
from core.models import Cliente, Sugerencia
from core.sanitizers import detect_sqli_payload, sanitize_plain_text

User = get_user_model()
WEB_ROOT = pathlib.Path(__file__).resolve().parent.parent


class StartupAndSmokeTests(TestCase):
    """Pruebas basicas de configuracion y rutas criticas (Meta 1)."""

    def test_debug_setting_is_boolean(self):
        self.assertIsInstance(settings.DEBUG, bool)

    def test_storages_configured_for_staticfiles(self):
        self.assertIn("staticfiles", settings.STORAGES)
        self.assertIn("BACKEND", settings.STORAGES["staticfiles"])

    def test_public_pages_respond_ok(self):
        for route_name in ("home", "acerca", "login", "register"):
            response = self.client.get(reverse(route_name))
            self.assertEqual(response.status_code, 200, f"Fallo en ruta {route_name}")

    def test_protected_routes_redirect_anonymous_users(self):
        for route_name in ("perfil", "payments:crear", "payments:historial"):
            response = self.client.get(reverse(route_name))
            self.assertEqual(response.status_code, 302, f"Ruta {route_name} debe redirigir a login")


class UIRulesComplianceTests(TestCase):
    """Auditoria automatica de reglas estrictas UI/UX (Meta 2 y Meta 4)."""

    def test_no_emojis_in_web_source_files(self):
        allowed_exts = {".py", ".html", ".css", ".js", ".sh", ".ps1", ".yml", ".yaml"}
        for path in WEB_ROOT.rglob("*"):
            if not path.is_file():
                continue
            if any(part in {".venv", ".git", "staticfiles", "__pycache__", "media"} for part in path.parts):
                continue
            if path.name.startswith("backup_"):
                continue
            if path.suffix.lower() not in allowed_exts and path.name not in {"Makefile", "Dockerfile", "Procfile"}:
                continue
            text = path.read_text(encoding="utf-8", errors="ignore")
            for idx, line in enumerate(text.splitlines(), 1):
                for ch in line:
                    cp = ord(ch)
                    is_emoji = cp >= 0x1F000 or (0x2600 <= cp <= 0x27BF) or cp in {0xFE0F, 0x200D}
                    self.assertFalse(
                        is_emoji,
                        f"Emoji detectado en {path.relative_to(WEB_ROOT)}:{idx} ({hex(cp)})",
                    )

    def test_no_pill_or_circle_classes_or_radius_above_4px(self):
        css_text = (WEB_ROOT / "static" / "css" / "main.css").read_text(encoding="utf-8")
        self.assertIn("--bs-border-radius-pill: 4px", css_text)
        self.assertNotIn("border-radius: 50%", css_text)
        self.assertNotIn("border-radius: 1rem", css_text)
        self.assertNotIn("border-radius: 0.85rem", css_text)
        self.assertNotIn("border-radius: 0.75rem", css_text)

        for tpl in (WEB_ROOT / "templates").rglob("*.html"):
            html = tpl.read_text(encoding="utf-8")
            self.assertNotIn("rounded-pill", html, f"Clase pill prohibida en {tpl.name}")
            self.assertNotIn("rounded-circle", html, f"Clase circular prohibida en {tpl.name}")
            self.assertNotIn("rounded-4", html, f"Clase rounded-4 (>4px) prohibida en {tpl.name}")

    def test_landing_contains_lazy_loading_and_no_inline_safe_xss(self):
        response = self.client.get(reverse("home"))
        html = response.content.decode("utf-8")
        self.assertIn('loading="lazy"', html)
        self.assertIn("data-lazy-section", html)
        self.assertIn('id="emergencias-pagination"', html)
        self.assertNotIn("{{ result|safe }}", (WEB_ROOT / "templates" / "donations" / "result.html").read_text(encoding="utf-8"))

    def test_emergencias_api_is_paginated_and_filterable(self):
        resp_p1 = self.client.get(reverse("api_emergencias"), {"page": 1, "page_size": 3})
        self.assertEqual(resp_p1.status_code, 200)
        data_p1 = resp_p1.json()
        self.assertEqual(len(data_p1["items"]), 3)
        self.assertEqual(data_p1["pagination"]["total_pages"], 2)
        self.assertTrue(data_p1["pagination"]["has_next"])

        resp_q = self.client.get(reverse("api_emergencias"), {"q": "4141"})
        self.assertEqual(resp_q.status_code, 200)
        self.assertEqual(len(resp_q.json()["items"]), 1)


class StatelessJWTAndSecurityTests(TestCase):
    """Pruebas de autenticacion stateless JWT, cookies HttpOnly y sanitizacion XSS/SQLi (Meta 3)."""

    def setUp(self):
        self.user = User.objects.create_user(
            username="ana_refugio",
            email="ana@mirefugio.cl",
            password="ClaveSegura!2026",
            first_name="Ana",
            last_name="Soto",
        )
        Cliente.objects.create(user=self.user, rut="11111111-1")

    def test_login_api_is_stateless_and_stores_refresh_in_httponly_cookie(self):
        resp = self.client.post(
            reverse("api_auth_login"),
            data='{"username": "ana_refugio", "password": "ClaveSegura!2026"}',
            content_type="application/json",
        )
        self.assertEqual(resp.status_code, 200)
        body = resp.json()
        self.assertIn("access_token", body)
        self.assertNotIn("refresh_token", body)
        self.assertEqual(Session.objects.count(), 0)

        refresh_cookie = resp.cookies.get(settings.JWT_REFRESH_COOKIE_NAME)
        access_cookie = resp.cookies.get(settings.JWT_ACCESS_COOKIE_NAME)
        self.assertIsNotNone(refresh_cookie)
        self.assertIsNotNone(access_cookie)
        self.assertTrue(refresh_cookie["httponly"])
        self.assertTrue(access_cookie["httponly"])

        me_resp = self.client.get(
            reverse("api_auth_me"),
            HTTP_AUTHORIZATION=f"Bearer {body['access_token']}",
        )
        self.assertEqual(me_resp.status_code, 200)
        self.assertEqual(me_resp.json()["user"]["username"], "ana_refugio")
        self.assertEqual(Session.objects.count(), 0)

    def test_expired_access_token_auto_refreshes_from_httponly_cookie(self):
        _, refresh_token, refresh_ttl = issue_token_pair(self.user, remember=False)
        expired_access = jwt.encode(
            {
                "iss": settings.JWT_ISSUER,
                "sub": str(self.user.pk),
                "username": self.user.username,
                "token_type": "access",
                "ver": "invalid",
                "iat": int(time.time()) - 1000,
                "exp": int(time.time()) - 500,
            },
            settings.JWT_SIGNING_KEY,
            algorithm=settings.JWT_ALGORITHM,
        )
        self.client.cookies[settings.JWT_ACCESS_COOKIE_NAME] = expired_access
        self.client.cookies[settings.JWT_REFRESH_COOKIE_NAME] = refresh_token

        perfil_resp = self.client.get(reverse("perfil"))
        self.assertEqual(perfil_resp.status_code, 200)
        self.assertIn(settings.JWT_ACCESS_COOKIE_NAME, perfil_resp.cookies)

        refresh_resp = self.client.post(reverse("api_auth_refresh"))
        self.assertEqual(refresh_resp.status_code, 200)
        self.assertIn("access_token", refresh_resp.json())

    def test_password_change_invalidates_prior_refresh_token_statelessly(self):
        _, old_refresh, _ = issue_token_pair(self.user, remember=False)
        self.user.set_password("NuevaClaveSegura!2026")
        self.user.save()

        self.client.cookies[settings.JWT_REFRESH_COOKIE_NAME] = old_refresh
        resp = self.client.post(reverse("api_auth_refresh"))
        self.assertEqual(resp.status_code, 401)

    def test_sqli_payloads_rejected_and_xss_sanitized(self):
        self.assertTrue(detect_sqli_payload("admin' OR '1'='1"))
        self.assertTrue(detect_sqli_payload("'; DROP TABLE auth_user; --"))
        self.assertEqual(
            sanitize_plain_text("<script>alert(1)</script>Hola <b>Mundo</b>"),
            "Hola Mundo",
        )

        sqli_resp = self.client.post(
            reverse("api_sugerencias"),
            data={
                "nombre": "Test' OR '1'='1",
                "email": "test@mirefugio.cl",
                "mensaje": "Mensaje de prueba suficientemente largo.",
            },
            HTTP_ACCEPT="application/json",
        )
        self.assertEqual(sqli_resp.status_code, 400)

    @override_settings(ASYNC_JOBS_EAGER=True, CONTACT_BYPASS_RECAPTCHA=True)
    def test_async_contact_endpoint_sanitizes_xss_and_completes_job(self):
        cache.clear()
        resp = self.client.post(
            reverse("api_sugerencias"),
            data={
                "nombre": "<script>alert(1)</script>Carlos",
                "email": "carlos@mirefugio.cl",
                "type": "pregunta",
                "mensaje": "<img src=x onerror=alert(1)>Necesito orientacion emocional.",
            },
            HTTP_ACCEPT="application/json",
        )
        self.assertEqual(resp.status_code, 202)
        payload = resp.json()
        self.assertIn("job_id", payload)
        self.assertIn("status_url", payload)

        status_resp = self.client.get(payload["status_url"])
        self.assertEqual(status_resp.status_code, 200)
        job = status_resp.json()
        self.assertEqual(job["status"], "completed")

        saved = Sugerencia.objects.get(email="carlos@mirefugio.cl")
        self.assertEqual(saved.nombre, "Carlos")
        self.assertNotIn("<script>", saved.mensaje)
        self.assertNotIn("onerror", saved.mensaje)

    def test_avatar_upload_rejects_spoofed_non_image_file(self):
        access, refresh, _ = issue_token_pair(self.user, remember=False)
        self.client.cookies[settings.JWT_ACCESS_COOKIE_NAME] = access
        self.client.cookies[settings.JWT_REFRESH_COOKIE_NAME] = refresh

        fake_img = SimpleUploadedFile(
            "payload.jpg",
            b"<html><script>alert(1)</script></html>",
            content_type="image/jpeg",
        )
        resp = self.client.post(
            reverse("perfil"),
            data={
                "first_name": "Ana",
                "last_name": "Soto",
                "email": "ana@mirefugio.cl",
                "avatar": fake_img,
            },
        )
        self.assertEqual(resp.status_code, 302)
        cliente = Cliente.objects.get(user=self.user)
        self.assertFalse(bool(cliente.avatar))
