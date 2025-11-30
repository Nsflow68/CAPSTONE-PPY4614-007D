"""Servicio de autenticación contra la API."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

from app.models.user import UserRecord
from app.services.api_client import ApiClient, ApiClientError


@dataclass
class AuthResult:
    success: bool
    message: str = ""
    user: Optional[UserRecord] = None


class AuthService:
    def __init__(self, api_client: Optional[ApiClient] = None) -> None:
        self._client = api_client or ApiClient()

    def authenticate(self, username: str, password: str) -> AuthResult:
        payload = {"username": username, "password": password}
        try:
            response = self._client.post("/auth/login", payload)
        except ApiClientError as exc:
            return AuthResult(False, str(exc))

        data = response.data
        if not isinstance(data, dict):
            return AuthResult(False, "Respuesta inesperada de la API.")

        if not data.get("success"):
            return AuthResult(False, data.get("message", "Credenciales inválidas."))

        user_data = data.get("user") or {}
        user = UserRecord(
            id=user_data.get("id"),
            username=user_data.get("username") or user_data.get("email") or username,
            full_name=user_data.get("full_name") or user_data.get("name"),
            role=user_data.get("role") or "user",
            password_hash=user_data.get("password_hash"),
        )
        if (user.role or "").lower() != "admin":
            return AuthResult(False, "Acceso restringido. Solo administradores.")
        return AuthResult(True, user=user)
