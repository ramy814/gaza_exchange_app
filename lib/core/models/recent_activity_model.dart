class RecentActivityModel {
  final int id;
  final String type; // 'item' or 'property'
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
      price: json['price']?.toString() ?? '0.00',
      status: json['status'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'price': price,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isItem => type == 'item';
  bool get isProperty => type == 'property';
  String get typeText => isItem ? 'سلعة' : 'عقار';

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
