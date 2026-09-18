# ---------------------------------------------------------------------------
# Etapa 1: construye las ruedas de las dependencias (psycopg2 necesita gcc y libpq-dev)
# ---------------------------------------------------------------------------
FROM python:3.12-slim AS builder

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 PIP_NO_CACHE_DIR=1
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential libpq-dev \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /wheels
COPY requirements.txt .
# setuptools aporta pkg_resources, que gunicorn 20.1 importa y las imagenes python:3.12 ya no incluyen
RUN pip wheel --wheel-dir /wheels -r requirements.txt "setuptools<81"

# ---------------------------------------------------------------------------
# Etapa 2: imagen de ejecucion, sin compiladores y con usuario sin privilegios
# ---------------------------------------------------------------------------
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    DJANGO_ENV=production \
    STATIC_ROOT=/app/staticfiles

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq5 \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system app && useradd --system --gid app --home-dir /app --shell /usr/sbin/nologin app

WORKDIR /app
COPY --from=builder /wheels /wheels
RUN pip install --no-index --find-links /wheels /wheels/*.whl && rm -rf /wheels

COPY --chown=app:app . .
RUN mkdir -p /app/staticfiles && chown -R app:app /app/staticfiles && chmod +x /app/entrypoint.sh

USER app
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/api/health/', timeout=4).status == 200 else 1)"

ENTRYPOINT ["/app/entrypoint.sh"]
