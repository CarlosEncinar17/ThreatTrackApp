# Threat Track App

> **Aviso: proyecto completamente refactorizado.** Threat Track App nació como Proyecto de Fin de Grado (Ingeniería Informática, Universidad Francisco de Vitoria, convocatoria de enero de 2025). La versión publicada en este repositorio es una refactorización completa de aquella entrega: se ha refactorizado todo el código, la base de datos y el backend, el frontend se ha cambiado a Angular y se han implementado nuevas medidas de seguridad, además de otras mejoras de calidad y documentación. La funcionalidad es la misma que la descrita en la memoria del proyecto.

Plataforma de **gestión de la superficie de ataque** (Attack Surface Management, ASM). Centraliza las alertas que generan distintas herramientas OSINT (fugas de información en GitHub, GitLab y Google, exposición de credenciales, defacement, typosquatting, certificados, hosts expuestos en Shodan…), las clasifica por criticidad y estado, y las presenta por cliente en dashboards y tablas interactivas.

- **Backend**: Django 5 + Django REST Framework, PostgreSQL 16.
- **Frontend**: Angular 22 servido por nginx.
- **Despliegue**: Docker Compose (tres contenedores: base de datos, backend y frontend).

## Características

- Servicios de cibervigilancia: fugas de información, exposición de credenciales, defacement, phishing y dominios fraudulentos, monitorización de dominios, monitorización de sistemas y vulnerabilidades.
- Clasificación de alertas por **criticidad** (crítica, alta, media, baja, informativa, desconocida) y **estado** (abierta, en progreso, resuelta, falso positivo, duplicada).
- Dashboards por cliente: casos abiertos y resueltos, distribución por criticidad y por módulo, evolución diaria.
- Gestión (crear, editar, eliminar) de clientes, servicios contratados, activos monitorizados (dominios, IPs, palabras clave), consultas avanzadas (dorks de Google, Shodan y Twitter) y alertas de cada servicio.
- Filtros globales por fecha de detección, cliente, estado y criticidad; búsqueda, ordenación, copiado, exportación a CSV e impresión en todas las tablas.
- Dos roles: **analista** (lectura y escritura sobre todo) y **cliente** (solo lectura de sus propios datos).

## Requisitos

- Docker Desktop (o Docker Engine 24+) con Docker Compose v2.
- Para desarrollo local, además: Python 3.12 y Node.js 22.

## Puesta en marcha

```bash
git clone <url-del-repositorio> threattrackapp
cd threattrackapp/compose
cp .env.example .env
```

Edita `compose/.env` y rellena como mínimo:

| Variable | Descripción |
|---|---|
| `POSTGRES_PASSWORD` | Contraseña de PostgreSQL (obligatoria). |
| `SECRET_KEY` | Clave secreta de Django, al menos 32 caracteres. `python -c "import secrets; print(secrets.token_urlsafe(50))"` |
| `BOOTSTRAP_ADMIN_PASSWORD` | Contraseña del superusuario `admin` (panel de administración). |
| `BOOTSTRAP_ANALYST_PASSWORD` | Contraseña del usuario `analyst` (rol analista). |
| `BOOTSTRAP_CLIENT_PASSWORD` | Contraseña del usuario `client` (rol cliente, vinculado al cliente `BOOTSTRAP_CLIENT_CUSTOMER`). |

Los usuarios solo se crean si su contraseña no está vacía. El resto de variables tienen valores por defecto razonables y están documentadas en el propio `.env.example`.

```bash
docker compose up --build
```

| Servicio | URL |
|---|---|
| Aplicación web | http://localhost:8080 |
| API REST | http://localhost:8080/api/ (o directamente http://localhost:8000/api/) |
| Panel de administración de Django | http://localhost:8080/admin/ |
| Estado del backend | http://localhost:8080/api/health/ |

La primera vez, PostgreSQL crea el esquema y carga los datos de ejemplo (`compose/db/01_schema.sql` y `02_seed.sql`); el backend aplica sus migraciones internas y crea los roles y usuarios iniciales. Para empezar de cero:

```bash
docker compose down --volumes
docker compose up --build
```

El puerto de PostgreSQL no se publica al host. Para conectar un cliente SQL desde fuera de Docker:

```bash
docker compose --profile debug up -d   # publica 127.0.0.1:5432
```

## Estructura del proyecto

```
ThreatTrackApp/
├── backend/            API REST (Django REST Framework)         → backend/README.md
├── frontend/           Aplicación Angular                       → frontend/README.md
├── compose/            Docker Compose, .env.example y base de datos
│   └── db/             esquema y datos de ejemplo                → compose/db/README.md
├── docs/               documentación de diseño
├── LICENSE             MIT
└── README.md
```

## Desarrollo local

**Backend** (necesita un PostgreSQL con el esquema; el más sencillo es el del compose con el perfil `debug`):

```bash
cd backend
py -3.12 -m venv .venv && .venv\Scripts\activate    # Linux/macOS: python3.12 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
copy .env.example .env                                # ajusta DATABASE_URL, SECRET_KEY...
python manage.py migrate
python manage.py bootstrap_roles
python manage.py runserver                            # http://localhost:8000 (API navegable en desarrollo)
python manage.py test                                 # pruebas de contrato de la API
```

**Frontend**:

```bash
cd frontend
npm install
npm start          # http://localhost:4200, redirige /api al backend en :8000
npm run build      # build de producción en dist/threattrack-frontend/browser
```

## Seguridad

- Inicio de sesión obligatorio (token) y control de acceso por rol y por cliente. `API_REQUIRE_AUTH=False` deja la API anónima solo para demostraciones.
- Secretos y credenciales únicamente en variables de entorno; en producción el backend rechaza arrancar con una `SECRET_KEY` de desarrollo.
- Cabeceras de seguridad en backend y nginx (CSP, `X-Frame-Options`, `nosniff`, `Referrer-Policy`), limitación de peticiones, validación de todos los parámetros de entrada, errores sin trazas internas, contenedores sin privilegios y base de datos sin puerto expuesto.
- Para servir con TLS delante (proxy inverso), activa `BEHIND_TLS_PROXY=True` para habilitar HSTS y cookies seguras.

Detalle en los README de `backend/` y `frontend/`.

## Documentación

| Documento | Contenido |
|---|---|
| [`backend/README.md`](backend/README.md) | Estructura del backend, API, autenticación y pruebas |
| [`frontend/README.md`](frontend/README.md) | Estructura de la aplicación Angular y guía de desarrollo |
| [`compose/db/README.md`](compose/db/README.md) | Esquema y datos de ejemplo |
| [`docs/fase6-recolectores-osint.md`](docs/fase6-recolectores-osint.md) | Propuesta de los recolectores OSINT que alimentan la plataforma (pendiente de ejecución) |

Los datos de ejemplo están fechados en septiembre de 2026 para que los dashboards muestren información. Para trasladarlos a otro mes: `python compose/db/tools/shift_seed_dates.py AAAA-MM-DD` (el día indicado pasa a ser la fecha más reciente) y recrear la base de datos con `docker compose down --volumes && docker compose up --build`.

## Licencia

MIT. Consulta el fichero [`LICENSE`](LICENSE).
