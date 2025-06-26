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
    final stats = json['statistics'];
    return StatisticsModel(
      totalItems: stats['total_items'] ?? 0,
      totalProperties: stats['total_properties'] ?? 0,
      availableItems: stats['available_items'] ?? 0,
      soldItems: stats['sold_items'] ?? 0,
      buyProperties: stats['buy_properties'] ?? 0,
      rentProperties: stats['rent_properties'] ?? 0,
      recentItems30Days: stats['recent_items_30_days'] ?? 0,
      recentProperties30Days: stats['recent_properties_30_days'] ?? 0,
      totalItemsValue: stats['total_items_value'] ?? '0.00',
      totalPropertiesValue: stats['total_properties_value'] ?? '0.00',
      totalValue: stats['total_value'] ?? '0.00',
    );
  }
}
