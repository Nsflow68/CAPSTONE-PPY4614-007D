from __future__ import annotations

from dataclasses import dataclass
from typing import Optional


@dataclass
class UserRecord:
    id: Optional[int]
    username: str
    full_name: Optional[str]
    role: str
    password_hash: Optional[str] = None
    gender: Optional[str] = None
    age: Optional[int] = None
    status: Optional[str] = None
