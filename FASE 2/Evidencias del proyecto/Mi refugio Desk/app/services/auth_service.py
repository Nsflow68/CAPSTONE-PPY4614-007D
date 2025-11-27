"""Servicio de autenticación de usuarios."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

from app.database.repositories.user_repository import UserRepository, UserRecord
from app.utils.security import hash_password, verify_password


@dataclass
class AuthResult:
    success: bool
    message: str = ""
    user: Optional[UserRecord] = None


class AuthService:
    def __init__(self, repository: Optional[UserRepository] = None) -> None:
        self._repository = repository or UserRepository()
        self._repository.ensure_default_admin(
            username="admin",
            password_hash=hash_password("admin123"),
        )

    def authenticate(self, username: str, password: str) -> AuthResult:
        user = self._repository.get_user_by_username(username)
        if not user:
            return AuthResult(False, "Credenciales inválidas.")
        if not verify_password(password, user.password_hash):
            return AuthResult(False, "Credenciales inválidas.")
        if (user.role or "").lower() != "admin":
            return AuthResult(False, "Acceso restringido. Solo administradores.")
        return AuthResult(True, user=user)

    def register_user(
        self,
        username: str,
        password: str,
        full_name: Optional[str] = None,
        role: str = "user",
    ) -> AuthResult:
        if self._repository.get_user_by_username(username):
            return AuthResult(False, "El usuario ya existe.")
        record = UserRecord(
            username=username,
            password_hash=hash_password(password),
            full_name=full_name,
            role=role,
        )
        created = self._repository.create_user(record)
        if not created:
            return AuthResult(False, "No se pudo crear el usuario.")
        return AuthResult(True, "Usuario creado correctamente.", user=created)
