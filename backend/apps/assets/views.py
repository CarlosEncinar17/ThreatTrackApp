from django.db.models import Count, Q
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.common.filters import AssetFilterSet, DateRangeFilterSet
from apps.common.permissions import CustomerScopedQuerysetMixin
from apps.common.viewsets import ScopedModelViewSet

from .models import (
    GoogleDorkQuery,
    MonitoredDomain,
    MonitoredIpAddress,
    MonitoredKeyword,
    ShodanDorkQuery,
    TelegramChannel,
    TwitterDorkQuery,
)
from .serializers import (
    GoogleDorkQuerySerializer,
    MonitoredDomainSerializer,
    MonitoredIpAddressSerializer,
    MonitoredKeywordSerializer,
    ShodanDorkQuerySerializer,
    TelegramChannelSerializer,
    TwitterDorkQuerySerializer,
)

ASSET_ORDERING = ["id", "customer__name", "is_active", "added_at"]


def asset_filterset(model_class):
    class _Filter(AssetFilterSet):
        class Meta:
            model = model_class
            fields = ["customer", "is_active"]

    _Filter.__name__ = f"{model_class.__name__}Filter"
    return _Filter


class AssetViewSet(ScopedModelViewSet):
    """Base de los activos por cliente: filtros por cliente, estado y fecha de alta."""

    ordering = ["-added_at", "-id"]

    def get_queryset(self):
        return super().get_queryset().select_related("customer")


class MonitoredDomainViewSet(AssetViewSet):
    queryset = MonitoredDomain.objects.all()
    serializer_class = MonitoredDomainSerializer
    filterset_class = asset_filterset(MonitoredDomain)
    search_fields = ["customer__name", "domain_name", "notes"]
    ordering_fields = ASSET_ORDERING + ["domain_name"]


class MonitoredIpAddressViewSet(AssetViewSet):
    queryset = MonitoredIpAddress.objects.all()
    serializer_class = MonitoredIpAddressSerializer
    filterset_class = asset_filterset(MonitoredIpAddress)
    search_fields = ["customer__name", "ip_address", "notes"]
    ordering_fields = ASSET_ORDERING + ["ip_address"]


class MonitoredKeywordViewSet(AssetViewSet):
    queryset = MonitoredKeyword.objects.all()
    serializer_class = MonitoredKeywordSerializer
    filterset_class = asset_filterset(MonitoredKeyword)
    search_fields = ["customer__name", "term", "notes"]
    ordering_fields = ASSET_ORDERING + ["term"]


class TelegramChannelFilter(DateRangeFilterSet):
    date_field = "added_at"

    class Meta:
        model = TelegramChannel
        fields = ["is_active"]


class TelegramChannelViewSet(ScopedModelViewSet):
    queryset = TelegramChannel.objects.all()
    serializer_class = TelegramChannelSerializer
    filterset_class = TelegramChannelFilter
    search_fields = ["channel_name", "notes"]
    ordering_fields = ["id", "channel_name", "is_active", "added_at"]
    ordering = ["-added_at", "-id"]
    customer_lookup = None


class GoogleDorkQueryViewSet(AssetViewSet):
    queryset = GoogleDorkQuery.objects.all()
    serializer_class = GoogleDorkQuerySerializer
    filterset_class = asset_filterset(GoogleDorkQuery)
    search_fields = ["customer__name", "query_text", "notes"]
    ordering_fields = ASSET_ORDERING + ["query_text"]


class ShodanDorkQueryViewSet(AssetViewSet):
    queryset = ShodanDorkQuery.objects.all()
    serializer_class = ShodanDorkQuerySerializer
    filterset_class = asset_filterset(ShodanDorkQuery)
    search_fields = ["customer__name", "query_text", "notes"]
    ordering_fields = ASSET_ORDERING + ["query_text"]


class TwitterDorkQueryViewSet(AssetViewSet):
    queryset = TwitterDorkQuery.objects.all()
    serializer_class = TwitterDorkQuerySerializer
    filterset_class = asset_filterset(TwitterDorkQuery)
    search_fields = ["customer__name", "query_text", "notes"]
    ordering_fields = ASSET_ORDERING + ["query_text"]


class _ModelQuerysetView(APIView):
    model = None

    def get_queryset(self):
        return self.model.objects.all()


class ActiveInactiveCountView(CustomerScopedQuerysetMixin, _ModelQuerysetView):
    """Recuento de activos activos e inactivos: {"active": n, "inactive": n}."""

    customer_lookup = "customer"

    def get(self, request):
        counts = self.get_queryset().aggregate(
            active=Count("id", filter=Q(is_active=True)),
            inactive=Count("id", filter=Q(is_active=False)),
        )
        return Response(counts)


class MonitoredIpAddressCountView(ActiveInactiveCountView):
    model = MonitoredIpAddress


class MonitoredDomainCountView(ActiveInactiveCountView):
    model = MonitoredDomain


class MonitoredKeywordCountView(ActiveInactiveCountView):
    model = MonitoredKeyword
