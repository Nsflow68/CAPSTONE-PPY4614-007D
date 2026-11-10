from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
import logging
import uuid

from django.conf import settings
from django.core.cache import cache
from django.db import close_old_connections

logger = logging.getLogger(__name__)

_EXECUTOR = ThreadPoolExecutor(max_workers=4, thread_name_prefix="mr-async")
_JOB_TTL_SECONDS = 3600


def _cache_key(job_id: str) -> str:
    return f"mr_async_job:{job_id}"


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _save_job_state(job_id: str, state: dict) -> None:
    cache.set(_cache_key(job_id), state, timeout=_JOB_TTL_SECONDS)


def get_async_job(job_id: str) -> dict | None:
    """Obtiene el estado actual de una tarea asincrona por ID."""
    if not job_id:
        return None
    return cache.get(_cache_key(job_id))


def _run_job(job_id: str, job_type: str, fn, args: tuple, kwargs: dict) -> None:
    close_old_connections()
    state = get_async_job(job_id) or {
        "job_id": job_id,
        "type": job_type,
        "created_at": _now_iso(),
    }
    state.update({"status": "processing", "started_at": _now_iso()})
    _save_job_state(job_id, state)

    try:
        result = fn(*args, **kwargs)
        state.update(
            {
                "status": "completed",
                "finished_at": _now_iso(),
                "result": result,
                "error": None,
            }
        )
    except Exception as exc:  # pragma: no cover - proteccion de worker
        logger.exception("Error ejecutando tarea asincrona %s (%s).", job_id, job_type)
        state.update(
            {
                "status": "failed",
                "finished_at": _now_iso(),
                "result": None,
                "error": str(exc),
            }
        )
    finally:
        _save_job_state(job_id, state)
        close_old_connections()


def submit_async_job(job_type: str, fn, *args, **kwargs) -> str:
    """
    Encola una tarea de procesamiento asincrono y devuelve su job_id inmediatamente.
    En pruebas con BD en memoria (ASYNC_JOBS_EAGER=True) ejecuta inline de forma determinista.
    """
    job_id = uuid.uuid4().hex
    _save_job_state(
        job_id,
        {
            "job_id": job_id,
            "type": job_type,
            "status": "queued",
            "created_at": _now_iso(),
            "result": None,
            "error": None,
        },
    )

    if getattr(settings, "ASYNC_JOBS_EAGER", False):
        _run_job(job_id, job_type, fn, args, kwargs)
    else:
        _EXECUTOR.submit(_run_job, job_id, job_type, fn, args, kwargs)

    return job_id

