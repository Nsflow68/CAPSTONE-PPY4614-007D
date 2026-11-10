#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SETUP_ONLY=0
RUN_COLLECTSTATIC=0
for arg in "$@"; do
  case "$arg" in
    --setup-only) SETUP_ONLY=1 ;;
    --collectstatic) RUN_COLLECTSTATIC=1 ;;
  esac
done

log() {
  printf "[setup] %s\n" "$1"
}

resolve_python() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1; then
    echo "python"
  else
    printf "[error] Python 3.10+ no esta instalado en PATH.\n" >&2
    exit 1
  fi
}

PYTHON_BIN="$(resolve_python)"
VENV_DIR="$SCRIPT_DIR/.venv"

if [[ ! -d "$VENV_DIR" ]]; then
  log "Creando entorno virtual en .venv..."
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

if [[ -f "$VENV_DIR/bin/python" ]]; then
  VENV_PYTHON="$VENV_DIR/bin/python"
elif [[ -f "$VENV_DIR/Scripts/python.exe" ]]; then
  VENV_PYTHON="$VENV_DIR/Scripts/python.exe"
else
  printf "[error] No se encontro el interprete Python dentro de .venv.\n" >&2
  exit 1
fi

log "Actualizando pip e instalando dependencias..."
"$VENV_PYTHON" -m pip install --upgrade pip --quiet
"$VENV_PYTHON" -m pip install -r requirements.txt --quiet

if [[ ! -f ".env" ]]; then
  log "Creando archivo .env desde .env.example..."
  cp .env.example .env
  GENERATED_KEY="$("$VENV_PYTHON" -c 'import secrets; print(secrets.token_urlsafe(50))')"
  "$VENV_PYTHON" -c "from pathlib import Path; p = Path('.env'); p.write_text(p.read_text(encoding='utf-8').replace('replace-with-secure-random-secret-key', '''$GENERATED_KEY'''), encoding='utf-8')"
fi

mkdir -p media

log "Validando configuracion de Django..."
"$VENV_PYTHON" manage.py check

log "Aplicando migraciones de base de datos..."
"$VENV_PYTHON" manage.py migrate --noinput

if [[ "$RUN_COLLECTSTATIC" -eq 1 ]]; then
  log "Recolectando archivos estaticos..."
  "$VENV_PYTHON" manage.py collectstatic --noinput --clear >/dev/null
fi

if [[ "$SETUP_ONLY" -eq 1 ]]; then
  log "Inicializacion completada (--setup-only)."
  exit 0
fi

HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-8000}"
log "Levantando Mi Refugio Web en http://${HOST}:${PORT} ..."
exec "$VENV_PYTHON" manage.py runserver "${HOST}:${PORT}"

