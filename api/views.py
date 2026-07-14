from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.decorators import action
from rest_framework.authtoken.models import Token
from django.shortcuts import get_object_or_404
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from django.db import IntegrityError
from .models import Profile, Category, Product, Order, ActivityLog
from .serializers import ProfileSerializer, CategorySerializer, ProductSerializer, OrderSerializer, ActivityLogSerializer


class RegisterView(APIView):
    """Cria um User + Profile ligados e devolve um token de autenticação.

    Aditivo: não altera nenhum ViewSet/rota existente.
    """
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        data = request.data
        email = data.get('email', '').strip().lower()
        phone = data.get('phone', '').strip()
        password = data.get('password')
        full_name = data.get('full_name', '').strip()

        if not email or not password or not full_name or not phone:
            return Response(
                {"detail": "full_name, email, phone e password são obrigatórios."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if User.objects.filter(username=email).exists():
            return Response({"detail": "Já existe uma conta com este email."}, status=status.HTTP_400_BAD_REQUEST)

        if Profile.objects.filter(phone=phone).exists():
            return Response({"detail": "Já existe uma conta com este telefone."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.create_user(username=email, email=email, password=password)
        except IntegrityError:
            return Response({"detail": "Já existe uma conta com este email."}, status=status.HTTP_400_BAD_REQUEST)

        profile = Profile.objects.create(
            user=user,
            full_name=full_name,
            phone=phone,
            commercial_phone=data.get('commercial_phone', ''),
            country=data.get('country', 'Moçambique'),
            province=data.get('province'),
            district=data.get('district'),
            posto=data.get('posto'),
            localidade=data.get('localidade'),
            role=data.get('role', 'comprador'),
            entity_type=data.get('entity_type', 'individual'),
            entity_name=data.get('entity_name'),
        )

        token, _ = Token.objects.get_or_create(user=user)
        serializer = ProfileSerializer(profile)
        return Response({"token": token.key, "profile": serializer.data}, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    """Autentica por email ou telefone + password e devolve um token."""
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        identifier = request.data.get('identifier', '').strip()
        password = request.data.get('password')

        if not identifier or not password:
            return Response({"detail": "identifier e password são obrigatórios."}, status=status.HTTP_400_BAD_REQUEST)

        username = identifier.lower()
        if '@' not in identifier:
            profile = Profile.objects.filter(phone=identifier).select_related('user').first()
            if not profile:
                return Response({"detail": "Credenciais inválidas."}, status=status.HTTP_401_UNAUTHORIZED)
            username = profile.user.username

        user = authenticate(request, username=username, password=password)
        if not user:
            return Response({"detail": "Credenciais inválidas."}, status=status.HTTP_401_UNAUTHORIZED)

        profile = get_object_or_404(Profile, user=user)
        token, _ = Token.objects.get_or_create(user=user)
        serializer = ProfileSerializer(profile)
        return Response({"token": token.key, "profile": serializer.data})

class ProfileViewSet(viewsets.ModelViewSet):
    queryset = Profile.objects.all()
    serializer_class = ProfileSerializer
    # In a real app, use more restrictive permissions
    permission_classes = [permissions.AllowAny]

    @action(detail=False, methods=['get'])
    def me(self, request):
        if not request.user.is_authenticated:
            return Response({"detail": "Not authenticated"}, status=status.HTTP_401_UNAUTHORIZED)
        profile = get_object_or_404(Profile, user=request.user)
        serializer = self.get_serializer(profile)
        return Response(serializer.data)

class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Category.objects.filter(is_active=True)
    serializer_class = CategorySerializer

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all().order_by('-created_at')
    serializer_class = ProductSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = super().get_queryset()
        category_id = self.request.query_params.get('category', None)
        if category_id:
            queryset = queryset.filter(category_id=category_id)
        return queryset

class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.all().order_by('-created_at')
    serializer_class = OrderSerializer
    permission_classes = [permissions.AllowAny]

class ActivityLogViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = ActivityLog.objects.all().order_by('-created_at')
    serializer_class = ActivityLogSerializer
