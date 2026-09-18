"""
Alertas generadas por los modulos de cibervigilancia.

Cada fuente OSINT tiene su propia tabla (definida en
compose/db/01_schema.sql). Todas comparten estado, criticidad, observaciones y fecha de
deteccion; casi todas pertenecen a un cliente.
"""
from django.db import models

from apps.assets.models import MonitoredDomain, MonitoredKeyword
from apps.customers.models import Customer


class AlertState(models.Model):
    """Estado de tratamiento de una alerta: open, in_progress, resolved, false_positive, duplicated."""

    OPEN = "open"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    FALSE_POSITIVE = "false_positive"
    DUPLICATED = "duplicated"

    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255)

    class Meta:
        managed = False
        db_table = "alert_states"
        ordering = ["id"]
        verbose_name = "estado de alerta"
        verbose_name_plural = "estados de alerta"

    def __str__(self) -> str:
        return self.name


class AlertSeverity(models.Model):
    """Criticidad de una alerta: critical, high, medium, low, informative, unknown."""

    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"
    INFORMATIVE = "informative"
    UNKNOWN = "unknown"

    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255)

    class Meta:
        managed = False
        db_table = "alert_severities"
        ordering = ["id"]
        verbose_name = "criticidad de alerta"
        verbose_name_plural = "criticidades de alerta"

    def __str__(self) -> str:
        return self.name


class AlertBase(models.Model):
    """Campos comunes de toda alerta."""

    id = models.AutoField(primary_key=True)
    detected_at = models.DateTimeField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    state = models.ForeignKey(AlertState, on_delete=models.PROTECT, db_column="state_id", related_name="+")
    severity = models.ForeignKey(AlertSeverity, on_delete=models.PROTECT, db_column="severity_id", related_name="+")

    class Meta:
        abstract = True
        ordering = ["-detected_at", "-id"]


class CustomerAlertBase(AlertBase):
    """Alerta asociada directamente a un cliente."""

    customer = models.ForeignKey(Customer, on_delete=models.PROTECT, db_column="customer_id", related_name="+")

    class Meta(AlertBase.Meta):
        abstract = True


# ---------------------------------------------------------------------------
# Fugas de informacion
# ---------------------------------------------------------------------------
class GithubCommitAlert(CustomerAlertBase):
    monitored_domain = models.ForeignKey(
        MonitoredDomain, on_delete=models.CASCADE, db_column="domain_id", related_name="+"
    )
    repository = models.CharField(max_length=255)
    author_name = models.CharField(max_length=255)
    author_email = models.CharField(max_length=255)
    commit_hash = models.CharField(max_length=255)
    url = models.TextField()
    committed_at = models.DateTimeField()
    is_analyzed = models.BooleanField(default=False)

    class Meta(CustomerAlertBase.Meta):
        managed = False
        db_table = "github_commit_alerts"
        unique_together = (("monitored_domain", "repository", "commit_hash"),)
        verbose_name = "alerta de commit de GitHub"
        verbose_name_plural = "alertas de commits de GitHub"


class GitlabProjectAlert(CustomerAlertBase):
    monitored_keyword = models.ForeignKey(
        MonitoredKeyword, on_delete=models.PROTECT, db_column="monitored_keyword_id", related_name="+"
    )
    project_name = models.CharField(max_length=255)
    author_name = models.CharField(max_length=255)
    project_description = models.TextField(blank=True, null=True)
    url = models.TextField(blank=True, null=True)
    project_created_at = models.CharField(max_length=255, blank=True, null=True)

    class Meta(CustomerAlertBase.Meta):
        managed = False
        db_table = "gitlab_project_alerts"
        unique_together = (("monitored_keyword", "project_name", "author_name"),)
        verbose_name = "alerta de proyecto de GitLab"
        verbose_name_plural = "alertas de proyectos de GitLab"


class GoogleSearchAlert(CustomerAlertBase):
    query_text = models.TextField()
    url = models.TextField()
    page_title = models.TextField(blank=True, null=True)
    last_seen_at = models.DateTimeField(blank=True, null=True)

    class Meta(CustomerAlertBase.Meta):
        managed = False
        db_table = "google_search_alerts"
        unique_together = (("query_text", "url"),)
        verbose_name = "alerta de busqueda de Google"
        verbose_name_plural = "alertas de busquedas de Google"


# ---------------------------------------------------------------------------
# Exposicion de credenciales
# ---------------------------------------------------------------------------
class IntelxLeakAlert(CustomerAlertBase):
    monitored_domain = models.ForeignKey(
        MonitoredDomain, on_delete=models.CASCADE, db_column="domain_id", related_name="+"
    )
    leak_name = models.TextField()
    url = models.TextField(unique=True, blank=True, null=True)
    source_bucket = models.TextField(blank=True, null=True)

    class Meta(CustomerAlertBase.Meta):
        managed = False
        db_table = "intelx_leak_alerts"
        verbose_name = "alerta de Intelligence X"
        verbose_name_plural = "alertas de Intelligence X"


class LeakedSecretAlert(AlertBase):
    """Secreto detectado dentro de un commit de GitHub (hereda el cliente del commit)."""

    github_alert = models.ForeignKey(
        GithubCommitAlert, on_delete=models.CASCADE, db_column="github_alert_id", related_name="secrets"
    )
    line_start = models.IntegerField()
    line_end = models.IntegerField()
    column_start = models.IntegerField()
    column_end = models.IntegerField()
    matched_text = models.TextField()
    secret_value = models.TextField()
    file_path = models.CharField(max_length=255)
    entropy_score = models.FloatField()
    author_name = models.CharField(max_length=255)
    author_email = models.CharField(max_length=255)
    committed_at = models.DateField()
    commit_message = models.TextField()
    detection_rule = models.CharField(max_length=255)
    fingerprint_hash = models.CharField(max_length=255)
    tag_list = models.TextField(blank=True, null=True)
    commit_hash = models.CharField(max_length=255)
    detected_at = models.DateField()
    rule_description = models.TextField(blank=True, null=True)

    class Meta(AlertBase.Meta):
        managed = False
        db_table = "leaked_secret_alerts"
        unique_together = (("fingerprint_hash", "github_alert"),)
        verbose_name = "secreto filtrado"
        verbose_name_plural = "secretos filtrados"


class TelegramMessageAlert(CustomerAlertBase):
    monitored_keyword_id = models.IntegerField()
    channel_id = models.IntegerField()
    message_text = models.TextField()
    sender_identifier = models.CharField(max_length=255)
    message_sent_at = models.CharField(max_length=255)

    class Meta(CustomerAlertBase.Meta):
        managed = False
        db_table = "telegram_message_alerts"
        unique_together = (("monitored_keyword_id", "channel_id", "message_text"),)
        verbose_name = "alerta de mensaje de Telegram"
        verbose_name_plural = "alertas de mensajes de Telegram"


class TwitterPostAlert(CustomerAlertBase):
    customer = models.ForeignKey(
        Customer, on_delete=models.PROTECT, db_column="customer_id", related_name="+", blank=True, null=True
    )
    post_text = models.TextField()
    display_name = models.CharField(max_length=255)
    account_handle = models.CharField(max_length=255)
    url = models.TextField(unique=True)
    query_text = models.TextField()

    class Meta(CustomerAlertBase.Meta):
        managed = False
        db_table = "twitter_post_alerts"
        verbose_name = "alerta de publicacion de Twitter"
        verbose_name_plural = "alertas de publicaciones de Twitter"


# ---------------------------------------------------------------------------
# Phishing, monitorizacion de dominios y defacement
# ---------------------------------------------------------------------------
class TyposquattingAlert(CustomerAlertBase):
    monitored_domain = models.ForeignKey(
        MonitoredDomain, on_delete=models.CASCADE, db_column="domain_id", related_name="+"
    )
    lookalike_domain = models.CharField(max_length=255)
    resolved_ip = models.CharField(max_length=19)

    class Meta(CustomerAlertBase.Meta):
        managed = False
        db_table = "typosquatting_alerts"
        unique_together = (("monitored_domain", "lookalike_domain", "resolved_ip"),)
        verbose_name = "alerta de typosquatting"
        verbose_name_plural = "alertas de typosquatting"


class CertificateAlert(CustomerAlertBase):
    monitored_domain = models.ForeignKey(
        MonitoredDomain, on_delete=models.CASCADE, db_column="domain_id", related_name="+"
    )
    certificate_summary = models.TextField()

    class Meta(CustomerAlertBase.Meta):
        managed = False
        db_table = "certificate_alerts"
        unique_together = (("monitored_domain", "certificate_summary"),)
        verbose_name = "alerta de certificado"
        verbose_name_plural = "alertas de certificados"


class DefacementAlert(CustomerAlertBase):
    monitored_domain = models.ForeignKey(
        MonitoredDomain, on_delete=models.CASCADE, db_column="domain_id", related_name="+"
    )
    content_md5 = models.BinaryField()
    content_sha256 = models.BinaryField()

    class Meta(CustomerAlertBase.Meta):
        managed = False
        db_table = "defacement_alerts"
        unique_together = (("monitored_domain", "content_md5", "content_sha256"),)
        verbose_name = "alerta de defacement"
        verbose_name_plural = "alertas de defacement"


# ---------------------------------------------------------------------------
# Monitorizacion de sistemas y vulnerabilidades (Shodan)
# ---------------------------------------------------------------------------
class ShodanLegacyAlert(CustomerAlertBase):
    monitored_domain = models.ForeignKey(
        MonitoredDomain, on_delete=models.CASCADE, db_column="domain_id", related_name="+"
    )
    ip_address = models.CharField(max_length=255)
    asn_number = models.CharField(max_length=10)
    vulnerability_id = models.TextField(blank=True, null=True)
    country_name = models.CharField(max_length=255)

    class Meta(CustomerAlertBase.Meta):
        managed = False
        db_table = "shodan_legacy_alerts"
        unique_together = (("monitored_domain", "ip_address", "asn_number", "vulnerability_id"),)
        verbose_name = "alerta de Shodan (formato antiguo)"
        verbose_name_plural = "alertas de Shodan (formato antiguo)"


class ShodanHostAlert(CustomerAlertBase):
    domain_names = models.TextField(blank=True, null=True)
    ip_address = models.TextField()
    query_text = models.TextField(blank=True, null=True)
    asn_number = models.CharField(max_length=10)
    country_name = models.CharField(max_length=255)
    hostname_list = models.TextField(blank=True, null=True)
    organization_name = models.TextField(blank=True, null=True)
    cpe_list = models.TextField(blank=True, null=True)

    class Meta(CustomerAlertBase.Meta):
        managed = False
        db_table = "shodan_host_alerts"
        unique_together = (("ip_address", "asn_number", "country_name"),)
        verbose_name = "alerta de host de Shodan"
        verbose_name_plural = "alertas de hosts de Shodan"


class ShodanPortAlert(AlertBase):
    host_alert = models.ForeignKey(
        ShodanHostAlert, on_delete=models.PROTECT, db_column="host_alert_id", related_name="ports"
    )
    port_number = models.IntegerField()

    class Meta(AlertBase.Meta):
        managed = False
        db_table = "shodan_port_alerts"
        unique_together = (("host_alert", "port_number"),)
        verbose_name = "alerta de puerto de Shodan"
        verbose_name_plural = "alertas de puertos de Shodan"


class ShodanVulnerabilityAlert(AlertBase):
    host_alert = models.ForeignKey(
        ShodanHostAlert, on_delete=models.PROTECT, db_column="host_alert_id", related_name="vulnerabilities"
    )
    vulnerability_id = models.TextField()

    class Meta(AlertBase.Meta):
        managed = False
        db_table = "shodan_vulnerability_alerts"
        unique_together = (("host_alert", "vulnerability_id"),)
        verbose_name = "alerta de vulnerabilidad de Shodan"
        verbose_name_plural = "alertas de vulnerabilidades de Shodan"


# ---------------------------------------------------------------------------
# Listas de bloqueo (sin cliente ni estado)
# ---------------------------------------------------------------------------
class BlocklistEntryBase(models.Model):
    id = models.AutoField(primary_key=True)
    list_category = models.CharField(max_length=20)
    list_source = models.CharField(max_length=255)
    listed_at = models.CharField(max_length=255)
    report_count = models.IntegerField()
    reliability_score = models.IntegerField()
    threat_score = models.DecimalField(max_digits=2, decimal_places=1)
    detected_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        abstract = True
        ordering = ["-detected_at", "-id"]


class BlocklistedDomain(BlocklistEntryBase):
    domain_name = models.CharField(max_length=1024)

    class Meta(BlocklistEntryBase.Meta):
        managed = False
        db_table = "blocklisted_domains"
        verbose_name = "dominio en lista de bloqueo"
        verbose_name_plural = "dominios en listas de bloqueo"


class BlocklistedDomainTopScore(BlocklistEntryBase):
    domain_name = models.CharField(max_length=255)

    class Meta(BlocklistEntryBase.Meta):
        managed = False
        db_table = "blocklisted_domains_top_scores"
        verbose_name = "dominio en lista de bloqueo (mayor puntuacion)"
        verbose_name_plural = "dominios en listas de bloqueo (mayor puntuacion)"


class BlocklistedIpAddress(BlocklistEntryBase):
    ip_address = models.CharField(max_length=255)

    class Meta(BlocklistEntryBase.Meta):
        managed = False
        db_table = "blocklisted_ip_addresses"
        verbose_name = "IP en lista de bloqueo"
        verbose_name_plural = "IPs en listas de bloqueo"


class BlocklistedIpAddressTopScore(BlocklistEntryBase):
    ip_address = models.CharField(max_length=255)

    class Meta(BlocklistEntryBase.Meta):
        managed = False
        db_table = "blocklisted_ip_addresses_top_scores"
        verbose_name = "IP en lista de bloqueo (mayor puntuacion)"
        verbose_name_plural = "IPs en listas de bloqueo (mayor puntuacion)"
