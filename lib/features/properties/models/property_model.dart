import 'package:gaza_exchange_app/core/models/user_model.dart';

class PropertyModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String image;
  final String price;
  final String address;
  final String type; // 'buy', 'rent', 'exchange'
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel user;

  PropertyModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.address,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      address: json['address'] ?? '',
      type: json['type'] ?? 'buy',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
      user: json['user'] != null
          ? UserModel.fromJson(json['user'])
          : UserModel(
              id: 0,
              name: 'غير معروف',
              phone: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'image': image,
      'price': price,
      'address': address,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }

  // Helper getters للحقول المحلية
  int get bedrooms => 0; // قيمة افتراضية لأن الـ API لا يدعمها
  int get bathrooms => 0; // قيمة افتراضية لأن الـ API لا يدعمها
  double get area => 0.0; // قيمة افتراضية لأن الـ API لا يدعمها
  String get purpose => type == 'rent'
      ? 'إيجار'
      : type == 'exchange'
          ? 'تبادل'
          : 'بيع';
  String get location => address;
}

class PropertyUserModel {
  final int id;
  final String name;
  final String phone;

  PropertyUserModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory PropertyUserModel.fromJson(Map<String, dynamic> json) {
    return PropertyUserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }
}
