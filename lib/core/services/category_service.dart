import 'package:get/get.dart';
import 'package:gaza_exchange_app/core/models/category_model.dart';
import 'package:gaza_exchange_app/core/models/api_response_model.dart';
import 'api_service.dart';

class CategoryService extends GetxService {
  static CategoryService get to => Get.find();

  final ApiService _apiService = Get.find<ApiService>();

  // عرض جميع التصنيفات الرئيسية
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _apiService.getAllCategories();
      if (response.statusCode == 200) {
        final responseData = response.data;

        // التحقق من الشكل الجديد للبيانات
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success')) {
          final apiResponse = ApiResponseModel.fromJson(responseData, null);

          if (apiResponse.success && apiResponse.data != null) {
            final data = apiResponse.data;
            if (data is Map<String, dynamic> &&
                data.containsKey('categories')) {
              final categoriesData = data['categories'] as List;
              return categoriesData
                  .map((category) => CategoryModel.fromJson(category))
                  .toList();
            } else if (data is List) {
              return data
                  .map((category) => CategoryModel.fromJson(category))
                  .toList();
            }
          }
        } else {
          // الشكل القديم للبيانات
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('categories')) {
            final categoriesData = responseData['categories'] as List;
            return categoriesData
                .map((category) => CategoryModel.fromJson(category))
                .toList();
          }
        }
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
        final responseData = response.data;
        List<CategoryModel> categories = [];

        // التحقق من الشكل الجديد للبيانات
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success')) {
          final apiResponse = ApiResponseModel.fromJson(responseData, null);

          if (apiResponse.success && apiResponse.data != null) {
            final data = apiResponse.data;
            if (data is Map<String, dynamic> &&
                data.containsKey('main_categories')) {
              final categoriesData = data['main_categories'] as List;
              categories = categoriesData
                  .map((category) => CategoryModel.fromJson(category))
                  .toList();
            } else if (data is List) {
              categories = data
                  .map((category) => CategoryModel.fromJson(category))
                  .toList();
            }
          }
        } else {
          // الشكل القديم للبيانات
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('main_categories')) {
            final categoriesData = responseData['main_categories'] as List;
            categories = categoriesData
                .map((category) => CategoryModel.fromJson(category))
                .toList();
          } else if (responseData is List) {
            categories = responseData
                .map((category) => CategoryModel.fromJson(category))
                .toList();
          }
        }

        // فحص وإزالة التكرار
        final uniqueCategories = <CategoryModel>[];
        final seenNames = <String>{};

        for (final category in categories) {
          // فحص صحة التصنيف
          if (!category.isValid) {
            print(
                '⚠️ Invalid category found: ID=${category.id}, Name="${category.displayName}"');
            continue;
          }

          if (!seenNames.contains(category.displayName)) {
            seenNames.add(category.displayName);
            uniqueCategories.add(category);
          } else {
            print('⚠️ Duplicate category name found: ${category.displayName}');
          }
        }

        print(
            '📊 Categories loaded: ${categories.length} total, ${uniqueCategories.length} unique');

        return uniqueCategories;
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
        final responseData = response.data;

        // التحقق من الشكل الجديد للبيانات
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success')) {
          final apiResponse = ApiResponseModel.fromJson(responseData, null);

          if (apiResponse.success && apiResponse.data != null) {
            final data = apiResponse.data;
            if (data is Map<String, dynamic> && data.containsKey('category')) {
              return CategoryModel.fromJson(data['category']);
            } else if (data is Map<String, dynamic>) {
              return CategoryModel.fromJson(data);
            }
          }
        } else {
          // الشكل القديم للبيانات
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('category')) {
            return CategoryModel.fromJson(responseData['category']);
          }
        }
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
        final responseData = response.data;

        // التحقق من الشكل الجديد للبيانات
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success')) {
          final apiResponse = ApiResponseModel.fromJson(responseData, null);

          if (apiResponse.success && apiResponse.data != null) {
            final data = apiResponse.data;
            if (data is Map<String, dynamic> &&
                data.containsKey('subcategories')) {
              final subcategoriesData = data['subcategories'] as List;
              return subcategoriesData
                  .map((category) => CategoryModel.fromJson(category))
                  .toList();
            } else if (data is List) {
              return data
                  .map((category) => CategoryModel.fromJson(category))
                  .toList();
            }
          }
        } else {
          // الشكل القديم للبيانات
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('subcategories')) {
            final subcategoriesData = responseData['subcategories'] as List;
            return subcategoriesData
                .map((category) => CategoryModel.fromJson(category))
                .toList();
          }
        }
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
        final responseData = response.data;

        // التحقق من الشكل الجديد للبيانات
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success')) {
          final apiResponse = ApiResponseModel.fromJson(responseData, null);

          if (apiResponse.success && apiResponse.data != null) {
            final data = apiResponse.data;
            if (data is Map<String, dynamic> &&
                data.containsKey('categories')) {
              final categoriesData = data['categories'] as List;
              return categoriesData
                  .map((category) => CategoryModel.fromJson(category))
                  .toList();
            } else if (data is List) {
              return data
                  .map((category) => CategoryModel.fromJson(category))
                  .toList();
            }
          }
        } else {
          // الشكل القديم للبيانات
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('categories')) {
            final categoriesData = responseData['categories'] as List;
            return categoriesData
                .map((category) => CategoryModel.fromJson(category))
                .toList();
          }
        }
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
        final responseData = response.data;

        // التحقق من الشكل الجديد للبيانات
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success')) {
          final apiResponse = ApiResponseModel.fromJson(responseData, null);

          if (apiResponse.success && apiResponse.data != null) {
            final data = apiResponse.data;
            if (data is Map<String, dynamic> && data.containsKey('category')) {
              return CategoryModel.fromJson(data['category']);
            } else if (data is Map<String, dynamic>) {
              return CategoryModel.fromJson(data);
            }
          }
        } else {
          // الشكل القديم للبيانات
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('category')) {
            return CategoryModel.fromJson(responseData['category']);
          }
        }
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
        final responseData = response.data;

        // التحقق من الشكل الجديد للبيانات
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success')) {
          final apiResponse = ApiResponseModel.fromJson(responseData, null);

          if (apiResponse.success && apiResponse.data != null) {
            final responseData = apiResponse.data;
            if (responseData is Map<String, dynamic> &&
                responseData.containsKey('category')) {
              return CategoryModel.fromJson(responseData['category']);
            } else if (responseData is Map<String, dynamic>) {
              return CategoryModel.fromJson(responseData);
            }
          }
        } else {
          // الشكل القديم للبيانات
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('category')) {
            return CategoryModel.fromJson(responseData['category']);
          }
        }
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
      if (response.statusCode == 200) {
        final responseData = response.data;

        // التحقق من الشكل الجديد للبيانات
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success')) {
          final apiResponse = ApiResponseModel.fromJson(responseData, null);
          return apiResponse.success;
        }
        return true; // الشكل القديم
      }
      return false;
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
