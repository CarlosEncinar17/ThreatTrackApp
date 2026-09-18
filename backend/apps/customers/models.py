"""
Clientes de la plataforma, servicios que tienen contratados, catalogo de servicios y
registro de ejecuciones de los scripts OSINT.

Las tablas las define compose/db/01_schema.sql y las escriben tambien los scripts de
recoleccion, por eso los modelos son `managed = False`.
"""
from django.db import models


class Customer(models.Model):
    """Empresa cliente a la que se presta el servicio de cibervigilancia."""

    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255, unique=True)
    registered_at = models.DateTimeField(blank=True, null=True)
    is_active = models.BooleanField()
    notes = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = "customers"
        ordering = ["id"]
        verbose_name = "cliente"
        verbose_name_plural = "clientes"

    def __str__(self) -> str:
        return self.name


class CustomerServiceSubscription(models.Model):
    """Servicios de cibervigilancia contratados por un cliente (una fila por cliente)."""

    customer = models.OneToOneField(
        Customer, on_delete=models.PROTECT, primary_key=True, db_column="customer_id", related_name="subscription"
    )
    defacement_enabled = models.BooleanField()
    github_enabled = models.BooleanField()
    gitlab_enabled = models.BooleanField()
    google_enabled = models.BooleanField()
    intelx_enabled = models.BooleanField()
    shodan_enabled = models.BooleanField()
    telegram_enabled = models.BooleanField()
    twitter_enabled = models.BooleanField()
    typosquatting_enabled = models.BooleanField()
    certificates_enabled = models.BooleanField()
    blocklist_enabled = models.BooleanField()
    notes = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = "customer_service_subscriptions"
        ordering = ["customer_id"]
        verbose_name = "servicios contratados"
        verbose_name_plural = "servicios contratados"

    def __str__(self) -> str:
        return f"Servicios de {self.customer_id}"


class ServiceCatalogEntry(models.Model):
    """Catalogo de servicios de cibervigilancia que ofrece la plataforma."""

    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255)

    class Meta:
        managed = False
        db_table = "service_catalog"
        ordering = ["id"]
        verbose_name = "servicio del catalogo"
        verbose_name_plural = "catalogo de servicios"

    def __str__(self) -> str:
        return self.name


class ScanRun(models.Model):
    """Ejecucion de un modulo de recoleccion OSINT (inicio, fin y observaciones)."""

    id = models.AutoField(primary_key=True)
    module_name = models.CharField(max_length=255)
    run_started_at = models.DateTimeField(blank=True, null=True)
    run_finished_at = models.DateTimeField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = "scan_runs"
        ordering = ["-run_started_at", "-id"]
        verbose_name = "ejecucion de modulo"
        verbose_name_plural = "ejecuciones de modulos"

    def __str__(self) -> str:
        return f"{self.module_name} @ {self.run_started_at:%Y-%m-%d %H:%M}" if self.run_started_at else self.module_name
