import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';

/// Acesso ao mesmo projecto Supabase que o site agrosuste_market usa.
/// Espelha os padrões de `lib/supabase.ts` + `App.tsx` + `pages/Auth.tsx`
/// do site: `select('*')` simples com filtragem/joins feitos no cliente,
/// RPCs `get_email_by_phone`/`get_all_profiles`/`approve_profile`.
class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  static const _adminEmails = ['jaimecebola001@gmail.com', 'brestondaniel@gmail.com'];

  // ---- Auth ----

  Session? get currentSession => _client.auth.currentSession;

  /// Regista o utilizador (Supabase Auth) e cria a linha em `profiles`,
  /// tal como o site faz (signUp + upsert manual, sem confiar só no
  /// trigger `handle_new_user`). Termina sempre com signOut, porque o
  /// projecto exige confirmação de email antes do primeiro login.
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    required String entityType,
    String? entityName,
    String? province,
    String? district,
    String? posto,
    String? localidade,
  }) async {
    final isAdmin = _adminEmails.contains(email.toLowerCase());
    final metadata = {
      'full_name': fullName,
      'role': isAdmin ? UserRole.admin : role,
      'country': 'Moçambique',
      'phone': phone,
      'commercial_phone': '',
      'entity_type': entityType,
      'entity_name': entityType == EntityType.individual ? fullName : (entityName ?? fullName),
      'province': province,
      'district': district,
      'posto_administrativo': posto,
      'localidade_bairro': localidade,
      'isapproved': isAdmin,
    };

    final res = await _client.auth.signUp(email: email, password: password, data: metadata);
    final user = res.user;
    if (user == null) {
      throw Exception('Não foi possível criar a conta.');
    }

    await _client.from('profiles').upsert({
      'id': user.id,
      'email': email,
      ...metadata,
      'status': 'offline',
      'balance': 0,
      'linked_accounts': [],
    }, onConflict: 'id');

    await _client.auth.signOut();
  }

  /// Login por email ou telefone (resolve telefone→email via RPC
  /// `get_email_by_phone`, mesmo nome/parâmetro usado pelo site).
  Future<Profile> login(String identifier, String password) async {
    String email = identifier.trim().toLowerCase();
    if (!email.contains('@')) {
      final bareDigits = identifier.replaceAll(RegExp(r'\D'), '');
      final found = await _client.rpc('get_email_by_phone', params: {'p_phone': bareDigits});
      if (found == null || (found is String && found.isEmpty)) {
        throw Exception('Não encontrámos nenhuma conta com este telefone (procurámos por "$bareDigits").');
      }
      email = (found as String).toLowerCase();
    }

    try {
      final res = await _client.auth.signInWithPassword(email: email, password: password);
      final user = res.user;
      if (user == null) {
        throw Exception('Credenciais inválidas.');
      }
      return await getProfile(user.id);
    } on AuthException catch (e) {
      // Propaga a mensagem real do Supabase (ex: "Invalid login credentials",
      // "Email not confirmed") em vez de a esconder — essencial para
      // perceber PORQUE falhou, já que a conta já existe no Supabase.
      throw Exception('Supabase: ${e.message}');
    }
  }

  Future<void> logout() => _client.auth.signOut();

  Future<Profile> getProfile(String userId) async {
    final row = await _client.from('profiles').select().eq('id', userId).single();
    return Profile.fromJson(row);
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await _client.from('profiles').update(data).eq('id', userId);
  }

  // ---- Catalog ----

  Future<List<Product>> getProducts() async {
    final rows = await _client.from('products').select().order('created_at', ascending: false);
    return (rows as List).map((r) => Product.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<List<Profile>> getProfiles() async {
    final rows = await _client.from('profiles').select();
    return (rows as List).map((r) => Profile.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<Product> createProduct(Product product) async {
    final row = await _client.from('products').insert(product.toInsertJson()).select().single();
    return Product.fromJson(row);
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> data) async {
    final row = await _client.from('products').update(data).eq('id', id).select().single();
    return Product.fromJson(row);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  Future<String> uploadProductImage(Uint8List bytes, String fileName) async {
    final path = 'products/$fileName';
    await _client.storage.from('product-images').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
    return _client.storage.from('product-images').getPublicUrl(path);
  }

  // ---- Orders ----

  Future<Order> createOrder({
    required String? buyerId,
    required String buyerName,
    required String buyerPhone,
    required List<CartItem> items,
    required String paymentMethod,
    String? province,
    String? district,
  }) async {
    final subtotal = items.fold(0.0, (sum, i) => sum + i.subtotal);
    const commissionRate = 0.05;
    final commission = subtotal * commissionRate;
    final total = subtotal + commission;

    final row = await _client
        .from('orders')
        .insert({
          'buyer_id': buyerId,
          'buyer_name': buyerName,
          'buyer_phone': buyerPhone,
          'items': items
              .map((i) => {
                    'product_id': i.product.id,
                    'name': i.product.name,
                    'price': i.product.price,
                    'quantity': i.quantity,
                    'unit': i.product.unit,
                  })
              .toList(),
          'subtotal': subtotal,
          'commission': commission,
          'total': total,
          'payment_method': paymentMethod,
          'province': province,
          'district': district,
        })
        .select()
        .single();
    return Order.fromJson(row);
  }

  Future<List<Order>> getOrders() async {
    final rows = await _client.from('orders').select().order('created_at', ascending: false);
    return (rows as List).map((r) => Order.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _client.from('orders').update({'status': status}).eq('id', id);
  }

  // ---- Admin ----

  Future<List<Profile>> adminGetAllProfiles() async {
    final rows = await _client.rpc('get_all_profiles');
    return (rows as List).map((r) => Profile.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<void> approveProfile(String userId) async {
    await _client.rpc('approve_profile', params: {'target_user_id': userId});
  }
}
