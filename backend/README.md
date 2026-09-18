# Backend de ThreatTrackApp (Django REST Framework)

## Estructura

```
backend/
├── config/               settings por entorno (base / development / production), urls, wsgi, asgi
├── apps/
│   ├── common/           paginación, permisos por rol, filtros, manejo de errores, endpoint de salud
│   ├── accounts/         inicio de sesión por token, perfil usuario→cliente, comando bootstrap_roles
│   ├── customers/        clientes, servicios contratados, catálogo de servicios, ejecuciones de módulos
│   ├── assets/           dominios, IPs, palabras clave, canales de Telegram y dorks por cliente
│   └── alerts/           estados, criticidades, alertas de cada fuente OSINT, listas de bloqueo y estadísticas
├── tests/                pruebas de contrato de la API
├── Dockerfile            imagen multi-etapa (python:3.12-slim, usuario sin privilegios)
├── entrypoint.sh         espera BD → migrate → collectstatic → bootstrap_roles → gunicorn
└── requirements.txt      dependencias fijadas
```

Las tablas de negocio las define `compose/db/01_schema.sql` (modelos `managed = False`); Django solo gestiona sus propias tablas y el perfil de usuario.

## Desarrollo local

```bash
cd backend
py -3.12 -m venv .venv && .venv\Scripts\activate      # Windows
pip install -r requirements.txt
copy .env.example .env                                 # ajusta DATABASE_URL, SECRET_KEY...
python manage.py migrate
python manage.py bootstrap_roles
python manage.py runserver
```

API navegable en http://localhost:8000/api/ (solo con `DJANGO_ENV=development`).

## Pruebas

Necesitan un PostgreSQL accesible con `DATABASE_URL` (Django crea una base `test_<nombre>`):

```bash
python manage.py test
```

## API

| Recurso | Ruta |
|---|---|
| Sesión | `POST /api/auth/login/` `{username, password}` → `{token, username, role, customer}` · `POST /api/auth/logout/` · `GET /api/auth/session/` |
| Clientes y configuración | `/api/Clients/`, `/api/Apps/` (servicios contratados, pk = id de cliente), `/api/Monitoring/`, `/api/Services/` |
| Activos y consultas | `/api/Domains/`, `/api/Ips/`, `/api/Keywords/`, `/api/TelGroups/`, `/api/GoogleDorks/`, `/api/ShodanDorks/`, `/api/TwitterDorks/` |
| Catálogos | `/api/AlertStatus/`, `/api/AlertCriticity/` |
| Alertas | `/api/Github/`, `/api/Gitlab/`, `/api/Google/`, `/api/Intelx/`, `/api/Secrets/`, `/api/Telegram/`, `/api/Tweets/`, `/api/Typosquatting/`, `/api/Certificates/`, `/api/Defacement/`, `/api/OldShodan/`, `/api/Shodan/`, `/api/ShodanPorts/`, `/api/ShodanVulns/` |
| Listas de bloqueo | `/api/BlacklistDomain/`, `/api/BlacklistDomainTopScore/`, `/api/BlacklistIp/`, `/api/BlacklistIpTopScore/` |
| Estadísticas | `/api/status-counts/`, `/api/total-count-open-resolved/`, `/api/criticity-counts/`, `/api/cases-by-status-and-criticity/`, `/api/case-counts-by-module/`, `/api/stacked-bar-chart/`, `/api/daily-counts-services/`, `/api/ips-count/`, `/api/domains-count/`, `/api/keywords-count/` |
| Salud | `GET /api/health/` |

Parámetros comunes de los listados: `page`, `page_size` (≤ 100), `search`, `ordering` (prefijo `-` para descendente), `customer`, `state`, `severity`, `date_from`, `date_to` (fechas `YYYY-MM-DD`, inclusivas), `is_active` (activos). Las estadísticas admiten `?customer=<id>` para los analistas.

Autenticación: cabecera `Authorization: Token <token>`. Roles: grupo `analyst` (lectura y escritura) y grupo `client` (solo lectura, únicamente de su cliente). Con `API_REQUIRE_AUTH=False` la API es anónima (modo heredado).
