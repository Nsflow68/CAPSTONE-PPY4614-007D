"""Repositorio para gestionar usuarios del sistema."""
from __future__ import annotations

import sqlite3
from dataclasses import dataclass
from typing import Dict, List, Optional

from app.database.connection import get_connection, initialise_database


@dataclass
class UserRecord:
    username: str
    password_hash: str
    full_name: Optional[str] = None
    role: str = "user"
    id: Optional[int] = None


class UserRepository:
    def __init__(self) -> None:
        initialise_database()
        self._ensure_schema()

    def _ensure_schema(self) -> None:
        with get_connection() as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS app_users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    username TEXT NOT NULL UNIQUE,
                    password_hash TEXT NOT NULL,
                    full_name TEXT,
                    role TEXT NOT NULL DEFAULT 'user'
                )
                """
            )

    def create_user(self, user: UserRecord) -> Optional[UserRecord]:
        """Inserta un nuevo usuario y devuelve el registro creado."""
        with get_connection() as conn:
            try:
                cursor = conn.execute(
                    """
                    INSERT INTO app_users (username, password_hash, full_name, role)
                    VALUES (?, ?, ?, ?)
                    """,
                    (user.username, user.password_hash, user.full_name, user.role),
                )
            except sqlite3.IntegrityError:
                return None
        return UserRecord(
            username=user.username,
            password_hash=user.password_hash,
            full_name=user.full_name,
            role=user.role,
            id=cursor.lastrowid,
        )

    def get_user_by_username(self, username: str) -> Optional[UserRecord]:
        with get_connection() as conn:
            row = conn.execute(
                """
                SELECT id, username, password_hash, full_name, role
                FROM app_users
                WHERE username = ?
                """,
                (username,),
            ).fetchone()
        if not row:
            return None
        return UserRecord(
            username=row[1],
            password_hash=row[2],
            full_name=row[3],
            role=row[4],
            id=row[0],
        )

    def get_user_by_id(self, user_id: int) -> Optional[UserRecord]:
        with get_connection() as conn:
            row = conn.execute(
                """
                SELECT id, username, password_hash, full_name, role
                FROM app_users
                WHERE id = ?
                """,
                (user_id,),
            ).fetchone()
        if not row:
            return None
        return UserRecord(
            username=row[1],
            password_hash=row[2],
            full_name=row[3],
            role=row[4],
            id=row[0],
        )

    def list_users(self) -> List[UserRecord]:
        with get_connection() as conn:
            rows = conn.execute(
                """
                SELECT id, username, password_hash, full_name, role
                FROM app_users
                ORDER BY username COLLATE NOCASE
                """
            ).fetchall()
        return [
            UserRecord(
                id=row[0],
                username=row[1],
                password_hash=row[2],
                full_name=row[3],
                role=row[4],
            )
            for row in rows
        ]

    def update_user(
        self,
        user_id: int,
        *,
        username: Optional[str] = None,
        password_hash: Optional[str] = None,
        full_name: Optional[str] = None,
        role: Optional[str] = None,
    ) -> bool:
        """Actualiza los campos indicados para el usuario dado."""
        updates: Dict[str, str] = {}
        if username is not None:
            updates["username"] = username
        if password_hash is not None:
            updates["password_hash"] = password_hash
        if full_name is not None:
            updates["full_name"] = full_name
        if role is not None:
            updates["role"] = role

        if not updates:
            return False

        assignments = ", ".join(f"{column} = ?" for column in updates.keys())
        values: List[str] = list(updates.values()) + [user_id]
        with get_connection() as conn:
            cursor = conn.execute(
                f"UPDATE app_users SET {assignments} WHERE id = ?", values
            )
        return cursor.rowcount > 0

    def delete_user(self, user_id: int) -> bool:
        with get_connection() as conn:
            cursor = conn.execute("DELETE FROM app_users WHERE id = ?", (user_id,))
        return cursor.rowcount > 0

    def ensure_default_admin(self, username: str, password_hash: str) -> None:
        """Crea un usuario administrador si la tabla está vacía."""
        with get_connection() as conn:
            existing = conn.execute("SELECT COUNT(*) FROM app_users").fetchone()[0]
            if existing == 0:
                conn.execute(
                    """
                    INSERT INTO app_users (username, password_hash, full_name, role)
                    VALUES (?, ?, ?, 'admin')
                    """,
                    (username, password_hash, "Administrador"),
                )
