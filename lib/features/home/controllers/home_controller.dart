import 'package:get/get.dart';
import 'package:gaza_exchange_app/core/services/api_service.dart';
import 'package:gaza_exchange_app/core/models/user_model.dart';
import 'package:gaza_exchange_app/core/models/statistics_model.dart';
import 'package:gaza_exchange_app/core/models/recent_activity_model.dart';
import 'package:gaza_exchange_app/features/items/models/item_model.dart';
import 'package:flutter/foundation.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Observable variables
  final isLoading = true.obs;
  final user = Rxn<UserModel>();
  final statistics = Rxn<StatisticsModel>();
  final recentActivity = <RecentActivityModel>[].obs;
  final trendingItems = <ItemModel>[].obs;

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
      final response = await _apiService.getTrendingItems();
      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['trending_items'];
        trendingItems.value =
            items.map((item) => ItemModel.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading trending items: $e');
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
}
