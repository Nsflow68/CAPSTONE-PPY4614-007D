"""
URL configuration for mirefugio project.
"""
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path

from core.views_auth import StatelessPasswordChangeView, login_view, logout_then_home

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", include("core.urls")),
    path("donar/", include(("payments.urls", "payments"), namespace="payments")),
    path("accounts/login/", login_view, name="login"),
    path("accounts/logout/", logout_then_home, name="logout"),
    path(
        "accounts/password_change/",
        StatelessPasswordChangeView.as_view(),
        name="password_change",
    ),
    path("accounts/", include("django.contrib.auth.urls")),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
