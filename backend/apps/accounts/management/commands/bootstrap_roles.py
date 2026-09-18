"""
Crea los grupos de rol (`analyst`, `client`) y, si se han definido sus contrasenas en
el entorno, los usuarios iniciales de administracion, analista y cliente.

Es idempotente: se ejecuta en cada arranque del contenedor sin efectos secundarios.
"""
import os

from django.conf import settings
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Group
from django.core.management.base import BaseCommand

from apps.accounts.models import UserProfile
from apps.customers.models import Customer


class Command(BaseCommand):
    help = "Crea los grupos de rol y los usuarios iniciales definidos en el entorno."

    def handle(self, *args, **options):
        analyst_group, _ = Group.objects.get_or_create(name=settings.ANALYST_GROUP)
        client_group, _ = Group.objects.get_or_create(name=settings.CLIENT_GROUP)
        self.stdout.write(f"Grupos disponibles: {settings.ANALYST_GROUP}, {settings.CLIENT_GROUP}")

        user_model = get_user_model()

        admin_password = os.environ.get("BOOTSTRAP_ADMIN_PASSWORD", "")
        if admin_password:
            username = os.environ.get("BOOTSTRAP_ADMIN_USERNAME", "admin")
            if not user_model.objects.filter(username=username).exists():
                user_model.objects.create_superuser(username=username, password=admin_password)
                self.stdout.write(f"Superusuario creado: {username}")

        analyst_password = os.environ.get("BOOTSTRAP_ANALYST_PASSWORD", "")
        if analyst_password:
            username = os.environ.get("BOOTSTRAP_ANALYST_USERNAME", "analyst")
            user, created = user_model.objects.get_or_create(username=username)
            if created:
                user.set_password(analyst_password)
                user.save()
                self.stdout.write(f"Analista creado: {username}")
            user.groups.add(analyst_group)

        client_password = os.environ.get("BOOTSTRAP_CLIENT_PASSWORD", "")
        if client_password:
            username = os.environ.get("BOOTSTRAP_CLIENT_USERNAME", "client")
            customer_name = os.environ.get("BOOTSTRAP_CLIENT_CUSTOMER", "")
            customer = Customer.objects.filter(name=customer_name).first()
            if customer is None:
                self.stderr.write(f"No existe el cliente '{customer_name}'; no se crea el usuario cliente.")
            else:
                user, created = user_model.objects.get_or_create(username=username)
                if created:
                    user.set_password(client_password)
                    user.save()
                    self.stdout.write(f"Usuario cliente creado: {username} -> {customer.name}")
                user.groups.add(client_group)
                UserProfile.objects.update_or_create(user=user, defaults={"customer": customer})
