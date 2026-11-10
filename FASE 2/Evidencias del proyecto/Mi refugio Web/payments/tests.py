from decimal import Decimal

from django.conf import settings
from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse

from core.jwt_auth import issue_token_pair
from core.models import Cliente

from .models import Donation

User = get_user_model()


class DonationPaginationAndSecurityTests(TestCase):
    """Pruebas de paginacion obligatoria, endpoint asincrono y acceso JWT en donaciones (Metas 3 y 4)."""

    def setUp(self):
        self.user = User.objects.create_user(
            username="donante",
            email="donante@mirefugio.cl",
            password="ClaveSegura!2026",
        )
        self.cliente = Cliente.objects.create(user=self.user, rut="22222222-2")

        for idx in range(15):
            Donation.objects.create(
                cliente=self.cliente,
                amount=Decimal("2000.00"),
                name="Donante",
                email="donante@mirefugio.cl",
                buy_order=f"MR-TEST-{idx:03d}",
                session_id=f"sess-{idx:03d}",
                token_ws=f"tok-{idx:03d}",
                status="authorized" if idx % 2 == 0 else "initialized",
            )

        access, refresh, _ = issue_token_pair(self.user, remember=False)
        self.client.cookies[settings.JWT_ACCESS_COOKIE_NAME] = access
        self.client.cookies[settings.JWT_REFRESH_COOKIE_NAME] = refresh

    def test_donation_history_html_is_paginated(self):
        resp = self.client.get(reverse("payments:historial"), {"page": 2, "page_size": 5})
        self.assertEqual(resp.status_code, 200)
        self.assertEqual(len(resp.context["donations"]), 5)
        self.assertEqual(resp.context["paginator"].num_pages, 3)
        self.assertContains(resp, 'id="donations-pagination"')

    def test_donation_history_api_pagination_and_filter(self):
        resp = self.client.get(
            reverse("payments:api_historial"),
            {"page": 1, "page_size": 4, "status": "authorized"},
        )
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertEqual(len(data["items"]), 4)
        self.assertEqual(data["pagination"]["total_items"], 8)
        self.assertEqual(data["pagination"]["total_pages"], 2)
        self.assertTrue(data["pagination"]["has_next"])

    def test_webpay_status_requires_owner_auth(self):
        self.client.cookies.clear()
        anon_resp = self.client.get(reverse("payments:webpay_status"), {"token": "tok-001"})
        self.assertEqual(anon_resp.status_code, 401)
