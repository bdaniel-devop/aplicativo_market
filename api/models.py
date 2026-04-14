from django.db import models
from django.contrib.auth.models import User
import uuid

class UserRole(models.TextChoices):
    BUYER = 'comprador', 'Comprador'
    SELLER = 'produtor', 'Produtor'
    TRANSPORTER = 'transportador', 'Transportador'
    EXTENSIONIST = 'extensionista', 'Técnico Extensionista'
    ADMIN = 'administrador', 'Administrador'
    STRATEGIC_PARTNER = 'parceiro_estrategico', 'Parceiro Estratégico'
    OTHER = 'outro', 'Outro'

class EntityType(models.TextChoices):
    INDIVIDUAL = 'individual', 'Produtor Individual'
    ASSOCIATION = 'associacao', 'Associação'
    COOPERATIVE = 'cooperativa', 'Cooperativa'
    COMPANY = 'empresa', 'Empresa'
    NGO_INTL = 'ong_internacional', 'ONG Internacional'
    OTHER = 'outro', 'Outro'

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    full_name = models.CharField(max_length=255)
    phone = models.CharField(max_length=20)
    commercial_phone = models.CharField(max_length=20, blank=True)
    country = models.CharField(max_length=100, default='Moçambique')
    province = models.CharField(max_length=100, blank=True, null=True)
    district = models.CharField(max_length=100, blank=True, null=True)
    posto = models.CharField(max_length=100, blank=True, null=True)
    localidade = models.CharField(max_length=100, blank=True, null=True)
    role = models.CharField(max_length=50, choices=UserRole.choices, default=UserRole.BUYER)
    entity_type = models.CharField(max_length=50, choices=EntityType.choices, default=EntityType.INDIVIDUAL)
    entity_name = models.CharField(max_length=255, blank=True, null=True)
    is_approved = models.BooleanField(default=False)
    balance = models.DecimalField(max_digits=12, decimal_places=2, default=0.00)
    status = models.CharField(max_length=20, default='active', choices=[
        ('active', 'Active'),
        ('inactive', 'Inactive'),
        ('blocked', 'Blocked'),
        ('online', 'Online'),
        ('offline', 'Offline'),
    ])
    linked_accounts = models.JSONField(default=list, blank=True)
    categories = models.JSONField(default=list, blank=True)
    documents = models.JSONField(default=dict, blank=True)
    logo = models.URLField(max_length=500, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.full_name} ({self.role})"

class Category(models.Model):
    name = models.CharField(max_length=100)
    icon = models.CharField(max_length=10, blank=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.name

class Product(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    producer = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='products')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, related_name='products')
    name = models.CharField(max_length=255)
    description = models.TextField()
    price = models.DecimalField(max_digits=12, decimal_places=2)
    unit = models.CharField(max_length=50)
    stock = models.IntegerField(default=0)
    images = models.JSONField(default=list)
    is_dried = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class Order(models.Model):
    STATUS_CHOICES = [
        ('pendente', 'Pendente'),
        ('pago', 'Pago'),
        ('entregue', 'Entregue'),
        ('cancelado', 'Cancelado'),
    ]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    buyer = models.ForeignKey(Profile, on_delete=models.SET_NULL, null=True, related_name='orders')
    buyer_name = models.CharField(max_length=255)
    buyer_phone = models.CharField(max_length=20)
    subtotal = models.DecimalField(max_digits=12, decimal_places=2)
    commission = models.DecimalField(max_digits=12, decimal_places=2)
    total = models.DecimalField(max_digits=12, decimal_places=2)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pendente')
    payment_method = models.CharField(max_length=50)
    province = models.CharField(max_length=100, blank=True, null=True)
    district = models.CharField(max_length=100, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Order {self.id} - {self.status}"

class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey(Product, on_delete=models.SET_NULL, null=True)
    name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=12, decimal_places=2)
    quantity = models.IntegerField()
    unit = models.CharField(max_length=50)

class ActivityLog(models.Model):
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='logs')
    type = models.CharField(max_length=50)
    description = models.TextField()
    details = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.type} - {self.profile.full_name}"
