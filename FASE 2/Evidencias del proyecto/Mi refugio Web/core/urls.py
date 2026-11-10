from django.urls import path

from . import views
from . import views_auth

urlpatterns = [
    path("", views.landing, name="home"),
    path("acerca/", views.acerca, name="acerca"),
    path("perfil/", views.perfil, name="perfil"),
    path("api/emergencias/", views.api_emergencias, name="api_emergencias"),
    path("api/sugerencias/", views.api_sugerencias, name="api_sugerencias"),
    path("api/jobs/<str:job_id>/", views.api_job_status, name="api_job_status"),
    path("api/auth/login/", views_auth.api_auth_login, name="api_auth_login"),
    path("api/auth/register/", views_auth.api_auth_register, name="api_auth_register"),
    path("api/auth/refresh/", views_auth.api_auth_refresh, name="api_auth_refresh"),
    path("api/auth/logout/", views_auth.api_auth_logout, name="api_auth_logout"),
    path("api/auth/me/", views_auth.api_auth_me, name="api_auth_me"),
    path("registro/", views_auth.register, name="register"),
]
