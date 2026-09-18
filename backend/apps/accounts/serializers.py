from rest_framework import serializers

from apps.common.permissions import customer_id_for, user_role


class SessionInfoSerializer(serializers.Serializer):
    """Informacion que el frontend necesita tras iniciar sesion."""

    username = serializers.CharField()
    role = serializers.CharField(allow_null=True)
    customer = serializers.DictField(allow_null=True)

    @classmethod
    def for_user(cls, user) -> dict:
        customer = None
        customer_id = customer_id_for(user)
        if customer_id is not None:
            customer = {"id": customer_id, "name": user.profile.customer.name}
        return {"username": user.get_username(), "role": user_role(user), "customer": customer}
