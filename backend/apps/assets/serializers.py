from rest_framework import serializers

from .models import (
    GoogleDorkQuery,
    MonitoredDomain,
    MonitoredIpAddress,
    MonitoredKeyword,
    ShodanDorkQuery,
    TelegramChannel,
    TwitterDorkQuery,
)

ASSET_COMMON_FIELDS = ["id", "customer", "customer_name", "is_active", "added_at", "notes"]


class CustomerNameMixin(serializers.Serializer):
    customer_name = serializers.CharField(source="customer.name", read_only=True)


class MonitoredDomainSerializer(CustomerNameMixin, serializers.ModelSerializer):
    class Meta:
        model = MonitoredDomain
        fields = ASSET_COMMON_FIELDS + ["domain_name"]


class MonitoredIpAddressSerializer(CustomerNameMixin, serializers.ModelSerializer):
    class Meta:
        model = MonitoredIpAddress
        fields = ASSET_COMMON_FIELDS + ["ip_address"]


class MonitoredKeywordSerializer(CustomerNameMixin, serializers.ModelSerializer):
    class Meta:
        model = MonitoredKeyword
        fields = ASSET_COMMON_FIELDS + ["term"]


class TelegramChannelSerializer(serializers.ModelSerializer):
    class Meta:
        model = TelegramChannel
        fields = ["id", "channel_name", "is_active", "added_at", "notes"]


class GoogleDorkQuerySerializer(CustomerNameMixin, serializers.ModelSerializer):
    class Meta:
        model = GoogleDorkQuery
        fields = ASSET_COMMON_FIELDS + ["query_text"]


class ShodanDorkQuerySerializer(CustomerNameMixin, serializers.ModelSerializer):
    class Meta:
        model = ShodanDorkQuery
        fields = ASSET_COMMON_FIELDS + ["query_text"]


class TwitterDorkQuerySerializer(CustomerNameMixin, serializers.ModelSerializer):
    class Meta:
        model = TwitterDorkQuery
        fields = ASSET_COMMON_FIELDS + ["query_text"]
