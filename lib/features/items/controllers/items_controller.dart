import 'package:get/get.dart';
import '../models/item_model.dart';
import '../../../core/services/items_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/models/category_model.dart';
import '../../../core/utils/app_routes.dart';

class ItemsController extends GetxController {
  static ItemsController get to => Get.find();

  final RxList<ItemModel> _items = <ItemModel>[].obs;
  final RxList<CategoryModel> _categories = <CategoryModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isCategoriesLoading = false.obs;
  final RxString _selectedCategoryId = ''.obs;
  final RxString _searchQuery = ''.obs;

  List<ItemModel> get items => _items;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading.value;
  bool get isCategoriesLoading => _isCategoriesLoading.value;
  String get selectedCategoryId => _selectedCategoryId.value;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      fetchCategories(),
      fetchItems(),
    ]);
  }

  Future<void> fetchCategories() async {
    try {
      _isCategoriesLoading.value = true;
      final categories = await CategoryService.to.getMainCategories();

      // إضافة "الكل" في البداية
      final allCategory = CategoryModel(
        id: 0,
        name: 'الكل',
        nameEn: 'All',
      );

      _categories.value = [allCategory, ...categories];
    } catch (e) {
      print('Error fetching categories: $e');
      Get.snackbar('خطأ', 'فشل في تحميل التصنيفات');
    } finally {
      _isCategoriesLoading.value = false;
    }
  }

  Future<void> fetchItems() async {
    try {
      _isLoading.value = true;
      print('🔄 Starting to fetch items...');

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

      print(
          '🔍 Fetching items with categoryId: $categoryId, searchQuery: $searchQuery');

      // جلب السلع من الخدمة
      final items = await ItemsService.to.getAllItems(
        categoryId: categoryId,
        search: searchQuery,
      );

      print('📦 Received ${items.length} items from service');

      _items.value = items;
      print('✅ Successfully assigned ${items.length} items to controller');

      // طباعة تفاصيل السلع للتحقق
      for (int i = 0; i < items.length; i++) {
        print(
            '📋 Item ${i + 1}: ID=${items[i].id}, Title=${items[i].title}, Price=${items[i].price}');
      }
    } catch (e) {
      print('💥 Error fetching items: $e');
      print('💥 Error stack trace: ${StackTrace.current}');
      Get.snackbar('خطأ', 'فشل في تحميل السلع');
    } finally {
      _isLoading.value = false;
      print('🏁 Finished fetching items. Loading state: ${_isLoading.value}');
    }
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
      print('Error deleting item: $e');
      Get.snackbar('خطأ', 'فشل في حذف السلعة');
    }
  }

  // الحصول على اسم التصنيف المحدد
  String get selectedCategoryName {
    if (_selectedCategoryId.value.isEmpty || _selectedCategoryId.value == '0') {
      return 'الكل';
    }

    final category = _categories.firstWhereOrNull(
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
