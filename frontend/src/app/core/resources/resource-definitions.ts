import { AlertSourceKey } from '../api/models';
import { FilterKind } from '../filters/global-filters.store';

export type ColumnType = 'text' | 'date' | 'datetime' | 'bool' | 'state' | 'severity' | 'link' | 'code' | 'number';

export interface ColumnDef {
  /** Campo del JSON que se muestra. */
  key: string;
  label: string;
  type?: ColumnType;
  /** Campo por el que se ordena en el servidor (por defecto `key`). `null` desactiva la ordenacion. */
  sortKey?: string | null;
  /** Oculta por defecto (se puede activar desde "Columnas"). */
  hidden?: boolean;
  /** Anchura maxima del contenido antes de truncar. */
  maxWidth?: string;
}

export type FieldType = 'text' | 'textarea' | 'number' | 'date' | 'datetime' | 'checkbox' | 'select' | 'email' | 'url';

/** Origen de las opciones de un campo `select`. */
export type OptionSource = 'customers' | 'states' | 'severities' | 'domains' | 'keywords';

export interface FieldDef {
  key: string;
  label: string;
  type: FieldType;
  required?: boolean;
  options?: OptionSource;
  /** No editable al modificar (por ejemplo, claves primarias). */
  lockOnEdit?: boolean;
  placeholder?: string;
  hint?: string;
}

export interface ResourceDef {
  key: string;
  /** Ruta del recurso en la API (misma que en la version original). */
  endpoint: string;
  title: string;
  /** Nombre en singular para los mensajes ("alerta", "cliente"...). */
  noun: string;
  columns: ColumnDef[];
  fields: FieldDef[];
  /** Filtros globales que afectan a este listado. */
  filters: FilterKind[];
  /** Campo identificador (por defecto `id`). */
  idKey?: string;
  /** Clave de la fuente en /status-counts/ (solo alertas). */
  countsKey?: AlertSourceKey;
  /** Ordenacion inicial. */
  defaultOrdering?: string;
}

// ---------------------------------------------------------------------------
// Columnas y campos reutilizados
// ---------------------------------------------------------------------------
const customerColumn: ColumnDef = { key: 'customer_name', label: 'Cliente', sortKey: 'customer__name' };
const notesColumn: ColumnDef = { key: 'notes', label: 'Observaciones', maxWidth: '18rem' };
const stateColumn: ColumnDef = { key: 'state_name', label: 'Estado', type: 'state', sortKey: 'state__name' };
const severityColumn: ColumnDef = { key: 'severity_name', label: 'Criticidad', type: 'severity', sortKey: 'severity__name' };
const detectedColumn: ColumnDef = { key: 'detected_at', label: 'Fecha', type: 'datetime' };
const domainColumn: ColumnDef = { key: 'domain_name', label: 'Dominio', sortKey: 'monitored_domain__domain_name' };

const customerField: FieldDef = { key: 'customer', label: 'Cliente', type: 'select', options: 'customers', required: true };
const notesField: FieldDef = { key: 'notes', label: 'Observaciones', type: 'textarea', placeholder: '¿Observaciones?' };
const stateField: FieldDef = { key: 'state', label: 'Estado', type: 'select', options: 'states' };
const severityField: FieldDef = { key: 'severity', label: 'Criticidad', type: 'select', options: 'severities' };
const detectedField: FieldDef = { key: 'detected_at', label: 'Fecha de detección', type: 'date' };
const domainField: FieldDef = { key: 'monitored_domain', label: 'Dominio', type: 'select', options: 'domains', required: true };

const assetColumns = (valueColumn: ColumnDef): ColumnDef[] => [
  customerColumn,
  { key: 'added_at', label: 'Fecha', type: 'datetime' },
  valueColumn,
  { key: 'is_active', label: 'Activo', type: 'bool' },
  notesColumn,
];

const assetFields = (valueField: FieldDef): FieldDef[] => [
  customerField,
  { key: 'added_at', label: 'Fecha de alta', type: 'date' },
  valueField,
  { key: 'is_active', label: 'Activo', type: 'checkbox' },
  notesField,
];

const alertFilters: FilterKind[] = ['dates', 'customer', 'state', 'severity'];
const assetFilters: FilterKind[] = ['dates', 'customer'];

// ---------------------------------------------------------------------------
// Clientes y configuracion
// ---------------------------------------------------------------------------
export const CUSTOMERS: ResourceDef = {
  key: 'customers',
  endpoint: 'Clients/',
  title: 'Clientes',
  noun: 'cliente',
  columns: [
    { key: 'name', label: 'Cliente' },
    { key: 'registered_at', label: 'Fecha', type: 'datetime' },
    { key: 'is_active', label: 'Estado', type: 'bool' },
    notesColumn,
  ],
  fields: [
    { key: 'name', label: 'Cliente', type: 'text', required: true, placeholder: 'Nombre del cliente' },
    { key: 'registered_at', label: 'Fecha de alta', type: 'date' },
    { key: 'is_active', label: 'Activo', type: 'checkbox' },
    notesField,
  ],
  filters: [],
  defaultOrdering: 'id',
};

const SERVICE_FLAGS: Array<[string, string]> = [
  ['defacement_enabled', 'Defacement'],
  ['github_enabled', 'GitHub'],
  ['gitlab_enabled', 'GitLab'],
  ['google_enabled', 'Google'],
  ['intelx_enabled', 'IntelX'],
  ['shodan_enabled', 'Shodan'],
  ['telegram_enabled', 'Telegram'],
  ['twitter_enabled', 'Twitter'],
  ['typosquatting_enabled', 'Typosquatting'],
  ['certificates_enabled', 'Certificados'],
  ['blocklist_enabled', 'Listas de bloqueo'],
];

export const SUBSCRIPTIONS: ResourceDef = {
  key: 'subscriptions',
  endpoint: 'Apps/',
  title: 'Servicios contratados por los clientes',
  noun: 'registro de servicios',
  idKey: 'customer',
  columns: [
    customerColumn,
    ...SERVICE_FLAGS.map(([key, label]): ColumnDef => ({ key, label, type: 'bool' })),
    notesColumn,
  ],
  fields: [
    { ...customerField, lockOnEdit: true },
    ...SERVICE_FLAGS.map(([key, label]): FieldDef => ({ key, label, type: 'checkbox' })),
    notesField,
  ],
  filters: ['customer'],
  defaultOrdering: 'customer_id',
};

export const DOMAINS: ResourceDef = {
  key: 'domains',
  endpoint: 'Domains/',
  title: 'Dominios del cliente',
  noun: 'dominio',
  columns: assetColumns({ key: 'domain_name', label: 'Dominio' }),
  fields: assetFields({ key: 'domain_name', label: 'Dominio', type: 'text', required: true, placeholder: 'ejemplo.com' }),
  filters: assetFilters,
  defaultOrdering: '-added_at',
};

export const IPS: ResourceDef = {
  key: 'ips',
  endpoint: 'Ips/',
  title: 'IPs del cliente',
  noun: 'IP',
  columns: assetColumns({ key: 'ip_address', label: 'IP' }),
  fields: assetFields({ key: 'ip_address', label: 'IP', type: 'text', required: true, placeholder: '203.0.113.10' }),
  filters: assetFilters,
  defaultOrdering: '-added_at',
};

export const KEYWORDS: ResourceDef = {
  key: 'keywords',
  endpoint: 'Keywords/',
  title: 'Keywords del cliente',
  noun: 'keyword',
  columns: assetColumns({ key: 'term', label: 'Keyword' }),
  fields: assetFields({ key: 'term', label: 'Keyword', type: 'text', required: true }),
  filters: assetFilters,
  defaultOrdering: '-added_at',
};

const dorkResource = (key: string, endpoint: string, title: string): ResourceDef => ({
  key,
  endpoint,
  title,
  noun: 'dork',
  columns: assetColumns({ key: 'query_text', label: 'Dork', maxWidth: '28rem' }),
  fields: assetFields({ key: 'query_text', label: 'Dork', type: 'textarea', required: true }),
  filters: assetFilters,
  defaultOrdering: '-added_at',
});

export const GOOGLE_DORKS = dorkResource('google_dorks', 'GoogleDorks/', 'Google Dorks');
export const SHODAN_DORKS = dorkResource('shodan_dorks', 'ShodanDorks/', 'Shodan Dorks');
export const TWITTER_DORKS = dorkResource('twitter_dorks', 'TwitterDorks/', 'Twitter Dorks');

// ---------------------------------------------------------------------------
// Alertas
// ---------------------------------------------------------------------------
export const GOOGLE_ALERTS: ResourceDef = {
  key: 'google',
  endpoint: 'Google/',
  title: 'Google',
  noun: 'alerta',
  countsKey: 'google',
  columns: [
    customerColumn,
    detectedColumn,
    severityColumn,
    { key: 'query_text', label: 'Dork', maxWidth: '16rem' },
    { key: 'url', label: 'Enlace', type: 'link' },
    { key: 'page_title', label: 'Título', maxWidth: '16rem' },
    { key: 'last_seen_at', label: 'Último hallazgo', type: 'datetime' },
    stateColumn,
    notesColumn,
  ],
  fields: [
    customerField,
    detectedField,
    severityField,
    { key: 'query_text', label: 'Dork', type: 'textarea', required: true },
    { key: 'url', label: 'Enlace', type: 'url', required: true },
    { key: 'page_title', label: 'Título', type: 'text' },
    { key: 'last_seen_at', label: 'Último hallazgo', type: 'date' },
    stateField,
    notesField,
  ],
  filters: alertFilters,
};

export const GITHUB_ALERTS: ResourceDef = {
  key: 'github',
  endpoint: 'Github/',
  title: 'Github',
  noun: 'alerta',
  countsKey: 'github',
  columns: [
    customerColumn,
    detectedColumn,
    severityColumn,
    domainColumn,
    { key: 'repository', label: 'Repositorio', type: 'link' },
    { key: 'author_name', label: 'Nombre de usuario' },
    { key: 'author_email', label: 'Correo electrónico' },
    { key: 'commit_hash', label: 'Commit', type: 'code' },
    { key: 'url', label: 'Enlace', type: 'link' },
    { key: 'committed_at', label: 'Fecha del commit', type: 'datetime' },
    { key: 'is_analyzed', label: 'Analizado', type: 'bool' },
    stateColumn,
    notesColumn,
  ],
  fields: [
    customerField,
    detectedField,
    severityField,
    domainField,
    { key: 'repository', label: 'Repositorio', type: 'text', required: true },
    { key: 'author_name', label: 'Nombre de usuario', type: 'text', required: true },
    { key: 'author_email', label: 'Correo electrónico', type: 'email', required: true },
    { key: 'commit_hash', label: 'Commit', type: 'text', required: true },
    { key: 'url', label: 'Enlace', type: 'url', required: true },
    { key: 'committed_at', label: 'Fecha del commit', type: 'date', required: true },
    { key: 'is_analyzed', label: 'Analizado', type: 'checkbox' },
    stateField,
    notesField,
  ],
  filters: alertFilters,
};

export const GITLAB_ALERTS: ResourceDef = {
  key: 'gitlab',
  endpoint: 'Gitlab/',
  title: 'Gitlab',
  noun: 'alerta',
  countsKey: 'gitlab',
  columns: [
    customerColumn,
    detectedColumn,
    severityColumn,
    { key: 'keyword_term', label: 'Keyword', sortKey: 'monitored_keyword__term' },
    { key: 'project_name', label: 'Proyecto' },
    { key: 'author_name', label: 'Nombre de usuario' },
    { key: 'project_description', label: 'Descripción', maxWidth: '16rem' },
    { key: 'url', label: 'Link', type: 'link' },
    { key: 'project_created_at', label: 'Fecha del proyecto' },
    stateColumn,
    notesColumn,
  ],
  fields: [
    customerField,
    detectedField,
    severityField,
    { key: 'monitored_keyword', label: 'Palabra clave', type: 'select', options: 'keywords', required: true },
    { key: 'project_name', label: 'Proyecto', type: 'text', required: true },
    { key: 'author_name', label: 'Nombre de usuario', type: 'text', required: true },
    { key: 'project_description', label: 'Descripción', type: 'textarea' },
    { key: 'url', label: 'Enlace', type: 'url' },
    { key: 'project_created_at', label: 'Fecha del proyecto', type: 'date' },
    stateField,
    notesField,
  ],
  filters: alertFilters,
};

export const INTELX_ALERTS: ResourceDef = {
  key: 'intelx',
  endpoint: 'Intelx/',
  title: 'IntelX',
  noun: 'alerta',
  countsKey: 'intelx',
  columns: [
    customerColumn,
    detectedColumn,
    severityColumn,
    domainColumn,
    { key: 'leak_name', label: 'Nombre', type: 'link' },
    { key: 'url', label: 'Link', type: 'link' },
    { key: 'source_bucket', label: 'Bucket' },
    stateColumn,
    notesColumn,
  ],
  fields: [
    customerField,
    detectedField,
    severityField,
    domainField,
    { key: 'leak_name', label: 'Nombre', type: 'text', required: true },
    { key: 'url', label: 'Enlace', type: 'url' },
    { key: 'source_bucket', label: 'Bucket', type: 'text' },
    stateField,
    notesField,
  ],
  filters: alertFilters,
};

export const DEFACEMENT_ALERTS: ResourceDef = {
  key: 'defacement',
  endpoint: 'Defacement/',
  title: 'Defacement',
  noun: 'alerta',
  countsKey: 'defacement',
  columns: [
    customerColumn,
    detectedColumn,
    severityColumn,
    domainColumn,
    { key: 'content_md5', label: 'MD5', type: 'code', sortKey: null, maxWidth: '12rem' },
    { key: 'content_sha256', label: 'SHA256', type: 'code', sortKey: null, maxWidth: '12rem' },
    stateColumn,
    notesColumn,
  ],
  fields: [
    customerField,
    detectedField,
    severityField,
    domainField,
    { key: 'content_md5', label: 'MD5', type: 'text', required: true, hint: 'Valor en base64 (tal y como lo almacena la API).' },
    { key: 'content_sha256', label: 'SHA256', type: 'text', required: true, hint: 'Valor en base64 (tal y como lo almacena la API).' },
    stateField,
    notesField,
  ],
  filters: alertFilters,
};

export const CERTIFICATE_ALERTS: ResourceDef = {
  key: 'certificates',
  endpoint: 'Certificates/',
  title: 'Certificates',
  noun: 'alerta',
  countsKey: 'certificates',
  columns: [
    customerColumn,
    detectedColumn,
    severityColumn,
    domainColumn,
    { key: 'certificate_summary', label: 'Certificados', maxWidth: '26rem' },
    stateColumn,
    notesColumn,
  ],
  fields: [
    customerField,
    detectedField,
    severityField,
    domainField,
    { key: 'certificate_summary', label: 'Certificados', type: 'textarea', required: true },
    stateField,
    notesField,
  ],
  filters: alertFilters,
};

export const SHODAN_ALERTS: ResourceDef = {
  key: 'shodan',
  endpoint: 'Shodan/',
  title: 'Shodan',
  noun: 'alerta',
  countsKey: 'shodan',
  columns: [
    customerColumn,
    detectedColumn,
    severityColumn,
    { key: 'domain_names', label: 'Dominio', maxWidth: '14rem' },
    { key: 'ip_address', label: 'IP' },
    { key: 'query_text', label: 'Dork', maxWidth: '14rem' },
    { key: 'asn_number', label: 'ASN' },
    { key: 'country_name', label: 'País' },
    { key: 'hostname_list', label: 'Hostnames', maxWidth: '14rem' },
    { key: 'organization_name', label: 'Organización' },
    { key: 'cpe_list', label: 'CPE', maxWidth: '14rem' },
    stateColumn,
    notesColumn,
  ],
  fields: [
    customerField,
    detectedField,
    severityField,
    { key: 'domain_names', label: 'Dominio', type: 'text' },
    { key: 'ip_address', label: 'IP', type: 'text', required: true },
    { key: 'query_text', label: 'Dork', type: 'textarea' },
    { key: 'asn_number', label: 'ASN', type: 'text', required: true },
    { key: 'country_name', label: 'País', type: 'text', required: true },
    { key: 'hostname_list', label: 'Hostnames', type: 'text' },
    { key: 'organization_name', label: 'Organización', type: 'text' },
    { key: 'cpe_list', label: 'CPE', type: 'text' },
    stateField,
    notesField,
  ],
  filters: alertFilters,
};

export const TYPOSQUATTING_ALERTS: ResourceDef = {
  key: 'typosquatting',
  endpoint: 'Typosquatting/',
  title: 'Typosquatting',
  noun: 'alerta',
  countsKey: 'typosquatting',
  columns: [
    customerColumn,
    detectedColumn,
    severityColumn,
    domainColumn,
    { key: 'lookalike_domain', label: 'Typosquatting' },
    { key: 'resolved_ip', label: 'IP' },
    stateColumn,
    notesColumn,
  ],
  fields: [
    customerField,
    detectedField,
    severityField,
    domainField,
    { key: 'lookalike_domain', label: 'Dominio parecido', type: 'text', required: true },
    { key: 'resolved_ip', label: 'IP', type: 'text', required: true },
    stateField,
    notesField,
  ],
  filters: alertFilters,
};
