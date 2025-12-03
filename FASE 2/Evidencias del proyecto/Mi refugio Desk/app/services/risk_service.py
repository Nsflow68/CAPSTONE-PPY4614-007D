"""Servicio local para detección de riesgo en textos de diario."""
from __future__ import annotations

import re
import unicodedata
import uuid
from dataclasses import dataclass
from datetime import datetime
from typing import List, Optional

import pandas as pd

from app.database.repositories.risk_repository import RiskAlert, RiskKeyword, RiskRepository


DEFAULT_KEYWORDS = [
    RiskKeyword(id=None, phrase="me quiero matar", risk_level="Alto"),
    RiskKeyword(id=None, phrase="quiero suicidarme", risk_level="Alto"),
    RiskKeyword(id=None, phrase="no quiero vivir", risk_level="Alto"),
    RiskKeyword(id=None, phrase="terminarlo todo", risk_level="Alto"),
    RiskKeyword(id=None, phrase="suicidio", risk_level="Alto"),
    RiskKeyword(id=None, phrase="me quiero hacer daño", risk_level="Medio"),
    RiskKeyword(id=None, phrase="autolesión", risk_level="Medio"),
    RiskKeyword(id=None, phrase="ya no puedo más", risk_level="Medio"),
]


RISK_ORDER = {"Alto": 2, "Medio": 1}


@dataclass
class Match:
    phrase: str
    risk_level: str


class RiskDetector:
    def __init__(self, repository: Optional[RiskRepository] = None) -> None:
        self.repo = repository or RiskRepository()
        self.repo.seed_keywords(DEFAULT_KEYWORDS)

    def normalize_level(self, level: str) -> str:
        raw = (level or "").strip().lower()
        if raw.startswith("a"):
            return "Alto"
        return "Medio"

    def _normalize_text(self, text: str) -> str:
        nfkd = unicodedata.normalize("NFD", text or "")
        return "".join([c for c in nfkd if unicodedata.category(c) != "Mn"]).lower()

    def get_keywords(self) -> pd.DataFrame:
        return self.repo.list_keywords()

    def add_or_update_keyword(self, phrase: str, risk_level: str, keyword_id: Optional[int] = None) -> bool:
        level = self.normalize_level(risk_level)
        return self.repo.upsert_keyword(phrase, level, keyword_id)

    def delete_keyword(self, keyword_id: int) -> bool:
        return self.repo.delete_keyword(keyword_id)

    def find_matches(self, text: str) -> List[Match]:
        if not text:
            return []
        norm_text = self._normalize_text(text)
        keywords_df = self.get_keywords()
        matches: List[Match] = []
        for _, row in keywords_df.iterrows():
            phrase = str(row["phrase"])
            level = str(row["risk_level"])
            norm_phrase = self._normalize_text(phrase)
            if norm_phrase and norm_phrase in norm_text:
                matches.append(Match(phrase=phrase, risk_level=level))
            else:
                # Regex fallback para capturar variaciones
                try:
                    pattern = re.compile(re.escape(norm_phrase), re.IGNORECASE)
                    if pattern.search(norm_text):
                        matches.append(Match(phrase=phrase, risk_level=level))
                except re.error:
                    continue
        return matches

    def _highest_level(self, levels: List[str]) -> str:
        if not levels:
            return "Medio"
        return max(levels, key=lambda lv: RISK_ORDER.get(lv, 1))

    def _build_alert(self, entry: pd.Series, match: Match) -> RiskAlert:
        return RiskAlert(
            id=uuid.uuid4().hex,
            diary_entry_id=str(entry.get("id") or entry.get("_id") or ""),
            user_id=str(entry.get("userId") or entry.get("user_id") or ""),
            user_email=str(entry.get("userEmail") or entry.get("user_email") or ""),
            user_name=str(entry.get("userName") or entry.get("username") or ""),
            text_content=str(entry.get("content") or entry.get("text_entry") or ""),
            keyword=match.phrase,
            risk_level=match.risk_level,
            detected_at=datetime.utcnow(),
        )

    def analyze_entries(self, df: pd.DataFrame) -> pd.DataFrame:
        """Analiza entradas y guarda/actualiza alertas; devuelve DataFrame de alertas."""
        if df is None or df.empty:
            return pd.DataFrame()

        for _, row in df.iterrows():
            text = str(row.get("content") or row.get("text_entry") or "")
            matches = self.find_matches(text)
            if not matches:
                continue
            highest = self._highest_level([m.risk_level for m in matches])
            matches = [Match(phrase=m.phrase, risk_level=highest) for m in matches]
            # Si hay varias coincidencias en la misma frase, se guardan todas,
            # el nivel más alto se refleja en cada coincidencia según la frase asociada.
            for m in matches:
                alert = self._build_alert(row, m)
                self.repo.save_alert(alert)

        return self.repo.list_alerts()
