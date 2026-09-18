/**
 * Modelos de la API REST de ThreatTrackApp (campos tal y como los devuelve el backend v2).
 */

export interface Paginated<T> {
  count: number;
  next: string | null;
  previous: string | null;
  results: T[];
}

export type QueryParams = Record<string, string | number | boolean | null | undefined>;

export interface Lookup {
  id: number;
  name: string;
}

export type AlertStateName = 'open' | 'in_progress' | 'resolved' | 'false_positive' | 'duplicated';
export type AlertSeverityName = 'critical' | 'high' | 'medium' | 'low' | 'informative' | 'unknown';
export type UserRole = 'analyst' | 'client';

export interface SessionInfo {
  username: string;
  role: UserRole | null;
  customer: { id: number; name: string } | null;
}

export interface LoginResponse extends SessionInfo {
  token: string;
}

// ---------------------------------------------------------------------------
// Clientes y configuracion
// ---------------------------------------------------------------------------
export interface Customer {
  id: number;
  name: string;
  registered_at: string | null;
  is_active: boolean;
  notes: string | null;
}

export interface CustomerServiceSubscription {
  customer: number;
  customer_name: string;
  defacement_enabled: boolean;
  github_enabled: boolean;
  gitlab_enabled: boolean;
  google_enabled: boolean;
  intelx_enabled: boolean;
  shodan_enabled: boolean;
  telegram_enabled: boolean;
  twitter_enabled: boolean;
  typosquatting_enabled: boolean;
  certificates_enabled: boolean;
  blocklist_enabled: boolean;
  notes: string | null;
}

export interface CustomerAsset {
  id: number;
  customer: number;
  customer_name: string;
  is_active: boolean;
  added_at: string | null;
  notes: string | null;
}

export interface MonitoredDomain extends CustomerAsset {
  domain_name: string;
}

export interface MonitoredIpAddress extends CustomerAsset {
  ip_address: string;
}

export interface MonitoredKeyword extends CustomerAsset {
  term: string;
}

export interface DorkQuery extends CustomerAsset {
  query_text: string;
}

// ---------------------------------------------------------------------------
// Alertas
// ---------------------------------------------------------------------------
export interface AlertBase {
  id: number;
  detected_at: string | null;
  state: number;
  state_name: AlertStateName;
  severity: number;
  severity_name: AlertSeverityName;
  notes: string | null;
  customer: number | null;
  customer_name: string;
}

export interface DomainAlert extends AlertBase {
  monitored_domain: number;
  domain_name: string;
}

export interface GithubCommitAlert extends DomainAlert {
  repository: string;
  author_name: string;
  author_email: string;
  commit_hash: string;
  url: string;
  committed_at: string;
  is_analyzed: boolean;
}

export interface GitlabProjectAlert extends AlertBase {
  monitored_keyword: number;
  keyword_term: string;
  project_name: string;
  author_name: string;
  project_description: string | null;
  url: string | null;
  project_created_at: string | null;
}

export interface GoogleSearchAlert extends AlertBase {
  query_text: string;
  url: string;
  page_title: string | null;
  last_seen_at: string | null;
}

export interface IntelxLeakAlert extends DomainAlert {
  leak_name: string;
  url: string | null;
  source_bucket: string | null;
}

export interface DefacementAlert extends DomainAlert {
  content_md5: string;
  content_sha256: string;
}

export interface CertificateAlert extends DomainAlert {
  certificate_summary: string;
}

export interface TyposquattingAlert extends DomainAlert {
  lookalike_domain: string;
  resolved_ip: string;
}

export interface ShodanHostAlert extends AlertBase {
  domain_names: string | null;
  ip_address: string;
  query_text: string | null;
  asn_number: string;
  country_name: string;
  hostname_list: string | null;
  organization_name: string | null;
  cpe_list: string | null;
}

// ---------------------------------------------------------------------------
// Estadisticas
// ---------------------------------------------------------------------------
export type AlertSourceKey =
  | 'certificates'
  | 'defacement'
  | 'github'
  | 'gitlab'
  | 'google'
  | 'intelx'
  | 'shodan_legacy'
  | 'shodan'
  | 'shodan_ports'
  | 'shodan_vulns'
  | 'telegram'
  | 'twitter'
  | 'typosquatting';

export type ServiceModuleKey =
  | 'information_leaks'
  | 'credential_exposure'
  | 'defacement'
  | 'domain_monitoring'
  | 'system_vulnerabilities_monitoring'
  | 'phishing_and_fraudulent_domains';

export type SeverityCounts = Record<'critical' | 'high' | 'medium' | 'low' | 'informative', number>;

export interface StatusCounts {
  window_days: number;
  open: Partial<Record<AlertSourceKey, number>>;
  in_progress: Partial<Record<AlertSourceKey, number>>;
  resolved: Partial<Record<AlertSourceKey, number>>;
}

export interface OpenResolvedTotals {
  open: number;
  resolved: number;
}

export interface OpenResolvedBySeverity {
  open_by_severity: SeverityCounts;
  resolved_by_severity: SeverityCounts;
}

export interface OpenResolvedByModule {
  open_by_module: Record<ServiceModuleKey, number>;
  resolved_by_module: Record<ServiceModuleKey, number>;
}

export interface DailyOpenResolved {
  days: string[];
  open: number[];
  resolved: number[];
}

export interface DailyByModule {
  days: string[];
  by_module: Record<ServiceModuleKey, number[]>;
}

export interface ActiveInactiveCount {
  active: number;
  inactive: number;
}
