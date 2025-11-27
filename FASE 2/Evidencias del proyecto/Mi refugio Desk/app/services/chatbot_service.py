"""Servicio para gestionar contenido del chatbot."""
from __future__ import annotations

from typing import Iterable

import pandas as pd

from app.database.repositories.chatbot_repository import (
    ChatbotEntry,
    ChatbotRepository,
)


class ChatbotService:
    def __init__(self, repository: ChatbotRepository | None = None) -> None:
        self._repository = repository or ChatbotRepository()
        self._seed_defaults()

    def _seed_defaults(self) -> None:
        defaults: Iterable[ChatbotEntry] = [
            ChatbotEntry(id=None, keyword="Hola", response="¡Hola! ¿En qué puedo ayudarte hoy?"),
            ChatbotEntry(id=None, keyword="Horario", response="Nuestro horario es de 9:00 a 18:00."),
            ChatbotEntry(id=None, keyword="Contacto", response="Puedes contactarnos a info@app.com."),
        ]
        self._repository.seed_defaults(defaults)

    def list_as_dataframe(self) -> pd.DataFrame:
        return self._repository.list_entries()

    def create_entry(self, keyword: str, response: str) -> bool:
        return self._repository.create(ChatbotEntry(id=None, keyword=keyword, response=response)) is not None

    def update_entry(self, entry_id: int, keyword: str, response: str) -> None:
        self._repository.update(entry_id, ChatbotEntry(id=entry_id, keyword=keyword, response=response))

    def delete_entry(self, entry_id: int) -> None:
        self._repository.delete(entry_id)
