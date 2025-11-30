"""Servicio para gestionar usuarios vía API."""
from __future__ import annotations

from typing import List, Mapping, Optional

import pandas as pd

from app.models.user import UserRecord
from app.services.api_client import ApiClient

USER_COLUMNS = ["ID", "Usuario", "Nombre", "Género", "Edad", "Rol", "Estado", "Contraseña"]


class UserService:
    def __init__(self, api_client: Optional[ApiClient] = None) -> None:
        self._client = api_client or ApiClient()

    # ------------------------------------------------------------------ #
    # API
    # ------------------------------------------------------------------ #
    def list_users(self) -> List[UserRecord]:
        response = self._client.get("/users")
        data = response.data
        if not isinstance(data, list):
            return []
        return [self._to_record(item) for item in data if isinstance(item, Mapping)]

    def list_users_dataframe(self) -> pd.DataFrame:
        return self._to_dataframe(self.list_users())

    def create_user(self, *, username: str, password: str, full_name: Optional[str], role: str) -> UserRecord:
        payload = {
            "username": username,
            "password": password,
            "full_name": full_name,
            "role": self._normalise_role(role),
        }
        response = self._client.post("/users", payload)
        data = response.data
        if isinstance(data, Mapping):
            return self._to_record(data)
        return UserRecord(id=None, username=username, full_name=full_name, role=role)

    def update_user(
        self,
        user_id: int,
        *,
        username: Optional[str] = None,
        full_name: Optional[str] = None,
        role: Optional[str] = None,
        password: Optional[str] = None,
        status: Optional[str] = None,
    ) -> UserRecord:
        payload = {k: v for k, v in {
            "username": username,
            "full_name": full_name,
            "role": self._normalise_role(role) if role else None,
            "password": password,
            "status": status,
        }.items() if v is not None}
        response = self._client.put(f"/users/{user_id}", payload)
        data = response.data
        if isinstance(data, Mapping):
            return self._to_record(data)
        return UserRecord(id=user_id, username=username or "", full_name=full_name, role=role or "user")

    def delete_user(self, user_id: int) -> None:
        self._client.delete(f"/users/{user_id}")

    # ------------------------------------------------------------------ #
    # Helpers
    # ------------------------------------------------------------------ #
    @staticmethod
    def _to_record(item: Mapping[str, object]) -> UserRecord:
        # Mapear roles provenientes de flags booleans (Django)
        role_value = item.get("role")
        if item.get("is_superuser"):
            role_value = "admin"
        elif item.get("is_staff"):
            role_value = "staff"

        status_value = item.get("status")
        if "is_active" in item:
            status_value = "Activo" if item.get("is_active") else "Inactivo"

        return UserRecord(
            id=item.get("id"),
            username=item.get("username") or item.get("email") or "",
            full_name=item.get("full_name") or item.get("name"),
            role=role_value or "user",
            password_hash=item.get("password_hash") or item.get("password"),
            gender=item.get("gender"),
            age=item.get("age"),
            status=status_value,
        )

    @staticmethod
    def _to_dataframe(users: List[UserRecord]) -> pd.DataFrame:
        records = []
        for user in users:
            records.append(
                {
                    "ID": user.id,
                    "Usuario": user.username,
                    "Nombre": user.full_name or user.username,
                    "Género": user.gender or "No especificado",
                    "Edad": user.age or "",
                    "Rol": UserService._format_role(user.role),
                    "Estado": user.status or "Activo",
                    "Contraseña": "********" if user.password_hash else "",
                }
            )
        return pd.DataFrame.from_records(records, columns=USER_COLUMNS)

    @staticmethod
    def _format_role(role: Optional[str]) -> str:
        if not role:
            return "Usuario"
        raw = role.strip().lower()
        if raw == "admin":
            return "Admin"
        return raw.title()

    @staticmethod
    def _normalise_role(role: Optional[str]) -> Optional[str]:
        if not role:
            return None
        raw = role.strip().lower()
        if raw in {"admin", "administrador"}:
            return "admin"
        if raw in {"staff", "moderador", "moderator"}:
            return "staff"
        return "user"
