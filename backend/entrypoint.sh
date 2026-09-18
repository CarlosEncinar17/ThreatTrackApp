#!/bin/sh
# Arranque del backend: espera a PostgreSQL, aplica migraciones de Django, recopila
# estaticos, crea roles/usuarios iniciales y lanza gunicorn.
set -e

echo "[entrypoint] esperando a la base de datos..."
python - <<'PY'
import os, sys, time
import psycopg2
url = os.environ["DATABASE_URL"]
for attempt in range(60):
    try:
        psycopg2.connect(url).close()
        print("[entrypoint] base de datos disponible")
        sys.exit(0)
    except psycopg2.OperationalError as exc:
        time.sleep(2)
print("[entrypoint] la base de datos no responde", file=sys.stderr)
sys.exit(1)
PY

python manage.py migrate --noinput
python manage.py collectstatic --noinput --clear >/dev/null
python manage.py bootstrap_roles

exec gunicorn config.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers "${GUNICORN_WORKERS:-3}" \
    --timeout "${GUNICORN_TIMEOUT:-60}" \
    --access-logfile - \
    --error-logfile -
