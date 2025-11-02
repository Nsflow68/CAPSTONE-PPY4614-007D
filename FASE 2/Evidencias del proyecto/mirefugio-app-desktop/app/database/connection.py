"""Módulo para gestionar conexiones SQLite reutilizables."""
from __future__ import annotations

import sqlite3
from contextlib import contextmanager
from pathlib import Path
from typing import Iterator, Optional

from app.config import get_database_path


def initialise_database(db_path: Optional[Path] = None) -> None:
    """Crea el archivo de base de datos si todavía no existe."""
    path = db_path or get_database_path()
    path.touch(exist_ok=True)


@contextmanager
def get_connection(db_path: Optional[Path] = None) -> Iterator[sqlite3.Connection]:
    """Provee una conexión SQLite con commit automático y cierre seguro."""
    path = db_path or get_database_path()
    connection = sqlite3.connect(path)
    try:
        yield connection
        connection.commit()
    finally:
        connection.close()
