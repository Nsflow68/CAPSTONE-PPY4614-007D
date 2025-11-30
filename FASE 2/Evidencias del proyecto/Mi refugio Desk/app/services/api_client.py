"""Cliente HTTP simple para consumir la API de Mi Refugio."""
from __future__ import annotations

import json
from dataclasses import dataclass
from typing import Any, Dict, Optional

import requests

from app.config import get_api_base_url

DEFAULT_BASE_URL = get_api_base_url()
DEFAULT_TIMEOUT = 10


class ApiClientError(RuntimeError):
    """Error al comunicarse con la API."""

    def __init__(self, message: str, status_code: Optional[int] = None) -> None:
        super().__init__(message)
        self.status_code = status_code


@dataclass
class ApiResponse:
    status_code: int
    data: Any


class ApiClient:
    """Wrapper ligero sobre requests para centralizar configuración y manejo de errores."""

    def __init__(
        self,
        base_url: str = DEFAULT_BASE_URL,
        *,
        timeout: int = DEFAULT_TIMEOUT,
    ) -> None:
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout
        self._session = requests.Session()
        self._session.headers.update({"Content-Type": "application/json"})

    def get(self, path: str) -> ApiResponse:
        return self._request("GET", path)

    def post(self, path: str, payload: Dict[str, Any]) -> ApiResponse:
        return self._request("POST", path, payload)

    def put(self, path: str, payload: Dict[str, Any]) -> ApiResponse:
        return self._request("PUT", path, payload)

    def delete(self, path: str) -> ApiResponse:
        return self._request("DELETE", path)

    # ------------------------------------------------------------------ #
    # Internos
    # ------------------------------------------------------------------ #
    def _request(self, method: str, path: str, payload: Optional[Dict[str, Any]] = None) -> ApiResponse:
        url = f"{self.base_url}/{path.lstrip('/')}"
        try:
            response = self._session.request(
                method=method,
                url=url,
                timeout=self.timeout,
                data=json.dumps(payload) if payload is not None else None,
            )
        except requests.RequestException as exc:
            raise ApiClientError(f"No se pudo conectar con la API: {exc}") from exc

        if not response.ok:
            detail = self._extract_error_message(response)
            raise ApiClientError(detail, status_code=response.status_code)

        try:
            data = response.json()
        except ValueError:
            raise ApiClientError("La API devolvió una respuesta inválida (no es JSON).", status_code=response.status_code)
        return ApiResponse(status_code=response.status_code, data=data)

    @staticmethod
    def _extract_error_message(response: requests.Response) -> str:
        try:
            data = response.json()
            # Buscamos mensajes comunes en las respuestas de error del backend.
            for key in ("message", "error", "detail"):
                if isinstance(data, dict) and data.get(key):
                    return str(data[key])
        except ValueError:
            pass
        return f"Error al llamar la API (HTTP {response.status_code})."
