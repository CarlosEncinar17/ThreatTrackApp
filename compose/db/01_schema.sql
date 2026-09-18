-- =====================================================================
-- ThreatTrackApp - esquema de base de datos (PostgreSQL 16)
--
-- Una tabla por fuente OSINT, con estado, criticidad y fecha de deteccion en
-- todas las alertas, restricciones UNIQUE que definen que es un hallazgo
-- repetido e indices sobre las columnas por las que filtran los dashboards.
--
-- Las tablas internas de Django (auth_*, django_*) las crea `manage.py migrate`
-- al arrancar el backend; ya no forman parte de este script.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- Catalogos y entidades sin dependencias
-- ---------------------------------------------------------------------

-- Empresas cliente de la plataforma
CREATE TABLE public.customers (
    id            serial4 NOT NULL,
    "name"        varchar(255) NOT NULL,
    registered_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    is_active     bool NOT NULL,
    notes         text NULL,
    CONSTRAINT customers_name_key UNIQUE ("name"),
    CONSTRAINT customers_pkey PRIMARY KEY (id)
);

-- Catalogo de criticidades de alerta (critical, high, medium, low, informative, unknown)
CREATE TABLE public.alert_severities (
    id     serial4 NOT NULL,
    "name" varchar(255) NOT NULL,
    CONSTRAINT alert_severities_pkey PRIMARY KEY (id)
);

-- Catalogo de estados de alerta (open, in_progress, resolved, false_positive, duplicated)
CREATE TABLE public.alert_states (
    id     serial4 NOT NULL,
    "name" varchar(255) NOT NULL,
    CONSTRAINT alert_states_pkey PRIMARY KEY (id)
);

-- Catalogo de servicios de cibervigilancia ofrecidos
CREATE TABLE public.service_catalog (
    id     serial4 NOT NULL,
    "name" varchar(255) NOT NULL,
    CONSTRAINT service_catalog_pkey PRIMARY KEY (id)
);

-- Ejecuciones de los scripts OSINT (un registro por modulo y ejecucion)
CREATE TABLE public.scan_runs (
    id              serial4 NOT NULL,
    module_name     varchar(255) NOT NULL,
    run_started_at  timestamptz DEFAULT CURRENT_TIMESTAMP NULL,
    run_finished_at timestamptz NULL,
    notes           text NULL,
    CONSTRAINT scan_runs_pkey PRIMARY KEY (id)
);

-- Canales y grupos de Telegram monitorizados
CREATE TABLE public.telegram_channels (
    id           serial4 NOT NULL,
    channel_name varchar(255) NOT NULL,
    added_at     timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    is_active    bool NOT NULL,
    notes        text NULL,
    CONSTRAINT telegram_channels_channel_name_key UNIQUE (channel_name),
    CONSTRAINT telegram_channels_pkey PRIMARY KEY (id)
);

-- Dominios presentes en listas de bloqueo publicas
CREATE TABLE public.blocklisted_domains (
    id                serial4 NOT NULL,
    domain_name       varchar(1024) NOT NULL,
    list_category     varchar(20) NOT NULL,
    list_source       varchar(255) NOT NULL,
    listed_at         varchar(255) NOT NULL,
    report_count      int4 NOT NULL,
    reliability_score int4 NOT NULL,
    threat_score      numeric(2, 1) NOT NULL,
    detected_at       timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    CONSTRAINT blocklisted_domains_pkey PRIMARY KEY (id)
);

-- Dominios en listas de bloqueo con mayor puntuacion
CREATE TABLE public.blocklisted_domains_top_scores (
    id                serial4 NOT NULL,
    domain_name       varchar(255) NOT NULL,
    list_category     varchar(20) NOT NULL,
    list_source       varchar(255) NOT NULL,
    listed_at         varchar(255) NOT NULL,
    report_count      int4 NOT NULL,
    reliability_score int4 NOT NULL,
    threat_score      numeric(2, 1) NOT NULL,
    detected_at       timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    CONSTRAINT blocklisted_domains_top_scores_pkey PRIMARY KEY (id)
);

-- Direcciones IP presentes en listas de bloqueo publicas
CREATE TABLE public.blocklisted_ip_addresses (
    id                serial4 NOT NULL,
    ip_address        varchar(255) NOT NULL,
    list_category     varchar(20) NOT NULL,
    list_source       varchar(255) NOT NULL,
    listed_at         varchar(255) NOT NULL,
    report_count      int4 NOT NULL,
    reliability_score int4 NOT NULL,
    threat_score      numeric(2, 1) NOT NULL,
    detected_at       timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    CONSTRAINT blocklisted_ip_addresses_pkey PRIMARY KEY (id)
);

-- Direcciones IP en listas de bloqueo con mayor puntuacion
CREATE TABLE public.blocklisted_ip_addresses_top_scores (
    id                serial4 NOT NULL,
    ip_address        varchar(255) NOT NULL,
    list_category     varchar(20) NOT NULL,
    list_source       varchar(255) NOT NULL,
    listed_at         varchar(255) NOT NULL,
    report_count      int4 NOT NULL,
    reliability_score int4 NOT NULL,
    threat_score      numeric(2, 1) NOT NULL,
    detected_at       timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    CONSTRAINT blocklisted_ip_addresses_top_scores_pkey PRIMARY KEY (id)
);

-- ---------------------------------------------------------------------
-- Configuracion por cliente: servicios contratados, activos y consultas
-- ---------------------------------------------------------------------

-- Servicios contratados por cada cliente (una fila por cliente)
CREATE TABLE public.customer_service_subscriptions (
    customer_id           int4 NOT NULL,
    defacement_enabled    bool NOT NULL,
    github_enabled        bool NOT NULL,
    gitlab_enabled        bool NOT NULL,
    google_enabled        bool NOT NULL,
    intelx_enabled        bool NOT NULL,
    shodan_enabled        bool NOT NULL,
    telegram_enabled      bool NOT NULL,
    twitter_enabled       bool NOT NULL,
    typosquatting_enabled bool NOT NULL,
    certificates_enabled  bool NOT NULL,
    blocklist_enabled     bool NOT NULL,
    notes                 text NULL,
    CONSTRAINT customer_service_subscriptions_pkey PRIMARY KEY (customer_id),
    CONSTRAINT customer_service_subscriptions_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id)
);

-- Dominios de cada cliente bajo monitorizacion
CREATE TABLE public.monitored_domains (
    id          serial4 NOT NULL,
    domain_name varchar(255) NOT NULL,
    added_at    timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    customer_id int4 NOT NULL,
    is_active   bool NOT NULL,
    notes       text NULL,
    CONSTRAINT monitored_domains_domain_name_key UNIQUE (domain_name),
    CONSTRAINT monitored_domains_pkey PRIMARY KEY (id),
    CONSTRAINT monitored_domains_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id)
);
CREATE INDEX monitored_domains_customer_id_idx ON public.monitored_domains USING btree (customer_id);

-- Direcciones IP de cada cliente bajo monitorizacion
CREATE TABLE public.monitored_ip_addresses (
    id          serial4 NOT NULL,
    ip_address  varchar(255) NOT NULL,
    added_at    timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    customer_id int4 NOT NULL,
    is_active   bool NOT NULL,
    notes       text NULL,
    CONSTRAINT monitored_ip_addresses_ip_address_key UNIQUE (ip_address),
    CONSTRAINT monitored_ip_addresses_pkey PRIMARY KEY (id),
    CONSTRAINT monitored_ip_addresses_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id)
);
CREATE INDEX monitored_ip_addresses_customer_id_idx ON public.monitored_ip_addresses USING btree (customer_id);

-- Palabras clave de cada cliente bajo monitorizacion
CREATE TABLE public.monitored_keywords (
    id          serial4 NOT NULL,
    term        varchar(255) NOT NULL,
    customer_id int4 NOT NULL,
    is_active   bool NOT NULL,
    added_at    timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    notes       text NULL,
    CONSTRAINT monitored_keywords_term_key UNIQUE (term),
    CONSTRAINT monitored_keywords_pkey PRIMARY KEY (id),
    CONSTRAINT monitored_keywords_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id)
);
CREATE INDEX monitored_keywords_customer_id_idx ON public.monitored_keywords USING btree (customer_id);

-- Consultas avanzadas (dorks) de Google por cliente
CREATE TABLE public.google_dork_queries (
    id          serial4 NOT NULL,
    query_text  text NOT NULL,
    customer_id int4 NOT NULL,
    is_active   bool NOT NULL,
    added_at    timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    notes       text NULL,
    CONSTRAINT google_dork_queries_query_text_key UNIQUE (query_text),
    CONSTRAINT google_dork_queries_pkey PRIMARY KEY (id),
    CONSTRAINT google_dork_queries_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id)
);
CREATE INDEX google_dork_queries_customer_id_idx ON public.google_dork_queries USING btree (customer_id);

-- Consultas avanzadas (dorks) de Shodan por cliente
CREATE TABLE public.shodan_dork_queries (
    id          serial4 NOT NULL,
    query_text  text NOT NULL,
    customer_id int4 NOT NULL,
    is_active   bool NOT NULL,
    added_at    timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    notes       text NULL,
    CONSTRAINT shodan_dork_queries_query_text_key UNIQUE (query_text),
    CONSTRAINT shodan_dork_queries_pkey PRIMARY KEY (id),
    CONSTRAINT shodan_dork_queries_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id)
);
CREATE INDEX shodan_dork_queries_customer_id_idx ON public.shodan_dork_queries USING btree (customer_id);

-- Consultas avanzadas (dorks) de Twitter por cliente
CREATE TABLE public.twitter_dork_queries (
    id          serial4 NOT NULL,
    query_text  text NOT NULL,
    customer_id int4 NOT NULL,
    is_active   bool NOT NULL,
    added_at    timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    notes       text NULL,
    CONSTRAINT twitter_dork_queries_pkey PRIMARY KEY (id),
    CONSTRAINT twitter_dork_queries_query_text_key UNIQUE (query_text),
    CONSTRAINT twitter_dork_queries_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id)
);
CREATE INDEX twitter_dork_queries_customer_id_idx ON public.twitter_dork_queries USING btree (customer_id);

-- ---------------------------------------------------------------------
-- Alertas: fugas de informacion
-- ---------------------------------------------------------------------

-- Commits de GitHub relacionados con dominios del cliente
CREATE TABLE public.github_commit_alerts (
    id           serial4 NOT NULL,
    domain_id    int4 NOT NULL,
    repository   varchar(255) NOT NULL,
    author_name  varchar(255) NOT NULL,
    author_email varchar(255) NOT NULL,
    commit_hash  varchar(255) NOT NULL,
    url          text NOT NULL,
    detected_at  timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    committed_at timestamp NOT NULL,
    is_analyzed  bool DEFAULT false NOT NULL,
    customer_id  int4 NOT NULL,
    notes        text NULL,
    state_id     int4 DEFAULT 1 NOT NULL,
    severity_id  int4 DEFAULT 6 NOT NULL,
    CONSTRAINT github_commit_alerts_domain_id_repository_commit_hash_key UNIQUE (domain_id, repository, commit_hash),
    CONSTRAINT github_commit_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT github_commit_alerts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
    CONSTRAINT github_commit_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT github_commit_alerts_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES public.monitored_domains(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT github_commit_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id)
);
CREATE INDEX github_commit_alerts_committed_at_idx ON public.github_commit_alerts USING btree (committed_at);
CREATE INDEX github_commit_alerts_state_id_idx ON public.github_commit_alerts USING btree (state_id);
CREATE INDEX github_commit_alerts_severity_id_idx ON public.github_commit_alerts USING btree (severity_id);
CREATE INDEX github_commit_alerts_detected_at_idx ON public.github_commit_alerts USING btree (detected_at);
CREATE INDEX github_commit_alerts_customer_id_idx ON public.github_commit_alerts USING btree (customer_id);
CREATE INDEX github_commit_alerts_domain_id_idx ON public.github_commit_alerts USING btree (domain_id);

-- Proyectos de GitLab que coinciden con palabras clave del cliente
CREATE TABLE public.gitlab_project_alerts (
    id                   serial4 NOT NULL,
    monitored_keyword_id int4 NOT NULL,
    project_name         varchar(255) NOT NULL,
    author_name          varchar(255) NOT NULL,
    project_description  text NULL,
    url                  text NULL,
    project_created_at   varchar(255) NULL,
    detected_at          timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    customer_id          int4 NOT NULL,
    notes                text NULL,
    state_id             int4 DEFAULT 1 NOT NULL,
    severity_id          int4 DEFAULT 6 NOT NULL,
    CONSTRAINT gitlab_project_alerts_keyword_project_author_key UNIQUE (monitored_keyword_id, project_name, author_name),
    CONSTRAINT gitlab_project_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT gitlab_project_alerts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
    CONSTRAINT gitlab_project_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT gitlab_project_alerts_monitored_keyword_id_fkey FOREIGN KEY (monitored_keyword_id) REFERENCES public.monitored_keywords(id),
    CONSTRAINT gitlab_project_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id)
);
CREATE INDEX gitlab_project_alerts_state_id_idx ON public.gitlab_project_alerts USING btree (state_id);
CREATE INDEX gitlab_project_alerts_severity_id_idx ON public.gitlab_project_alerts USING btree (severity_id);
CREATE INDEX gitlab_project_alerts_detected_at_idx ON public.gitlab_project_alerts USING btree (detected_at);
CREATE INDEX gitlab_project_alerts_customer_id_idx ON public.gitlab_project_alerts USING btree (customer_id);
CREATE INDEX gitlab_project_alerts_monitored_keyword_id_idx ON public.gitlab_project_alerts USING btree (monitored_keyword_id);

-- Resultados de busquedas avanzadas de Google
CREATE TABLE public.google_search_alerts (
    id           serial4 NOT NULL,
    query_text   text NOT NULL,
    url          text NOT NULL,
    page_title   text NULL,
    detected_at  timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    last_seen_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    customer_id  int4 NOT NULL,
    notes        text NULL,
    state_id     int4 DEFAULT 1 NOT NULL,
    severity_id  int4 DEFAULT 6 NOT NULL,
    CONSTRAINT google_search_alerts_query_text_url_key UNIQUE (query_text, url),
    CONSTRAINT google_search_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT google_search_alerts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
    CONSTRAINT google_search_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT google_search_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id)
);
CREATE INDEX google_search_alerts_state_id_idx ON public.google_search_alerts USING btree (state_id);
CREATE INDEX google_search_alerts_severity_id_idx ON public.google_search_alerts USING btree (severity_id);
CREATE INDEX google_search_alerts_detected_at_idx ON public.google_search_alerts USING btree (detected_at);
CREATE INDEX google_search_alerts_customer_id_idx ON public.google_search_alerts USING btree (customer_id);

-- ---------------------------------------------------------------------
-- Alertas: exposicion de credenciales
-- ---------------------------------------------------------------------

-- Hallazgos de Intelligence X asociados a dominios del cliente
CREATE TABLE public.intelx_leak_alerts (
    id            serial4 NOT NULL,
    domain_id     int4 NOT NULL,
    leak_name     text NOT NULL,
    url           text NULL,
    source_bucket text NULL,
    detected_at   timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    customer_id   int4 NOT NULL,
    notes         text NULL,
    state_id      int4 DEFAULT 1 NOT NULL,
    severity_id   int4 DEFAULT 6 NOT NULL,
    CONSTRAINT intelx_leak_alerts_url_key UNIQUE (url),
    CONSTRAINT intelx_leak_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT intelx_leak_alerts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
    CONSTRAINT intelx_leak_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT intelx_leak_alerts_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES public.monitored_domains(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT intelx_leak_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id)
);
CREATE INDEX intelx_leak_alerts_state_id_idx ON public.intelx_leak_alerts USING btree (state_id);
CREATE INDEX intelx_leak_alerts_severity_id_idx ON public.intelx_leak_alerts USING btree (severity_id);
CREATE INDEX intelx_leak_alerts_detected_at_idx ON public.intelx_leak_alerts USING btree (detected_at);
CREATE INDEX intelx_leak_alerts_customer_id_idx ON public.intelx_leak_alerts USING btree (customer_id);
CREATE INDEX intelx_leak_alerts_domain_id_idx ON public.intelx_leak_alerts USING btree (domain_id);

-- Secretos detectados dentro de los commits de GitHub
CREATE TABLE public.leaked_secret_alerts (
    id               serial4 NOT NULL,
    line_start       int4 NOT NULL,
    line_end         int4 NOT NULL,
    column_start     int4 NOT NULL,
    column_end       int4 NOT NULL,
    matched_text     varchar NOT NULL,
    secret_value     varchar NOT NULL,
    file_path        varchar(255) NOT NULL,
    entropy_score    float4 NOT NULL,
    author_name      varchar(255) NOT NULL,
    author_email     varchar(255) NOT NULL,
    committed_at     date NOT NULL,
    commit_message   varchar NOT NULL,
    detection_rule   varchar(255) NOT NULL,
    fingerprint_hash varchar(255) NOT NULL,
    tag_list         varchar NULL,
    commit_hash      varchar(255) NOT NULL,
    github_alert_id  int4 NOT NULL,
    detected_at      date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    rule_description varchar NULL,
    notes            text NULL,
    state_id         int4 DEFAULT 1 NOT NULL,
    severity_id      int4 DEFAULT 6 NOT NULL,
    CONSTRAINT leaked_secret_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT leaked_secret_alerts_fingerprint_hash_github_alert_id_key UNIQUE (fingerprint_hash, github_alert_id),
    CONSTRAINT leaked_secret_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT leaked_secret_alerts_github_alert_id_fkey FOREIGN KEY (github_alert_id) REFERENCES public.github_commit_alerts(id) ON DELETE CASCADE,
    CONSTRAINT leaked_secret_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id)
);
COMMENT ON TABLE public.leaked_secret_alerts IS 'Secretos identificados en los repositorios de codigo monitorizados';
CREATE INDEX leaked_secret_alerts_state_id_idx ON public.leaked_secret_alerts USING btree (state_id);
CREATE INDEX leaked_secret_alerts_severity_id_idx ON public.leaked_secret_alerts USING btree (severity_id);
CREATE INDEX leaked_secret_alerts_detected_at_idx ON public.leaked_secret_alerts USING btree (detected_at);
CREATE INDEX leaked_secret_alerts_github_alert_id_idx ON public.leaked_secret_alerts USING btree (github_alert_id);

-- Mensajes de Telegram que coinciden con palabras clave del cliente
CREATE TABLE public.telegram_message_alerts (
    id                   serial4 NOT NULL,
    monitored_keyword_id int4 NOT NULL,
    channel_id           int4 NOT NULL,
    message_text         text NOT NULL,
    sender_identifier    varchar(255) NOT NULL,
    message_sent_at      varchar(255) NOT NULL,
    customer_id          int4 NOT NULL,
    detected_at          timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    notes                text NULL,
    state_id             int4 DEFAULT 1 NOT NULL,
    severity_id          int4 DEFAULT 6 NOT NULL,
    CONSTRAINT telegram_message_alerts_keyword_channel_message_key UNIQUE (monitored_keyword_id, channel_id, message_text),
    CONSTRAINT telegram_message_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT telegram_message_alerts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
    CONSTRAINT telegram_message_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT telegram_message_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id)
);
CREATE INDEX telegram_message_alerts_state_id_idx ON public.telegram_message_alerts USING btree (state_id);
CREATE INDEX telegram_message_alerts_severity_id_idx ON public.telegram_message_alerts USING btree (severity_id);
CREATE INDEX telegram_message_alerts_detected_at_idx ON public.telegram_message_alerts USING btree (detected_at);
CREATE INDEX telegram_message_alerts_customer_id_idx ON public.telegram_message_alerts USING btree (customer_id);

-- Publicaciones de Twitter que coinciden con las consultas del cliente
CREATE TABLE public.twitter_post_alerts (
    id             serial4 NOT NULL,
    post_text      text NOT NULL,
    display_name   varchar(255) NOT NULL,
    account_handle varchar(255) NOT NULL,
    url            text NOT NULL,
    detected_at    timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    query_text     text NOT NULL,
    customer_id    int4 NULL,
    notes          text NULL,
    state_id       int4 DEFAULT 1 NOT NULL,
    severity_id    int4 DEFAULT 6 NOT NULL,
    CONSTRAINT twitter_post_alerts_url_key UNIQUE (url),
    CONSTRAINT twitter_post_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT twitter_post_alerts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
    CONSTRAINT twitter_post_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT twitter_post_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id)
);
CREATE INDEX twitter_post_alerts_state_id_idx ON public.twitter_post_alerts USING btree (state_id);
CREATE INDEX twitter_post_alerts_severity_id_idx ON public.twitter_post_alerts USING btree (severity_id);
CREATE INDEX twitter_post_alerts_detected_at_idx ON public.twitter_post_alerts USING btree (detected_at);
CREATE INDEX twitter_post_alerts_customer_id_idx ON public.twitter_post_alerts USING btree (customer_id);

-- ---------------------------------------------------------------------
-- Alertas: phishing, monitorizacion de dominios y defacement
-- ---------------------------------------------------------------------

-- Dominios parecidos a los del cliente (typosquatting / phishing)
CREATE TABLE public.typosquatting_alerts (
    id               serial4 NOT NULL,
    domain_id        int4 NOT NULL,
    lookalike_domain varchar(255) NOT NULL,
    resolved_ip      varchar(19) NOT NULL,
    detected_at      timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    customer_id      int4 NOT NULL,
    notes            text NULL,
    state_id         int4 DEFAULT 1 NOT NULL,
    severity_id      int4 DEFAULT 6 NOT NULL,
    CONSTRAINT typosquatting_alerts_domain_id_lookalike_domain_resolved_ip_key UNIQUE (domain_id, lookalike_domain, resolved_ip),
    CONSTRAINT typosquatting_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT typosquatting_alerts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
    CONSTRAINT typosquatting_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT typosquatting_alerts_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES public.monitored_domains(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT typosquatting_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id)
);
CREATE INDEX typosquatting_alerts_state_id_idx ON public.typosquatting_alerts USING btree (state_id);
CREATE INDEX typosquatting_alerts_severity_id_idx ON public.typosquatting_alerts USING btree (severity_id);
CREATE INDEX typosquatting_alerts_detected_at_idx ON public.typosquatting_alerts USING btree (detected_at);
CREATE INDEX typosquatting_alerts_customer_id_idx ON public.typosquatting_alerts USING btree (customer_id);
CREATE INDEX typosquatting_alerts_domain_id_idx ON public.typosquatting_alerts USING btree (domain_id);

-- Certificados detectados para los dominios del cliente
CREATE TABLE public.certificate_alerts (
    id                  serial4 NOT NULL,
    domain_id           int4 NOT NULL,
    certificate_summary text NOT NULL,
    detected_at         timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    customer_id         int4 NOT NULL,
    notes               text NULL,
    state_id            int4 DEFAULT 1 NOT NULL,
    severity_id         int4 DEFAULT 6 NOT NULL,
    CONSTRAINT certificate_alerts_domain_id_certificate_summary_key UNIQUE (domain_id, certificate_summary),
    CONSTRAINT certificate_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT certificate_alerts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
    CONSTRAINT certificate_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT certificate_alerts_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES public.monitored_domains(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT certificate_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id)
);
CREATE INDEX certificate_alerts_state_id_idx ON public.certificate_alerts USING btree (state_id);
CREATE INDEX certificate_alerts_severity_id_idx ON public.certificate_alerts USING btree (severity_id);
CREATE INDEX certificate_alerts_detected_at_idx ON public.certificate_alerts USING btree (detected_at);
CREATE INDEX certificate_alerts_customer_id_idx ON public.certificate_alerts USING btree (customer_id);
CREATE INDEX certificate_alerts_domain_id_idx ON public.certificate_alerts USING btree (domain_id);

-- Cambios de contenido detectados en los sitios web del cliente
CREATE TABLE public.defacement_alerts (
    id             serial4 NOT NULL,
    domain_id      int4 NOT NULL,
    content_md5    bytea NOT NULL,
    content_sha256 bytea NOT NULL,
    detected_at    timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    customer_id    int4 NOT NULL,
    notes          text NULL,
    state_id       int4 DEFAULT 1 NOT NULL,
    severity_id    int4 DEFAULT 6 NOT NULL,
    CONSTRAINT defacement_alerts_domain_id_content_md5_content_sha256_key UNIQUE (domain_id, content_md5, content_sha256),
    CONSTRAINT defacement_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT defacement_alerts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
    CONSTRAINT defacement_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT defacement_alerts_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES public.monitored_domains(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT defacement_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id)
);
CREATE INDEX defacement_alerts_state_id_idx ON public.defacement_alerts USING btree (state_id);
CREATE INDEX defacement_alerts_severity_id_idx ON public.defacement_alerts USING btree (severity_id);
CREATE INDEX defacement_alerts_detected_at_idx ON public.defacement_alerts USING btree (detected_at);
CREATE INDEX defacement_alerts_customer_id_idx ON public.defacement_alerts USING btree (customer_id);
CREATE INDEX defacement_alerts_domain_id_idx ON public.defacement_alerts USING btree (domain_id);

-- ---------------------------------------------------------------------
-- Alertas: monitorizacion de sistemas y vulnerabilidades (Shodan)
-- ---------------------------------------------------------------------

-- Alertas de Shodan en el formato antiguo (se conservan por compatibilidad)
CREATE SEQUENCE public.shodan_legacy_alerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.shodan_legacy_alerts (
    id               int4 DEFAULT nextval('public.shodan_legacy_alerts_id_seq'::regclass) NOT NULL,
    domain_id        int4 NOT NULL,
    ip_address       varchar(255) NOT NULL,
    asn_number       varchar(10) NOT NULL,
    vulnerability_id text NULL,
    country_name     varchar(255) NOT NULL,
    detected_at      timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    customer_id      int4 NOT NULL,
    notes            text NULL,
    state_id         int4 DEFAULT 1 NOT NULL,
    severity_id      int4 DEFAULT 6 NOT NULL,
    CONSTRAINT shodan_legacy_alerts_domain_ip_asn_vuln_key UNIQUE (domain_id, ip_address, asn_number, vulnerability_id),
    CONSTRAINT shodan_legacy_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT shodan_legacy_alerts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
    CONSTRAINT shodan_legacy_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT shodan_legacy_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id),
    CONSTRAINT shodan_legacy_alerts_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES public.monitored_domains(id) ON DELETE CASCADE ON UPDATE CASCADE
);
ALTER SEQUENCE public.shodan_legacy_alerts_id_seq OWNED BY public.shodan_legacy_alerts.id;
CREATE INDEX shodan_legacy_alerts_state_id_idx ON public.shodan_legacy_alerts USING btree (state_id);
CREATE INDEX shodan_legacy_alerts_severity_id_idx ON public.shodan_legacy_alerts USING btree (severity_id);
CREATE INDEX shodan_legacy_alerts_detected_at_idx ON public.shodan_legacy_alerts USING btree (detected_at);
CREATE INDEX shodan_legacy_alerts_customer_id_idx ON public.shodan_legacy_alerts USING btree (customer_id);
CREATE INDEX shodan_legacy_alerts_domain_id_idx ON public.shodan_legacy_alerts USING btree (domain_id);

-- Hosts expuestos encontrados en Shodan
CREATE SEQUENCE public.shodan_host_alerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE public.shodan_host_alerts (
    id                int4 DEFAULT nextval('public.shodan_host_alerts_id_seq'::regclass) NOT NULL,
    domain_names      text NULL,
    ip_address        text NOT NULL,
    query_text        text NULL,
    asn_number        varchar(10) NOT NULL,
    country_name      varchar(255) NOT NULL,
    hostname_list     text NULL,
    organization_name text NULL,
    customer_id       int4 NOT NULL,
    detected_at       timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    cpe_list          text NULL,
    notes             text NULL,
    state_id          int4 DEFAULT 1 NOT NULL,
    severity_id       int4 DEFAULT 6 NOT NULL,
    CONSTRAINT shodan_host_alerts_ip_address_asn_number_country_name_key UNIQUE (ip_address, asn_number, country_name),
    CONSTRAINT shodan_host_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT shodan_host_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT shodan_host_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id),
    CONSTRAINT shodan_host_alerts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id)
);
ALTER SEQUENCE public.shodan_host_alerts_id_seq OWNED BY public.shodan_host_alerts.id;
CREATE INDEX shodan_host_alerts_state_id_idx ON public.shodan_host_alerts USING btree (state_id);
CREATE INDEX shodan_host_alerts_severity_id_idx ON public.shodan_host_alerts USING btree (severity_id);
CREATE INDEX shodan_host_alerts_detected_at_idx ON public.shodan_host_alerts USING btree (detected_at);
CREATE INDEX shodan_host_alerts_customer_id_idx ON public.shodan_host_alerts USING btree (customer_id);

-- Puertos abiertos de cada host de Shodan
CREATE TABLE public.shodan_port_alerts (
    id            serial4 NOT NULL,
    host_alert_id int4 NOT NULL,
    port_number   int4 NOT NULL,
    detected_at   timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    notes         text NULL,
    state_id      int4 DEFAULT 1 NOT NULL,
    severity_id   int4 DEFAULT 6 NOT NULL,
    CONSTRAINT shodan_port_alerts_host_alert_id_port_number_key UNIQUE (host_alert_id, port_number),
    CONSTRAINT shodan_port_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT shodan_port_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT shodan_port_alerts_host_alert_id_fkey FOREIGN KEY (host_alert_id) REFERENCES public.shodan_host_alerts(id),
    CONSTRAINT shodan_port_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id)
);
CREATE INDEX shodan_port_alerts_state_id_idx ON public.shodan_port_alerts USING btree (state_id);
CREATE INDEX shodan_port_alerts_severity_id_idx ON public.shodan_port_alerts USING btree (severity_id);
CREATE INDEX shodan_port_alerts_detected_at_idx ON public.shodan_port_alerts USING btree (detected_at);
CREATE INDEX shodan_port_alerts_host_alert_id_idx ON public.shodan_port_alerts USING btree (host_alert_id);

-- Vulnerabilidades de cada host de Shodan
CREATE TABLE public.shodan_vulnerability_alerts (
    id               serial4 NOT NULL,
    host_alert_id    int4 NOT NULL,
    vulnerability_id text NOT NULL,
    detected_at      timestamp DEFAULT CURRENT_TIMESTAMP NULL,
    notes            text NULL,
    state_id         int4 DEFAULT 1 NOT NULL,
    severity_id      int4 DEFAULT 6 NOT NULL,
    CONSTRAINT shodan_vulnerability_alerts_host_alert_id_vulnerability_id_key UNIQUE (host_alert_id, vulnerability_id),
    CONSTRAINT shodan_vulnerability_alerts_pkey PRIMARY KEY (id),
    CONSTRAINT shodan_vulnerability_alerts_severity_id_fkey FOREIGN KEY (severity_id) REFERENCES public.alert_severities(id),
    CONSTRAINT shodan_vulnerability_alerts_host_alert_id_fkey FOREIGN KEY (host_alert_id) REFERENCES public.shodan_host_alerts(id),
    CONSTRAINT shodan_vulnerability_alerts_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.alert_states(id)
);
CREATE INDEX shodan_vulnerability_alerts_state_id_idx ON public.shodan_vulnerability_alerts USING btree (state_id);
CREATE INDEX shodan_vulnerability_alerts_severity_id_idx ON public.shodan_vulnerability_alerts USING btree (severity_id);
CREATE INDEX shodan_vulnerability_alerts_detected_at_idx ON public.shodan_vulnerability_alerts USING btree (detected_at);
CREATE INDEX shodan_vulnerability_alerts_host_alert_id_idx ON public.shodan_vulnerability_alerts USING btree (host_alert_id);

COMMIT;
