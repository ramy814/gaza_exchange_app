import 'package:get/get.dart';
import 'package:gaza_exchange_app/core/services/api_service.dart';
import 'package:gaza_exchange_app/features/properties/models/property_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PropertiesController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = true.obs;
  final properties = <PropertyModel>[].obs;
  final filteredProperties = <PropertyModel>[].obs;
  final selectedType = 'الكل'.obs;
  final searchQuery = ''.obs;

  final List<String> propertyTypes = ['الكل', 'للبيع', 'للإيجار'];

  @override
  void onInit() {
    super.onInit();
    loadProperties();
  }

  Future<void> loadProperties() async {
    try {
      isLoading.value = true;

      final response = await _apiService.getAllProperties();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        properties.value =
            data.map((json) => PropertyModel.fromJson(json)).toList();
        filteredProperties.value = properties;
      } else {
        Get.snackbar(
          'خطأ',
          'فشل في تحميل العقارات',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error loading properties: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في تحميل العقارات: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProperties() async {
    await loadProperties();
  }

  void searchProperties(String query) {
    searchQuery.value = query;
    _filterProperties();
  }

  void filterByType(String type) {
    selectedType.value = type;
    _filterProperties();
  }

  void _filterProperties() {
    List<PropertyModel> filtered = properties;

    // Filter by type
    if (selectedType.value != 'الكل') {
      String typeFilter = selectedType.value == 'للبيع' ? 'buy' : 'rent';
      filtered =
          filtered.where((property) => property.type == typeFilter).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where((property) =>
              property.title
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              property.description
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              property.address
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    filteredProperties.value = filtered;
  }

  void goToPropertyDetail(int propertyId) {
    Get.toNamed('/property-detail/$propertyId');
  }
}
