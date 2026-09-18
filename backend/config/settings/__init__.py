"""
Selecciona la configuracion segun la variable de entorno DJANGO_ENV:
  - development (por defecto): DEBUG, API navegable, CORS abierto a localhost.
  - production: cabeceras de seguridad, DEBUG desactivado, secretos obligatorios.
"""
import os

_env = os.environ.get("DJANGO_ENV", "development").lower()

if _env == "production":
    from .production import *  # noqa: F401,F403
else:
    from .development import *  # noqa: F401,F403
