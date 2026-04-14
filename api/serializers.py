from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Profile, Category, Product, Order, OrderItem, ActivityLog

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']

class ProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    class Meta:
        model = Profile
        fields = '__all__'

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = '__all__'

class ProductSerializer(serializers.ModelSerializer):
    producer_name = serializers.CharField(source='producer.full_name', read_only=True)
    class Meta:
        model = Product
        fields = '__all__'

class OrderItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderItem
        fields = '__all__'

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    class Meta:
        model = Order
        fields = '__all__'

class ActivityLogSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='profile.full_name', read_only=True)
    class Meta:
        model = ActivityLog
        fields = '__all__'
