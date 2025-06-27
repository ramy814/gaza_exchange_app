class UserModel {
  final int id;
  final String name;
  final String phone;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<UserItemModel>? items;
  final List<UserPropertyModel>? properties;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.createdAt,
    required this.updatedAt,
    this.items,
    this.properties,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      locationName: json['location_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items: json['items'] != null
          ? List<UserItemModel>.from(
              json['items'].map((x) => UserItemModel.fromJson(x)))
          : null,
      properties: json['properties'] != null
          ? List<UserPropertyModel>.from(
              json['properties'].map((x) => UserPropertyModel.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items?.map((x) => x.toJson()).toList(),
      'properties': properties?.map((x) => x.toJson()).toList(),
    };
  }

  bool get hasLocation => latitude != null && longitude != null;
}

// نموذج مبسط للسلع في الملف الشخصي
class UserItemModel {
  final int id;
  final String title;
  final String price;
  final String status;

  UserItemModel({
    required this.id,
    required this.title,
    required this.price,
    required this.status,
  });

  factory UserItemModel.fromJson(Map<String, dynamic> json) {
    return UserItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      status: json['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'status': status,
    };
  }
}

// نموذج مبسط للعقارات في الملف الشخصي
class UserPropertyModel {
  final int id;
  final String title;
  final String price;
  final String type;

  UserPropertyModel({
    required this.id,
    required this.title,
    required this.price,
    required this.type,
  });

  factory UserPropertyModel.fromJson(Map<String, dynamic> json) {
    return UserPropertyModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      type: json['type'] ?? 'buy',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'type': type,
    };
  }
}
