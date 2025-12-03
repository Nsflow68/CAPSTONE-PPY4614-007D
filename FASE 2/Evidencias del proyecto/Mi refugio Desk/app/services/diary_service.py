"""Servicio para consumir entradas de diario desde la API."""
from __future__ import annotations

from typing import Optional

import pandas as pd

from app.services.api_client import ApiClient, ApiClientError


class DiaryService:
    def __init__(self, api_client: Optional[ApiClient] = None) -> None:
        self._client = api_client or ApiClient()

    def list_entries(self, user_id: Optional[str] = None) -> pd.DataFrame:
        """Devuelve un DataFrame con las entradas del diario."""
        path = "/diary"
        if user_id:
            path += f"?userId={user_id}"

        response = self._client.get(path)
        data = response.data if isinstance(response.data, list) else []
        return pd.DataFrame(data)
