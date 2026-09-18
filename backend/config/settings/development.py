"""Configuracion de desarrollo: DEBUG, API navegable y valores por defecto comodos."""
import os

# Valores por defecto SOLO para desarrollo local; en produccion son obligatorios.
os.environ.setdefault("SECRET_KEY", "dev-only-insecure-key-change-me")
os.environ.setdefault("DEBUG", "True")
os.environ.setdefault("DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/ThreatTrackAppDB")

from .base import *  # noqa: E402,F401,F403
from .base import REST_FRAMEWORK  # noqa: E402

REST_FRAMEWORK = {
    **REST_FRAMEWORK,
    "DEFAULT_RENDERER_CLASSES": [
        "rest_framework.renderers.JSONRenderer",
        "rest_framework.renderers.BrowsableAPIRenderer",
    ],
}
