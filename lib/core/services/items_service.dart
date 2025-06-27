import 'package:get/get.dart';
import 'package:gaza_exchange_app/features/items/models/item_model.dart';
import 'package:gaza_exchange_app/core/models/nearby_item_model.dart';
import 'api_service.dart';

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

      print('🔍 Fetching items with params: $queryParams');
      final response =
          await _apiService.getAllItems(queryParameters: queryParams);

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response data type: ${response.data.runtimeType}');
      print('📡 Response data: ${response.data}');

      if (response.statusCode == 200) {
        // التحقق من نوع البيانات الراجعة
        if (response.data is List) {
          final itemsData = response.data as List;
          print('📦 Found ${itemsData.length} items in response');

          if (itemsData.isEmpty) {
            print('⚠️ No items found in response');
            return [];
          }

          // طباعة أول عنصر للتحقق من البنية
          if (itemsData.isNotEmpty) {
            print('📋 First item structure: ${itemsData.first}');
          }

          final items = <ItemModel>[];
          for (int i = 0; i < itemsData.length; i++) {
            try {
              final item = ItemModel.fromJson(itemsData[i]);
              items.add(item);
              print('✅ Successfully parsed item ${i + 1}: ${item.title}');
            } catch (e) {
              print('❌ Error parsing item ${i + 1}: $e');
              print('❌ Item data: ${itemsData[i]}');
            }
          }

          print(
              '🎯 Successfully parsed ${items.length} out of ${itemsData.length} items');
          return items;
        } else if (response.data is Map) {
          // إذا كانت البيانات في كائن بدلاً من مصفوفة
          final data = response.data as Map;
          print('📦 Response is Map, checking for items key...');
          print('📦 Available keys: ${data.keys.toList()}');

          if (data.containsKey('items') && data['items'] is List) {
            final itemsData = data['items'] as List;
            print('📦 Found items in data.items: ${itemsData.length} items');

            final items =
                itemsData.map((item) => ItemModel.fromJson(item)).toList();
            print(
                '🎯 Successfully parsed ${items.length} items from data.items');
            return items;
          } else if (data.containsKey('data') && data['data'] is List) {
            final itemsData = data['data'] as List;
            print('📦 Found items in data.data: ${itemsData.length} items');

            final items =
                itemsData.map((item) => ItemModel.fromJson(item)).toList();
            print(
                '🎯 Successfully parsed ${items.length} items from data.data');
            return items;
          } else {
            print('⚠️ No items found in response data');
            return [];
          }
        } else {
          print(
              '⚠️ Unexpected response data type: ${response.data.runtimeType}');
          return [];
        }
      } else {
        print('❌ API returned status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 Error getting all items: $e');
      print('💥 Error stack trace: ${StackTrace.current}');
      return [];
    }
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
        final nearbyItemsData = response.data['nearby_items'] as List;
        return nearbyItemsData
            .map((item) => NearbyItemModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting nearby items: $e');
      return [];
    }
  }

  // عرض السلع الرائجة
  Future<List<ItemModel>> getTrendingItems() async {
    try {
      print('🔥 Fetching trending items...');
      final response = await _apiService.getTrendingItems();

      print('📡 Trending items response status: ${response.statusCode}');
      print(
          '📡 Trending items response data type: ${response.data.runtimeType}');
      print('📡 Trending items response data: ${response.data}');

      if (response.statusCode == 200) {
        // التحقق من نوع البيانات الراجعة
        if (response.data is List) {
          final trendingItemsData = response.data as List;
          print(
              '📦 Found ${trendingItemsData.length} trending items in response');

          if (trendingItemsData.isEmpty) {
            print('⚠️ No trending items found in response');
            return [];
          }

          // طباعة أول عنصر للتحقق من البنية
          if (trendingItemsData.isNotEmpty) {
            print(
                '📋 First trending item structure: ${trendingItemsData.first}');
          }

          final items = <ItemModel>[];
          for (int i = 0; i < trendingItemsData.length; i++) {
            try {
              final item = ItemModel.fromJson(trendingItemsData[i]);
              items.add(item);
              print(
                  '✅ Successfully parsed trending item ${i + 1}: ${item.title}');
            } catch (e) {
              print('❌ Error parsing trending item ${i + 1}: $e');
              print('❌ Trending item data: ${trendingItemsData[i]}');
            }
          }

          print(
              '🎯 Successfully parsed ${items.length} out of ${trendingItemsData.length} trending items');
          return items;
        } else if (response.data is Map) {
          // إذا كانت البيانات في كائن بدلاً من مصفوفة
          final data = response.data as Map;
          print('📦 Trending response is Map, checking for items key...');
          print('📦 Available keys: ${data.keys.toList()}');

          if (data.containsKey('trending_items') &&
              data['trending_items'] is List) {
            final trendingItemsData = data['trending_items'] as List;
            print(
                '📦 Found trending items in data.trending_items: ${trendingItemsData.length} items');

            final items = trendingItemsData
                .map((item) => ItemModel.fromJson(item))
                .toList();
            print(
                '🎯 Successfully parsed ${items.length} trending items from data.trending_items');
            return items;
          } else if (data.containsKey('items') && data['items'] is List) {
            final trendingItemsData = data['items'] as List;
            print(
                '📦 Found trending items in data.items: ${trendingItemsData.length} items');

            final items = trendingItemsData
                .map((item) => ItemModel.fromJson(item))
                .toList();
            print(
                '🎯 Successfully parsed ${items.length} trending items from data.items');
            return items;
          } else if (data.containsKey('data') && data['data'] is List) {
            final trendingItemsData = data['data'] as List;
            print(
                '📦 Found trending items in data.data: ${trendingItemsData.length} items');

            final items = trendingItemsData
                .map((item) => ItemModel.fromJson(item))
                .toList();
            print(
                '🎯 Successfully parsed ${items.length} trending items from data.data');
            return items;
          } else {
            print('⚠️ No trending items found in response data');
            return [];
          }
        } else {
          print(
              '⚠️ Unexpected trending items response data type: ${response.data.runtimeType}');
          return [];
        }
      } else {
        print(
            '❌ Trending items API returned status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('💥 Error getting trending items: $e');
      print('💥 Error stack trace: ${StackTrace.current}');
      return [];
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
      print('Error getting item: $e');
      return null;
    }
  }

  // إضافة سلعة جديدة
  Future<ItemModel?> createItem(
      Map<String, dynamic> data, String? imagePath) async {
    try {
      final formData = await _apiService.uploadFile(
        'items',
        filePath: imagePath ?? '',
        fieldName: 'image',
        additionalData: data,
      );

      if (formData.statusCode == 201) {
        final itemData = formData.data['item'];
        return ItemModel.fromJson(itemData);
      }
      return null;
    } catch (e) {
      print('Error creating item: $e');
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
      print('Error updating item: $e');
      return null;
    }
  }

  // حذف سلعة
  Future<bool> deleteItem(int id) async {
    try {
      final response = await _apiService.deleteItem(id);
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting item: $e');
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
