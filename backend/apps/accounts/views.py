"""Inicio y cierre de sesion por token (rest_framework.authtoken) y datos de la sesion."""
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.throttling import AnonRateThrottle
from rest_framework.views import APIView

from .serializers import SessionInfoSerializer


class LoginThrottle(AnonRateThrottle):
    """Limite especifico para intentos de inicio de sesion."""

    scope = "login"
    rate = "20/min"


class LoginView(ObtainAuthToken):
    """POST {username, password} -> {token, username, role, customer}."""

    permission_classes = []
    authentication_classes = []
    throttle_classes = [LoginThrottle]

    def post(self, request, *args, **kwargs):
        serializer = self.serializer_class(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data["user"]
        token, _ = Token.objects.get_or_create(user=user)
        return Response({"token": token.key, **SessionInfoSerializer.for_user(user)})


class LogoutView(APIView):
    """POST: invalida el token del usuario actual."""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        Token.objects.filter(user=request.user).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class SessionView(APIView):
    """GET: usuario, rol y cliente de la sesion actual."""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(SessionInfoSerializer.for_user(request.user))
