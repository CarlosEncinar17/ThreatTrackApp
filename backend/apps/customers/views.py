import django_filters

from apps.common.filters import DateRangeFilterSet
from apps.common.viewsets import ScopedModelViewSet

from .models import Customer, CustomerServiceSubscription, ScanRun, ServiceCatalogEntry
from .serializers import (
    CustomerSerializer,
    CustomerServiceSubscriptionSerializer,
    ScanRunSerializer,
    ServiceCatalogEntrySerializer,
)


class CustomerFilter(DateRangeFilterSet):
    date_field = "registered_at"
    is_active = django_filters.BooleanFilter(field_name="is_active")

    class Meta:
        model = Customer
        fields = ["is_active"]


class CustomerViewSet(ScopedModelViewSet):
    """Clientes. Un usuario con rol cliente solo ve su propio registro."""

    queryset = Customer.objects.all()
    serializer_class = CustomerSerializer
    filterset_class = CustomerFilter
    search_fields = ["name", "notes"]
    ordering_fields = ["id", "name", "registered_at", "is_active"]
    ordering = ["id"]
    customer_lookup = "pk"


class CustomerServiceSubscriptionFilter(django_filters.FilterSet):
    customer = django_filters.NumberFilter(field_name="customer_id")

    class Meta:
        model = CustomerServiceSubscription
        fields = ["customer"]


class CustomerServiceSubscriptionViewSet(ScopedModelViewSet):
    """Servicios contratados por cada cliente (clave primaria = id del cliente)."""

    queryset = CustomerServiceSubscription.objects.select_related("customer")
    serializer_class = CustomerServiceSubscriptionSerializer
    filterset_class = CustomerServiceSubscriptionFilter
    search_fields = ["customer__name", "notes"]
    ordering_fields = [
        "customer_id",
        "customer__name",
        "defacement_enabled",
        "github_enabled",
        "gitlab_enabled",
        "google_enabled",
        "intelx_enabled",
        "shodan_enabled",
        "telegram_enabled",
        "twitter_enabled",
        "typosquatting_enabled",
        "certificates_enabled",
        "blocklist_enabled",
    ]
    ordering = ["customer_id"]
    customer_lookup = "customer_id"


class ServiceCatalogEntryViewSet(ScopedModelViewSet):
    queryset = ServiceCatalogEntry.objects.all()
    serializer_class = ServiceCatalogEntrySerializer
    search_fields = ["name"]
    ordering_fields = ["id", "name"]
    ordering = ["id"]
    customer_lookup = None


class ScanRunFilter(DateRangeFilterSet):
    date_field = "run_started_at"
    module_name = django_filters.CharFilter(field_name="module_name", lookup_expr="iexact")

    class Meta:
        model = ScanRun
        fields = ["module_name"]


class ScanRunViewSet(ScopedModelViewSet):
    queryset = ScanRun.objects.all()
    serializer_class = ScanRunSerializer
    filterset_class = ScanRunFilter
    search_fields = ["module_name", "notes"]
    ordering_fields = ["id", "module_name", "run_started_at", "run_finished_at"]
    ordering = ["-run_started_at", "-id"]
    customer_lookup = None
