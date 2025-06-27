class StatisticsModel {
  final int totalItems;
  final int totalProperties;
  final int availableItems;
  final int soldItems;
  final int buyProperties;
  final int rentProperties;
  final int recentItems30Days;
  final int recentProperties30Days;
  final String totalItemsValue;
  final String totalPropertiesValue;
  final String totalValue;

  StatisticsModel({
    required this.totalItems,
    required this.totalProperties,
    required this.availableItems,
    required this.soldItems,
    required this.buyProperties,
    required this.rentProperties,
    required this.recentItems30Days,
    required this.recentProperties30Days,
    required this.totalItemsValue,
    required this.totalPropertiesValue,
    required this.totalValue,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalItems: json['total_items'] ?? 0,
      totalProperties: json['total_properties'] ?? 0,
      availableItems: json['available_items'] ?? 0,
      soldItems: json['sold_items'] ?? 0,
      buyProperties: json['buy_properties'] ?? 0,
      rentProperties: json['rent_properties'] ?? 0,
      recentItems30Days: json['recent_items_30_days'] ?? 0,
      recentProperties30Days: json['recent_properties_30_days'] ?? 0,
      totalItemsValue: json['total_items_value']?.toString() ?? '0.00',
      totalPropertiesValue:
          json['total_properties_value']?.toString() ?? '0.00',
      totalValue: json['total_value']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_items': totalItems,
      'total_properties': totalProperties,
      'available_items': availableItems,
      'sold_items': soldItems,
      'buy_properties': buyProperties,
      'rent_properties': rentProperties,
      'recent_items_30_days': recentItems30Days,
      'recent_properties_30_days': recentProperties30Days,
      'total_items_value': totalItemsValue,
      'total_properties_value': totalPropertiesValue,
      'total_value': totalValue,
    };
  }
}
