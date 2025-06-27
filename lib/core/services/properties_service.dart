import 'package:get/get.dart';
import 'package:gaza_exchange_app/features/properties/models/property_model.dart';
import 'api_service.dart';

class PropertiesService extends GetxService {
  static PropertiesService get to => Get.find();

  final ApiService _apiService = Get.find<ApiService>();

  // عرض جميع العقارات
  Future<List<PropertyModel>> getAllProperties({
    String? type,
    double? minPrice,
    double? maxPrice,
    String? search,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (search != null) queryParams['search'] = search;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radius != null) queryParams['radius'] = radius;

      print('Fetching properties with params: $queryParams');
      final response =
          await _apiService.getAllProperties(queryParameters: queryParams);

      print('Properties response status: ${response.statusCode}');
      print('Properties response data: ${response.data}');

      if (response.statusCode == 200) {
        final propertiesData = response.data as List;
        final List<PropertyModel> properties = [];

        for (int i = 0; i < propertiesData.length; i++) {
          try {
            final property = PropertyModel.fromJson(propertiesData[i]);
            properties.add(property);
            print('✅ Successfully parsed property ${i + 1}: ${property.title}');
          } catch (e) {
            print('❌ Error parsing property ${i + 1}: $e');
            print('❌ Property data: ${propertiesData[i]}');
            // Continue with next property instead of failing completely
          }
        }

        print(
            '🎯 Successfully parsed ${properties.length} out of ${propertiesData.length} properties');
        return properties;
      }
      return [];
    } catch (e) {
      print('Error getting all properties: $e');
      return [];
    }
  }

  // عرض عقار محدد
  Future<PropertyModel?> getProperty(int id) async {
    try {
      final response = await _apiService.getProperty(id);
      if (response.statusCode == 200) {
        return PropertyModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error getting property: $e');
      return null;
    }
  }

  // إضافة عقار جديد
  Future<PropertyModel?> createProperty(
      Map<String, dynamic> data, String? imagePath) async {
    try {
      final formData = await _apiService.uploadFile(
        'properties',
        filePath: imagePath ?? '',
        fieldName: 'image',
        additionalData: data,
      );

      if (formData.statusCode == 201) {
        final propertyData = formData.data['property'];
        return PropertyModel.fromJson(propertyData);
      }
      return null;
    } catch (e) {
      print('Error creating property: $e');
      return null;
    }
  }

  // تحديث عقار
  Future<PropertyModel?> updateProperty(
      int id, Map<String, dynamic> data, String? imagePath) async {
    try {
      final formData = await _apiService.uploadFile(
        'properties/$id',
        filePath: imagePath ?? '',
        fieldName: 'image',
        additionalData: data,
      );

      if (formData.statusCode == 200) {
        final propertyData = formData.data['property'];
        return PropertyModel.fromJson(propertyData);
      }
      return null;
    } catch (e) {
      print('Error updating property: $e');
      return null;
    }
  }

  // حذف عقار
  Future<bool> deleteProperty(int id) async {
    try {
      final response = await _apiService.deleteProperty(id);
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting property: $e');
      return false;
    }
  }

  // Search properties by text
  Future<List<PropertyModel>> searchProperties(String query) async {
    return await getAllProperties(search: query);
  }

  // Filter properties by type
  Future<List<PropertyModel>> getPropertiesByType(String type) async {
    return await getAllProperties(type: type);
  }

  // Filter properties by price range
  Future<List<PropertyModel>> getPropertiesByPriceRange({
    required double minPrice,
    required double maxPrice,
  }) async {
    return await getAllProperties(minPrice: minPrice, maxPrice: maxPrice);
  }

  // Get properties for sale
  Future<List<PropertyModel>> getPropertiesForSale() async {
    return await getAllProperties(type: 'buy');
  }

  // Get properties for rent
  Future<List<PropertyModel>> getPropertiesForRent() async {
    return await getAllProperties(type: 'rent');
  }

  // Get properties for exchange
  Future<List<PropertyModel>> getPropertiesForExchange() async {
    return await getAllProperties(type: 'exchange');
  }
}
