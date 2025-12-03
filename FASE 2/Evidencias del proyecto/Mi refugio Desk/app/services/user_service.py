"""Servicio para gestionar usuarios vía API."""
from __future__ import annotations

from typing import List, Mapping, Optional

import pandas as pd

from app.models.user import UserRecord
from app.services.api_client import ApiClient

USER_COLUMNS = ["Email", "Usuario", "Nombre", "Género", "Edad", "Rol", "Estado", "Contraseña", "Fecha Nacimiento"]



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

    def create_user(self, *, username: str, password: str, full_name: Optional[str], role: str, email: Optional[str] = None, gender: Optional[str] = None, birthdate: Optional[str] = None) -> UserRecord:
        payload = {
            "username": username,
            "password": password,
            "full_name": full_name,
            "role": self._normalise_role(role),
            "email": email,
            "gender": gender,
            "birthday": birthdate,
            "birthdate": birthdate,
        }
        response = self._client.post("/users", payload)
        data = response.data
        if isinstance(data, Mapping):
            return self._to_record(data)
        return UserRecord(id=None, username=username, full_name=full_name, role=role)

    def update_user(
        self,
        user_id: str,
        *,
        username: Optional[str] = None,
        full_name: Optional[str] = None,
        role: Optional[str] = None,
        password: Optional[str] = None,
        status: Optional[str] = None,
        email: Optional[str] = None,
        gender: Optional[str] = None,
        birthdate: Optional[str] = None,
    ) -> UserRecord:
        # No enviar password si viene vacío (no se actualiza)
        password_to_send = password.strip() if isinstance(password, str) else password
        if password_to_send == "":
            password_to_send = None

        payload = {k: v for k, v in {
            "username": username,
            "full_name": full_name,
            "role": self._normalise_role(role) if role else None,
            "password": password_to_send,
            "status": status,
            "email": email,
            "gender": gender,
            "birthday": birthdate,
            "birthdate": birthdate,
        }.items() if v is not None}
        response = self._client.put(f"/users/{user_id}", payload)
        data = response.data
        if isinstance(data, Mapping):
            return self._to_record(data)
        return UserRecord(id=user_id, external_id=user_id, username=username or "", full_name=full_name, role=role or "user")

    def delete_user(self, user_id: str) -> None:
        self._client.delete(f"/users/{user_id}")

    # ------------------------------------------------------------------ #
    # Helpers
    # ------------------------------------------------------------------ #
    @staticmethod
    def _format_date(value: Optional[str]) -> str:
        if not value:
            return ""
        try:
            dt = pd.to_datetime(value, errors="coerce")
            if pd.isna(dt):
                return str(value)
            return dt.strftime("%d/%m/%Y")
        except Exception:
            return str(value)

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

        external_id = item.get("external_id") or item.get("id")

        return UserRecord(
            id=external_id,
            external_id=external_id,
            username=item.get("username") or item.get("email") or "",
            full_name=item.get("full_name") or item.get("name"),
            email=item.get("email"),
            role=role_value or "user",
            password_hash=item.get("password_hash") or item.get("password"),
            gender=item.get("gender"),
            birthdate=item.get("birthday") or item.get("birthdate"),
            age=item.get("age"),
            status=status_value,
        )

    @staticmethod
    def _to_dataframe(users: List[UserRecord]) -> pd.DataFrame:
        records = []
        for idx, user in enumerate(users, start=1):
            email = user.email or ""
            age_value = user.age
            birthdate_val = getattr(user, "birthdate", None) if hasattr(user, "birthdate") else None
            if (age_value is None or age_value == "") and birthdate_val:
                try:
                    age_value = pd.to_datetime("today").year - pd.to_datetime(birthdate_val).year
                except Exception:
                    age_value = ""
            formatted_birthdate = UserService._format_date(birthdate_val)
            password_display = "Contraseña hasheada" if user.password_hash else ""
            internal_id = getattr(user, "external_id", None) or getattr(user, "id", None) or str(idx)
            records.append(
                {
                    "Email": email,
                    "Usuario": user.username,
                    "Nombre": user.full_name or user.username,
                    "Género": user.gender or "No especificado",
                    "Edad": age_value or "",
                    "Rol": UserService._format_role(user.role),
                    "Estado": user.status or "Activo",
                    "Contraseña": password_display,
                    "Fecha Nacimiento": formatted_birthdate,
                    "_id_internal": str(internal_id),  # ID oculto (uuid o fallback)
                }
            )
        df = pd.DataFrame.from_records(records)
        if "Email" not in df:
            df.insert(0, "Email", "")
        return df


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
        if raw in {"member", "miembro"}:
            return "member"
        return "user"
