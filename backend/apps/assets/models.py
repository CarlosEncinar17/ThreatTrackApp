"""
Activos que cada cliente pone bajo monitorizacion (dominios, IPs, palabras clave),
canales de Telegram y consultas avanzadas (dorks) de Google, Shodan y Twitter.
"""
from django.db import models

from apps.customers.models import Customer


class CustomerAssetBase(models.Model):
    """Campos comunes de los activos y consultas asociados a un cliente."""

    id = models.AutoField(primary_key=True)
    customer = models.ForeignKey(Customer, on_delete=models.PROTECT, db_column="customer_id", related_name="+")
    is_active = models.BooleanField()
    added_at = models.DateTimeField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    class Meta:
        abstract = True
        ordering = ["-added_at", "-id"]


class MonitoredDomain(CustomerAssetBase):
    domain_name = models.CharField(max_length=255, unique=True)

    class Meta(CustomerAssetBase.Meta):
        managed = False
        db_table = "monitored_domains"
        verbose_name = "dominio monitorizado"
        verbose_name_plural = "dominios monitorizados"

    def __str__(self) -> str:
        return self.domain_name


class MonitoredIpAddress(CustomerAssetBase):
    ip_address = models.CharField(max_length=255, unique=True)

    class Meta(CustomerAssetBase.Meta):
        managed = False
        db_table = "monitored_ip_addresses"
        verbose_name = "IP monitorizada"
        verbose_name_plural = "IPs monitorizadas"

    def __str__(self) -> str:
        return self.ip_address


class MonitoredKeyword(CustomerAssetBase):
    term = models.CharField(max_length=255, unique=True)

    class Meta(CustomerAssetBase.Meta):
        managed = False
        db_table = "monitored_keywords"
        verbose_name = "palabra clave monitorizada"
        verbose_name_plural = "palabras clave monitorizadas"

    def __str__(self) -> str:
        return self.term


class TelegramChannel(models.Model):
    """Canal o grupo de Telegram que vigilan los scripts (no esta ligado a un cliente)."""

    id = models.AutoField(primary_key=True)
    channel_name = models.CharField(max_length=255, unique=True)
    added_at = models.DateTimeField(blank=True, null=True)
    is_active = models.BooleanField()
    notes = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = "telegram_channels"
        ordering = ["-added_at", "-id"]
        verbose_name = "canal de Telegram"
        verbose_name_plural = "canales de Telegram"

    def __str__(self) -> str:
        return self.channel_name


class DorkQueryBase(CustomerAssetBase):
    """Consulta avanzada (dork) asociada a un cliente."""

    query_text = models.TextField(unique=True)

    class Meta(CustomerAssetBase.Meta):
        abstract = True

    def __str__(self) -> str:
        return self.query_text[:80]


class GoogleDorkQuery(DorkQueryBase):
    class Meta(DorkQueryBase.Meta):
        managed = False
        db_table = "google_dork_queries"
        verbose_name = "dork de Google"
        verbose_name_plural = "dorks de Google"


class ShodanDorkQuery(DorkQueryBase):
    class Meta(DorkQueryBase.Meta):
        managed = False
        db_table = "shodan_dork_queries"
        verbose_name = "dork de Shodan"
        verbose_name_plural = "dorks de Shodan"


class TwitterDorkQuery(DorkQueryBase):
    class Meta(DorkQueryBase.Meta):
        managed = False
        db_table = "twitter_dork_queries"
        verbose_name = "dork de Twitter"
        verbose_name_plural = "dorks de Twitter"
