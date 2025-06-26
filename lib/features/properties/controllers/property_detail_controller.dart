import 'package:get/get.dart';
import '../models/property_model.dart';
import '../../../core/services/api_service.dart';

class PropertyDetailController extends GetxController {
  final Rx<PropertyModel?> _property = Rx<PropertyModel?>(null);
  final RxBool _isLoading = true.obs;

  PropertyModel? get property => _property.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    final propertyId = int.tryParse(Get.parameters['id'] ?? '0');
    if (propertyId != null && propertyId > 0) {
      fetchPropertyDetail(propertyId);
    }
  }

  Future<void> fetchPropertyDetail(int propertyId) async {
    try {
      _isLoading.value = true;
      final response = await ApiService.to.getProperty(propertyId);

      if (response.statusCode == 200) {
        _property.value = PropertyModel.fromJson(response.data);
      } else {
        Get.snackbar('خطأ', 'فشل في تحميل تفاصيل العقار');
        Get.back();
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل تفاصيل العقار');
      Get.back();
    } finally {
      _isLoading.value = false;
    }
  }

  void contactOwner() {
    if (_property.value != null) {
      // يمكن إضافة منطق الاتصال هنا
      Get.snackbar('اتصال', 'سيتم إضافة ميزة الاتصال قريباً');
    }
  }

  void shareProperty() {
    if (_property.value != null) {
      // يمكن إضافة منطق المشاركة هنا
      Get.snackbar('مشاركة', 'سيتم إضافة ميزة المشاركة قريباً');
    }
  }
}
