from django.conf import settings
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.common.filters import AlertFilterSet, DateRangeFilterSet
from apps.common.permissions import customer_id_for, is_analyst
from apps.common.viewsets import ScopedModelViewSet

from . import statistics
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
from .serializers import (
    AlertSeveritySerializer,
    AlertStateSerializer,
    BlocklistedDomainSerializer,
    BlocklistedDomainTopScoreSerializer,
    BlocklistedIpAddressSerializer,
    BlocklistedIpAddressTopScoreSerializer,
    CertificateAlertSerializer,
    DefacementAlertSerializer,
    GithubCommitAlertSerializer,
    GitlabProjectAlertSerializer,
    GoogleSearchAlertSerializer,
    IntelxLeakAlertSerializer,
    LeakedSecretAlertSerializer,
    ShodanHostAlertSerializer,
    ShodanLegacyAlertSerializer,
    ShodanPortAlertSerializer,
    ShodanVulnerabilityAlertSerializer,
    TelegramMessageAlertSerializer,
    TwitterPostAlertSerializer,
    TyposquattingAlertSerializer,
)

# ---------------------------------------------------------------------------
# Catalogos
# ---------------------------------------------------------------------------


class AlertStateViewSet(ScopedModelViewSet):
    queryset = AlertState.objects.all()
    serializer_class = AlertStateSerializer
    search_fields = ["name"]
    ordering_fields = ["id", "name"]
    ordering = ["id"]
    customer_lookup = None


class AlertSeverityViewSet(ScopedModelViewSet):
    queryset = AlertSeverity.objects.all()
    serializer_class = AlertSeveritySerializer
    search_fields = ["name"]
    ordering_fields = ["id", "name"]
    ordering = ["id"]
    customer_lookup = None


# ---------------------------------------------------------------------------
# Alertas
# ---------------------------------------------------------------------------

ALERT_ORDERING = ["id", "detected_at", "customer__name", "state__name", "severity__name"]
ALERT_SEARCH = ["customer__name", "state__name", "severity__name", "notes"]


def alert_filterset(model_class, customer_field="customer_id"):
    class _Filter(AlertFilterSet):
        class Meta:
            model = model_class
            fields = ["customer", "state", "severity"]

    _Filter.customer_field = customer_field
    _Filter.__name__ = f"{model_class.__name__}Filter"
    return _Filter


class AlertViewSet(ScopedModelViewSet):
    """Base de las alertas: filtros por cliente, estado, criticidad y fecha de deteccion."""

    ordering = ["-detected_at", "-id"]
    select_related = ("customer", "state", "severity")

    def get_queryset(self):
        return super().get_queryset().select_related(*self.select_related)


class GithubCommitAlertViewSet(AlertViewSet):
    queryset = GithubCommitAlert.objects.all()
    serializer_class = GithubCommitAlertSerializer
    filterset_class = alert_filterset(GithubCommitAlert)
    select_related = ("customer", "state", "severity", "monitored_domain")
    search_fields = ALERT_SEARCH + [
        "monitored_domain__domain_name", "repository", "author_name", "author_email", "commit_hash", "url",
    ]
    ordering_fields = ALERT_ORDERING + [
        "monitored_domain__domain_name", "repository", "author_name", "author_email", "commit_hash",
        "committed_at", "is_analyzed",
    ]


class GitlabProjectAlertViewSet(AlertViewSet):
    queryset = GitlabProjectAlert.objects.all()
    serializer_class = GitlabProjectAlertSerializer
    filterset_class = alert_filterset(GitlabProjectAlert)
    select_related = ("customer", "state", "severity", "monitored_keyword")
    search_fields = ALERT_SEARCH + [
        "monitored_keyword__term", "project_name", "author_name", "project_description", "url", "project_created_at",
    ]
    ordering_fields = ALERT_ORDERING + [
        "monitored_keyword__term", "project_name", "author_name", "project_created_at",
    ]


class GoogleSearchAlertViewSet(AlertViewSet):
    queryset = GoogleSearchAlert.objects.all()
    serializer_class = GoogleSearchAlertSerializer
    filterset_class = alert_filterset(GoogleSearchAlert)
    search_fields = ALERT_SEARCH + ["query_text", "url", "page_title"]
    ordering_fields = ALERT_ORDERING + ["query_text", "url", "page_title", "last_seen_at"]


class IntelxLeakAlertViewSet(AlertViewSet):
    queryset = IntelxLeakAlert.objects.all()
    serializer_class = IntelxLeakAlertSerializer
    filterset_class = alert_filterset(IntelxLeakAlert)
    select_related = ("customer", "state", "severity", "monitored_domain")
    search_fields = ALERT_SEARCH + ["monitored_domain__domain_name", "leak_name", "url", "source_bucket"]
    ordering_fields = ALERT_ORDERING + ["monitored_domain__domain_name", "leak_name", "url", "source_bucket"]


class LeakedSecretAlertViewSet(AlertViewSet):
    queryset = LeakedSecretAlert.objects.all()
    serializer_class = LeakedSecretAlertSerializer
    filterset_class = alert_filterset(LeakedSecretAlert, customer_field="github_alert__customer_id")
    select_related = ("state", "severity", "github_alert", "github_alert__customer")
    customer_lookup = "github_alert__customer"
    search_fields = [
        "github_alert__customer__name", "state__name", "severity__name", "notes", "file_path", "detection_rule",
        "author_name", "author_email", "commit_hash", "commit_message",
    ]
    ordering_fields = [
        "id", "detected_at", "github_alert__customer__name", "state__name", "severity__name", "file_path",
        "detection_rule", "author_name", "committed_at", "entropy_score",
    ]


class TelegramMessageAlertViewSet(AlertViewSet):
    queryset = TelegramMessageAlert.objects.all()
    serializer_class = TelegramMessageAlertSerializer
    filterset_class = alert_filterset(TelegramMessageAlert)
    search_fields = ALERT_SEARCH + ["message_text", "sender_identifier", "message_sent_at"]
    ordering_fields = ALERT_ORDERING + ["monitored_keyword_id", "channel_id", "sender_identifier", "message_sent_at"]


class TwitterPostAlertViewSet(AlertViewSet):
    queryset = TwitterPostAlert.objects.all()
    serializer_class = TwitterPostAlertSerializer
    filterset_class = alert_filterset(TwitterPostAlert)
    search_fields = ALERT_SEARCH + ["post_text", "display_name", "account_handle", "url", "query_text"]
    ordering_fields = ALERT_ORDERING + ["display_name", "account_handle", "query_text"]


class TyposquattingAlertViewSet(AlertViewSet):
    queryset = TyposquattingAlert.objects.all()
    serializer_class = TyposquattingAlertSerializer
    filterset_class = alert_filterset(TyposquattingAlert)
    select_related = ("customer", "state", "severity", "monitored_domain")
    search_fields = ALERT_SEARCH + ["monitored_domain__domain_name", "lookalike_domain", "resolved_ip"]
    ordering_fields = ALERT_ORDERING + ["monitored_domain__domain_name", "lookalike_domain", "resolved_ip"]


class CertificateAlertViewSet(AlertViewSet):
    queryset = CertificateAlert.objects.all()
    serializer_class = CertificateAlertSerializer
    filterset_class = alert_filterset(CertificateAlert)
    select_related = ("customer", "state", "severity", "monitored_domain")
    search_fields = ALERT_SEARCH + ["monitored_domain__domain_name", "certificate_summary"]
    ordering_fields = ALERT_ORDERING + ["monitored_domain__domain_name", "certificate_summary"]


class DefacementAlertViewSet(AlertViewSet):
    queryset = DefacementAlert.objects.all()
    serializer_class = DefacementAlertSerializer
    filterset_class = alert_filterset(DefacementAlert)
    select_related = ("customer", "state", "severity", "monitored_domain")
    search_fields = ALERT_SEARCH + ["monitored_domain__domain_name"]
    ordering_fields = ALERT_ORDERING + ["monitored_domain__domain_name"]


class ShodanLegacyAlertViewSet(AlertViewSet):
    queryset = ShodanLegacyAlert.objects.all()
    serializer_class = ShodanLegacyAlertSerializer
    filterset_class = alert_filterset(ShodanLegacyAlert)
    select_related = ("customer", "state", "severity", "monitored_domain")
    search_fields = ALERT_SEARCH + [
        "monitored_domain__domain_name", "ip_address", "asn_number", "vulnerability_id", "country_name",
    ]
    ordering_fields = ALERT_ORDERING + [
        "monitored_domain__domain_name", "ip_address", "asn_number", "vulnerability_id", "country_name",
    ]


class ShodanHostAlertViewSet(AlertViewSet):
    queryset = ShodanHostAlert.objects.all()
    serializer_class = ShodanHostAlertSerializer
    filterset_class = alert_filterset(ShodanHostAlert)
    search_fields = ALERT_SEARCH + [
        "domain_names", "ip_address", "query_text", "asn_number", "country_name", "hostname_list",
        "organization_name", "cpe_list",
    ]
    ordering_fields = ALERT_ORDERING + [
        "domain_names", "ip_address", "query_text", "asn_number", "country_name", "hostname_list",
        "organization_name", "cpe_list",
    ]


class ShodanPortAlertViewSet(AlertViewSet):
    queryset = ShodanPortAlert.objects.all()
    serializer_class = ShodanPortAlertSerializer
    filterset_class = alert_filterset(ShodanPortAlert, customer_field="host_alert__customer_id")
    select_related = ("state", "severity", "host_alert", "host_alert__customer")
    customer_lookup = "host_alert__customer"
    search_fields = ["host_alert__customer__name", "host_alert__ip_address", "state__name", "severity__name", "notes"]
    ordering_fields = ["id", "detected_at", "host_alert__ip_address", "port_number", "state__name", "severity__name"]


class ShodanVulnerabilityAlertViewSet(AlertViewSet):
    queryset = ShodanVulnerabilityAlert.objects.all()
    serializer_class = ShodanVulnerabilityAlertSerializer
    filterset_class = alert_filterset(ShodanVulnerabilityAlert, customer_field="host_alert__customer_id")
    select_related = ("state", "severity", "host_alert", "host_alert__customer")
    customer_lookup = "host_alert__customer"
    search_fields = [
        "host_alert__customer__name", "host_alert__ip_address", "vulnerability_id", "state__name", "severity__name",
        "notes",
    ]
    ordering_fields = [
        "id", "detected_at", "host_alert__ip_address", "vulnerability_id", "state__name", "severity__name",
    ]


# ---------------------------------------------------------------------------
# Listas de bloqueo
# ---------------------------------------------------------------------------


def blocklist_filterset(model_class):
    class _Filter(DateRangeFilterSet):
        class Meta:
            model = model_class
            fields = ["list_category", "list_source"]

    _Filter.__name__ = f"{model_class.__name__}Filter"
    return _Filter


class BlocklistViewSet(ScopedModelViewSet):
    ordering = ["-detected_at", "-id"]
    customer_lookup = None
    search_fields = ["list_category", "list_source", "listed_at"]
    ordering_fields = ["id", "detected_at", "list_category", "list_source", "report_count", "reliability_score", "threat_score"]


class BlocklistedDomainViewSet(BlocklistViewSet):
    queryset = BlocklistedDomain.objects.all()
    serializer_class = BlocklistedDomainSerializer
    filterset_class = blocklist_filterset(BlocklistedDomain)
    search_fields = BlocklistViewSet.search_fields + ["domain_name"]
    ordering_fields = BlocklistViewSet.ordering_fields + ["domain_name"]


class BlocklistedDomainTopScoreViewSet(BlocklistViewSet):
    queryset = BlocklistedDomainTopScore.objects.all()
    serializer_class = BlocklistedDomainTopScoreSerializer
    filterset_class = blocklist_filterset(BlocklistedDomainTopScore)
    search_fields = BlocklistViewSet.search_fields + ["domain_name"]
    ordering_fields = BlocklistViewSet.ordering_fields + ["domain_name"]


class BlocklistedIpAddressViewSet(BlocklistViewSet):
    queryset = BlocklistedIpAddress.objects.all()
    serializer_class = BlocklistedIpAddressSerializer
    filterset_class = blocklist_filterset(BlocklistedIpAddress)
    search_fields = BlocklistViewSet.search_fields + ["ip_address"]
    ordering_fields = BlocklistViewSet.ordering_fields + ["ip_address"]


class BlocklistedIpAddressTopScoreViewSet(BlocklistViewSet):
    queryset = BlocklistedIpAddressTopScore.objects.all()
    serializer_class = BlocklistedIpAddressTopScoreSerializer
    filterset_class = blocklist_filterset(BlocklistedIpAddressTopScore)
    search_fields = BlocklistViewSet.search_fields + ["ip_address"]
    ordering_fields = BlocklistViewSet.ordering_fields + ["ip_address"]


# ---------------------------------------------------------------------------
# Estadisticas de los dashboards
# ---------------------------------------------------------------------------


class StatisticsView(APIView):
    """
    Base de los endpoints de estadisticas. Un usuario con rol cliente solo ve sus datos;
    un analista puede restringir con ?customer=<id>.
    """

    compute = None

    def get(self, request):
        customer_id = self._customer_scope(request)
        return Response(type(self).compute(customer_id=customer_id))

    def _customer_scope(self, request):
        raw = request.query_params.get("customer")
        requested = int(raw) if raw and raw.isdigit() else None
        if not settings.API_REQUIRE_AUTH or is_analyst(request.user):
            return requested
        own = customer_id_for(request.user)
        return own if own is not None else -1  # sin cliente asignado -> sin datos


class StatusCountsView(StatisticsView):
    compute = staticmethod(statistics.status_counts)


class OpenResolvedTotalsView(StatisticsView):
    compute = staticmethod(statistics.open_resolved_totals)


class SeverityCountsView(StatisticsView):
    compute = staticmethod(statistics.severity_counts)


class OpenResolvedBySeverityView(StatisticsView):
    compute = staticmethod(statistics.open_resolved_by_severity)


class OpenResolvedByModuleView(StatisticsView):
    compute = staticmethod(statistics.open_resolved_by_module)


class DailyOpenResolvedView(StatisticsView):
    compute = staticmethod(statistics.daily_open_resolved)


class DailyByModuleView(StatisticsView):
    compute = staticmethod(statistics.daily_by_module)
