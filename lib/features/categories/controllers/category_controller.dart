import 'package:get/get.dart';
import '../../../core/services/category_service.dart';
import '../../../core/models/category_model.dart';
import '../../../core/services/api_service.dart';

class CategoryController extends GetxController {
  static CategoryController get to => Get.find();

  final RxList<CategoryModel> _categories = <CategoryModel>[].obs;
  final RxList<CategoryModel> _mainCategories = <CategoryModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isMainCategoriesLoading = false.obs;

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get mainCategories => _mainCategories;
  bool get isLoading => _isLoading.value;
  bool get isMainCategoriesLoading => _isMainCategoriesLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadMainCategories();
  }

  // تحميل جميع التصنيفات
  Future<void> loadCategories() async {
    try {
      _isLoading.value = true;
      final categories = await CategoryService.to.getAllCategories();
      _categories.value = categories;
    } catch (e) {
      print('Error loading categories: $e');
      Get.snackbar('خطأ', 'فشل في تحميل التصنيفات');
    } finally {
      _isLoading.value = false;
    }
  }

  // تحميل التصنيفات الرئيسية فقط
  Future<void> loadMainCategories() async {
    try {
      _isMainCategoriesLoading.value = true;
      final categories = await CategoryService.to.getMainCategories();

      if (categories.isNotEmpty) {
        _mainCategories.value = categories;
      } else {
        // Fallback للتصنيفات الافتراضية في حالة فشل API
        print('⚠️ No categories from API, using fallback categories');
        _mainCategories.value = _getFallbackCategories();
      }
    } catch (e) {
      print('Error loading main categories: $e');
      Get.snackbar('خطأ', 'فشل في تحميل التصنيفات الرئيسية');

      // Fallback للتصنيفات الافتراضية في حالة الخطأ
      _mainCategories.value = _getFallbackCategories();
    } finally {
      _isMainCategoriesLoading.value = false;
    }
  }

  // التصنيفات الافتراضية كـ fallback
  List<CategoryModel> _getFallbackCategories() {
    return [
      CategoryModel(
        id: 1,
        name: 'الإلكترونيات',
        nameEn: 'Electronics',
        icon: 'fas fa-laptop',
        color: '#007bff',
      ),
      CategoryModel(
        id: 2,
        name: 'السيارات',
        nameEn: 'Vehicles',
        icon: 'fas fa-car',
        color: '#28a745',
      ),
      CategoryModel(
        id: 3,
        name: 'الأثاث',
        nameEn: 'Furniture',
        icon: 'fas fa-couch',
        color: '#ffc107',
      ),
      CategoryModel(
        id: 4,
        name: 'الملابس',
        nameEn: 'Clothing',
        icon: 'fas fa-tshirt',
        color: '#dc3545',
      ),
      CategoryModel(
        id: 5,
        name: 'الكتب',
        nameEn: 'Books',
        icon: 'fas fa-book',
        color: '#6f42c1',
      ),
      CategoryModel(
        id: 6,
        name: 'أخرى',
        nameEn: 'Others',
        icon: 'fas fa-ellipsis-h',
        color: '#6c757d',
      ),
    ];
  }

  // تحميل التصنيفات الفرعية
  Future<List<CategoryModel>> loadSubcategories(int categoryId) async {
    try {
      print('📂 Loading subcategories for category ID: $categoryId');

      final response =
          await ApiService.to.get('categories/$categoryId/subcategories');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final subcategoriesData =
            response.data['data']['subcategories'] as List;
        final subcategories = subcategoriesData
            .map((json) => CategoryModel.fromJson(json))
            .where((category) => category.name.isNotEmpty)
            .toList();

        print('📂 Loaded ${subcategories.length} subcategories');
        return subcategories;
      } else {
        print('❌ Failed to load subcategories: ${response.data}');
        return [];
      }
    } catch (e) {
      print('❌ Error loading subcategories: $e');
      return [];
    }
  }

  // البحث في التصنيفات
  Future<List<CategoryModel>> searchCategories(String query) async {
    try {
      final results = await CategoryService.to.searchCategories(query);
      return results;
    } catch (e) {
      print('Error searching categories: $e');
      return [];
    }
  }

  // الحصول على تصنيف محدد
  Future<CategoryModel?> getCategory(int id) async {
    try {
      final category = await CategoryService.to.getCategory(id);
      return category;
    } catch (e) {
      print('Error getting category: $e');
      return null;
    }
  }

  // الحصول على اسم التصنيف من المعرف
  Future<String> getCategoryName(int id) async {
    try {
      final category = await CategoryService.to.getCategory(id);
      return category?.name ?? 'غير محدد';
    } catch (e) {
      return 'غير محدد';
    }
  }

  // الحصول على معرف التصنيف من الاسم
  int? getCategoryId(String categoryName) {
    if (categoryName.isEmpty) return null;

    // البحث في التصنيفات الرئيسية
    final category = _mainCategories.firstWhereOrNull(
      (cat) => cat.displayName == categoryName,
    );

    if (category != null) {
      return category.id;
    }

    // البحث في جميع التصنيفات إذا لم يتم العثور عليه في الرئيسية
    final allCategory = _categories.firstWhereOrNull(
      (cat) => cat.displayName == categoryName,
    );

    return allCategory?.id;
  }

  // الحصول على قائمة فريدة من التصنيفات (بدون تكرار)
  List<CategoryModel> get uniqueMainCategories {
    final seen = <String>{};
    return _mainCategories.where((category) {
      if (seen.contains(category.displayName)) {
        return false;
      }
      seen.add(category.displayName);
      return true;
    }).toList();
  }

  // تحديث التصنيفات
  Future<void> refreshCategories() async {
    await Future.wait([
      loadCategories(),
      loadMainCategories(),
    ]);
  }

  // التحقق من وجود تصنيفات
  bool get hasCategories => _categories.isNotEmpty;
  bool get hasMainCategories => _mainCategories.isNotEmpty;

  // الحصول على عدد التصنيفات
  int get categoriesCount => _categories.length;
  int get mainCategoriesCount => _mainCategories.length;

  // طباعة معلومات التصنيفات للتصحيح
  void debugCategories() {
    print('=== Categories Debug Info ===');
    print('Main categories count: ${_mainCategories.length}');
    print('All categories count: ${_categories.length}');

    print('Main categories:');
    for (int i = 0; i < _mainCategories.length; i++) {
      print(
          '  ${i + 1}. ID: ${_mainCategories[i].id}, Name: "${_mainCategories[i].displayName}"');
    }

    // فحص التكرار
    final names = _mainCategories.map((c) => c.displayName).toList();
    final duplicates = <String>[];
    for (int i = 0; i < names.length; i++) {
      for (int j = i + 1; j < names.length; j++) {
        if (names[i] == names[j] && !duplicates.contains(names[i])) {
          duplicates.add(names[i]);
        }
      }
    }

    if (duplicates.isNotEmpty) {
      print('⚠️ Duplicate category names found: $duplicates');
    } else {
      print('✅ No duplicate category names found');
    }
  }
}
