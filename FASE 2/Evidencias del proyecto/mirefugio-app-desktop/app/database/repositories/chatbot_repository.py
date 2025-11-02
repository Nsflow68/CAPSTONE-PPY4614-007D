"""Repositorio SQLite para respuestas del chatbot."""
from __future__ import annotations

import sqlite3
from dataclasses import dataclass
from typing import Iterable, List, Optional

import pandas as pd

from app.database.connection import get_connection, initialise_database


@dataclass
class ChatbotEntry:
    id: Optional[int]
    keyword: str
    response: str


class ChatbotRepository:
    def __init__(self) -> None:
        initialise_database()
        self._ensure_schema()

    def _ensure_schema(self) -> None:
        with get_connection() as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS chatbot_responses (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    keyword TEXT NOT NULL UNIQUE,
                    response TEXT NOT NULL
                )
                """
            )

    def list_entries(self) -> pd.DataFrame:
        """Devuelve todos los registros en un DataFrame listo para la UI."""
        with get_connection() as conn:
            df = pd.read_sql_query(
                """
                SELECT
                    id AS ID,
                    keyword AS "Pregunta/Keyword",
                    response AS Respuesta
                FROM chatbot_responses
                ORDER BY keyword COLLATE NOCASE
                """,
                conn,
            )
        return df

    def list_records(self) -> List[ChatbotEntry]:
        """Devuelve los registros como objetos de dominio."""
        with get_connection() as conn:
            rows = conn.execute(
                """
                SELECT id, keyword, response
                FROM chatbot_responses
                ORDER BY keyword COLLATE NOCASE
                """
            ).fetchall()
        return [
            ChatbotEntry(id=row[0], keyword=row[1], response=row[2])
            for row in rows
        ]

    def get_by_id(self, entry_id: int) -> Optional[ChatbotEntry]:
        with get_connection() as conn:
            row = conn.execute(
                """
                SELECT id, keyword, response
                FROM chatbot_responses
                WHERE id = ?
                """,
                (entry_id,),
            ).fetchone()
        if not row:
            return None
        return ChatbotEntry(id=row[0], keyword=row[1], response=row[2])

    def create(self, entry: ChatbotEntry) -> Optional[ChatbotEntry]:
        with get_connection() as conn:
            try:
                cursor = conn.execute(
                    "INSERT INTO chatbot_responses (keyword, response) VALUES (?, ?)",
                    (entry.keyword, entry.response),
                )
            except sqlite3.IntegrityError:
                return None
        return ChatbotEntry(
            id=cursor.lastrowid,
            keyword=entry.keyword,
            response=entry.response,
        )

    def update(self, entry_id: int, entry: ChatbotEntry) -> bool:
        with get_connection() as conn:
            cursor = conn.execute(
                """
                UPDATE chatbot_responses
                SET keyword = ?, response = ?
                WHERE id = ?
                """,
                (entry.keyword, entry.response, entry_id),
            )
        return cursor.rowcount > 0

    def delete(self, entry_id: int) -> bool:
        with get_connection() as conn:
            cursor = conn.execute("DELETE FROM chatbot_responses WHERE id = ?", (entry_id,))
        return cursor.rowcount > 0

    def seed_defaults(self, entries: Iterable[ChatbotEntry]) -> None:
        """Inserta registros por defecto respetando existentes."""
        with get_connection() as conn:
            for entry in entries:
                conn.execute(
                    """
                    INSERT OR IGNORE INTO chatbot_responses (keyword, response)
                    VALUES (?, ?)
                    """,
                    (entry.keyword, entry.response),
                )
