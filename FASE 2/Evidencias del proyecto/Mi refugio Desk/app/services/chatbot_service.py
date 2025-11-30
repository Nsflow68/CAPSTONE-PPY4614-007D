"""Servicio para gestionar contenido del chatbot vía API."""
from __future__ import annotations

from typing import Iterable, List, Mapping

import pandas as pd

from app.services.api_client import ApiClient, ApiClientError

DEFAULT_COLUMNS = ["ID", "Pregunta/Keyword", "Respuesta"]


class ChatbotService:
    def __init__(self, api_client: ApiClient | None = None) -> None:
        self._client = api_client or ApiClient()

    def list_as_dataframe(self) -> pd.DataFrame:
        try:
            response = self._client.get("/chatbot")
        except ApiClientError:
            # Dejamos que la vista capture la excepción para mostrar feedback.
            raise

        records = self._normalise_records(response.data)
        return pd.DataFrame.from_records(records, columns=DEFAULT_COLUMNS)

    def create_entry(self, keyword: str, response: str) -> None:
        payload = {"keyword": keyword, "response": response}
        self._client.post("/chatbot", payload)

    def update_entry(self, entry_id: int, keyword: str, response: str) -> None:
        payload = {"keyword": keyword, "response": response}
        self._client.put(f"/chatbot/{entry_id}", payload)

    def delete_entry(self, entry_id: int) -> None:
        self._client.delete(f"/chatbot/{entry_id}")

    # ------------------------------------------------------------------ #
    # Helpers
    # ------------------------------------------------------------------ #
    @staticmethod
    def _normalise_records(data: Iterable[Mapping[str, object]] | object) -> List[dict]:
        if isinstance(data, Mapping):
            items = [data]
        elif isinstance(data, Iterable) and not isinstance(data, (str, bytes)):
            items = data
        else:
            return []
        normalised: List[dict] = []
        for item in items:
            if not isinstance(item, Mapping):
                continue
            normalised.append(
                {
                    "ID": item.get("id"),
                    "Pregunta/Keyword": item.get("keyword"),
                    "Respuesta": item.get("response"),
                }
            )
        return normalised
