"""
Manejador de excepciones de la API: respuestas JSON coherentes y sin fugas de
informacion interna.

- Errores de validacion de Django -> 400.
- Violaciones de integridad (UNIQUE, claves foraneas) -> 409 con un mensaje generico.
- Cualquier otro error no controlado -> 500 sin detalle (queda en el log del servidor).
"""
import logging

from django.core.exceptions import ValidationError as DjangoValidationError
from django.db import IntegrityError
from django.db.models import ProtectedError, RestrictedError
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import exception_handler as drf_exception_handler

logger = logging.getLogger(__name__)


def exception_handler(exc, context):
    response = drf_exception_handler(exc, context)
    if response is not None:
        return response

    if isinstance(exc, DjangoValidationError):
        detail = exc.message_dict if hasattr(exc, "message_dict") else exc.messages
        return Response({"detail": detail}, status=status.HTTP_400_BAD_REQUEST)

    if isinstance(exc, (ProtectedError, RestrictedError)):
        return Response(
            {"detail": "No se puede eliminar: otros registros dependen de este."},
            status=status.HTTP_409_CONFLICT,
        )

    if isinstance(exc, IntegrityError):
        logger.warning("Violacion de integridad en %s: %s", context.get("view"), exc.__class__.__name__)
        return Response(
            {"detail": "La operacion incumple una restriccion de integridad (registro duplicado o referencia inexistente)."},
            status=status.HTTP_409_CONFLICT,
        )

    logger.exception("Error no controlado en %s", context.get("view"))
    return Response({"detail": "Error interno del servidor."}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
