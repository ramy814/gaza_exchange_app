import 'package:get/get.dart';
import 'dart:developer' as developer;
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

      developer.log('Fetching properties with params: $queryParams',
          name: 'PropertiesService');
      final response =
          await _apiService.getAllProperties(queryParameters: queryParams);

      developer.log('Properties response status: ${response.statusCode}',
          name: 'PropertiesService');
      developer.log('Properties response data: ${response.data}',
          name: 'PropertiesService');

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> propertiesData = [];
        if (responseData['data'] != null &&
            responseData['data']['properties'] != null) {
          propertiesData = responseData['data']['properties'] as List;
        } else if (responseData['properties'] != null) {
          propertiesData = responseData['properties'] as List;
        } else if (responseData is List) {
          propertiesData = responseData;
        }
        return _parsePropertiesList(propertiesData);
      }
      return [];
    } catch (e) {
      developer.log('Error getting all properties: $e',
          name: 'PropertiesService');
      return [];
    }
  }

  // دالة مساعدة لتحليل قائمة العقارات
  List<PropertyModel> _parsePropertiesList(List propertiesData) {
    final List<PropertyModel> properties = [];

    for (int i = 0; i < propertiesData.length; i++) {
      try {
        final property = PropertyModel.fromJson(propertiesData[i]);
        properties.add(property);
        developer.log(
            '✅ Successfully parsed property ${i + 1}: ${property.title}',
            name: 'PropertiesService');
      } catch (e) {
        developer.log('❌ Error parsing property ${i + 1}: $e',
            name: 'PropertiesService');
        developer.log('❌ Property data: ${propertiesData[i]}',
            name: 'PropertiesService');
        // Continue with next property instead of failing completely
      }
    }

    developer.log(
        '🎯 Successfully parsed ${properties.length} out of ${propertiesData.length} properties',
        name: 'PropertiesService');
    return properties;
  }

  // عرض عقار محدد
  Future<PropertyModel?> getProperty(int id) async {
    try {
      final response = await _apiService.getProperty(id);
      if (response.statusCode == 200) {
        final responseData = response.data;
        dynamic propertyData;
        if (responseData['data'] != null &&
            responseData['data']['property'] != null) {
          propertyData = responseData['data']['property'];
        } else if (responseData['property'] != null) {
          propertyData = responseData['property'];
        } else if (responseData is Map<String, dynamic>) {
          propertyData = responseData;
        } else {
          propertyData = null;
        }
        if (propertyData != null) {
          return PropertyModel.fromJson(propertyData);
        }
      }
      return null;
    } catch (e) {
      developer.log('Error getting property: $e', name: 'PropertiesService');
      return null;
    }
  }

  // إضافة عقار جديد
  Future<PropertyModel?> createProperty(
      Map<String, dynamic> data, List<String> imagePaths) async {
    try {
      developer.log('📸 Creating property with ${imagePaths.length} images',
          name: 'PropertiesService');

      final response = await _apiService.uploadPropertyWithImages(
        'properties',
        imagePaths: imagePaths,
        data: data,
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        dynamic propertyData;

        // التحقق من شكل البيانات المستلمة
        if (responseData['data'] != null &&
            responseData['data']['property'] != null) {
          propertyData = responseData['data']['property'];
        } else if (responseData['property'] != null) {
          propertyData = responseData['property'];
        } else if (responseData is Map<String, dynamic>) {
          propertyData = responseData;
        } else {
          propertyData = null;
        }

        if (propertyData != null) {
          return PropertyModel.fromJson(propertyData);
        }
      }
      return null;
    } catch (e) {
      developer.log('Error creating property: $e', name: 'PropertiesService');
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
        final responseData = formData.data;
        dynamic propertyData;
        if (responseData['data'] != null &&
            responseData['data']['property'] != null) {
          propertyData = responseData['data']['property'];
        } else if (responseData['property'] != null) {
          propertyData = responseData['property'];
        } else if (responseData is Map<String, dynamic>) {
          propertyData = responseData;
        } else {
          propertyData = null;
        }
        if (propertyData != null) {
          return PropertyModel.fromJson(propertyData);
        }
      }
      return null;
    } catch (e) {
      developer.log('Error updating property: $e', name: 'PropertiesService');
      return null;
    }
  }

  // حذف عقار
  Future<bool> deleteProperty(int id) async {
    try {
      final response = await _apiService.deleteProperty(id);
      return response.statusCode == 200;
    } catch (e) {
      developer.log('Error deleting property: $e', name: 'PropertiesService');
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

  // Filter properties by location
  Future<List<PropertyModel>> getPropertiesByLocation({
    required double latitude,
    required double longitude,
    double radius = 10,
  }) async {
    return await getAllProperties(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }
}
