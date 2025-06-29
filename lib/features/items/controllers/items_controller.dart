import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../models/item_model.dart';
import '../../../core/services/items_service.dart';
import '../../../core/models/category_model.dart';
import '../../../core/utils/app_routes.dart';
import '../../categories/controllers/category_controller.dart';

class ItemsController extends GetxController {
  static ItemsController get to => Get.find();

  final RxList<ItemModel> _items = <ItemModel>[].obs;
  final RxString _selectedCategoryId = ''.obs;
  final RxString _searchQuery = ''.obs;

  List<ItemModel> get items => _items;
  List<CategoryModel> get categories => CategoryController.to.mainCategories;
  bool get isLoading => false; // سيتم تحديثه لاحقاً
  bool get isCategoriesLoading => CategoryController.to.isMainCategoriesLoading;
  String get selectedCategoryId => _selectedCategoryId.value;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      developer.log('🔄 Starting to fetch items...', name: 'ItemsController');

      // تحديد معاملات البحث
      int? categoryId;
      if (_selectedCategoryId.value.isNotEmpty &&
          _selectedCategoryId.value != '0') {
        categoryId = int.tryParse(_selectedCategoryId.value);
      }

      String? searchQuery;
      if (_searchQuery.value.isNotEmpty) {
        searchQuery = _searchQuery.value;
      }

      developer.log(
          '🔍 Fetching items with categoryId: $categoryId, searchQuery: $searchQuery',
          name: 'ItemsController');

      // جلب السلع من الخدمة
      final items = await ItemsService.to.getAllItems(
        categoryId: categoryId,
        search: searchQuery,
      );

      developer.log('📦 Received ${items.length} items from service',
          name: 'ItemsController');

      _items.value = items;
      developer.log(
          '✅ Successfully assigned ${items.length} items to controller',
          name: 'ItemsController');

      // طباعة تفاصيل السلع للتحقق
      for (int i = 0; i < items.length; i++) {
        developer.log(
            '📋 Item ${i + 1}: ID=${items[i].id}, Title=${items[i].title}, Price=${items[i].price}',
            name: 'ItemsController');
      }
    } catch (e) {
      developer.log('💥 Error fetching items: $e', name: 'ItemsController');
      developer.log('💥 Error stack trace: ${StackTrace.current}',
          name: 'ItemsController');
      Get.snackbar('خطأ', 'فشل في تحميل السلع');
    }
    developer.log('🏁 Finished fetching items.', name: 'ItemsController');
  }

  Future<void> refreshItems() async {
    await fetchItems();
  }

  void searchItems(String query) {
    _searchQuery.value = query;
    fetchItems(); // إعادة جلب السلع مع البحث
  }

  void filterByCategory(String categoryId) {
    _selectedCategoryId.value = categoryId;
    fetchItems(); // إعادة جلب السلع مع التصنيف المحدد
  }

  void clearFilters() {
    _selectedCategoryId.value = '';
    _searchQuery.value = '';
    fetchItems();
  }

  void goToItemDetail(int itemId) {
    Get.toNamed('${AppRoutes.itemDetail}/$itemId');
  }

  Future<void> deleteItem(int itemId) async {
    try {
      final success = await ItemsService.to.deleteItem(itemId);

      if (success) {
        _items.removeWhere((item) => item.id == itemId);
        Get.snackbar('نجح', 'تم حذف السلعة بنجاح');
      } else {
        Get.snackbar('خطأ', 'فشل في حذف السلعة');
      }
    } catch (e) {
      developer.log('Error deleting item: $e', name: 'ItemsController');
      Get.snackbar('خطأ', 'فشل في حذف السلعة');
    }
  }

  // الحصول على اسم التصنيف المحدد
  String get selectedCategoryName {
    if (_selectedCategoryId.value.isEmpty || _selectedCategoryId.value == '0') {
      return 'الكل';
    }

    final category = categories.firstWhereOrNull(
      (cat) => cat.id.toString() == _selectedCategoryId.value,
    );

    return category?.name ?? 'غير محدد';
  }

  // التحقق من وجود فلاتر نشطة
  bool get hasActiveFilters {
    return _searchQuery.value.isNotEmpty ||
        (_selectedCategoryId.value.isNotEmpty &&
            _selectedCategoryId.value != '0');
  }

  // عدد النتائج
  int get resultsCount => _items.length;
}
