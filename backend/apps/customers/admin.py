from django.contrib import admin

from .models import Customer, CustomerServiceSubscription, ScanRun, ServiceCatalogEntry


@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "is_active", "registered_at")
    list_filter = ("is_active",)
    search_fields = ("name",)


@admin.register(CustomerServiceSubscription)
class CustomerServiceSubscriptionAdmin(admin.ModelAdmin):
    list_display = (
        "customer",
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
    )
    list_select_related = ("customer",)


@admin.register(ServiceCatalogEntry)
class ServiceCatalogEntryAdmin(admin.ModelAdmin):
    list_display = ("id", "name")


@admin.register(ScanRun)
class ScanRunAdmin(admin.ModelAdmin):
    list_display = ("id", "module_name", "run_started_at", "run_finished_at")
    list_filter = ("module_name",)
