from rest_framework import generics, status
from .serializers import CustomTokenRefreshSerializer, UserRegistrationSerializer, CustomTokenObtainPairSerializer
from rest_framework.response import Response
from rest_framework.authtoken.serializers import AuthTokenSerializer
from rest_framework_simplejwt.views import TokenRefreshView

class RegisterView(generics.CreateAPIView):
    serializer_class = UserRegistrationSerializer

class LoginView(generics.GenericAPIView):
    serializer_class = CustomTokenObtainPairSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response(serializer.validated_data, status=status.HTTP_200_OK)

class CustomTokenRefreshView(TokenRefreshView):
    serializer_class = CustomTokenRefreshSerializer