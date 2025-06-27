import 'package:get/get.dart';
import 'package:gaza_exchange_app/core/services/api_service.dart';
import 'package:gaza_exchange_app/core/services/items_service.dart';
import 'package:gaza_exchange_app/core/services/properties_service.dart';
import 'package:gaza_exchange_app/core/models/user_model.dart';
import 'package:gaza_exchange_app/core/models/statistics_model.dart';
import 'package:gaza_exchange_app/core/models/recent_activity_model.dart';
import 'package:gaza_exchange_app/features/items/models/item_model.dart';
import 'package:gaza_exchange_app/features/properties/models/property_model.dart';
import 'package:flutter/foundation.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ItemsService _itemsService = Get.find<ItemsService>();
  final PropertiesService _propertiesService = Get.find<PropertiesService>();

  // Observable variables
  final isLoading = true.obs;
  final user = Rxn<UserModel>();
  final statistics = Rxn<StatisticsModel>();
  final recentActivity = <RecentActivityModel>[].obs;
  final trendingItems = <ItemModel>[].obs;
  final recentProperties = <PropertyModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;

      // Load all data concurrently
      await Future.wait([
        loadUserProfile(),
        loadStatistics(),
        loadRecentActivity(),
        loadTrendingItems(),
        loadRecentProperties(),
      ]);
    } catch (e) {
      debugPrint('Error loading home data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserProfile() async {
    try {
      final response = await _apiService.getUserProfile();
      if (response.statusCode == 200) {
        user.value = UserModel.fromJson(response.data['user']);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> loadStatistics() async {
    try {
      final response = await _apiService.getUserStatistics();
      if (response.statusCode == 200) {
        statistics.value = StatisticsModel.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  Future<void> loadRecentActivity() async {
    try {
      final response = await _apiService.getUserRecentActivity();
      if (response.statusCode == 200) {
        final List<dynamic> activities = response.data['recent_activity'];
        recentActivity.value = activities
            .map((activity) => RecentActivityModel.fromJson(activity))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading recent activity: $e');
    }
  }

  Future<void> loadTrendingItems() async {
    try {
      print('🔥 Starting to load trending items...');
      final items = await _itemsService.getTrendingItems();
      trendingItems.value = items;
      print('✅ Successfully loaded ${items.length} trending items');

      // طباعة تفاصيل السلع الرائجة للتحقق
      for (int i = 0; i < items.length; i++) {
        print(
            '📋 Trending Item ${i + 1}: ID=${items[i].id}, Title=${items[i].title}, Price=${items[i].price}');
      }
    } catch (e) {
      print('💥 Error loading trending items: $e');
      print('💥 Error stack trace: ${StackTrace.current}');
    }
  }

  Future<void> loadRecentProperties() async {
    try {
      final properties = await _propertiesService.getAllProperties();
      // Take only the first 5 properties for recent display
      recentProperties.value = properties.take(5).toList();
      debugPrint('Loaded ${properties.length} recent properties');
    } catch (e) {
      debugPrint('Error loading recent properties: $e');
    }
  }

  Future<void> refreshData() async {
    await loadHomeData();
  }

  // Navigation methods
  void goToItems() {
    Get.toNamed('/items');
  }

  void goToProperties() {
    Get.toNamed('/properties');
  }

  void goToAddItem() {
    Get.toNamed('/add-item');
  }

  void goToAddProperty() {
    Get.toNamed('/add-property');
  }

  void goToProfile() {
    Get.toNamed('/profile');
  }

  void goToItemDetail(int itemId) {
    Get.toNamed('/item-detail/$itemId');
  }

  void goToPropertyDetail(int propertyId) {
    Get.toNamed('/property-detail/$propertyId');
  }
}
