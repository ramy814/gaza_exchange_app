import 'package:get/get.dart';
import 'package:gaza_exchange_app/core/services/api_service.dart';
import 'package:gaza_exchange_app/core/models/user_model.dart';
import 'package:gaza_exchange_app/features/items/models/item_model.dart';
import 'package:gaza_exchange_app/features/properties/models/property_model.dart';
import 'package:flutter/foundation.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = true.obs;
  final user = Rxn<UserModel>();
  final userItems = <ItemModel>[].obs;
  final userProperties = <PropertyModel>[].obs;
  final itemsCount = 0.obs;
  final propertiesCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;

      final response = await _apiService.getUserProfile();
      if (response.statusCode == 200) {
        final data = response.data;
        // استخراج بيانات المستخدم من البنية الجديدة أو القديمة
        dynamic userData;
        if (data['data'] != null && data['data']['user'] != null) {
          userData = data['data']['user'];
        } else if (data['user'] != null) {
          userData = data['user'];
        } else {
          userData = null;
        }
        if (userData != null) {
          user.value = UserModel.fromJson(userData);

          // Set items
          if (userData['items'] != null) {
            final List<dynamic> items = userData['items'];
            userItems.value =
                items.map((item) => ItemModel.fromJson(item)).toList();
          }

          // Set properties
          if (userData['properties'] != null) {
            final List<dynamic> properties = userData['properties'];
            userProperties.value = properties
                .map((property) => PropertyModel.fromJson(property))
                .toList();
          }
        }

        // Set counts (من البنية الجديدة أو القديمة)
        if (data['data'] != null) {
          itemsCount.value = data['data']['items_count'] ?? 0;
          propertiesCount.value = data['data']['properties_count'] ?? 0;
        } else {
          itemsCount.value = data['items_count'] ?? 0;
          propertiesCount.value = data['properties_count'] ?? 0;
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  void goToAddItem() {
    Get.toNamed('/add-item');
  }

  void goToAddProperty() {
    Get.toNamed('/add-property');
  }

  void goToItemDetail(int itemId) {
    Get.toNamed('/item-detail/$itemId');
  }

  void goToPropertyDetail(int propertyId) {
    Get.toNamed('/property-detail/$propertyId');
  }
}
