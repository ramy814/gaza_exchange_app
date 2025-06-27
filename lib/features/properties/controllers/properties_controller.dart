import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../../../core/services/properties_service.dart';

class PropertiesController extends GetxController {
  final PropertiesService _propertiesService = Get.find<PropertiesService>();

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

      final propertiesList = await _propertiesService.getAllProperties();
      properties.value = propertiesList;
      filteredProperties.value = properties;

      print('Loaded ${propertiesList.length} properties');
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
