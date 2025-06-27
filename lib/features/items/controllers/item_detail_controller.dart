import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
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

  void contactOwner() async {
    final user = _item.value?.user;
    final phone = user?.phone;
    if (user != null && phone != null && phone.isNotEmpty) {
      final phoneNumber = phone;

      // تنظيف رقم الهاتف من المسافات والرموز
      final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

      // محاولة فتح تطبيق الهاتف
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhoneNumber);

      try {
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          // إذا فشل فتح الهاتف، عرض رقم الهاتف للمستخدم
          _showContactOptions(cleanPhoneNumber);
        }
      } catch (e) {
        // في حالة الخطأ، عرض خيارات الاتصال
        _showContactOptions(cleanPhoneNumber);
      }
    } else {
      Get.snackbar('خطأ', 'رقم الهاتف غير متوفر');
    }
  }

  void _showContactOptions(String phoneNumber) {
    Get.dialog(
      AlertDialog(
        title: const Text('خيارات الاتصال'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('رقم الهاتف: $phoneNumber'),
            const SizedBox(height: 16),
            const Text('اختر طريقة الاتصال:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              // محاولة فتح تطبيق الهاتف مرة أخرى
              final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
              try {
                await launchUrl(phoneUri);
              } catch (e) {
                Get.snackbar('خطأ', 'لا يمكن فتح تطبيق الهاتف');
              }
            },
            child: const Text('اتصال مباشر'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              // نسخ رقم الهاتف للحافظة
              // يمكن إضافة package clipboard هنا إذا لزم الأمر
              Get.snackbar('تم', 'تم نسخ رقم الهاتف');
            },
            child: const Text('نسخ الرقم'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void shareItem() {
    if (_item.value != null) {
      // يمكن إضافة منطق المشاركة هنا
      Get.snackbar('مشاركة', 'سيتم إضافة ميزة المشاركة قريباً');
    }
  }
}
