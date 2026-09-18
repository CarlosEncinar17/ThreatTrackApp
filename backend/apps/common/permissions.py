"""
Control de acceso por rol.

- Analistas (grupo `analyst`, staff o superusuarios): lectura y escritura sobre toda la API.
- Clientes (grupo `client`): solo lectura, y unicamente sobre los datos de su propio
  cliente (el recorte del queryset lo hace `CustomerScopedQuerysetMixin`).
- Cualquier otro usuario autenticado sin rol: sin acceso.

Cuando `API_REQUIRE_AUTH` es False no se instala esta clase y la API es anonima
(comportamiento del sistema original).
"""
from django.conf import settings
from rest_framework.permissions import SAFE_METHODS, BasePermission


def is_analyst(user) -> bool:
    if not user or not user.is_authenticated:
        return False
    if user.is_superuser or user.is_staff:
        return True
    return user.groups.filter(name=settings.ANALYST_GROUP).exists()


def is_client(user) -> bool:
    if not user or not user.is_authenticated:
        return False
    return user.groups.filter(name=settings.CLIENT_GROUP).exists()


def user_role(user) -> str | None:
    if is_analyst(user):
        return settings.ANALYST_GROUP
    if is_client(user):
        return settings.CLIENT_GROUP
    return None


def customer_id_for(user):
    """Cliente al que pertenece un usuario con rol cliente (None si no tiene)."""
    profile = getattr(user, "profile", None)
    return getattr(profile, "customer_id", None)


class RoleBasedAccess(BasePermission):
    message = "No tienes permiso para realizar esta operacion."

    def has_permission(self, request, view) -> bool:
        if not settings.API_REQUIRE_AUTH:
            return True
        user = request.user
        if not user or not user.is_authenticated:
            return False
        if is_analyst(user):
            return True
        if is_client(user):
            return request.method in SAFE_METHODS
        return False


class CustomerScopedQuerysetMixin:
    """
    Recorta el queryset a los datos del cliente del usuario cuando este tiene rol cliente.

    `customer_lookup` es la ruta ORM hasta el id de cliente ('customer', 'host_alert__customer',
    'pk' para el propio modelo Customer...). None significa que el recurso no esta ligado a un
    cliente (catalogos) y se devuelve completo.
    """

    customer_lookup: str | None = "customer"

    def get_queryset(self):
        queryset = super().get_queryset()
        if not settings.API_REQUIRE_AUTH or self.customer_lookup is None:
            return queryset
        user = self.request.user
        if is_analyst(user):
            return queryset
        customer_id = customer_id_for(user)
        if customer_id is None:
            return queryset.none()
        return queryset.filter(**{self.customer_lookup: customer_id})
