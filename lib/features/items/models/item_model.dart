import 'package:gaza_exchange_app/core/models/category_model.dart';
import 'package:gaza_exchange_app/core/services/api_service.dart';
import 'package:gaza_exchange_app/core/utils/api_config.dart';
import 'package:gaza_exchange_app/core/utils/validators.dart';
import 'dart:developer' as developer;

class ItemModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String? image;
  final List<ItemImageModel> images;
  final double price;
  final String? exchangeFor;
  final String status;
  final int? categoryId;
  final int? subcategoryId;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? phone;
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
    this.images = const [],
    required this.price,
    this.exchangeFor,
    required this.status,
    this.categoryId,
    this.subcategoryId,
    this.latitude,
    this.longitude,
    this.locationName,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.category,
    this.subcategory,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    developer.log(
        '🔧 Parsing ItemModel from JSON: ${json.toString().length > 200 ? '${json.toString().substring(0, 200)}...' : json}',
        name: 'ItemModel');
    developer.log('🖼️ Item image field from API: ${json['image']}',
        name: 'ItemModel');
    developer.log('🖼️ Item images field from API: ${json['images']}',
        name: 'ItemModel');

    try {
      // Parse images array if available
      List<ItemImageModel> images = [];
      if (json['images'] != null && json['images'] is List) {
        images = (json['images'] as List)
            .map((imageJson) => ItemImageModel.fromJson(imageJson))
            .toList();
      }

      return ItemModel(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? 0,
        categoryId: json['category_id'] ?? 0,
        subcategoryId: json['subcategory_id'],
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        image: json['image'],
        images: images,
        price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
        exchangeFor: json['exchange_for'],
        status: json['status'] ?? 'available',
        latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
        longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
        locationName: json['location_name'] ?? '',
        phone: json['phone'],
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
      developer.log('❌ Error parsing ItemModel: $e', name: 'ItemModel');
      developer.log('❌ JSON data: $json', name: 'ItemModel');
      developer.log('❌ Error stack trace: $stackTrace', name: 'ItemModel');
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
      'images': images.map((image) => image.toJson()).toList(),
      'price': price.toString(),
      'exchange_for': exchangeFor,
      'status': status,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'phone': phone,
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
  bool get hasImages => images.isNotEmpty;

  // Get full image URL (for backward compatibility)
  String? get fullImageUrl {
    if (image == null || image!.isEmpty) return null;

    // If image is already a full URL, return it as is
    if (image!.startsWith('http://') || image!.startsWith('https://')) {
      developer.log('🖼️ Item: Using full URL: $image', name: 'ItemModel');
      return image;
    }

    // If image is a relative path, combine with storage URL
    // Remove leading slash if present
    String imagePath = image!.startsWith('/') ? image!.substring(1) : image!;

    // Combine with storage URL
    String fullUrl = '${ApiConfig.storageUrl}$imagePath';
    developer.log('🖼️ Item: Original image: $image', name: 'ItemModel');
    developer.log('🖼️ Item: Image path: $imagePath', name: 'ItemModel');
    developer.log('🖼️ Item: Storage URL: ${ApiConfig.storageUrl}',
        name: 'ItemModel');
    developer.log('🖼️ Item: Full URL: $fullUrl', name: 'ItemModel');

    return fullUrl;
  }

  // Get first image URL from images array
  String? get firstImageUrl {
    if (images.isNotEmpty) {
      return images.first.fullImageUrl;
    }
    return fullImageUrl; // fallback to old image field
  }

  // Get all image URLs
  List<String> get allImageUrls {
    List<String> urls = [];

    // Add URLs from images array
    for (var image in images) {
      if (image.fullImageUrl != null) {
        urls.add(image.fullImageUrl!);
      }
    }

    // Add old image field if no images in array
    if (urls.isEmpty && fullImageUrl != null) {
      urls.add(fullImageUrl!);
    }

    return urls;
  }

  // Get Arabic status for display
  String get arabicStatus => Validators.convertItemStatusToArabic(status);

  // Get formatted price in Arabic numbers
  String get formattedPrice =>
      Validators.convertEnglishToArabicNumbers(price.toStringAsFixed(2));

  // Get formatted phone number in Arabic numbers
  String? get formattedPhone {
    if (phone == null || phone!.isEmpty) return null;
    return Validators.convertEnglishToArabicNumbers(phone!);
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

  // Get formatted phone number in Arabic numbers
  String get formattedPhone => Validators.convertEnglishToArabicNumbers(phone);
}

// نموذج لصورة السلعة
class ItemImageModel {
  final int id;
  final int itemId;
  final String image;
  final String? imageUrl; // المسار الكامل من API
  final DateTime? createdAt;

  ItemImageModel({
    required this.id,
    required this.itemId,
    required this.image,
    this.imageUrl,
    this.createdAt,
  });

  factory ItemImageModel.fromJson(Map<String, dynamic> json) {
    return ItemImageModel(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      image: json['image'] ?? '',
      imageUrl: json['image_url'], // استخدام المسار من API
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'image': image,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Get full image URL through API endpoint
  String? get fullImageUrl {
    // إذا كان API يرجع image_url، استخدمه عبر API endpoint
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // استخدام API endpoint للحصول على الصورة بشكل آمن
      return ApiService().getImageApiUrl(imageUrl!);
    }

    // fallback للطريقة القديمة
    if (image.isEmpty) return null;

    // If image is already a full URL, return it as is
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    // استخدام API endpoint للصور القديمة أيضاً
    String imagePath = image.startsWith('/') ? image : '/storage/items/$image';
    return ApiService().getImageApiUrl(imagePath);
  }
}
