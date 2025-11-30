"""Servicio de lectura de recursos publicados por la API."""
from __future__ import annotations

from typing import Iterable, List, Mapping

import pandas as pd

from app.services.api_client import ApiClient

RESOURCE_COLUMNS = ["ID", "Nombre Archivo", "Tipo", "Tamaño (KB)", "URL"]


class ResourceService:
    def __init__(self, api_client: ApiClient | None = None) -> None:
        self._client = api_client or ApiClient()

    def list_resources(self) -> pd.DataFrame:
        response = self._client.get("/resources")
        records = self._normalise(response.data)
        return pd.DataFrame.from_records(records, columns=RESOURCE_COLUMNS)

    @staticmethod
    def _normalise(data: Iterable[Mapping[str, object]] | object) -> List[dict]:
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
                    "Nombre Archivo": item.get("name") or item.get("title") or item.get("filename"),
                    "Tipo": item.get("type") or item.get("mime_type") or item.get("format"),
                    "Tamaño (KB)": item.get("size") or item.get("file_size") or item.get("weight"),
                    "URL": item.get("url") or item.get("path") or item.get("link"),
                }
            )
        return normalised
