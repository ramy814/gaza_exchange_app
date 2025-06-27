import 'package:get/get.dart';
import 'package:gaza_exchange_app/core/models/category_model.dart';
import 'api_service.dart';

class CategoryService extends GetxService {
  static CategoryService get to => Get.find();

  final ApiService _apiService = Get.find<ApiService>();

  // عرض جميع التصنيفات الرئيسية
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _apiService.getAllCategories();
      if (response.statusCode == 200) {
        final categoriesData = response.data['categories'] as List;
        return categoriesData
            .map((category) => CategoryModel.fromJson(category))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting all categories: $e');
      return [];
    }
  }

  // عرض التصنيفات الرئيسية فقط
  Future<List<CategoryModel>> getMainCategories() async {
    try {
      print('Fetching main categories...');
      final response = await _apiService.getMainCategories();

      print('Categories response status: ${response.statusCode}');
      print('Categories response data: ${response.data}');

      if (response.statusCode == 200) {
        // Handle nested response structure: {"main_categories": [...]}
        List<dynamic> categoriesData;
        if (response.data is Map &&
            response.data.containsKey('main_categories')) {
          categoriesData = response.data['main_categories'] as List;
        } else if (response.data is List) {
          // Fallback for direct array response
          categoriesData = response.data as List;
        } else {
          print('Unexpected response format: ${response.data.runtimeType}');
          return [];
        }

        final categories = categoriesData
            .map((category) => CategoryModel.fromJson(category))
            .toList();
        print('Parsed ${categories.length} categories');
        return categories;
      }
      return [];
    } catch (e) {
      print('Error getting main categories: $e');
      return [];
    }
  }

  // عرض تصنيف محدد
  Future<CategoryModel?> getCategory(int id) async {
    try {
      final response = await _apiService.getCategory(id);
      if (response.statusCode == 200) {
        final categoryData = response.data['category'];
        return CategoryModel.fromJson(categoryData);
      }
      return null;
    } catch (e) {
      print('Error getting category: $e');
      return null;
    }
  }

  // عرض التصنيفات الفرعية
  Future<List<CategoryModel>> getSubcategories(int categoryId) async {
    try {
      final response = await _apiService.getSubcategories(categoryId);
      if (response.statusCode == 200) {
        final subcategoriesData = response.data['subcategories'] as List;
        return subcategoriesData
            .map((category) => CategoryModel.fromJson(category))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting subcategories: $e');
      return [];
    }
  }

  // البحث في التصنيفات
  Future<List<CategoryModel>> searchCategories(String query) async {
    try {
      final response = await _apiService.searchCategories(query);
      if (response.statusCode == 200) {
        final categoriesData = response.data['categories'] as List;
        return categoriesData
            .map((category) => CategoryModel.fromJson(category))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error searching categories: $e');
      return [];
    }
  }

  // إنشاء تصنيف جديد (محمي)
  Future<CategoryModel?> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.createCategory(data);
      if (response.statusCode == 201) {
        final categoryData = response.data['category'];
        return CategoryModel.fromJson(categoryData);
      }
      return null;
    } catch (e) {
      print('Error creating category: $e');
      return null;
    }
  }

  // تحديث تصنيف (محمي)
  Future<CategoryModel?> updateCategory(
      int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.updateCategory(id, data);
      if (response.statusCode == 200) {
        final categoryData = response.data['category'];
        return CategoryModel.fromJson(categoryData);
      }
      return null;
    } catch (e) {
      print('Error updating category: $e');
      return null;
    }
  }

  // حذف تصنيف (محمي)
  Future<bool> deleteCategory(int id) async {
    try {
      final response = await _apiService.deleteCategory(id);
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  // Helper method to get category name by ID
  Future<String> getCategoryName(int id) async {
    try {
      final category = await getCategory(id);
      return category?.name ?? 'غير محدد';
    } catch (e) {
      return 'غير محدد';
    }
  }

  // Helper method to get subcategory name by ID
  Future<String> getSubcategoryName(int id) async {
    try {
      final category = await getCategory(id);
      return category?.name ?? 'غير محدد';
    } catch (e) {
      return 'غير محدد';
    }
  }
}
