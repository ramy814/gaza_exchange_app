import 'package:get/get.dart';
import '../models/item_model.dart';
import '../../../core/services/api_service.dart';

class ItemDetailController extends GetxController {
  final Rx<ItemModel?> _item = Rx<ItemModel?>(null);
  final RxBool _isLoading = true.obs;

  ItemModel? get item => _item.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    final itemId = int.tryParse(Get.parameters['id'] ?? '0');
    if (itemId != null && itemId > 0) {
      fetchItemDetail(itemId);
    }
  }

  Future<void> fetchItemDetail(int itemId) async {
    try {
      _isLoading.value = true;
      final response = await ApiService.to.getItem(itemId);

      if (response.statusCode == 200) {
        _item.value = ItemModel.fromJson(response.data);
      } else {
        Get.snackbar('خطأ', 'فشل في تحميل تفاصيل السلعة');
        Get.back();
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل تفاصيل السلعة');
      Get.back();
    } finally {
      _isLoading.value = false;
    }
  }

  void contactOwner() {
    if (_item.value != null) {
      // يمكن إضافة منطق الاتصال هنا
      Get.snackbar('اتصال', 'سيتم إضافة ميزة الاتصال قريباً');
    }
  }

  void shareItem() {
    if (_item.value != null) {
      // يمكن إضافة منطق المشاركة هنا
      Get.snackbar('مشاركة', 'سيتم إضافة ميزة المشاركة قريباً');
    }
  }
}
