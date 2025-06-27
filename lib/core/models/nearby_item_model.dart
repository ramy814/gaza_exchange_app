class NearbyItemModel {
  final int id;
  final String title;
  final String price;
  final double distance;
  final NearbyUserModel user;
  final NearbyCategoryModel category;

  NearbyItemModel({
    required this.id,
    required this.title,
    required this.price,
    required this.distance,
    required this.user,
    required this.category,
  });

  factory NearbyItemModel.fromJson(Map<String, dynamic> json) {
    return NearbyItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      distance: json['distance']?.toDouble() ?? 0.0,
      user: json['user'] != null
          ? NearbyUserModel.fromJson(json['user'])
          : NearbyUserModel(id: 0, name: ''),
      category: json['category'] != null
          ? NearbyCategoryModel.fromJson(json['category'])
          : NearbyCategoryModel(id: 0, name: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'distance': distance,
      'user': user.toJson(),
      'category': category.toJson(),
    };
  }

  String get distanceText => '${distance.toStringAsFixed(1)} كم';
}

class NearbyUserModel {
  final int id;
  final String name;

  NearbyUserModel({
    required this.id,
    required this.name,
  });

  factory NearbyUserModel.fromJson(Map<String, dynamic> json) {
    return NearbyUserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class NearbyCategoryModel {
  final int id;
  final String name;

  NearbyCategoryModel({
    required this.id,
    required this.name,
  });

  factory NearbyCategoryModel.fromJson(Map<String, dynamic> json) {
    return NearbyCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class SearchLocationModel {
  final double latitude;
  final double longitude;
  final double radiusKm;

  SearchLocationModel({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });

  factory SearchLocationModel.fromJson(Map<String, dynamic> json) {
    return SearchLocationModel(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      radiusKm: json['radius_km']?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius_km': radiusKm,
    };
  }
}
