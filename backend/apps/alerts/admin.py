from django.contrib import admin

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


@admin.register(AlertState, AlertSeverity)
class LookupAdmin(admin.ModelAdmin):
    list_display = ("id", "name")


class CustomerAlertAdmin(admin.ModelAdmin):
    list_display = ("id", "customer", "detected_at", "state", "severity")
    list_filter = ("state", "severity", "customer")
    list_select_related = ("customer", "state", "severity")
    date_hierarchy = "detected_at"


@admin.register(GithubCommitAlert)
class GithubCommitAlertAdmin(CustomerAlertAdmin):
    list_display = CustomerAlertAdmin.list_display + ("repository", "author_name", "is_analyzed")
    search_fields = ("repository", "author_name", "author_email", "commit_hash")


@admin.register(GitlabProjectAlert)
class GitlabProjectAlertAdmin(CustomerAlertAdmin):
    list_display = CustomerAlertAdmin.list_display + ("project_name", "author_name")
    search_fields = ("project_name", "author_name")


@admin.register(GoogleSearchAlert)
class GoogleSearchAlertAdmin(CustomerAlertAdmin):
    list_display = CustomerAlertAdmin.list_display + ("page_title", "url")
    search_fields = ("query_text", "url", "page_title")


@admin.register(IntelxLeakAlert)
class IntelxLeakAlertAdmin(CustomerAlertAdmin):
    list_display = CustomerAlertAdmin.list_display + ("leak_name", "source_bucket")
    search_fields = ("leak_name", "url")


@admin.register(TelegramMessageAlert)
class TelegramMessageAlertAdmin(CustomerAlertAdmin):
    list_display = CustomerAlertAdmin.list_display + ("sender_identifier", "message_sent_at")
    search_fields = ("message_text", "sender_identifier")


@admin.register(TwitterPostAlert)
class TwitterPostAlertAdmin(CustomerAlertAdmin):
    list_display = CustomerAlertAdmin.list_display + ("account_handle", "url")
    search_fields = ("post_text", "account_handle", "display_name")


@admin.register(TyposquattingAlert)
class TyposquattingAlertAdmin(CustomerAlertAdmin):
    list_display = CustomerAlertAdmin.list_display + ("lookalike_domain", "resolved_ip")
    search_fields = ("lookalike_domain", "resolved_ip")


@admin.register(CertificateAlert, DefacementAlert)
class DomainAlertAdmin(CustomerAlertAdmin):
    list_display = CustomerAlertAdmin.list_display + ("monitored_domain",)


@admin.register(ShodanLegacyAlert, ShodanHostAlert)
class ShodanAlertAdmin(CustomerAlertAdmin):
    list_display = CustomerAlertAdmin.list_display + ("ip_address", "asn_number", "country_name")
    search_fields = ("ip_address", "asn_number", "country_name")


@admin.register(LeakedSecretAlert)
class LeakedSecretAlertAdmin(admin.ModelAdmin):
    list_display = ("id", "github_alert", "file_path", "detection_rule", "detected_at", "state", "severity")
    list_filter = ("state", "severity", "detection_rule")
    list_select_related = ("github_alert", "state", "severity")
    search_fields = ("file_path", "detection_rule", "author_name")
    # El valor del secreto nunca se muestra en listados; solo en el detalle.
    exclude = ()


@admin.register(ShodanPortAlert, ShodanVulnerabilityAlert)
class ShodanChildAlertAdmin(admin.ModelAdmin):
    list_display = ("id", "host_alert", "detected_at", "state", "severity")
    list_filter = ("state", "severity")
    list_select_related = ("host_alert", "state", "severity")


@admin.register(BlocklistedDomain, BlocklistedDomainTopScore, BlocklistedIpAddress, BlocklistedIpAddressTopScore)
class BlocklistAdmin(admin.ModelAdmin):
    list_display = ("id", "list_category", "list_source", "threat_score", "detected_at")
    list_filter = ("list_category", "list_source")
