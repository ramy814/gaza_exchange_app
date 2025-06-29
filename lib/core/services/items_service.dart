import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:gaza_exchange_app/core/services/api_service.dart';
import 'package:gaza_exchange_app/features/items/models/item_model.dart';
import 'package:gaza_exchange_app/core/models/api_response_model.dart';
import 'package:gaza_exchange_app/core/models/nearby_item_model.dart';

class ItemsService extends GetxService {
  static ItemsService get to => Get.find();

  final ApiService _apiService = Get.find<ApiService>();

  // عرض جميع السلع
  Future<List<ItemModel>> getAllItems({
    int? categoryId,
    int? subcategoryId,
    String? status,
    double? minPrice,
    double? maxPrice,
    String? search,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (subcategoryId != null) queryParams['subcategory_id'] = subcategoryId;
      if (status != null) queryParams['status'] = status;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (search != null) queryParams['search'] = search;
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radius != null) queryParams['radius'] = radius;

      developer.log('🔍 Fetching items with params: $queryParams',
          name: 'ItemsService');
      final response =
          await _apiService.getAllItems(queryParameters: queryParams);

      developer.log('📡 Response status: ${response.statusCode}',
          name: 'ItemsService');
      developer.log('📡 Response data type: ${response.data.runtimeType}',
          name: 'ItemsService');
      developer.log('📡 Response data: ${response.data}', name: 'ItemsService');

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> itemsData = [];
        if (responseData['data'] != null &&
            responseData['data']['items'] != null) {
          itemsData = responseData['data']['items'] as List;
        } else if (responseData['items'] != null) {
          itemsData = responseData['items'] as List;
        } else if (responseData is List) {
          itemsData = responseData;
        }
        return _parseItemsList(itemsData);
      } else {
        developer.log('❌ API returned status code: ${response.statusCode}',
            name: 'ItemsService');
        return [];
      }
    } catch (e) {
      developer.log('💥 Error getting all items: $e', name: 'ItemsService');
      developer.log('💥 Error stack trace: ${StackTrace.current}',
          name: 'ItemsService');
      return [];
    }
  }

  // دالة مساعدة لتحليل قائمة السلع
  List<ItemModel> _parseItemsList(List itemsData) {
    developer.log('📦 Found ${itemsData.length} items in response',
        name: 'ItemsService');

    if (itemsData.isEmpty) {
      developer.log('⚠️ No items found in response', name: 'ItemsService');
      return [];
    }

    final items = <ItemModel>[];
    for (int i = 0; i < itemsData.length; i++) {
      try {
        final item = ItemModel.fromJson(itemsData[i]);
        items.add(item);
        developer.log('✅ Successfully parsed item ${i + 1}: ${item.title}',
            name: 'ItemsService');
      } catch (e) {
        developer.log('❌ Error parsing item ${i + 1}: $e',
            name: 'ItemsService');
        developer.log('❌ Item data: ${itemsData[i]}', name: 'ItemsService');
      }
    }

    developer.log(
        '🎯 Successfully parsed ${items.length} out of ${itemsData.length} items',
        name: 'ItemsService');
    return items;
  }

  // عرض السلع القريبة
  Future<List<NearbyItemModel>> getNearbyItems({
    required double latitude,
    required double longitude,
    double radius = 10,
  }) async {
    try {
      final response = await _apiService.getNearbyItems(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // التحقق من الشكل الجديد للبيانات
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success')) {
          final apiResponse = ApiResponseModel.fromJson(responseData, null);

          if (apiResponse.success && apiResponse.data != null) {
            final data = apiResponse.data;
            if (data is Map<String, dynamic> &&
                data.containsKey('nearby_items')) {
              final nearbyItemsData = data['nearby_items'] as List;
              return nearbyItemsData
                  .map((item) => NearbyItemModel.fromJson(item))
                  .toList();
            } else if (data is List) {
              return data
                  .map((item) => NearbyItemModel.fromJson(item))
                  .toList();
            }
          }
        } else {
          // الشكل القديم للبيانات
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('nearby_items')) {
            final nearbyItemsData = responseData['nearby_items'] as List;
            return nearbyItemsData
                .map((item) => NearbyItemModel.fromJson(item))
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      developer.log('Error getting nearby items: $e', name: 'ItemsService');
      return [];
    }
  }

  // عرض السلع الرائجة
  Future<List<ItemModel>> getTrendingItems() async {
    try {
      developer.log('🔥 Fetching trending items...', name: 'ItemsService');
      final response = await _apiService.getTrendingItems();

      developer.log('📡 Trending items response status: ${response.statusCode}',
          name: 'ItemsService');
      developer.log(
          '📡 Trending items response data type: ${response.data.runtimeType}',
          name: 'ItemsService');
      developer.log('📡 Trending items response data: ${response.data}',
          name: 'ItemsService');

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> trendingData = [];
        if (responseData['data'] != null &&
            responseData['data']['trending_items'] != null) {
          trendingData = responseData['data']['trending_items'] as List;
        } else if (responseData['trending_items'] != null) {
          trendingData = responseData['trending_items'] as List;
        } else if (responseData is List) {
          trendingData = responseData;
        }
        return _parseItemsList(trendingData);
      } else {
        developer.log('❌ API returned status code: ${response.statusCode}',
            name: 'ItemsService');
        throw Exception('API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('💥 Error getting trending items: $e',
          name: 'ItemsService');
      rethrow;
    }
  }

  // عرض سلعة محددة
  Future<ItemModel?> getItem(int id) async {
    try {
      final response = await _apiService.getItem(id);
      if (response.statusCode == 200) {
        return ItemModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      developer.log('Error getting item: $e', name: 'ItemsService');
      return null;
    }
  }

  // إضافة سلعة جديدة
  Future<ItemModel?> createItem(
      Map<String, dynamic> data, List<String> imagePaths) async {
    try {
      developer.log('📸 Creating item with ${imagePaths.length} images',
          name: 'ItemsService');

      final response = await _apiService.uploadItemWithImages(
        'items',
        imagePaths: imagePaths,
        data: data,
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        dynamic itemData;

        // التحقق من شكل البيانات المستلمة
        if (responseData['data'] != null &&
            responseData['data']['item'] != null) {
          itemData = responseData['data']['item'];
        } else if (responseData['item'] != null) {
          itemData = responseData['item'];
        } else if (responseData is Map<String, dynamic>) {
          itemData = responseData;
        } else {
          itemData = null;
        }

        if (itemData != null) {
          return ItemModel.fromJson(itemData);
        }
      }
      return null;
    } catch (e) {
      developer.log('Error creating item: $e', name: 'ItemsService');
      return null;
    }
  }

  // تحديث سلعة
  Future<ItemModel?> updateItem(
      int id, Map<String, dynamic> data, String? imagePath) async {
    try {
      final formData = await _apiService.uploadFile(
        'items/$id',
        filePath: imagePath ?? '',
        fieldName: 'image',
        additionalData: data,
      );

      if (formData.statusCode == 200) {
        final itemData = formData.data['item'];
        return ItemModel.fromJson(itemData);
      }
      return null;
    } catch (e) {
      developer.log('Error updating item: $e', name: 'ItemsService');
      return null;
    }
  }

  // حذف سلعة
  Future<bool> deleteItem(int id) async {
    try {
      final response = await _apiService.deleteItem(id);
      return response.statusCode == 200;
    } catch (e) {
      developer.log('Error deleting item: $e', name: 'ItemsService');
      return false;
    }
  }

  // Search items by text
  Future<List<ItemModel>> searchItems(String query) async {
    return await getAllItems(search: query);
  }

  // Filter items by category
  Future<List<ItemModel>> getItemsByCategory(int categoryId) async {
    return await getAllItems(categoryId: categoryId);
  }

  // Filter items by subcategory
  Future<List<ItemModel>> getItemsBySubcategory(int subcategoryId) async {
    return await getAllItems(subcategoryId: subcategoryId);
  }

  // Filter items by price range
  Future<List<ItemModel>> getItemsByPriceRange({
    required double minPrice,
    required double maxPrice,
  }) async {
    return await getAllItems(minPrice: minPrice, maxPrice: maxPrice);
  }

  // Filter items by status
  Future<List<ItemModel>> getItemsByStatus(String status) async {
    return await getAllItems(status: status);
  }
}
