# Frontend de ThreatTrackApp (Angular)

Aplicación Angular 22 (componentes standalone, signals, sin zone.js) que sustituye a las páginas HTML/AdminLTE originales conservando toda su funcionalidad.

## Estructura

```
src/app/
├── core/
│   ├── api/            ApiClient (base URL en tiempo de ejecución) y modelos TypeScript de la API
│   ├── auth/           AuthService (token), interceptor HTTP y guards por rol
│   ├── config/         carga de assets/config.json antes de arrancar
│   ├── filters/        GlobalFiltersStore: fecha, cliente, estado y criticidad de la barra superior
│   ├── resources/      definición de columnas, campos y filtros de cada tabla (16 recursos)
│   ├── services/       catálogos (clientes, estados, criticidades) y estadísticas
│   └── ui/             avisos y confirmaciones (SweetAlert2)
├── layout/             shell (sidebar + barra superior), sidebar, filtros globales
├── shared/             tabla genérica (paginación en servidor, orden, búsqueda, copiar/CSV/imprimir/columnas,
│                       selección y CRUD), diálogo de formulario, tarjeta de gráfico (Chart.js), KPI, insignias
└── features/
    ├── auth/           login, registro, recuperación (las dos últimas informativas, como en el original)
    ├── client/         dashboard, servicios de defensa
    ├── alerts/         tablero de alertas por servicio (lectura para clientes, CRUD para analistas)
    └── analyst/        configuración de clientes/metadatos/dorks y estado de servidores (datos de ejemplo)
```

## Desarrollo

```bash
cd frontend
npm install
npm start          # http://localhost:4200, /api se redirige a http://localhost:8000 (proxy.conf.json)
npm run build      # dist/threattrack-frontend/browser
```

La URL de la API se lee de `public/assets/config.json` (`apiBaseUrl`, por defecto `/api`). En Docker, nginx sirve la aplicación y redirige `/api`, `/admin` y `/static` al backend, así que no hace falta CORS.

## Roles

- **Analista**: todas las secciones, con crear/editar/eliminar en todas las tablas.
- **Cliente**: dashboards, alertas y servicios de su propio cliente, solo lectura.

Los usuarios los crea el backend (`bootstrap_roles` o panel de administración).
