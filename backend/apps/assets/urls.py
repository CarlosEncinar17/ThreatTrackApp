from django.urls import path
from rest_framework import routers

from .views import (
    GoogleDorkQueryViewSet,
    MonitoredDomainCountView,
    MonitoredDomainViewSet,
    MonitoredIpAddressCountView,
    MonitoredIpAddressViewSet,
    MonitoredKeywordCountView,
    MonitoredKeywordViewSet,
    ShodanDorkQueryViewSet,
    TelegramChannelViewSet,
    TwitterDorkQueryViewSet,
)

# Las rutas conservan los nombres del sistema original.
router = routers.DefaultRouter()
router.register("Domains", MonitoredDomainViewSet, basename="Domains")
router.register("Ips", MonitoredIpAddressViewSet, basename="Ips")
router.register("Keywords", MonitoredKeywordViewSet, basename="Keywords")
router.register("TelGroups", TelegramChannelViewSet, basename="TelGroups")
router.register("GoogleDorks", GoogleDorkQueryViewSet, basename="GoogleDorks")
router.register("ShodanDorks", ShodanDorkQueryViewSet, basename="ShodanDorks")
router.register("TwitterDorks", TwitterDorkQueryViewSet, basename="TwitterDorks")

urlpatterns = [
    path("ips-count/", MonitoredIpAddressCountView.as_view(), name="ips-count"),
    path("domains-count/", MonitoredDomainCountView.as_view(), name="domains-count"),
    path("keywords-count/", MonitoredKeywordCountView.as_view(), name="keywords-count"),
    *router.urls,
]
