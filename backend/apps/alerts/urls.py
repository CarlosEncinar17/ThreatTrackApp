from django.urls import path
from rest_framework import routers

from .views import (
    AlertSeverityViewSet,
    AlertStateViewSet,
    BlocklistedDomainTopScoreViewSet,
    BlocklistedDomainViewSet,
    BlocklistedIpAddressTopScoreViewSet,
    BlocklistedIpAddressViewSet,
    CertificateAlertViewSet,
    DailyByModuleView,
    DailyOpenResolvedView,
    DefacementAlertViewSet,
    GithubCommitAlertViewSet,
    GitlabProjectAlertViewSet,
    GoogleSearchAlertViewSet,
    IntelxLeakAlertViewSet,
    LeakedSecretAlertViewSet,
    OpenResolvedByModuleView,
    OpenResolvedBySeverityView,
    OpenResolvedTotalsView,
    SeverityCountsView,
    ShodanHostAlertViewSet,
    ShodanLegacyAlertViewSet,
    ShodanPortAlertViewSet,
    ShodanVulnerabilityAlertViewSet,
    StatusCountsView,
    TelegramMessageAlertViewSet,
    TwitterPostAlertViewSet,
    TyposquattingAlertViewSet,
)

# Las rutas conservan los nombres del sistema original.
router = routers.DefaultRouter()
router.register("AlertStatus", AlertStateViewSet, basename="AlertStatus")
router.register("AlertCriticity", AlertSeverityViewSet, basename="AlertCriticity")
router.register("Certificates", CertificateAlertViewSet, basename="Certificates")
router.register("Defacement", DefacementAlertViewSet, basename="Defacement")
router.register("Github", GithubCommitAlertViewSet, basename="Github")
router.register("Gitlab", GitlabProjectAlertViewSet, basename="Gitlab")
router.register("Google", GoogleSearchAlertViewSet, basename="Google")
router.register("Intelx", IntelxLeakAlertViewSet, basename="Intelx")
router.register("Secrets", LeakedSecretAlertViewSet, basename="Secrets")
router.register("Telegram", TelegramMessageAlertViewSet, basename="Telegram")
router.register("Tweets", TwitterPostAlertViewSet, basename="Tweets")
router.register("Typosquatting", TyposquattingAlertViewSet, basename="Typosquatting")
router.register("OldShodan", ShodanLegacyAlertViewSet, basename="OldShodan")
router.register("Shodan", ShodanHostAlertViewSet, basename="Shodan")
router.register("ShodanPorts", ShodanPortAlertViewSet, basename="ShodanPorts")
router.register("ShodanVulns", ShodanVulnerabilityAlertViewSet, basename="ShodanVulns")
router.register("BlacklistDomain", BlocklistedDomainViewSet, basename="BlacklistDomain")
router.register("BlacklistDomainTopScore", BlocklistedDomainTopScoreViewSet, basename="BlacklistDomainTopScore")
router.register("BlacklistIp", BlocklistedIpAddressViewSet, basename="BlacklistIp")
router.register("BlacklistIpTopScore", BlocklistedIpAddressTopScoreViewSet, basename="BlacklistIpTopScore")

urlpatterns = [
    path("status-counts/", StatusCountsView.as_view(), name="status-counts"),
    path("total-count-open-resolved/", OpenResolvedTotalsView.as_view(), name="total-count-open-resolved"),
    path("criticity-counts/", SeverityCountsView.as_view(), name="criticity-counts"),
    path("cases-by-status-and-criticity/", OpenResolvedBySeverityView.as_view(), name="cases-by-status-and-criticity"),
    path("case-counts-by-module/", OpenResolvedByModuleView.as_view(), name="case-counts-by-module"),
    path("stacked-bar-chart/", DailyOpenResolvedView.as_view(), name="stacked-bar-chart"),
    path("daily-counts-services/", DailyByModuleView.as_view(), name="daily-counts-services"),
    *router.urls,
]
