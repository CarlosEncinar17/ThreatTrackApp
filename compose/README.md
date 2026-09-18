# Orquestación con Docker Compose

| Fichero / carpeta | Contenido |
|---|---|
| `docker-compose.yml` | Servicios `database` (PostgreSQL 16), `backend` (Django REST Framework, gunicorn) y `frontend` (Angular servido por nginx, que además redirige `/api`, `/admin` y `/static` al backend). El servicio `database-port` (perfil `debug`) publica PostgreSQL en `127.0.0.1:5432`. |
| `.env.example` | Plantilla de variables: credenciales de PostgreSQL, `SECRET_KEY`, hosts, CORS, usuarios iniciales y claves OSINT. Cópiala a `.env` (no se versiona). |
| `db/` | Esquema (`01_schema.sql`), datos de ejemplo (`02_seed.sql`), migración desde el esquema anterior y herramientas. Ver `db/README.md`. |

```bash
cd compose
cp .env.example .env      # rellena POSTGRES_PASSWORD, SECRET_KEY y las contraseñas iniciales
docker compose up --build
```

- Frontend: http://localhost:8080 · Backend: http://localhost:8000 · Salud: http://localhost:8080/api/health/
- Empezar de cero (borra la base de datos): `docker compose down --volumes && docker compose up --build`
- Ver registros: `docker compose logs -f backend`
- Consola de Django: `docker compose exec backend python manage.py shell`
