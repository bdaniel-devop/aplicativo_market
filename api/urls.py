from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ProfileViewSet, CategoryViewSet, ProductViewSet, OrderViewSet, ActivityLogViewSet

router = DefaultRouter()
router.register(r'profiles', ProfileViewSet)
router.register(r'categories', CategoryViewSet)
router.register(r'products', ProductViewSet)
router.register(r'orders', OrderViewSet)
router.register(r'logs', ActivityLogViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
