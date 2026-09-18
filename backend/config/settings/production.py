"""
Configuracion de produccion: DEBUG desactivado, secretos obligatorios y cabeceras
de seguridad. El TLS lo termina el proxy (nginx), por eso SECURE_SSL_REDIRECT y las
cookies seguras se activan solo cuando BEHIND_TLS_PROXY=True.
"""
from .base import *  # noqa: F401,F403
from .base import env

DEBUG = False

if SECRET_KEY.startswith("dev-only") or len(SECRET_KEY) < 32:  # noqa: F405
    raise RuntimeError("SECRET_KEY debe ser un valor secreto de al menos 32 caracteres en produccion.")

BEHIND_TLS_PROXY = env.bool("BEHIND_TLS_PROXY", default=False)

SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_REFERRER_POLICY = "strict-origin-when-cross-origin"
SECURE_CROSS_ORIGIN_OPENER_POLICY = "same-origin"
X_FRAME_OPTIONS = "DENY"
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = "Lax"
CSRF_COOKIE_SAMESITE = "Lax"

if BEHIND_TLS_PROXY:
    SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_HSTS_SECONDS = 60 * 60 * 24 * 365
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
