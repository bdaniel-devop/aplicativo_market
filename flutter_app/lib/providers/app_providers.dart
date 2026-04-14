import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  Profile? _user;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Profile? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // For now, simulate login success or call the API
      // final response = await _apiService.login(email, password);
      // _user = Profile.fromJson(response.data);
      
      // Mock user for immediate UI testing
      _user = Profile(
        id: '1',
        email: email,
        fullName: 'Utilizador Teste',
        phone: '840000000',
        role: UserRole.buyer,
        status: 'active',
        isApproved: true,
        balance: 0.0,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}

class MarketProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  final Map<String, int> _cart = {};
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  Map<String, int> get cart => _cart;
  bool get isLoading => _isLoading;

  int get cartCount => _cart.values.fold(0, (sum, q) => sum + q);

  Future<void> fetchMarketData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final catResponse = await _apiService.getCategories();
      _categories = (catResponse.data as List).map((c) => Category.fromJson(c)).toList();
      
      final prodResponse = await _apiService.getProducts();
      _products = (prodResponse.data as List).map((p) => Product.fromJson(p)).toList();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addToCart(String productId) {
    _cart[productId] = (_cart[productId] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromCart(String productId) {
    if (_cart.containsKey(productId)) {
      if (_cart[productId]! > 1) {
        _cart[productId] = _cart[productId]! - 1;
      } else {
        _cart.remove(productId);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
