"""Configuración centralizada de la aplicación."""
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
DATABASE_DIR = BASE_DIR / "database"

# Aseguramos la existencia de directorios clave en tiempo de ejecución.
DATABASE_DIR.mkdir(exist_ok=True)
DATA_DIR.mkdir(exist_ok=True)

# Nombre del archivo de base de datos principal.
DEFAULT_DB_FILENAME = "mi_refugio.db"


def get_database_path(filename: str = DEFAULT_DB_FILENAME) -> Path:
    """Devuelve la ruta absoluta al archivo de base de datos solicitado."""
    return DATABASE_DIR / filename
