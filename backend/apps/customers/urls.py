from rest_framework import routers

from .views import CustomerServiceSubscriptionViewSet, CustomerViewSet, ScanRunViewSet, ServiceCatalogEntryViewSet

# Las rutas conservan los nombres del sistema original para no romper a ningun consumidor.
router = routers.DefaultRouter()
router.register("Clients", CustomerViewSet, basename="Clients")
router.register("Apps", CustomerServiceSubscriptionViewSet, basename="Apps")
router.register("Monitoring", ScanRunViewSet, basename="Monitoring")
router.register("Services", ServiceCatalogEntryViewSet, basename="Services")

urlpatterns = router.urls
