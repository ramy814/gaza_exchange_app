import 'package:gaza_exchange_app/core/models/category_model.dart';

class ItemModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String? image;
  final double price;
  final String? exchangeFor;
  final String status;
  final int? categoryId;
  final int? subcategoryId;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ItemUserModel? user;
  final CategoryModel? category;
  final CategoryModel? subcategory;

  ItemModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.image,
    required this.price,
    this.exchangeFor,
    required this.status,
    this.categoryId,
    this.subcategoryId,
    this.latitude,
    this.longitude,
    this.locationName,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.category,
    this.subcategory,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    print(
        '🔧 Parsing ItemModel from JSON: ${json.toString().length > 200 ? json.toString().substring(0, 200) + '...' : json}');
    print('🖼️ Item image field from API: ${json['image']}');
    print('🖼️ Item image field type: ${json['image']?.runtimeType}');

    try {
      return ItemModel(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? 0,
        categoryId: json['category_id'] ?? 0,
        subcategoryId: json['subcategory_id'],
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        image: json['image'],
        price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
        exchangeFor: json['exchange_for'],
        status: json['status'] ?? 'available',
        latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
        longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
        locationName: json['location_name'] ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'])
            : null,
        user:
            json['user'] != null ? ItemUserModel.fromJson(json['user']) : null,
        category: json['category'] != null
            ? CategoryModel.fromJson(json['category'])
            : null,
        subcategory: json['subcategory'] != null
            ? CategoryModel.fromJson(json['subcategory'])
            : null,
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing ItemModel: $e');
      print('❌ JSON data: $json');
      print('❌ Error stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'image': image,
      'price': price.toString(),
      'exchange_for': exchangeFor,
      'status': status,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
      'category': category?.toJson(),
      'subcategory': subcategory?.toJson(),
    };
  }

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasCategory => categoryId != null;
  bool get hasSubcategory => subcategoryId != null;

  // Get full image URL
  String? get fullImageUrl {
    if (image == null || image!.isEmpty) return null;

    // If image is already a full URL, return it as is
    if (image!.startsWith('http://') || image!.startsWith('https://')) {
      return image;
    }

    // If image is a relative path, combine with base URL
    // Remove leading slash if present
    String imagePath = image!.startsWith('/') ? image!.substring(1) : image!;

    // Combine with base URL (adjust this according to your API base URL)
    return 'http://localhost:8000/storage/$imagePath';
  }
}

// نموذج مبسط للمستخدم في السلع
class ItemUserModel {
  final int id;
  final String name;
  final String phone;

  ItemUserModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory ItemUserModel.fromJson(Map<String, dynamic> json) {
    return ItemUserModel(
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
