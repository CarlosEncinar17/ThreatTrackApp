from django.contrib import admin

from .models import (
    GoogleDorkQuery,
    MonitoredDomain,
    MonitoredIpAddress,
    MonitoredKeyword,
    ShodanDorkQuery,
    TelegramChannel,
    TwitterDorkQuery,
)


class CustomerAssetAdmin(admin.ModelAdmin):
    list_filter = ("is_active", "customer")
    list_select_related = ("customer",)
    autocomplete_fields = ("customer",)


@admin.register(MonitoredDomain)
class MonitoredDomainAdmin(CustomerAssetAdmin):
    list_display = ("id", "domain_name", "customer", "is_active", "added_at")
    search_fields = ("domain_name",)


@admin.register(MonitoredIpAddress)
class MonitoredIpAddressAdmin(CustomerAssetAdmin):
    list_display = ("id", "ip_address", "customer", "is_active", "added_at")
    search_fields = ("ip_address",)


@admin.register(MonitoredKeyword)
class MonitoredKeywordAdmin(CustomerAssetAdmin):
    list_display = ("id", "term", "customer", "is_active", "added_at")
    search_fields = ("term",)


@admin.register(TelegramChannel)
class TelegramChannelAdmin(admin.ModelAdmin):
    list_display = ("id", "channel_name", "is_active", "added_at")
    list_filter = ("is_active",)
    search_fields = ("channel_name",)


@admin.register(GoogleDorkQuery, ShodanDorkQuery, TwitterDorkQuery)
class DorkQueryAdmin(CustomerAssetAdmin):
    list_display = ("id", "query_text", "customer", "is_active", "added_at")
    search_fields = ("query_text",)
