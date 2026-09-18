from rest_framework import serializers

from .models import (
    AlertSeverity,
    AlertState,
    BlocklistedDomain,
    BlocklistedDomainTopScore,
    BlocklistedIpAddress,
    BlocklistedIpAddressTopScore,
    CertificateAlert,
    DefacementAlert,
    GithubCommitAlert,
    GitlabProjectAlert,
    GoogleSearchAlert,
    IntelxLeakAlert,
    LeakedSecretAlert,
    ShodanHostAlert,
    ShodanLegacyAlert,
    ShodanPortAlert,
    ShodanVulnerabilityAlert,
    TelegramMessageAlert,
    TwitterPostAlert,
    TyposquattingAlert,
)


class AlertStateSerializer(serializers.ModelSerializer):
    class Meta:
        model = AlertState
        fields = ["id", "name"]


class AlertSeveritySerializer(serializers.ModelSerializer):
    class Meta:
        model = AlertSeverity
        fields = ["id", "name"]


class AlertSerializerMixin(serializers.Serializer):
    """
    Campos comunes de las alertas. `state` y `severity` son opcionales al crear: si no se
    indican se aplican los valores por defecto del esquema (open / unknown).
    """

    state = serializers.PrimaryKeyRelatedField(queryset=AlertState.objects.all(), required=False)
    severity = serializers.PrimaryKeyRelatedField(queryset=AlertSeverity.objects.all(), required=False)
    state_name = serializers.CharField(source="state.name", read_only=True)
    severity_name = serializers.CharField(source="severity.name", read_only=True)

    def create(self, validated_data):
        validated_data.setdefault("state", AlertState.objects.get(name=AlertState.OPEN))
        validated_data.setdefault("severity", AlertSeverity.objects.get(name=AlertSeverity.UNKNOWN))
        return super().create(validated_data)


class CustomerAlertSerializerMixin(AlertSerializerMixin):
    customer_name = serializers.CharField(source="customer.name", read_only=True)


class MonitoredDomainNameMixin(serializers.Serializer):
    domain_name = serializers.CharField(source="monitored_domain.domain_name", read_only=True)


ALERT_FIELDS = ["id", "detected_at", "state", "state_name", "severity", "severity_name", "notes"]
CUSTOMER_ALERT_FIELDS = ALERT_FIELDS + ["customer", "customer_name"]
DOMAIN_ALERT_FIELDS = CUSTOMER_ALERT_FIELDS + ["monitored_domain", "domain_name"]


class GithubCommitAlertSerializer(CustomerAlertSerializerMixin, MonitoredDomainNameMixin, serializers.ModelSerializer):
    class Meta:
        model = GithubCommitAlert
        fields = DOMAIN_ALERT_FIELDS + [
            "repository", "author_name", "author_email", "commit_hash", "url", "committed_at", "is_analyzed",
        ]


class GitlabProjectAlertSerializer(CustomerAlertSerializerMixin, serializers.ModelSerializer):
    keyword_term = serializers.CharField(source="monitored_keyword.term", read_only=True)

    class Meta:
        model = GitlabProjectAlert
        fields = CUSTOMER_ALERT_FIELDS + [
            "monitored_keyword", "keyword_term", "project_name", "author_name", "project_description", "url",
            "project_created_at",
        ]


class GoogleSearchAlertSerializer(CustomerAlertSerializerMixin, serializers.ModelSerializer):
    class Meta:
        model = GoogleSearchAlert
        fields = CUSTOMER_ALERT_FIELDS + ["query_text", "url", "page_title", "last_seen_at"]


class IntelxLeakAlertSerializer(CustomerAlertSerializerMixin, MonitoredDomainNameMixin, serializers.ModelSerializer):
    class Meta:
        model = IntelxLeakAlert
        fields = DOMAIN_ALERT_FIELDS + ["leak_name", "url", "source_bucket"]


class LeakedSecretAlertSerializer(AlertSerializerMixin, serializers.ModelSerializer):
    customer = serializers.IntegerField(source="github_alert.customer_id", read_only=True)
    customer_name = serializers.CharField(source="github_alert.customer.name", read_only=True)

    class Meta:
        model = LeakedSecretAlert
        fields = ALERT_FIELDS + [
            "customer", "customer_name", "github_alert", "line_start", "line_end", "column_start", "column_end",
            "matched_text", "secret_value", "file_path", "entropy_score", "author_name", "author_email",
            "committed_at", "commit_message", "detection_rule", "fingerprint_hash", "tag_list", "commit_hash",
            "rule_description",
        ]


class TelegramMessageAlertSerializer(CustomerAlertSerializerMixin, serializers.ModelSerializer):
    class Meta:
        model = TelegramMessageAlert
        fields = CUSTOMER_ALERT_FIELDS + [
            "monitored_keyword_id", "channel_id", "message_text", "sender_identifier", "message_sent_at",
        ]


class TwitterPostAlertSerializer(CustomerAlertSerializerMixin, serializers.ModelSerializer):
    class Meta:
        model = TwitterPostAlert
        fields = CUSTOMER_ALERT_FIELDS + ["post_text", "display_name", "account_handle", "url", "query_text"]


class TyposquattingAlertSerializer(CustomerAlertSerializerMixin, MonitoredDomainNameMixin, serializers.ModelSerializer):
    class Meta:
        model = TyposquattingAlert
        fields = DOMAIN_ALERT_FIELDS + ["lookalike_domain", "resolved_ip"]


class CertificateAlertSerializer(CustomerAlertSerializerMixin, MonitoredDomainNameMixin, serializers.ModelSerializer):
    class Meta:
        model = CertificateAlert
        fields = DOMAIN_ALERT_FIELDS + ["certificate_summary"]


class DefacementAlertSerializer(CustomerAlertSerializerMixin, MonitoredDomainNameMixin, serializers.ModelSerializer):
    # Los hashes se almacenan como bytea y viajan en base64 (igual que en el sistema original).
    class Meta:
        model = DefacementAlert
        fields = DOMAIN_ALERT_FIELDS + ["content_md5", "content_sha256"]


class ShodanLegacyAlertSerializer(CustomerAlertSerializerMixin, MonitoredDomainNameMixin, serializers.ModelSerializer):
    class Meta:
        model = ShodanLegacyAlert
        fields = DOMAIN_ALERT_FIELDS + ["ip_address", "asn_number", "vulnerability_id", "country_name"]


class ShodanHostAlertSerializer(CustomerAlertSerializerMixin, serializers.ModelSerializer):
    class Meta:
        model = ShodanHostAlert
        fields = CUSTOMER_ALERT_FIELDS + [
            "domain_names", "ip_address", "query_text", "asn_number", "country_name", "hostname_list",
            "organization_name", "cpe_list",
        ]


class ShodanChildAlertSerializerMixin(AlertSerializerMixin):
    customer = serializers.IntegerField(source="host_alert.customer_id", read_only=True)
    customer_name = serializers.CharField(source="host_alert.customer.name", read_only=True)
    host_ip_address = serializers.CharField(source="host_alert.ip_address", read_only=True)


class ShodanPortAlertSerializer(ShodanChildAlertSerializerMixin, serializers.ModelSerializer):
    class Meta:
        model = ShodanPortAlert
        fields = ALERT_FIELDS + ["customer", "customer_name", "host_alert", "host_ip_address", "port_number"]


class ShodanVulnerabilityAlertSerializer(ShodanChildAlertSerializerMixin, serializers.ModelSerializer):
    class Meta:
        model = ShodanVulnerabilityAlert
        fields = ALERT_FIELDS + ["customer", "customer_name", "host_alert", "host_ip_address", "vulnerability_id"]


BLOCKLIST_FIELDS = [
    "id", "list_category", "list_source", "listed_at", "report_count", "reliability_score", "threat_score",
    "detected_at",
]


class BlocklistedDomainSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlocklistedDomain
        fields = BLOCKLIST_FIELDS + ["domain_name"]


class BlocklistedDomainTopScoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlocklistedDomainTopScore
        fields = BLOCKLIST_FIELDS + ["domain_name"]


class BlocklistedIpAddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlocklistedIpAddress
        fields = BLOCKLIST_FIELDS + ["ip_address"]


class BlocklistedIpAddressTopScoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlocklistedIpAddressTopScore
        fields = BLOCKLIST_FIELDS + ["ip_address"]
