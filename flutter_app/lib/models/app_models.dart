class UserRole {
  static const String buyer = 'comprador';
  static const String seller = 'produtor';
  static const String transporter = 'transportador';
  static const String extensionist = 'extensionista';
  static const String admin = 'administrador';
  static const String strategicPartner = 'parceiro_estrategico';
}

class Category {
  final String id;
  final String name;
  final String icon;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'],
      icon: json['icon'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}

class Product {
  final String id;
  final String producerId;
  final String? producerName;
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      producerId: json['producer'].toString(),
      producerName: json['producer_name'],
      categoryId: json['category'].toString(),
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      unit: json['unit'],
      stock: json['stock'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      isDried: json['is_dried'] ?? false,
    );
  }
}

class Profile {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String role;
  final String status;
  final bool isApproved;
  final double balance;
  final String? entityName;
  final String? logo;

  Profile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.status,
    required this.isApproved,
    required this.balance,
    this.entityName,
    this.logo,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'].toString(),
      email: json['user']['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      role: json['role'],
      status: json['status'],
      isApproved: json['is_approved'] ?? false,
      balance: double.parse(json['balance'].toString()),
      entityName: json['entity_name'],
      logo: json['logo'],
    );
  }
}
