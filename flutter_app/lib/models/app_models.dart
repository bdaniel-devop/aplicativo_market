class UserRole {
  static const String buyer = 'comprador';
  static const String seller = 'produtor';
  static const String transporter = 'transportador';
  static const String extensionist = 'extensionista';
  static const String admin = 'administrador';
  static const String strategicPartner = 'parceiro_estrategico';
  static const String other = 'outro';
}

class EntityType {
  static const String individual = 'individual';
  static const String association = 'associacao';
  static const String cooperative = 'cooperativa';
  static const String company = 'empresa';
  static const String ngoIntl = 'ong_internacional';
  static const String other = 'outro';
}

double _parseDouble(dynamic v) {
  if (v == null) return 0.0;
  return double.tryParse(v.toString()) ?? 0.0;
}

int _parseInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

/// Categorias são estáticas no site (constants.tsx) — não existe tabela
/// `categories` no Supabase. `name` aqui é uma chave de tradução (cat_*).
class Category {
  final String id;
  final String name;
  final String icon;

  Category({required this.id, required this.name, required this.icon});
}

/// Espelha a tabela `public.products` do Supabase.
class Product {
  final String id;
  final String producerId;
  final String? producerName; // resolvido no cliente (join com profiles), não é coluna da tabela
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int stock;
  final List<String> images;
  final bool isDried;

  Product({
    required this.id,
    required this.producerId,
    this.producerName,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stock,
    required this.images,
    required this.isDried,
  });

  factory Product.fromJson(Map<String, dynamic> json, {String? producerName}) {
    return Product(
      id: json['id'].toString(),
      producerId: json['producer_id'].toString(),
      producerName: producerName,
      categoryId: (json['category_id'] ?? '1').toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: _parseDouble(json['price']),
      unit: json['unit'] ?? '',
      stock: _parseInt(json['stock']),
      images: List<String>.from(json['images'] ?? []),
      isDried: json['is_dried'] ?? false,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'producer_id': producerId,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'unit': unit,
        'stock': stock,
        'images': images,
        'is_dried': isDried,
      };
}

/// Espelha a tabela `public.profiles` do Supabase (id = auth.users.id).
class Profile {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String commercialPhone;
  final String country;
  final String? province;
  final String? district;
  final String? posto;
  final String? localidade;
  final String role;
  final String entityType;
  final String? entityName;
  final String status;
  final bool isApproved;
  final double balance;
  final List<dynamic> linkedAccounts;

  Profile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    this.commercialPhone = '',
    this.country = 'Moçambique',
    this.province,
    this.district,
    this.posto,
    this.localidade,
    required this.role,
    this.entityType = EntityType.individual,
    this.entityName,
    required this.status,
    required this.isApproved,
    required this.balance,
    this.linkedAccounts = const [],
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      commercialPhone: json['commercial_phone'] ?? '',
      country: json['country'] ?? 'Moçambique',
      province: json['province'],
      district: json['district'],
      posto: json['posto_administrativo'],
      localidade: json['localidade_bairro'],
      role: json['role'] ?? UserRole.buyer,
      entityType: json['entity_type'] ?? EntityType.individual,
      entityName: json['entity_name'],
      status: json['status'] ?? 'offline',
      isApproved: json['isapproved'] ?? false,
      balance: _parseDouble(json['balance']),
      linkedAccounts: json['linked_accounts'] ?? [],
    );
  }
}

/// Linha de encomenda — guardada inline no jsonb `orders.items`
/// (o Supabase deste projecto não tem tabela `order_items`).
class OrderItem {
  final String? productId;
  final String name;
  final double price;
  final int quantity;
  final String unit;

  OrderItem({
    this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id']?.toString(),
      name: json['name'] ?? '',
      price: _parseDouble(json['price']),
      quantity: _parseInt(json['quantity'], 1),
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'name': name,
        'price': price,
        'quantity': quantity,
        'unit': unit,
      };
}

/// Espelha a tabela `public.orders` do Supabase.
class Order {
  final String id;
  final String? buyerId;
  final String buyerName;
  final String buyerPhone;
  final double subtotal;
  final double commission;
  final double total;
  final String status;
  final String paymentMethod;
  final String? province;
  final String? district;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.subtotal,
    required this.commission,
    required this.total,
    required this.status,
    required this.paymentMethod,
    this.province,
    this.district,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      buyerId: json['buyer_id']?.toString(),
      buyerName: json['buyer_name'] ?? '',
      buyerPhone: json['buyer_phone'] ?? '',
      subtotal: _parseDouble(json['subtotal']),
      commission: _parseDouble(json['commission']),
      total: _parseDouble(json['total']),
      status: json['status'] ?? 'pendente',
      paymentMethod: json['payment_method'] ?? '',
      province: json['province'],
      district: json['district'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Snapshot de um produto no carrinho — guarda preço/nome no momento
/// da adição para não depender de o produto continuar disponível.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class Rating {
  final String id;
  final String targetId;
  final String targetName;
  final String authorName;
  final int stars;
  final String comment;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.targetId,
    required this.targetName,
    required this.authorName,
    required this.stars,
    required this.comment,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        id: json['id'],
        targetId: json['targetId'],
        targetName: json['targetName'] ?? '',
        authorName: json['authorName'] ?? '',
        stars: json['stars'] ?? 5,
        comment: json['comment'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetId': targetId,
        'targetName': targetName,
        'authorName': authorName,
        'stars': stars,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.read = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'],
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        read: json['read'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };
}

class AssistanceVisit {
  final String id;
  final String producerName;
  final String type;
  final String district;
  final String notes;
  final DateTime date;

  AssistanceVisit({
    required this.id,
    required this.producerName,
    required this.type,
    required this.district,
    required this.notes,
    required this.date,
  });

  factory AssistanceVisit.fromJson(Map<String, dynamic> json) => AssistanceVisit(
        id: json['id'],
        producerName: json['producerName'] ?? '',
        type: json['type'] ?? '',
        district: json['district'] ?? '',
        notes: json['notes'] ?? '',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'producerName': producerName,
        'type': type,
        'district': district,
        'notes': notes,
        'date': date.toIso8601String(),
      };
}
