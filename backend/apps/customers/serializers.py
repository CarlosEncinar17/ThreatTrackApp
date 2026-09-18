from rest_framework import serializers

from .models import Customer, CustomerServiceSubscription, ScanRun, ServiceCatalogEntry


class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = ["id", "name", "registered_at", "is_active", "notes"]


class CustomerServiceSubscriptionSerializer(serializers.ModelSerializer):
    customer_name = serializers.CharField(source="customer.name", read_only=True)

    class Meta:
        model = CustomerServiceSubscription
        fields = [
            "customer",
            "customer_name",
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
            "notes",
        ]


class ServiceCatalogEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = ServiceCatalogEntry
        fields = ["id", "name"]


class ScanRunSerializer(serializers.ModelSerializer):
    class Meta:
        model = ScanRun
        fields = ["id", "module_name", "run_started_at", "run_finished_at", "notes"]
