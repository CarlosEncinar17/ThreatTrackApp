"""Filtros reutilizables para los listados de la API."""
import django_filters


class DateRangeFilterSet(django_filters.FilterSet):
    """
    Rango de fechas inclusivo sobre el campo indicado en `date_field`:
      ?date_from=YYYY-MM-DD  -> fecha >= date_from
      ?date_to=YYYY-MM-DD    -> fecha <= date_to (dia completo)
    Cada parametro funciona por separado; un valor mal formado devuelve 400.
    """

    date_field = "detected_at"

    date_from = django_filters.DateFilter(method="filter_date_from")
    date_to = django_filters.DateFilter(method="filter_date_to")

    def filter_date_from(self, queryset, name, value):
        return queryset.filter(**{f"{self.date_field}__date__gte": value})

    def filter_date_to(self, queryset, name, value):
        return queryset.filter(**{f"{self.date_field}__date__lte": value})


class CustomerFilterSet(DateRangeFilterSet):
    """Anade ?customer=<id> (ruta ORM configurable con `customer_field`)."""

    customer_field = "customer_id"
    customer = django_filters.NumberFilter(method="filter_customer")

    def filter_customer(self, queryset, name, value):
        return queryset.filter(**{self.customer_field: value})


class AlertFilterSet(CustomerFilterSet):
    """Filtros comunes de las alertas: cliente, estado, criticidad y rango de deteccion."""

    state = django_filters.NumberFilter(field_name="state_id")
    severity = django_filters.NumberFilter(field_name="severity_id")


class AssetFilterSet(CustomerFilterSet):
    """Filtros de activos y consultas: cliente, activo y rango de alta."""

    date_field = "added_at"
    is_active = django_filters.BooleanFilter(field_name="is_active")
