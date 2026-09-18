"""Rutas raiz: panel de administracion y API REST."""
from django.contrib import admin
from django.urls import include, path

from apps.common.views import HealthView

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/health/", HealthView.as_view(), name="health"),
    path("api/auth/", include("apps.accounts.urls")),
    path("api/", include("apps.customers.urls")),
    path("api/", include("apps.assets.urls")),
    path("api/", include("apps.alerts.urls")),
]
