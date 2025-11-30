"""Servicio para obtener donaciones desde la API."""
from __future__ import annotations

from typing import Dict, Optional, Tuple, List

import pandas as pd

from app.services.api_client import ApiClient, ApiClientError


class DonationService:
    def __init__(self, api_client: Optional[ApiClient] = None) -> None:
        self._client = api_client or ApiClient()

    def fetch_donations(self) -> Tuple[pd.DataFrame, Dict[str, Optional[object]]]:
        response = self._client.get("/donations")
        data = response.data
        if not isinstance(data, dict):
            raise ApiClientError("Respuesta inesperada de la API de donaciones.")

        columns: List[str] = data.get("columns") or []
        rows = data.get("data") or []

        df = pd.DataFrame(rows)
        if columns:
            df = df.reindex(columns=columns)

        # Renombramos columnas para una UI más clara.
        rename_map = {
            "id": "ID",
            "created_at": "Fecha",
            "amount": "Monto",
            "name": "Donante",
            "email": "Email",
            "currency": "Moneda",
            "message": "Mensaje",
        }
        df = df.rename(columns=rename_map)

        summary: Dict[str, Optional[object]] = {
            "total_records": data.get("total_records") or len(df),
            "total_amount": data.get("total_amount"),
            "currency": data.get("currency"),
        }
        return df, summary
