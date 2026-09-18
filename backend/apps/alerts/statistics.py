"""
Calculo de las estadisticas de los dashboards.

Cada fuente de alertas se consulta una sola vez con una agregacion en base de datos
(estado x criticidad, o estado x dia); el resto se compone en memoria. El sistema
original lanzaba una consulta `count()` por cada combinacion (hasta 130 por endpoint).
"""
from collections import defaultdict
from datetime import timedelta

from django.conf import settings
from django.db.models import Count
from django.db.models.functions import TruncDay
from django.utils.timezone import now

from .models import AlertSeverity, AlertState
from .registry import (
    ALERT_SOURCES,
    DASHBOARD_SEVERITIES,
    DASHBOARD_SOURCES,
    SERVICE_MODULES,
    STATUS_COUNT_SOURCES,
)


def _ids_by_name(model):
    return {row.name: row.id for row in model.objects.all()}


def _since(days: int):
    return now() - timedelta(days=days)


def _state_severity_matrix(sources, since, customer_id=None):
    """
    {fuente: {(state_id, severity_id): n}} para las alertas detectadas desde `since`.
    Una consulta agrupada por fuente.
    """
    matrix = {}
    for key in sources:
        queryset = ALERT_SOURCES[key].objects.filter(detected_at__gte=since)
        queryset = _scope(queryset, key, customer_id)
        rows = queryset.values("state_id", "severity_id").annotate(n=Count("id"))
        matrix[key] = {(row["state_id"], row["severity_id"]): row["n"] for row in rows}
    return matrix


def _scope(queryset, source_key, customer_id):
    """Restringe una fuente al cliente indicado (si la fuente esta ligada a un cliente)."""
    if customer_id is None:
        return queryset
    if source_key in ("shodan_ports", "shodan_vulns"):
        return queryset.filter(host_alert__customer_id=customer_id)
    return queryset.filter(customer_id=customer_id)


def _sum_state(cells, state_id):
    return sum(n for (s, _), n in cells.items() if s == state_id)


def _sum_state_severity(cells, state_id, severity_id):
    return cells.get((state_id, severity_id), 0)


def status_counts(customer_id=None) -> dict:
    """Abiertas / en progreso / resueltas por fuente (ultimos 30 dias)."""
    states = _ids_by_name(AlertState)
    since = _since(settings.STATISTICS_STATUS_COUNTS_WINDOW_DAYS)
    matrix = _state_severity_matrix(STATUS_COUNT_SOURCES, since, customer_id)
    return {
        "window_days": settings.STATISTICS_STATUS_COUNTS_WINDOW_DAYS,
        "open": {key: _sum_state(matrix[key], states.get(AlertState.OPEN)) for key in STATUS_COUNT_SOURCES},
        "in_progress": {
            key: _sum_state(matrix[key], states.get(AlertState.IN_PROGRESS)) for key in STATUS_COUNT_SOURCES
        },
        "resolved": {key: _sum_state(matrix[key], states.get(AlertState.RESOLVED)) for key in STATUS_COUNT_SOURCES},
    }


def _dashboard_matrix(customer_id=None):
    since = _since(settings.STATISTICS_DASHBOARD_WINDOW_DAYS)
    return _state_severity_matrix(DASHBOARD_SOURCES, since, customer_id)


def open_resolved_totals(customer_id=None) -> dict:
    """Total de alertas abiertas y resueltas (ultimos 365 dias)."""
    states = _ids_by_name(AlertState)
    matrix = _dashboard_matrix(customer_id)
    return {
        "open": sum(_sum_state(cells, states.get(AlertState.OPEN)) for cells in matrix.values()),
        "resolved": sum(_sum_state(cells, states.get(AlertState.RESOLVED)) for cells in matrix.values()),
    }


def severity_counts(customer_id=None) -> dict:
    """Total de alertas por criticidad (ultimos 365 dias)."""
    severities = _ids_by_name(AlertSeverity)
    matrix = _dashboard_matrix(customer_id)
    return {
        name: sum(n for cells in matrix.values() for (_, sev), n in cells.items() if sev == severities.get(name))
        for name in DASHBOARD_SEVERITIES
    }


def open_resolved_by_severity(customer_id=None) -> dict:
    """Alertas abiertas y resueltas desglosadas por criticidad (ultimos 365 dias)."""
    states = _ids_by_name(AlertState)
    severities = _ids_by_name(AlertSeverity)
    matrix = _dashboard_matrix(customer_id)

    def by_severity(state_name):
        state_id = states.get(state_name)
        return {
            name: sum(_sum_state_severity(cells, state_id, severities.get(name)) for cells in matrix.values())
            for name in DASHBOARD_SEVERITIES
        }

    return {
        "open_by_severity": by_severity(AlertState.OPEN),
        "resolved_by_severity": by_severity(AlertState.RESOLVED),
    }


def open_resolved_by_module(customer_id=None) -> dict:
    """Alertas abiertas y resueltas por modulo de servicio (ultimos 365 dias)."""
    states = _ids_by_name(AlertState)
    matrix = _dashboard_matrix(customer_id)

    def by_module(state_name):
        state_id = states.get(state_name)
        return {
            module: sum(_sum_state(matrix[key], state_id) for key in sources)
            for module, sources in SERVICE_MODULES.items()
        }

    return {
        "open_by_module": by_module(AlertState.OPEN),
        "resolved_by_module": by_module(AlertState.RESOLVED),
    }


def _daily_by_state(sources, since, customer_id=None):
    """{fuente: {(dia, state_id): n}} con una consulta agrupada por fuente."""
    result = {}
    for key in sources:
        queryset = _scope(ALERT_SOURCES[key].objects.filter(detected_at__gte=since), key, customer_id)
        rows = (
            queryset.annotate(day=TruncDay("detected_at"))
            .values("day", "state_id")
            .annotate(n=Count("id"))
        )
        result[key] = {(row["day"].strftime("%Y-%m-%d"), row["state_id"]): row["n"] for row in rows}
    return result


def daily_open_resolved(customer_id=None) -> dict:
    """Serie diaria de alertas abiertas y resueltas (ultimos 365 dias)."""
    states = _ids_by_name(AlertState)
    since = _since(settings.STATISTICS_DASHBOARD_WINDOW_DAYS)
    daily = _daily_by_state(DASHBOARD_SOURCES, since, customer_id)

    open_id, resolved_id = states.get(AlertState.OPEN), states.get(AlertState.RESOLVED)
    open_counts, resolved_counts = defaultdict(int), defaultdict(int)
    for cells in daily.values():
        for (day, state_id), n in cells.items():
            if state_id == open_id:
                open_counts[day] += n
            elif state_id == resolved_id:
                resolved_counts[day] += n

    days = sorted(set(open_counts) | set(resolved_counts))
    return {
        "days": days,
        "open": [open_counts[d] for d in days],
        "resolved": [resolved_counts[d] for d in days],
    }


def daily_by_module(customer_id=None) -> dict:
    """Serie diaria de alertas detectadas por modulo de servicio (ultimos 365 dias)."""
    since = _since(settings.STATISTICS_DASHBOARD_WINDOW_DAYS)
    module_sources = [key for sources in SERVICE_MODULES.values() for key in sources]
    daily = _daily_by_state(module_sources, since, customer_id)

    per_module = {module: defaultdict(int) for module in SERVICE_MODULES}
    for module, sources in SERVICE_MODULES.items():
        for key in sources:
            for (day, _), n in daily[key].items():
                per_module[module][day] += n

    days = sorted({day for counts in per_module.values() for day in counts})
    return {
        "days": days,
        "by_module": {module: [counts[d] for d in days] for module, counts in per_module.items()},
    }
