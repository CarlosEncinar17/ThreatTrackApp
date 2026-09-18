# ThreatTrackApp · Fase 6: recolectores OSINT

Fecha: 2026-09-18 · Estado: **propuesta, pendiente de confirmación**

## 1. Punto de partida

La plataforma almacena, clasifica y muestra alertas, pero **no contiene ningún recolector**: los scripts OSINT que las generaban no forman parte del repositorio. Lo que sí existe y condiciona el diseño:

| Elemento | Situación actual |
|---|---|
| Tablas de alertas | 14 tablas (`github_commit_alerts`, `leaked_secret_alerts`, `gitlab_project_alerts`, `google_search_alerts`, `intelx_leak_alerts`, `telegram_message_alerts`, `twitter_post_alerts`, `typosquatting_alerts`, `certificate_alerts`, `defacement_alerts`, `shodan_host_alerts`, `shodan_port_alerts`, `shodan_vulnerability_alerts`, `shodan_legacy_alerts`) y 4 de listas de bloqueo. Todas con `state_id` (por defecto 1 = abierta), `severity_id` (por defecto 6 = desconocida), `detected_at` y restricciones UNIQUE que definen qué es un hallazgo repetido. |
| Activos a vigilar | `monitored_domains`, `monitored_ip_addresses`, `monitored_keywords`, `telegram_channels`, `google_dork_queries`, `shodan_dork_queries`, `twitter_dork_queries`, todos con `is_active` y (salvo los canales) `customer_id`. |
| Servicios contratados | `customer_service_subscriptions` con un booleano por fuente (`github_enabled`, `shodan_enabled`, `blocklist_enabled`…). |
| Registro de ejecuciones | `scan_runs` (`module_name`, `run_started_at`, `run_finished_at`, `notes`), expuesta en `GET /api/Monitoring/`. Los datos de ejemplo usan los nombres de módulo `Typosquatting`, `Google`, `Twitter`, `GitLab`, `Git`, `Cert` e `Intelx`. |
| Credenciales | `compose/.env.example` y `backend/.env.example` reservan `SHODAN_API_KEY`, `INTELX_API_KEY`, `GITHUB_TOKEN`, `GITLAB_TOKEN`, `GOOGLE_API_KEY`, `GOOGLE_CSE_ID`, `TELEGRAM_API_ID`, `TELEGRAM_API_HASH` y `TWITTER_BEARER_TOKEN`. Ningún código las lee todavía. |
| Frontend | La entrada de menú "Estado de scripts" está marcada como pendiente. |

Por tanto, **rellenar las claves no basta**: hay que construir los recolectores. Esta fase propone cómo.

## 2. Objetivo y alcance

Crear un recolector por fuente que, de forma periódica y sin intervención manual, lea los activos de cada cliente con el servicio contratado, consulte la fuente, normalice los resultados e inserte las alertas nuevas en las tablas existentes, dejando constancia de cada ejecución en `scan_runs`. Sin cambios de esquema ni de contrato de la API: el frontend y los dashboards actuales mostrarán los hallazgos tal cual.

Fuera de alcance: los servicios "en desarrollo" del catálogo (categorización, carding, fraude de app, hacktivismo, VIP/VAP), que no tienen tablas de alertas.

## 3. Arquitectura propuesta

**Los recolectores viven dentro del backend**, como una app Django más (`apps/collectors`), y se ejecutan en un contenedor propio construido con la misma imagen. Motivos:

- Reutilizan los modelos existentes: las claves foráneas, las restricciones UNIQUE y los valores por defecto de estado y criticidad ya están definidos una vez; un script externo con SQL a mano los duplicaría.
- Las credenciales ya están previstas en el `.env` del backend y se leen con `django-environ`, igual que el resto de la configuración.
- Se prueban con el mismo `manage.py test` y el mismo runner que la API.
- No exponen ningún puerto: el contenedor solo habla con PostgreSQL y con Internet de salida.

```
backend/apps/collectors/
├── base.py            BaseCollector: objetivos → consulta → normalización → inserción + scan_run
├── http.py            cliente HTTP mínimo (urllib de la biblioteca estándar): timeouts, reintentos, cabeceras
├── severity.py        reglas de criticidad inicial por fuente (configurables)
├── sources/
│   ├── typosquatting.py, certificates.py, defacement.py     (sin credenciales)
│   ├── github.py, secrets.py, gitlab.py, google.py          (fugas de información)
│   ├── intelx.py, twitter.py, telegram.py                   (exposición de credenciales)
│   ├── shodan.py                                            (hosts, puertos, vulnerabilidades)
│   └── blocklists.py                                        (listas de bloqueo)
└── management/commands/collect.py
```

**Comando único** `python manage.py collect [módulo...] [--once | --loop] [--dry-run]`:

- `--once` ejecuta los módulos indicados (o todos) una vez y termina; es lo que usarán las pruebas manuales y un cron externo si se prefiere.
- `--loop` es el modo del contenedor: recorre los módulos cada `COLLECTOR_INTERVAL_MINUTES` (60 por defecto), con intervalo propio por módulo si se define (`COLLECTOR_INTERVAL_SHODAN=1440`, por ejemplo).
- `--dry-run` consulta la fuente y muestra qué insertaría, sin escribir.
- Un módulo sin credencial configurada se salta y deja un `scan_run` con la nota "sin credencial"; nunca aborta a los demás.

**Servicio de compose** `collector`: misma imagen que `backend`, `command: python manage.py collect --loop`, `env_file: .env`, sin puertos, usuario sin privilegios, `depends_on: database (healthy)`, `restart: unless-stopped`. `COLLECTOR_MODULES` permite limitar qué módulos corren (por defecto, todos).

## 4. Recolectores

Cada fila indica qué activa el módulo, qué activos recorre, de dónde obtiene los datos, en qué tabla escribe y qué define un hallazgo repetido (la restricción UNIQUE ya existente).

| Módulo (`module_name`) | Se ejecuta si | Activos que recorre | Fuente y credencial | Tabla destino y clave de unicidad |
|---|---|---|---|---|
| `Typosquatting` | `typosquatting_enabled` | dominios activos | Generación local de variantes del dominio (omisión, transposición, sustitución de caracteres, homoglifos, cambio de TLD…) y resolución DNS. Sin credencial. | `typosquatting_alerts` (dominio, dominio parecido, IP resuelta) |
| `Cert` | `certificates_enabled` | dominios activos | Registros públicos de transparencia de certificados consultados por dominio. Sin credencial. | `certificate_alerts` (dominio, resumen del certificado) |
| `Defacement` | `defacement_enabled` | dominios activos | Descarga de la página principal del dominio; MD5 y SHA-256 del contenido. Se genera alerta cuando los hashes difieren de los últimos conocidos. Sin credencial. | `defacement_alerts` (dominio, MD5, SHA-256) |
| `Git` | `github_enabled` | dominios activos | Búsqueda de commits en GitHub que mencionan el dominio. `GITHUB_TOKEN`. | `github_commit_alerts` (dominio, repositorio, hash de commit) |
| `Secrets` | `github_enabled` | commits nuevos de `github_commit_alerts` con `is_analyzed = false` | Análisis del commit con un escáner de secretos. Las columnas de `leaked_secret_alerts` (`detection_rule`, `fingerprint_hash`, `entropy_score`, `tag_list`, líneas y columnas de inicio y fin, `rule_description`) coinciden con los campos del informe JSON de gitleaks, así que se propone ese formato como contrato de entrada. | `leaked_secret_alerts` (huella, commit); marca `is_analyzed = true` |
| `GitLab` | `gitlab_enabled` | palabras clave activas | Búsqueda de proyectos públicos por palabra clave. `GITLAB_TOKEN`. | `gitlab_project_alerts` (palabra clave, proyecto, autor) |
| `Google` | `google_enabled` | dorks de Google activos | Búsqueda programable de Google (Custom Search JSON). `GOOGLE_API_KEY` + `GOOGLE_CSE_ID`. | `google_search_alerts` (consulta, URL); si la URL ya existe solo se actualiza `last_seen_at` |
| `Intelx` | `intelx_enabled` | dominios activos | Búsqueda de fugas por dominio en Intelligence X. `INTELX_API_KEY`. | `intelx_leak_alerts` (URL) |
| `Twitter` | `twitter_enabled` | dorks de Twitter activos | Búsqueda reciente de publicaciones. `TWITTER_BEARER_TOKEN`. | `twitter_post_alerts` (URL) |
| `Telegram` | `telegram_enabled` | canales activos × palabras clave activas | Lectura de mensajes de los canales y coincidencia con las palabras clave. `TELEGRAM_API_ID` + `TELEGRAM_API_HASH` (ver decisión 3). | `telegram_message_alerts` (palabra clave, canal, texto) |
| `Shodan` | `shodan_enabled` | IPs activas y dorks de Shodan activos | Consulta de host por IP y búsqueda por dork. `SHODAN_API_KEY`. | `shodan_host_alerts` (IP, ASN, país) y, por cada host, `shodan_port_alerts` (host, puerto) y `shodan_vulnerability_alerts` (host, CVE). `shodan_legacy_alerts` queda solo en lectura. |
| `Blocklist` | `blocklist_enabled` | dominios e IPs activos | Comprobación de presencia en listas públicas de bloqueo. Las tablas (`list_category`, `list_source`, `listed_at`, `report_count`, `reliability_score`, `threat_score`) no documentan la fuente concreta (ver decisión 5). | `blocklisted_domains`, `blocklisted_ip_addresses` y sus tablas `_top_scores` |

Las consultas a cada proveedor se hacen con los endpoints y parámetros de su documentación oficial vigente en el momento de implementar; este documento no fija rutas ni límites de cuota, que cambian con el tiempo.

## 5. Reglas comunes

- **Estado inicial**: toda alerta nueva nace `open`. El recolector **nunca modifica** el estado, la criticidad ni las notas de una alerta existente: si un analista la marcó como falso positivo o resuelta, así se queda aunque la fuente la devuelva otra vez.
- **Idempotencia**: la inserción se apoya en la restricción UNIQUE de cada tabla (`get_or_create` sobre esas columnas). Ejecutar dos veces no duplica nada.
- **Criticidad inicial**: `unknown` por defecto. Se proponen reglas mínimas, revisables por el analista: secretos detectados → `high`; vulnerabilidades de Shodan con CVE → `high`; dominio parecido que resuelve → `medium`; cambio de contenido (defacement) → `high`; resto → `unknown`.
- **Ámbito por cliente**: solo se recorren activos con `is_active = true` de clientes con el servicio contratado y `customers.is_active = true`.
- **Ejecuciones**: un `scan_run` por módulo y pasada, con `run_started_at`, `run_finished_at` y en `notes` un resumen (`objetivos=12 consultas=12 nuevas=3 repetidas=40 errores=0`). Los errores de un objetivo se registran y no interrumpen el resto.
- **Salida a Internet**: timeouts en todas las peticiones, reintentos con espera creciente ante límites de cuota, y una pausa configurable entre consultas para no agotar cuotas.
- **Datos hostiles**: todo lo que devuelve una fuente se trata como texto; se recortan longitudes al tamaño de columna y no se interpreta HTML. El frontend ya escapa e inserta `rel="noopener noreferrer nofollow"` en los enlaces.
- **Secretos**: `leaked_secret_alerts.secret_value` almacena el secreto tal cual por diseño del esquema; se propone guardarlo enmascarado (primeros y últimos caracteres) y dejar el valor completo solo en `matched_text` si el analista lo necesita (decisión 4).
- **Registros**: sin credenciales ni cuerpos de respuesta en los logs; solo contadores y errores.

## 6. Frontend

Convertir la entrada "Estado de scripts" en una página real para el analista, sobre `GET /api/Monitoring/` (ya existe): tabla de ejecuciones por módulo con inicio, fin, duración y resumen, y un indicador por módulo (última ejecución correcta, con errores, sin credencial). Sin nuevos endpoints; como mucho, un filtro por `module_name` en el existente.

## 7. Pruebas

- Pruebas unitarias por recolector con respuestas grabadas en JSON (`backend/tests/collectors/fixtures/`), inyectando un transporte HTTP falso: sin red en las pruebas.
- Prueba de idempotencia común: ejecutar dos veces un módulo sobre las mismas respuestas deja el mismo número de filas y un `scan_run` por pasada.
- Prueba de que no se sobreescriben estado, criticidad ni notas de una alerta existente.
- Prueba del comando `collect` con un módulo sin credencial (se salta con nota) y con `--dry-run` (no escribe).
- Validación manual: `docker compose exec backend python manage.py collect typosquatting cert --once` contra los dominios de ejemplo, que no necesitan credenciales, y comprobación en la tabla de alertas y en el dashboard.

## 8. Dependencias

Todos los recolectores pueden hacerse con la biblioteca estándar de Python (`urllib.request`, `json`, `hashlib`, `socket`, `ssl`, `re`), sin añadir paquetes. Las dos excepciones se dejan como decisiones explícitas: leer canales de Telegram exige una biblioteca del protocolo MTProto, y analizar secretos de un commit exige un escáner (binario de gitleaks en la imagen del recolector, o un conjunto de reglas propio en Python).

## 9. Plan de entregas

| Entrega | Contenido | Verificable con |
|---|---|---|
| 6.1 | Base: `apps/collectors`, `BaseCollector`, cliente HTTP, comando `collect`, servicio `collector` en compose, `scan_runs`; módulos `Typosquatting`, `Cert` y `Defacement` (sin credenciales). | Ejecución real contra los dominios de ejemplo y alertas visibles en el dashboard. |
| 6.2 | Fugas de información: `Git`, `Secrets`, `GitLab`, `Google`. | Pruebas con respuestas grabadas; ejecución real con las claves que aportes. |
| 6.3 | Exposición y sistemas: `Intelx`, `Twitter`, `Shodan` (hosts, puertos, vulnerabilidades). | Ídem. |
| 6.4 | `Telegram` y `Blocklist`, según las decisiones 3 y 5. | Ídem. |
| 6.5 | Página "Estado de scripts" en el frontend y documentación (`backend/README.md`, `compose/.env.example`, este documento con estado confirmado). | Recorrido en el navegador. |

Cada entrega termina con `manage.py check`, las pruebas en verde y el stack completo levantado con `docker compose up --build`.

## 10. Decisiones que necesito antes de empezar

1. **Ubicación**: recolectores como app del backend con contenedor `collector` (recomendado, sección 3), o scripts independientes fuera de Django que escriban por SQL.
2. **Planificación**: bucle interno con `COLLECTOR_INTERVAL_MINUTES` (recomendado; no requiere nada más) o cron del host llamando a `collect --once`.
3. **Telegram**: añadir una biblioteca MTProto (nueva dependencia de Python y una sesión de usuario de Telegram, no un bot) o dejar el módulo fuera de esta fase.
4. **Secretos**: incluir el binario de gitleaks en la imagen del recolector (formato de informe que ya encaja con la tabla) o escribir reglas propias en Python (sin dependencias, menor cobertura). Y si el valor del secreto se guarda completo o enmascarado.
5. **Listas de bloqueo**: qué fuente pública se usa; el esquema no la identifica y no quiero suponerla.
6. **Criticidad inicial**: aceptar las reglas mínimas de la sección 5 o dejar todo en `unknown` para que la asigne el analista.
7. **Intervalos**: 60 minutos para todo, o intervalos distintos por fuente (por ejemplo, Shodan y certificados una vez al día y Telegram cada 15 minutos).

Con las respuestas, la fase se ejecuta en el orden de la sección 9 y se documenta como las anteriores.
