from django.conf import settings
from django.db import models


class UserProfile(models.Model):
    """
    Vincula un usuario con rol cliente al cliente cuyos datos puede consultar.
    El rol en si lo determina la pertenencia a los grupos `analyst` / `client`.
    """

    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="profile")
    customer = models.ForeignKey(
        "customers.Customer",
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="user_profiles",
        help_text="Cliente al que pertenece el usuario (solo para el rol cliente).",
    )

    class Meta:
        verbose_name = "perfil de usuario"
        verbose_name_plural = "perfiles de usuario"

    def __str__(self) -> str:
        return f"{self.user.username} -> {self.customer or 'sin cliente'}"
