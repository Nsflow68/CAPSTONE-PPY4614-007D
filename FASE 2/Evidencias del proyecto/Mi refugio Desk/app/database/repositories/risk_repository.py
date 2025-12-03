"""Repositorio local (SQLite) para alertas de riesgo y palabras clave."""
from __future__ import annotations

import sqlite3
from dataclasses import dataclass
from datetime import datetime
from typing import Iterable, List, Optional

import pandas as pd

from app.database.connection import get_connection, initialise_database


@dataclass
class RiskKeyword:
    id: Optional[int]
    phrase: str
    risk_level: str  # "Alto" | "Medio"


@dataclass
class RiskAlert:
    id: str  # uuid4 hex
    diary_entry_id: Optional[str]
    user_id: Optional[str]
    user_email: Optional[str]
    user_name: Optional[str]
    text_content: str
    keyword: str
    risk_level: str
    detected_at: datetime


class RiskRepository:
    def __init__(self) -> None:
        initialise_database()
        self._ensure_schema()

    def _ensure_schema(self) -> None:
        with get_connection() as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS risk_keywords (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    phrase TEXT NOT NULL UNIQUE,
                    risk_level TEXT NOT NULL CHECK (risk_level IN ('Alto', 'Medio'))
                )
                """
            )
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS risk_alerts (
                    id TEXT PRIMARY KEY,
                    diary_entry_id TEXT,
                    user_id TEXT,
                    user_email TEXT,
                    user_name TEXT,
                    text_content TEXT NOT NULL,
                    keyword TEXT NOT NULL,
                    risk_level TEXT NOT NULL,
                    detected_at TEXT NOT NULL
                )
                """
            )
            conn.execute(
                """
                CREATE UNIQUE INDEX IF NOT EXISTS idx_risk_alerts_entry_keyword
                ON risk_alerts(diary_entry_id, keyword, text_content)
                """
            )

    # -------------------- Keywords -------------------- #
    def seed_keywords(self, entries: Iterable[RiskKeyword]) -> None:
        with get_connection() as conn:
            for entry in entries:
                conn.execute(
                    """
                    INSERT OR IGNORE INTO risk_keywords (phrase, risk_level)
                    VALUES (?, ?)
                    """,
                    (entry.phrase, entry.risk_level),
                )

    def list_keywords(self) -> pd.DataFrame:
        with get_connection() as conn:
            df = pd.read_sql_query(
                """
                SELECT id, phrase, risk_level
                FROM risk_keywords
                ORDER BY phrase COLLATE NOCASE
                """,
                conn,
            )
        return df

    def upsert_keyword(self, phrase: str, risk_level: str, keyword_id: Optional[int] = None) -> bool:
        phrase = phrase.strip()
        if not phrase:
            return False
        with get_connection() as conn:
            try:
                if keyword_id:
                    cursor = conn.execute(
                        """
                        UPDATE risk_keywords
                        SET phrase = ?, risk_level = ?
                        WHERE id = ?
                        """,
                        (phrase, risk_level, keyword_id),
                    )
                    return cursor.rowcount > 0
                else:
                    conn.execute(
                        """
                        INSERT OR IGNORE INTO risk_keywords (phrase, risk_level)
                        VALUES (?, ?)
                        """,
                        (phrase, risk_level),
                    )
                    return True
            except sqlite3.IntegrityError:
                return False

    def delete_keyword(self, keyword_id: int) -> bool:
        with get_connection() as conn:
            cursor = conn.execute("DELETE FROM risk_keywords WHERE id = ?", (keyword_id,))
        return cursor.rowcount > 0

    # -------------------- Alerts -------------------- #
    def save_alert(self, alert: RiskAlert) -> None:
        with get_connection() as conn:
            conn.execute(
                """
                INSERT INTO risk_alerts (
                    id, diary_entry_id, user_id, user_email, user_name,
                    text_content, keyword, risk_level, detected_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT(diary_entry_id, keyword, text_content) DO UPDATE SET
                    risk_level = excluded.risk_level,
                    detected_at = excluded.detected_at,
                    user_id = excluded.user_id,
                    user_email = excluded.user_email,
                    user_name = excluded.user_name
                """,
                (
                    alert.id,
                    alert.diary_entry_id,
                    alert.user_id,
                    alert.user_email,
                    alert.user_name,
                    alert.text_content,
                    alert.keyword,
                    alert.risk_level,
                    alert.detected_at.isoformat(),
                ),
            )

    def list_alerts(self) -> pd.DataFrame:
        with get_connection() as conn:
            df = pd.read_sql_query(
                """
                SELECT
                    id,
                    user_name AS usuario,
                    user_email AS email,
                    keyword AS palabra,
                    risk_level AS nivel,
                    detected_at AS fecha,
                    text_content AS texto
                FROM risk_alerts
                ORDER BY datetime(detected_at) DESC
                """,
                conn,
            )
        if not df.empty:
            df["preview"] = df["texto"].apply(lambda t: (t[:160] + "...") if isinstance(t, str) and len(t) > 160 else t)
        return df

    def clear_alerts(self) -> None:
        with get_connection() as conn:
            conn.execute("DELETE FROM risk_alerts")
