import 'package:gaza_exchange_app/core/services/api_service.dart';
import 'package:gaza_exchange_app/core/utils/api_config.dart';
import 'package:gaza_exchange_app/core/utils/validators.dart';
import 'dart:developer' as developer;

class PropertyModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String? image;
  final List<PropertyImageModel> images;
  final double price;
  final String address;
  final String type; // 'buy', 'rent', 'exchange'
  final int bedrooms;
  final int bathrooms;
  final double area;
  final String status; // 'available', 'sold', 'rented'
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PropertyUserModel? user;

  PropertyModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.image,
    this.images = const [],
    required this.price,
    required this.address,
    required this.type,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.status,
    this.latitude,
    this.longitude,
    this.locationName,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    developer.log(
        '🔧 Parsing PropertyModel from JSON: ${json.toString().length > 200 ? '${json.toString().substring(0, 200)}...' : json}',
        name: 'PropertyModel');
    developer.log('🖼️ Property image field from API: ${json['image']}',
        name: 'PropertyModel');
    developer.log('🖼️ Property images field from API: ${json['images']}',
        name: 'PropertyModel');

    try {
      // Parse images array if available
      List<PropertyImageModel> images = [];
      if (json['images'] != null && json['images'] is List) {
        for (var imageItem in json['images']) {
          if (imageItem is String) {
            // Handle simple string format: ["image1.jpg", "image2.jpg"]
            images.add(PropertyImageModel(
              id: 0, // Default ID for string format
              propertyId: json['id'] ?? 0,
              image: imageItem,
            ));
          } else if (imageItem is Map<String, dynamic>) {
            // Handle object format: [{"id": 1, "image": "image1.jpg"}]
            images.add(PropertyImageModel.fromJson(imageItem));
          }
        }
      }

      return PropertyModel(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? 0,
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        image: json['image'],
        images: images,
        price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
        address: json['address'] ?? '',
        type: json['type'] ?? '',
        bedrooms: json['bedrooms'] ?? 0,
        bathrooms: json['bathrooms'] ?? 0,
        area: double.tryParse(json['area']?.toString() ?? '0') ?? 0.0,
        status: json['status'] ?? 'available',
        latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
        longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
        locationName: json['location_name'],
        phone: json['phone'],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'])
            : null,
        user: json['user'] != null
            ? PropertyUserModel.fromJson(json['user'])
            : null,
      );
    } catch (e, stackTrace) {
      developer.log('❌ Error parsing PropertyModel: $e', name: 'PropertyModel');
      developer.log('❌ JSON data: $json', name: 'PropertyModel');
      developer.log('❌ Error stack trace: $stackTrace', name: 'PropertyModel');
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
      'address': address,
      'type': type,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
    };
  }

  // Helper getters للحقول المحلية
  String get purpose => Validators.convertPropertyTypeToArabic(type);
  String get location => locationName ?? address;
  bool get hasLocation => latitude != null && longitude != null;
  bool get hasImages => images.isNotEmpty;

  // Get full image URL (for backward compatibility)
  String? get fullImageUrl {
    if (image == null || image!.isEmpty) return null;

    // If image is already a full URL, return it as is
    if (image!.startsWith('http://') || image!.startsWith('https://')) {
      developer.log('🖼️ Property: Using full URL: $image',
          name: 'PropertyModel');
      return image;
    }

    // If image is a relative path, combine with storage URL
    // Remove leading slash if present
    String imagePath = image!.startsWith('/') ? image!.substring(1) : image!;

    // Combine with storage URL
    String fullUrl = '${ApiConfig.storageUrl}$imagePath';
    developer.log('🖼️ Property: Original image: $image',
        name: 'PropertyModel');
    developer.log('🖼️ Property: Image path: $imagePath',
        name: 'PropertyModel');
    developer.log('🖼️ Property: Storage URL: ${ApiConfig.storageUrl}',
        name: 'PropertyModel');
    developer.log('🖼️ Property: Full URL: $fullUrl', name: 'PropertyModel');

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

  // Get formatted price in Arabic numbers
  String get formattedPrice =>
      Validators.convertEnglishToArabicNumbers(price.toStringAsFixed(2));

  // Get formatted phone number in Arabic numbers
  String? get formattedPhone {
    if (phone == null || phone!.isEmpty) return null;
    return Validators.convertEnglishToArabicNumbers(phone!);
  }
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

  // Get formatted phone number in Arabic numbers
  String get formattedPhone => Validators.convertEnglishToArabicNumbers(phone);
}

// نموذج لصورة العقار
class PropertyImageModel {
  final int id;
  final int propertyId;
  final String image;
  final String? imageUrl; // المسار الكامل من API
  final DateTime? createdAt;

  PropertyImageModel({
    required this.id,
    required this.propertyId,
    required this.image,
    this.imageUrl,
    this.createdAt,
  });

  factory PropertyImageModel.fromJson(Map<String, dynamic> json) {
    return PropertyImageModel(
      id: json['id'] ?? 0,
      propertyId: json['property_id'] ?? 0,
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
      'property_id': propertyId,
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
    String imagePath =
        image.startsWith('/') ? image : '/storage/properties/$image';
    return ApiService().getImageApiUrl(imagePath);
  }
}
