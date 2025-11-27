from __future__ import annotations

import sqlite3
from typing import List, Optional

from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field, root_validator

from app.database.repositories.chatbot_repository import (
    ChatbotEntry,
    ChatbotRepository,
)
from app.database.repositories.user_repository import UserRecord, UserRepository
from app.services.auth_service import AuthService
from app.utils.security import hash_password

app = FastAPI(title="Mi Refugio API", version="1.0.0")

_auth_service = AuthService()
_user_repository = UserRepository()
_chatbot_repository = ChatbotRepository()


# --------------------------------------------------------------------------- #
# Pydantic models
# --------------------------------------------------------------------------- #
class UserResponse(BaseModel):
    id: int
    username: str
    full_name: Optional[str] = Field(default=None, description="Nombre completo del usuario")
    role: str


class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=150)
    password: str = Field(..., min_length=6, description="Contraseña en texto plano")
    full_name: Optional[str] = Field(default=None, max_length=255)
    role: str = Field(default="user", min_length=3, max_length=50)


class UserUpdate(BaseModel):
    username: Optional[str] = Field(default=None, min_length=3, max_length=150)
    password: Optional[str] = Field(default=None, min_length=6)
    full_name: Optional[str] = Field(default=None, max_length=255)
    role: Optional[str] = Field(default=None, min_length=3, max_length=50)

    @root_validator
    def ensure_changes(cls, values: dict) -> dict:
        if not any(values.values()):
            raise ValueError("Debe proporcionar al menos un campo para actualizar.")
        return values


class LoginRequest(BaseModel):
    username: str
    password: str


class LoginResponse(BaseModel):
    message: str
    user: UserResponse


class ChatbotResponse(BaseModel):
    id: int
    keyword: str
    response: str


class ChatbotCreate(BaseModel):
    keyword: str = Field(..., min_length=1, max_length=255)
    response: str = Field(..., min_length=1)


class ChatbotUpdate(BaseModel):
    keyword: Optional[str] = Field(default=None, min_length=1, max_length=255)
    response: Optional[str] = Field(default=None, min_length=1)

    @root_validator
    def ensure_changes(cls, values: dict) -> dict:
        if not any(values.values()):
            raise ValueError("Debe proporcionar al menos un campo para actualizar.")
        return values


# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #
def _serialize_user(record: UserRecord) -> UserResponse:
    if record.id is None:
        raise ValueError("El usuario recuperado no tiene ID asignado.")
    return UserResponse(
        id=record.id,
        username=record.username,
        full_name=record.full_name,
        role=record.role,
    )


def _serialize_chatbot(entry: ChatbotEntry) -> ChatbotResponse:
    if entry.id is None:
        raise ValueError("El registro del chatbot necesita un ID válido.")
    return ChatbotResponse(id=entry.id, keyword=entry.keyword, response=entry.response)


# --------------------------------------------------------------------------- #
# Routes
# --------------------------------------------------------------------------- #
@app.get("/", tags=["health"])
def root() -> dict[str, str]:
    return {"message": "API de Mi Refugio funcionando"}


@app.post("/auth/login", response_model=LoginResponse, tags=["auth"])
def login(payload: LoginRequest) -> LoginResponse:
    """Valida las credenciales de un usuario administrador."""
    result = _auth_service.authenticate(payload.username, payload.password)
    if not result.success or not result.user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=result.message or "Credenciales inválidas.",
        )
    return LoginResponse(message="Autenticación exitosa.", user=_serialize_user(result.user))


@app.get("/users", response_model=List[UserResponse], tags=["usuarios"])
def list_users() -> List[UserResponse]:
    """Devuelve todos los usuarios registrados."""
    records = _user_repository.list_users()
    return [_serialize_user(record) for record in records]


@app.get("/users/{user_id}", response_model=UserResponse, tags=["usuarios"])
def get_user(user_id: int) -> UserResponse:
    record = _user_repository.get_user_by_id(user_id)
    if not record:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Usuario no encontrado.")
    return _serialize_user(record)


@app.post("/users", response_model=UserResponse, status_code=status.HTTP_201_CREATED, tags=["usuarios"])
def create_user(payload: UserCreate) -> UserResponse:
    username = payload.username.strip()
    if not username:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El nombre de usuario no puede estar vacío.")
    if _user_repository.get_user_by_username(username):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El nombre de usuario ya existe.")
    role = payload.role.strip() or "user"
    full_name = payload.full_name.strip() if payload.full_name else None
    record = UserRecord(
        username=username,
        password_hash=hash_password(payload.password),
        full_name=full_name,
        role=role,
    )
    created = _user_repository.create_user(record)
    if not created:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="No se pudo crear el usuario.")
    return _serialize_user(created)


@app.put("/users/{user_id}", response_model=UserResponse, tags=["usuarios"])
def update_user(user_id: int, payload: UserUpdate) -> UserResponse:
    existing = _user_repository.get_user_by_id(user_id)
    if not existing:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Usuario no encontrado.")

    updates: dict[str, Optional[str]] = {}
    if payload.username is not None:
        username = payload.username.strip()
        if not username:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El nombre de usuario no puede estar vacío.")
        updates["username"] = username
    if payload.full_name is not None:
        full_name = payload.full_name.strip()
        updates["full_name"] = full_name or None
    if payload.role is not None:
        role = payload.role.strip()
        if not role:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El rol no puede estar vacío.")
        updates["role"] = role
    if payload.password is not None:
        updates["password_hash"] = hash_password(payload.password)

    try:
        updated = _user_repository.update_user(user_id, **updates)
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El nombre de usuario ya está en uso.")

    if not updated:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No se detectaron cambios.")
    refreshed = _user_repository.get_user_by_id(user_id)
    if not refreshed:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Usuario no encontrado tras la actualización.")
    return _serialize_user(refreshed)


@app.delete("/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["usuarios"])
def delete_user(user_id: int) -> None:
    deleted = _user_repository.delete_user(user_id)
    if not deleted:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Usuario no encontrado.")


@app.get("/chatbot", response_model=List[ChatbotResponse], tags=["chatbot"])
def list_chatbot_entries() -> List[ChatbotResponse]:
    entries = _chatbot_repository.list_records()
    return [_serialize_chatbot(entry) for entry in entries]


@app.get("/chatbot/{entry_id}", response_model=ChatbotResponse, tags=["chatbot"])
def get_chatbot_entry(entry_id: int) -> ChatbotResponse:
    entry = _chatbot_repository.get_by_id(entry_id)
    if not entry:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Entrada no encontrada.")
    return _serialize_chatbot(entry)


@app.post("/chatbot", response_model=ChatbotResponse, status_code=status.HTTP_201_CREATED, tags=["chatbot"])
def create_chatbot_entry(payload: ChatbotCreate) -> ChatbotResponse:
    keyword = payload.keyword.strip()
    response = payload.response.strip()
    if not keyword or not response:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="La palabra clave y la respuesta no pueden estar vacías.")
    created = _chatbot_repository.create(ChatbotEntry(id=None, keyword=keyword, response=response))
    if not created:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Ya existe una entrada con esa palabra clave.")
    return _serialize_chatbot(created)


@app.put("/chatbot/{entry_id}", response_model=ChatbotResponse, tags=["chatbot"])
def update_chatbot_entry(entry_id: int, payload: ChatbotUpdate) -> ChatbotResponse:
    existing = _chatbot_repository.get_by_id(entry_id)
    if not existing:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Entrada no encontrada.")

    keyword = payload.keyword.strip() if payload.keyword is not None else existing.keyword
    response = payload.response.strip() if payload.response is not None else existing.response
    if payload.keyword is not None and not keyword:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="La palabra clave no puede estar vacía.")
    if payload.response is not None and not response:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="La respuesta no puede estar vacía.")

    try:
        updated = _chatbot_repository.update(entry_id, ChatbotEntry(id=entry_id, keyword=keyword, response=response))
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="La palabra clave ya está en uso.")

    if not updated:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No se detectaron cambios.")
    refreshed = _chatbot_repository.get_by_id(entry_id)
    if not refreshed:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Entrada no encontrada tras la actualización.")
    return _serialize_chatbot(refreshed)


@app.delete("/chatbot/{entry_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["chatbot"])
def delete_chatbot_entry(entry_id: int) -> None:
    deleted = _chatbot_repository.delete(entry_id)
    if not deleted:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Entrada no encontrada.")
