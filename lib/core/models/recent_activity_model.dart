class RecentActivityModel {
  final int id;
  final String type;
  final String title;
  final String price;
  final String status;
  final DateTime createdAt;

  RecentActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? '0.00',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get typeInArabic {
    switch (type) {
      case 'item':
        return 'سلعة';
      case 'property':
        return 'عقار';
      default:
        return type;
    }
  }

  String get statusInArabic {
    switch (status) {
      case 'available':
        return 'متاح';
      case 'sold':
        return 'مباع';
      case 'buy':
        return 'للبيع';
      case 'rent':
        return 'للإيجار';
      default:
        return status;
    }
  }
}
