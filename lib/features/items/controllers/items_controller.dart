import 'package:get/get.dart';
import '../models/item_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/app_routes.dart';

class ItemsController extends GetxController {
  static ItemsController get to => Get.find();

  final RxList<ItemModel> _items = <ItemModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _selectedCategory = ''.obs;
  final RxString _searchQuery = ''.obs;

  List<ItemModel> get items => _items;
  bool get isLoading => _isLoading.value;
  String get selectedCategory => _selectedCategory.value;
  String get searchQuery => _searchQuery.value;

  final List<String> categories = [
    'الكل',
    'مواد غذائية',
    'إلكترونيات',
    'ملابس',
    'أثاث',
    'كتب',
    'أدوات مكتبية',
    'ألعاب',
    'أدوات منزلية',
    'أدوات صحية',
    'أدوات طبية',
    'أدوات مطبخ',
    'أدوات رياضية',
    'أدوات موسيقية',
    'أدوات صيد',
    'أدوات زراعية',
    'أدوات صناعية',
    'أدوات تجميل',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      _isLoading.value = true;
      final response = await ApiService.to.get('items');

      if (response.statusCode == 200) {
        final List<dynamic> itemsData = response.data;
        _items.value =
            itemsData.map((json) => ItemModel.fromJson(json)).toList();
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل السلع');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshItems() async {
    await fetchItems();
  }

  void searchItems(String query) {
    _searchQuery.value = query;
    // Note: API doesn't support search yet, so we'll filter locally
  }

  void filterByCategory(String category) {
    _selectedCategory.value = category;
    // Note: API doesn't support category filtering yet, so we'll filter locally
  }

  void goToItemDetail(int itemId) {
    Get.toNamed('${AppRoutes.itemDetail}/$itemId');
  }

  Future<void> deleteItem(int itemId) async {
    try {
      final response = await ApiService.to.delete('items/$itemId');

      if (response.statusCode == 200) {
        _items.removeWhere((item) => item.id == itemId);
        Get.snackbar('نجح', 'تم حذف السلعة بنجاح');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في حذف السلعة');
    }
  }

  List<ItemModel> get filteredItems {
    List<ItemModel> filtered = _items;

    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item.title
                  .toLowerCase()
                  .contains(_searchQuery.value.toLowerCase()) ||
              item.description
                  .toLowerCase()
                  .contains(_searchQuery.value.toLowerCase()))
          .toList();
    }

    // Filter by category (if API supports it in the future)
    if (_selectedCategory.value.isNotEmpty &&
        _selectedCategory.value != 'الكل') {
      // For now, we'll keep all items since API doesn't support category filtering
    }

    return filtered;
  }
}
