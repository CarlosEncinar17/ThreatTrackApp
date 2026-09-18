# Base de datos de ThreatTrackApp

| Fichero | Uso |
|---|---|
| `01_schema.sql` | DDL completo del esquema. PostgreSQL lo ejecuta automáticamente la primera vez que arranca el contenedor `database` (carpeta `docker-entrypoint-initdb.d`). |
| `02_seed.sql` | Datos de ejemplo: dos clientes, sus activos y consultas, y alertas de todas las fuentes. Se ejecuta tras el esquema. |
| `tools/shift_seed_dates.py` | Traslada todas las fechas de `02_seed.sql` a un mes concreto (`python compose/db/tools/shift_seed_dates.py 2026-09-17`: ese día pasa a ser la fecha más reciente y el resto conserva su orden). Los datos de ejemplo están fechados en septiembre de 2026 para que los dashboards, que miran los últimos 30 y 365 días, muestren información. |

Las tablas internas de Django (`auth_*`, `django_*`) no forman parte del DDL: las crea `python manage.py migrate` al arrancar el backend.

## Instalación nueva

No hay que hacer nada: `docker compose up --build` crea la base de datos con `01_schema.sql` y `02_seed.sql`.

## Convenciones del esquema

- Tablas en `snake_case` y plural, agrupadas por concepto: `customers`, `monitored_*` (activos), `*_dork_queries` (consultas avanzadas), `*_alerts` (una por fuente OSINT), `blocklisted_*` (listas de bloqueo), `scan_runs` (ejecuciones de los recolectores).
- Todas las alertas tienen `state_id` (1 = abierta por defecto), `severity_id` (6 = desconocida por defecto), `detected_at`, `notes` y, salvo las tablas hijas de Shodan y los secretos, `customer_id`.
- Las restricciones UNIQUE de cada tabla de alertas definen qué se considera un hallazgo repetido.
- Índices sobre `customer_id`, `state_id`, `severity_id` y `detected_at`, que son las columnas por las que filtran las tablas y los dashboards.

## Refrescar las fechas de los datos de ejemplo

```bash
python compose/db/tools/shift_seed_dates.py 2026-10-15
docker compose down --volumes && docker compose up --build
```
