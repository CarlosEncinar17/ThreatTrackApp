"""Clases base de los viewsets de la API."""
from rest_framework import viewsets

from .permissions import CustomerScopedQuerysetMixin


class ScopedModelViewSet(CustomerScopedQuerysetMixin, viewsets.ModelViewSet):
    """
    CRUD completo con paginacion, filtros (`filterset_class`), busqueda (`search_fields`),
    ordenacion (`ordering_fields`, `ordering`) y recorte por cliente para usuarios con rol cliente.
    """

    ordering = ["-id"]
