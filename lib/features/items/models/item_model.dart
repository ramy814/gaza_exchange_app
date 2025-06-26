import 'package:gaza_exchange_app/core/models/user_model.dart';

class ItemModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String image;
  final String price;
  final String? exchangeFor;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel user;

  ItemModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    this.exchangeFor,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      exchangeFor: json['exchange_for'],
      status: json['status'] ?? 'available',
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
              name: '',
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
      'exchange_for': exchangeFor,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}
