import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/supabase_service.dart';
import '../services/local_store_service.dart';
import '../data/translations.dart';
import '../data/categories.dart';

final SupabaseService sharedSupabaseService = SupabaseService();
final LocalStoreService sharedLocalStore = LocalStoreService();

class AuthProvider extends ChangeNotifier {
  Profile? _profile;
  bool _isLoading = false;
  bool _initialized = false;
  final SupabaseService _service = sharedSupabaseService;

  Profile? get user => _profile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _profile != null;
  bool get initialized => _initialized;

  /// Restaura a sessão que o supabase_flutter já mantém persistida.
  Future<void> autoLogin() async {
    final session = _service.currentSession;
    if (session != null) {
      // Com retry: a rede/DNS pode ainda não estar pronta nos primeiros
      // segundos após abrir a app — sem isto, um utilizador com sessão
      // válida aparecia como "deslogado" só por causa desse atraso.
      const maxAttempts = 3;
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          _profile = await _service.getProfile(session.user.id);
          break;
        } catch (_) {
          if (attempt == maxAttempts) {
            _profile = null;
          } else {
            await Future.delayed(Duration(milliseconds: 700 * attempt));
          }
        }
      }
    }
    _initialized = true;
    notifyListeners();
  }

  /// Devolve true se a conta ficou pronta a usar de imediato, ou false se
  /// o Supabase exige confirmação por email antes do primeiro login.
  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.register(
        email: data['email'],
        password: data['password'],
        fullName: data['full_name'],
        phone: data['phone'],
        role: data['role'],
        entityType: data['entity_type'],
        entityName: data['entity_name'],
        province: data['province'],
        district: data['district'],
        posto: data['posto'],
        localidade: data['localidade'],
      );
      // O registo termina sempre com signOut (o Supabase pode exigir
      // confirmação de email); tentamos logo o login — se o projecto não
      // exigir confirmação, entra directamente.
      try {
        await login(data['email'], data['password']);
        return true;
      } catch (_) {
        return false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _service.login(identifier, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_profile == null) return;
    await _service.updateProfile(_profile!.id, data);
    _profile = await _service.getProfile(_profile!.id);
    notifyListeners();
  }

  Future<void> logout() async {
    await _service.logout();
    _profile = null;
    notifyListeners();
  }
}

class MarketProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Profile> _profiles = [];
  final Map<String, CartItem> _cart = {};
  bool _isLoading = false;
  final SupabaseService _service = sharedSupabaseService;

  List<Product> get products => _products;
  List<Category> get categories => staticCategories;
  List<Profile> get profiles => _profiles;
  List<CartItem> get cartItems => _cart.values.toList();
  bool get isLoading => _isLoading;

  int get cartCount => _cart.values.fold(0, (sum, c) => sum + c.quantity);
  double get cartSubtotal => _cart.values.fold(0.0, (sum, c) => sum + c.subtotal);

  Future<void> fetchMarketData() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Logo a seguir a instalar/abrir a app, o Android por vezes ainda não
      // tem a rede/DNS totalmente pronta (SocketException "Failed host
      // lookup" nos primeiros segundos) — sem retry, isto ficava vazio
      // para sempre até o utilizador puxar para actualizar manualmente.
      const maxAttempts = 3;
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          _profiles = await _service.getProfiles();
          final rawProducts = await _service.getProducts();
          // Junta o nome do produtor no cliente (mesma abordagem do site: sem join no Supabase).
          _products = rawProducts
              .map((p) => Product.fromJson(
                    {
                      'id': p.id,
                      'producer_id': p.producerId,
                      'category_id': p.categoryId,
                      'name': p.name,
                      'description': p.description,
                      'price': p.price,
                      'unit': p.unit,
                      'stock': p.stock,
                      'images': p.images,
                      'is_dried': p.isDried,
                    },
                    producerName: profileById(p.producerId)?.fullName,
                  ))
              .toList();
          break;
        } catch (e) {
          if (attempt == maxAttempts) rethrow;
          await Future.delayed(Duration(milliseconds: 700 * attempt));
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Profile? profileById(String id) {
    try {
      return _profiles.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Product? productById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> productsByProducer(String producerId) {
    return _products.where((p) => p.producerId == producerId).toList();
  }

  List<Profile> profilesByRole(String role) => _profiles.where((p) => p.role == role).toList();

  void addToCart(Product product) {
    if (_cart.containsKey(product.id)) {
      _cart[product.id]!.quantity++;
    } else {
      _cart[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    if (_cart.containsKey(productId)) {
      if (_cart[productId]!.quantity > 1) {
        _cart[productId]!.quantity--;
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

  Future<void> createProduct(Product product) async {
    final created = await _service.createProduct(product);
    _products.insert(0, created);
    notifyListeners();
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    final updated = await _service.updateProduct(id, data);
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) _products[index] = updated;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await _service.deleteProduct(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> approveProfile(String id) async {
    await _service.approveProfile(id);
    await fetchMarketData();
  }

  Future<void> updateProfileById(String id, Map<String, dynamic> data) async {
    await _service.updateProfile(id, data);
    await fetchMarketData();
  }
}

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  final SupabaseService _service = sharedSupabaseService;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  List<Order> ordersForBuyer(String buyerId) => _orders.where((o) => o.buyerId == buyerId).toList();

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _service.getOrders();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order> createOrder({
    required String? buyerId,
    required String buyerName,
    required String buyerPhone,
    required List<CartItem> items,
    required String paymentMethod,
    String? province,
    String? district,
  }) async {
    // Mesma protecção usada em fetchMarketData: dados móveis falham mais
    // vezes por instabilidade transitória de rede/DNS do que WiFi/banda larga.
    const maxAttempts = 3;
    Order? order;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        order = await _service.createOrder(
          buyerId: buyerId,
          buyerName: buyerName,
          buyerPhone: buyerPhone,
          items: items,
          paymentMethod: paymentMethod,
          province: province,
          district: district,
        );
        break;
      } catch (e) {
        if (attempt == maxAttempts) rethrow;
        await Future.delayed(Duration(milliseconds: 700 * attempt));
      }
    }
    _orders.insert(0, order!);
    notifyListeners();
    return order;
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _service.updateOrderStatus(id, status);
    await fetchOrders();
  }
}

class RatingsProvider extends ChangeNotifier {
  final LocalStoreService _localStore = sharedLocalStore;
  List<Rating> _ratings = [];

  List<Rating> get ratings => _ratings;

  Future<void> load() async {
    _ratings = await _localStore.getRatings();
    notifyListeners();
  }

  List<Rating> ratingsFor(String targetId) => _ratings.where((r) => r.targetId == targetId).toList();

  double averageFor(String targetId) {
    final list = ratingsFor(targetId);
    if (list.isEmpty) return 0;
    return list.fold(0, (sum, r) => sum + r.stars) / list.length;
  }

  Future<void> addRating(Rating rating) async {
    await _localStore.addRating(rating);
    _ratings.add(rating);
    notifyListeners();
  }
}

class NotificationsProvider extends ChangeNotifier {
  final LocalStoreService _localStore = sharedLocalStore;
  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> load() async {
    _notifications = await _localStore.getNotifications();
    notifyListeners();
  }

  Future<void> notify(String title, String message) async {
    _notifications.insert(
      0,
      AppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        message: message,
        createdAt: DateTime.now(),
      ),
    );
    await _localStore.saveNotifications(_notifications);
    notifyListeners();
  }

  Future<void> markAllRead() async {
    for (final n in _notifications) {
      n.read = true;
    }
    await _localStore.saveNotifications(_notifications);
    notifyListeners();
  }
}

class ExtensionistProvider extends ChangeNotifier {
  final LocalStoreService _localStore = sharedLocalStore;
  List<AssistanceVisit> _visits = [];

  List<AssistanceVisit> get visits => _visits;

  Future<void> load() async {
    _visits = await _localStore.getVisits();
    notifyListeners();
  }

  Future<void> addVisit(AssistanceVisit visit) async {
    await _localStore.addVisit(visit);
    _visits.insert(0, visit);
    notifyListeners();
  }
}

class LanguageProvider extends ChangeNotifier {
  final LocalStoreService _localStore = sharedLocalStore;
  String _lang = 'pt';

  String get lang => _lang;

  Future<void> load() async {
    _lang = await _localStore.getLanguage();
    notifyListeners();
  }

  Future<void> toggle() async {
    _lang = _lang == 'pt' ? 'en' : 'pt';
    await _localStore.setLanguage(_lang);
    notifyListeners();
  }

  String t(String key) => translate(key, _lang);
}

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void goToMarket() => setIndex(1);
}
