"""Configuración centralizada de la aplicación."""
import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
DATABASE_DIR = BASE_DIR / "database"

# Aseguramos la existencia de directorios clave en tiempo de ejecución.
DATABASE_DIR.mkdir(exist_ok=True)
DATA_DIR.mkdir(exist_ok=True)

# Nombre del archivo de base de datos principal.
DEFAULT_DB_FILENAME = "mi_refugio.db"

# Endpoint base de la API (configurable por variable de entorno).
API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:3001/api")


def get_database_path(filename: str = DEFAULT_DB_FILENAME) -> Path:
    """Devuelve la ruta absoluta al archivo de base de datos solicitado."""
    return DATABASE_DIR / filename


def get_api_base_url() -> str:
    """Devuelve la URL base configurada para la API."""
    return API_BASE_URL
