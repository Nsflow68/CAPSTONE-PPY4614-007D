import json
import logging
import os

import requests
from django.conf import settings
from django.contrib import messages
from django.contrib.auth import get_user_model
from django.contrib.auth.decorators import login_required
from django.core.exceptions import ValidationError
from django.core.paginator import Paginator
from django.core.validators import validate_email
from django.http import HttpResponseNotAllowed, JsonResponse
from django.shortcuts import redirect, render
from django.urls import reverse
from django.views.decorators.csrf import csrf_protect

from .async_jobs import get_async_job, submit_async_job
from .models import Cliente, Sugerencia
from .sanitizers import (
    detect_sqli_payload,
    sanitize_email,
    sanitize_plain_text,
    validate_uploaded_image,
)

logger = logging.getLogger(__name__)
CONTACT_SECTION = "/#contacto"
ALLOWED_SUGGESTION_TYPES = frozenset({"", "pregunta", "sugerencia", "otro"})
User = get_user_model()

EMERGENCY_DIRECTORY = (
    {
        "code": "*4141",
        "title": "Prevención del suicidio",
        "description": "Atención 24/7, gratuita y confidencial por profesionales especializados.",
        "schedule": "24/7",
        "category": "Crisis",
    },
    {
        "code": "600 360 7777",
        "title": "Salud Responde (MINSAL)",
        "description": "Orientación de salud 24/7 y derivación directa a la red pública.",
        "schedule": "24/7",
        "category": "Salud Pública",
    },
    {
        "code": "1455",
        "title": "Violencias de género (Sernameg)",
        "description": "Atención gratuita para víctimas o testigos de violencia de género.",
        "schedule": "08:00 - 24:00",
        "category": "Protección",
    },
    {
        "code": "131 / 132 / 133 / 134",
        "title": "Emergencias generales",
        "description": "131 SAMU, 132 Bomberos, 133 Carabineros y 134 PDI en todo el país.",
        "schedule": "24/7",
        "category": "Urgencias",
    },
    {
        "code": "800 200 818",
        "title": "Fono Infancia",
        "description": "Apoyo psicológico gratuito en crianza de niños, niñas y adolescentes.",
        "schedule": "Lunes a Viernes",
        "category": "Infancia",
    },
)


def _wants_json(request) -> bool:
    accept = request.META.get("HTTP_ACCEPT", "")
    content_type = request.META.get("CONTENT_TYPE", "")
    return (
        "application/json" in accept
        or "application/json" in content_type
        or request.headers.get("X-Requested-With") == "fetch"
    )


def _create_sugerencia_record(nombre: str, email: str, mensaje: str) -> dict:
    obj = Sugerencia.objects.create(nombre=nombre, email=email, mensaje=mensaje)
    return {
        "id": obj.pk,
        "nombre": obj.nombre,
        "creado": obj.creado.isoformat(),
        "message": "Sugerencia registrada correctamente.",
    }


def landing(request):
    """Pantalla principal del sitio con directorio de emergencias paginado."""
    paginator = Paginator(EMERGENCY_DIRECTORY, 3)
    emergencies_page = paginator.get_page(request.GET.get("emergencias_page", 1))
    context = {
        "recaptcha_site_key": getattr(settings, "RECAPTCHA_SITE_KEY", ""),
        "contact_bypass_recaptcha": getattr(settings, "CONTACT_BYPASS_RECAPTCHA", False),
        "emergencies_page": emergencies_page,
        "emergencies_paginator": paginator,
    }
    return render(request, "index.html", context)


def api_emergencias(request):
    """Endpoint paginado de lineas de emergencia psicologica para consumo asincrono."""
    if request.method != "GET":
        return HttpResponseNotAllowed(["GET"])

    query = sanitize_plain_text(request.GET.get("q") or "", multiline=False, max_length=60).lower()
    items = list(EMERGENCY_DIRECTORY)
    if query:
        items = [
            entry
            for entry in items
            if query in entry["code"].lower()
            or query in entry["title"].lower()
            or query in entry["description"].lower()
            or query in entry["category"].lower()
        ]

    try:
        page_size = max(1, min(int(request.GET.get("page_size", "3")), 10))
    except (TypeError, ValueError):
        page_size = 3

    paginator = Paginator(items, page_size)
    page_obj = paginator.get_page(request.GET.get("page", 1))

    return JsonResponse(
        {
            "items": list(page_obj.object_list),
            "pagination": {
                "page": page_obj.number,
                "page_size": page_size,
                "total_items": paginator.count,
                "total_pages": paginator.num_pages,
                "has_next": page_obj.has_next(),
                "has_previous": page_obj.has_previous(),
                "next_page": page_obj.next_page_number() if page_obj.has_next() else None,
                "previous_page": page_obj.previous_page_number() if page_obj.has_previous() else None,
            },
        },
        status=200,
    )


def acerca(request):
    """Pagina estatica con informacion del proyecto."""
    return render(request, "acerca.html")


@csrf_protect
@login_required(login_url="login")
def perfil(request):
    """Ficha resumida del perfil de usuario con sanitizacion y validacion de imagen."""
    cliente, _ = Cliente.objects.get_or_create(user=request.user)

    if request.method == "POST":
        raw_first = request.POST.get("first_name")
        raw_last = request.POST.get("last_name")
        raw_email = request.POST.get("email")

        first_name = sanitize_plain_text(
            raw_first if raw_first is not None else request.user.first_name,
            multiline=False,
            max_length=150,
        )
        last_name = sanitize_plain_text(
            raw_last if raw_last is not None else request.user.last_name,
            multiline=False,
            max_length=150,
        )
        email = sanitize_email(raw_email if raw_email is not None else request.user.email)
        avatar = request.FILES.get("avatar")

        try:
            validate_email(email)
        except ValidationError:
            messages.error(request, "Ingresa un correo valido.")
            return redirect("perfil")

        if (
            User.objects.filter(email__iexact=email)
            .exclude(pk=request.user.pk)
            .exists()
        ):
            messages.error(request, "Este correo ya esta registrado en otra cuenta.")
            return redirect("perfil")

        if avatar:
            try:
                validate_uploaded_image(avatar)
            except ValidationError as exc:
                messages.error(request, exc.message)
                return redirect("perfil")

        request.user.first_name = first_name
        request.user.last_name = last_name
        request.user.email = email
        request.user.save(update_fields=["first_name", "last_name", "email"])

        if avatar:
            cliente.avatar = avatar
            cliente.save(update_fields=["avatar"])

        messages.success(request, "Actualizamos tu perfil.")
        return redirect("perfil")

    return render(request, "perfil.html", {"cliente": cliente})


@csrf_protect
def api_sugerencias(request):
    """
    Recibe el formulario de contacto, sanitiza entradas, valida reCAPTCHA y
    procesa en modo asincrono (202 + job_id) cuando se invoca via API/fetch.
    """
    if request.method != "POST":
        return HttpResponseNotAllowed(["POST"])

    wants_json = _wants_json(request)
    data = getattr(request, "sanitized_json", None)
    if not isinstance(data, dict):
        if "application/json" in request.META.get("CONTENT_TYPE", "") and request.body:
            try:
                data = json.loads(request.body.decode("utf-8"))
            except (UnicodeDecodeError, json.JSONDecodeError):
                return JsonResponse({"error": "Cuerpo JSON invalido."}, status=400)
        else:
            data = request.POST

    raw_nombre = str(data.get("nombre") or "")
    raw_email = str(data.get("email") or "")
    raw_mensaje = str(data.get("mensaje") or "")
    raw_tipo = str(data.get("type") or "")
    token = str(data.get("g-recaptcha-response") or "")

    if any(detect_sqli_payload(v) for v in (raw_nombre, raw_email, raw_mensaje, raw_tipo)):
        if wants_json:
            return JsonResponse({"error": "Entrada rechazada por seguridad."}, status=400)
        messages.error(request, "Entrada rechazada por seguridad.")
        return redirect(CONTACT_SECTION)

    nombre = sanitize_plain_text(raw_nombre, multiline=False, max_length=120)
    email = sanitize_email(raw_email)
    mensaje = sanitize_plain_text(raw_mensaje, multiline=True, max_length=1000)
    tipo = sanitize_plain_text(raw_tipo, multiline=False, max_length=20).lower()

    if tipo not in ALLOWED_SUGGESTION_TYPES:
        tipo = "otro"

    if not (nombre and email and mensaje):
        if wants_json:
            return JsonResponse({"error": "Faltan datos obligatorios."}, status=400)
        messages.error(request, "Faltan datos obligatorios.")
        return redirect(CONTACT_SECTION)

    try:
        validate_email(email)
    except ValidationError:
        if wants_json:
            return JsonResponse({"error": "Ingresa un correo valido."}, status=400)
        messages.error(request, "Ingresa un correo valido.")
        return redirect(CONTACT_SECTION)

    bypass_flag = getattr(settings, "CONTACT_BYPASS_RECAPTCHA", False)
    bypass_env = os.environ.get("CONTACT_BYPASS_RECAPTCHA", "").strip().lower()
    bypass = bypass_flag or bypass_env in {"1", "true", "yes"}

    recaptcha_secret = (
        getattr(settings, "RECAPTCHA_SECRET", "")
        or os.environ.get("RECAPTCHA_SECRET", "")
    )

    should_verify = not bypass and bool(recaptcha_secret)
    if not recaptcha_secret and not bypass:
        logger.warning("No RECAPTCHA_SECRET configured; skipping verification.")
        should_verify = False

    if should_verify:
        if not token:
            if wants_json:
                return JsonResponse({"error": "Falta reCAPTCHA."}, status=400)
            messages.error(request, "Falta reCAPTCHA.")
            return redirect(CONTACT_SECTION)
        try:
            response = requests.post(
                "https://www.google.com/recaptcha/api/siteverify",
                data={"secret": recaptcha_secret, "response": token},
                timeout=8,
            )
            response.raise_for_status()
            payload = response.json()
            if not payload.get("success", False):
                logger.info("reCAPTCHA failed: %s", payload)
                if wants_json:
                    return JsonResponse({"error": "No pudimos validar el reCAPTCHA."}, status=400)
                messages.error(request, "No pudimos validar el reCAPTCHA. Intenta de nuevo.")
                return redirect(CONTACT_SECTION)
        except requests.RequestException:
            logger.exception("Error validando reCAPTCHA.")
            if wants_json:
                return JsonResponse({"error": "Servicio de reCAPTCHA no disponible."}, status=503)
            messages.error(request, "Servicio de reCAPTCHA no disponible. Intenta mas tarde.")
            return redirect(CONTACT_SECTION)

    if len(mensaje) < 10:
        if wants_json:
            return JsonResponse({"error": "El mensaje debe tener al menos 10 caracteres."}, status=400)
        messages.error(request, "El mensaje debe tener al menos 10 caracteres.")
        return redirect(CONTACT_SECTION)

    formatted_msg = f"[{tipo.upper()}] {mensaje}" if tipo else mensaje

    if wants_json:
        job_id = submit_async_job(
            "sugerencia_create",
            _create_sugerencia_record,
            nombre,
            email,
            formatted_msg,
        )
        return JsonResponse(
            {
                "job_id": job_id,
                "status": "queued",
                "status_url": reverse("api_job_status", args=[job_id]),
                "message": "Solicitud recibida y en procesamiento asincrono.",
            },
            status=202,
        )

    _create_sugerencia_record(nombre, email, formatted_msg)
    messages.success(request, "Gracias. Recibimos tu mensaje.")
    return redirect(CONTACT_SECTION)


def api_job_status(request, job_id: str):
    """Consulta de estado para tareas asincronas encoladas por el backend."""
    if request.method != "GET":
        return HttpResponseNotAllowed(["GET"])

    clean_id = sanitize_plain_text(job_id, multiline=False, max_length=64)
    job = get_async_job(clean_id)
    if job is None:
        return JsonResponse({"error": "Trabajo no encontrado."}, status=404)

    response = JsonResponse(job, status=200)
    if job.get("status") in {"queued", "processing"}:
        response["Retry-After"] = "1"
    return response
