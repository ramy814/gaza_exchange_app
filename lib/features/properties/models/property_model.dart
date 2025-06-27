class PropertyModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String? image;
  final double price;
  final String address;
  final String type; // 'buy', 'rent', 'exchange'
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PropertyUserModel? user;

  PropertyModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.image,
    required this.price,
    required this.address,
    required this.type,
    this.latitude,
    this.longitude,
    this.locationName,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    print(
        '🔧 Parsing PropertyModel from JSON: ${json.toString().length > 200 ? json.toString().substring(0, 200) + '...' : json}');
    print('🖼️ Property image field from API: ${json['image']}');
    print('🖼️ Property image field type: ${json['image']?.runtimeType}');

    try {
      return PropertyModel(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? 0,
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        image: json['image'],
        price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
        address: json['address'] ?? '',
        type: json['type'] ?? '',
        latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
        longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
        locationName: json['location_name'],
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
      print('❌ Error parsing PropertyModel: $e');
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
      'address': address,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
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
  String get location => locationName ?? address;
  bool get hasLocation => latitude != null && longitude != null;

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
