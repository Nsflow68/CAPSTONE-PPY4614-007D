from __future__ import annotations

from dataclasses import dataclass
from typing import Optional


@dataclass
class UserRecord:
    id: Optional[str]
    username: str
    full_name: Optional[str]
    role: str
    external_id: Optional[str] = None
    email: Optional[str] = None
    password_hash: Optional[str] = None
    gender: Optional[str] = None
    birthdate: Optional[str] = None
    age: Optional[int] = None
    status: Optional[str] = None
