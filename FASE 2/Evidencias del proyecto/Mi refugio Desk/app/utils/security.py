"""Utilidades básicas de seguridad para manejo de contraseñas."""
from __future__ import annotations

import os
import hashlib
import hmac
from typing import Tuple

PBKDF2_ITERATIONS = 390000
HASH_NAME = "sha256"
SALT_LENGTH = 16


def _derive_key(password: str, salt: bytes) -> bytes:
    return hashlib.pbkdf2_hmac(
        HASH_NAME,
        password.encode("utf-8"),
        salt,
        PBKDF2_ITERATIONS,
        dklen=32,
    )


def hash_password(password: str) -> str:
    """Genera un hash con sal en formato salt$hash (hex)."""
    salt = os.urandom(SALT_LENGTH)
    key = _derive_key(password, salt)
    return f"{salt.hex()}${key.hex()}"


def verify_password(password: str, hashed: str) -> bool:
    try:
        salt_hex, key_hex = hashed.split("$")
        salt = bytes.fromhex(salt_hex)
        expected_key = bytes.fromhex(key_hex)
    except ValueError:
        return False

    candidate_key = _derive_key(password, salt)
    return hmac.compare_digest(candidate_key, expected_key)
