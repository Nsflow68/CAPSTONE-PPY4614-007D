import decimal
import json
import logging
import uuid

from django.conf import settings
from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.core.exceptions import ValidationError
from django.core.paginator import Paginator
from django.core.validators import validate_email
from django.http import HttpResponseBadRequest, HttpResponseNotAllowed, JsonResponse
from django.shortcuts import redirect, render
from django.utils import timezone
from django.views.decorators.csrf import csrf_protect

from transbank.webpay.webpay_plus.transaction import Transaction

from core.sanitizers import detect_sqli_payload, sanitize_email, sanitize_plain_text

from .models import Donation

logger = logging.getLogger(__name__)
MIN_AMOUNT = decimal.Decimal(str(getattr(settings, "DONATION_MIN_CLP", 500)))
MAX_AMOUNT = decimal.Decimal("50000000")
AMOUNT_STEP = decimal.Decimal("1")
DEFAULT_PAGE_SIZE = 10
MAX_PAGE_SIZE = 50

try:
    from transbank.common.options import WebpayOptions as WebpayOptions
except ImportError:
    try:
        from transbank.common.options import Options as WebpayOptions
    except ImportError:  # pragma: no cover - fallback para SDK antiguos
        from transbank.common import Options as WebpayOptions  # type: ignore

try:
    from transbank.common.integration_api_keys import IntegrationApiKeys
    from transbank.common.integration_commerce_codes import IntegrationCommerceCodes
    from transbank.common.integration_type import IntegrationType
except ImportError:  # pragma: no cover - fallback para SDK antiguos
    from transbank.common import (  # type: ignore
        IntegrationApiKeys,
        IntegrationCommerceCodes,
        IntegrationType,
    )


def _wants_json(request) -> bool:
    accept = request.META.get("HTTP_ACCEPT", "")
    content_type = request.META.get("CONTENT_TYPE", "")
    return (
        "application/json" in accept
        or "application/json" in content_type
        or request.headers.get("X-Requested-With") == "fetch"
    )


def _tbk_options():
    """Configura el SDK de Transbank de acuerdo al ambiente."""
    environment = getattr(settings, "TBK_ENV", "integration")
    if environment == "production":
        return WebpayOptions(
            settings.TBK_API_KEY_ID,
            settings.TBK_API_KEY_SECRET,
            IntegrationType.LIVE,
        )
    return WebpayOptions(
        IntegrationCommerceCodes.WEBPAY_PLUS,
        IntegrationApiKeys.WEBPAY,
        IntegrationType.TEST,
    )


def _parse_page_size(request) -> int:
    raw = request.GET.get("page_size", str(DEFAULT_PAGE_SIZE))
    try:
        size = int(raw)
    except (TypeError, ValueError):
        size = DEFAULT_PAGE_SIZE
    return max(1, min(size, MAX_PAGE_SIZE))


@csrf_protect
@login_required(login_url="login")
def donation_form(request):
    """Muestra y procesa el formulario de donaciones con sanitizacion estricta."""
    if request.method == "GET":
        return render(
            request,
            "donations/form.html",
            {"donation_min_amount": int(MIN_AMOUNT)},
        )

    wants_json = _wants_json(request)
    data = getattr(request, "sanitized_json", None)
    if not isinstance(data, dict):
        data = request.POST

    amount_raw = sanitize_plain_text(str(data.get("amount") or ""), multiline=False, max_length=20)
    try:
        amount = decimal.Decimal(amount_raw).quantize(AMOUNT_STEP, rounding=decimal.ROUND_HALF_UP)
    except (decimal.InvalidOperation, TypeError):
        if wants_json:
            return JsonResponse({"error": "Monto invalido."}, status=400)
        messages.error(request, "Monto invalido.")
        return redirect("payments:crear")

    if amount < MIN_AMOUNT or amount > MAX_AMOUNT:
        msg = f"El monto debe estar entre ${int(MIN_AMOUNT)} y ${int(MAX_AMOUNT)}."
        if wants_json:
            return JsonResponse({"error": msg}, status=400)
        messages.error(request, msg)
        return redirect("payments:crear")

    raw_name = str(data.get("name") or "")
    raw_email = str(data.get("email") or "")
    raw_message = str(data.get("message") or "")
    if any(detect_sqli_payload(v) for v in (raw_name, raw_email, raw_message)):
        if wants_json:
            return JsonResponse({"error": "Entrada rechazada por seguridad."}, status=400)
        messages.error(request, "Entrada rechazada por seguridad.")
        return redirect("payments:crear")

    name = sanitize_plain_text(raw_name, multiline=False, max_length=120)
    email = sanitize_email(raw_email) if raw_email.strip() else ""
    message = sanitize_plain_text(raw_message, multiline=True, max_length=1000)

    if email:
        try:
            validate_email(email)
        except ValidationError:
            if wants_json:
                return JsonResponse({"error": "Correo electronico invalido."}, status=400)
            messages.error(request, "Correo electronico invalido.")
            return redirect("payments:crear")

    buy_order = f"MR-{timezone.now().strftime('%Y%m%d%H%M%S')}-{uuid.uuid4().hex[:6]}"
    session_id = uuid.uuid4().hex[:12]
    cliente = getattr(request.user, "cliente", None)

    donation = Donation.objects.create(
        cliente=cliente,
        amount=amount,
        name=name,
        email=email,
        message=message,
        buy_order=buy_order,
        session_id=session_id,
    )

    try:
        transaction = Transaction(_tbk_options())
        response = transaction.create(buy_order, session_id, int(amount), settings.TBK_RETURN_URL)
    except Exception:  # pragma: no cover - dependiente de SDK externo
        logger.exception("Error iniciando transaccion Webpay.")
        donation.status = "failed"
        donation.save(update_fields=["status"])
        if wants_json:
            return JsonResponse({"error": "No pudimos iniciar el pago."}, status=502)
        messages.error(request, "No pudimos iniciar el pago. Intenta mas tarde.")
        return redirect("payments:crear")

    token = response.get("token")
    url = response.get("url")
    if not token or not url:
        logger.error("Respuesta inesperada de Webpay: %s", response)
        donation.status = "failed"
        donation.response_raw = response
        donation.save(update_fields=["status", "response_raw"])
        if wants_json:
            return JsonResponse({"error": "Respuesta inesperada de Webpay."}, status=502)
        messages.error(request, "No pudimos iniciar el pago. Intenta mas tarde.")
        return redirect("payments:crear")

    donation.token_ws = token
    donation.response_raw = response
    donation.save(update_fields=["token_ws", "response_raw"])

    redirect_url = f"{url}?token_ws={token}"
    if wants_json:
        return JsonResponse(
            {
                "buy_order": buy_order,
                "token_ws": token,
                "redirect_url": redirect_url,
                "status": donation.status,
            },
            status=201,
        )

    return redirect(redirect_url)


def webpay_return(request):
    """Procesa el retorno desde Webpay (exitoso o abortado)."""
    token = sanitize_plain_text(request.POST.get("token_ws") or request.GET.get("token_ws") or "", max_length=200)
    tbk_token = sanitize_plain_text(request.POST.get("TBK_TOKEN") or "", max_length=200)
    tbk_order = sanitize_plain_text(request.POST.get("TBK_ORDEN_COMPRA") or "", max_length=60)
    tbk_session = sanitize_plain_text(request.POST.get("TBK_ID_SESION") or "", max_length=60)

    if tbk_token or tbk_order or tbk_session:
        if tbk_order:
            Donation.objects.filter(buy_order=tbk_order).update(status="aborted")
        return render(request, "donations/result.html", {"ok": False, "aborted": True})

    if not token:
        return HttpResponseBadRequest("Token faltante")

    donation = Donation.objects.filter(token_ws=token).first()
    if not donation:
        logger.warning("Retorno Webpay sin donacion vinculada. token=%s", token)
        return HttpResponseBadRequest("Transaccion desconocida")

    try:
        transaction = Transaction(_tbk_options())
        result = transaction.commit(token)
    except Exception:  # pragma: no cover - dependiente de SDK externo
        logger.exception("Error confirmando transaccion Webpay.")
        donation.status = "failed"
        donation.save(update_fields=["status"])
        return render(request, "donations/result.html", {"ok": False, "error": "commit_failed"})

    status_raw = (result.get("status") or "").upper()
    ok = status_raw == "AUTHORIZED"

    donation.status = "authorized" if ok else (status_raw or "failed").lower()
    donation.authorization_code = result.get("authorization_code") or ""
    donation.payment_type = result.get("payment_type_code") or ""
    donation.installments_number = result.get("installments_number")
    donation.response_raw = result
    donation.save(
        update_fields=[
            "status",
            "authorization_code",
            "payment_type",
            "installments_number",
            "response_raw",
        ]
    )

    return render(
        request,
        "donations/result.html",
        {
            "ok": ok,
            "result": result,
            "result_pretty": json.dumps(result, indent=2, ensure_ascii=False),
            "donation": donation,
        },
    )


def webpay_status(request):
    """Consulta asincrona del estado de una transaccion Webpay del usuario autenticado."""
    if request.method != "GET":
        return HttpResponseNotAllowed(["GET"])
    if not request.user.is_authenticated:
        return JsonResponse({"error": "No autenticado."}, status=401)

    token = sanitize_plain_text(request.GET.get("token") or "", max_length=200)
    if not token:
        return JsonResponse({"error": "Falta token"}, status=400)

    cliente = getattr(request.user, "cliente", None)
    donation = Donation.objects.filter(token_ws=token, cliente=cliente).first()
    if donation is None:
        return JsonResponse({"error": "Transaccion no encontrada."}, status=404)

    try:
        transaction = Transaction(_tbk_options())
        data = transaction.status(token)
    except Exception as exc:  # pragma: no cover - dependiente de SDK externo
        logger.exception("Error consultando estado Webpay.")
        return JsonResponse(
            {
                "buy_order": donation.buy_order,
                "status": donation.status,
                "local_fallback": True,
                "error": str(exc),
            },
            status=200,
        )

    return JsonResponse(data)


@login_required(login_url="login")
def donation_history(request):
    """Listado paginado obligatorio de donaciones del usuario autenticado."""
    cliente = getattr(request.user, "cliente", None)
    qs = Donation.objects.none()
    if cliente:
        qs = Donation.objects.filter(cliente=cliente).order_by("-created_at")

    page_size = _parse_page_size(request)
    paginator = Paginator(qs, page_size)
    page_obj = paginator.get_page(request.GET.get("page", 1))

    return render(
        request,
        "donations/history.html",
        {
            "donations": page_obj.object_list,
            "page_obj": page_obj,
            "paginator": paginator,
            "page_size": page_size,
        },
    )


def donation_history_api(request):
    """Endpoint JSON paginado para consumo asincrono desde el frontend."""
    if request.method != "GET":
        return HttpResponseNotAllowed(["GET"])
    if not request.user.is_authenticated:
        return JsonResponse({"error": "No autenticado."}, status=401)

    cliente = getattr(request.user, "cliente", None)
    qs = Donation.objects.none()
    if cliente:
        qs = Donation.objects.filter(cliente=cliente).order_by("-created_at")

    status_filter = sanitize_plain_text(request.GET.get("status") or "", max_length=30).lower()
    if status_filter in {"initialized", "authorized", "failed", "aborted"}:
        qs = qs.filter(status=status_filter)

    page_size = _parse_page_size(request)
    paginator = Paginator(qs, page_size)
    page_obj = paginator.get_page(request.GET.get("page", 1))

    items = [
        {
            "id": d.pk,
            "created_at": timezone.localtime(d.created_at).strftime("%Y-%m-%d %H:%M"),
            "buy_order": d.buy_order,
            "amount": str(d.amount),
            "status": d.status,
            "authorization_code": d.authorization_code or "-",
            "payment_type": d.payment_type or "-",
            "token_ws": d.token_ws or "",
        }
        for d in page_obj.object_list
    ]

    return JsonResponse(
        {
            "items": items,
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
