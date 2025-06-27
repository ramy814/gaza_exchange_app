import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:io';
import '../../../core/services/api_service.dart';

class AddItemController extends GetxController {
  final formKey = GlobalKey<FormBuilderState>();
  final RxList<File> _selectedImages = <File>[].obs;
  final RxBool _isLoading = false.obs;

  RxList<File> get selectedImages => _selectedImages;
  bool get isLoading => _isLoading.value;

  final List<String> categories = [
    'مواد غذائية',
    'إلكترونيات',
    'أثاث',
    'ملابس',
    'أدوات منزلية',
    'كتب',
    'ألعاب',
    'رياضة',
    'أخرى',
  ];

  final List<String> conditions = [
    'جديد',
    'مستعمل - ممتاز',
    'مستعمل - جيد',
    'مستعمل - مقبول',
  ];

  // دالة لتحويل الأرقام العربية إلى الإنجليزية
  String convertArabicToEnglishNumbers(String input) {
    if (input.isEmpty) return input;

    const Map<String, String> arabicToEnglish = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    String result = input;
    arabicToEnglish.forEach((arabic, english) {
      result = result.replaceAll(arabic, english);
    });

    // إزالة أي أحرف غير رقمية باستثناء النقطة العشرية
    result = result.replaceAll(RegExp(r'[^\d.]'), '');

    // التأكد من وجود رقم واحد على الأقل
    if (result.isEmpty || result == '.') {
      result = '0';
    }

    return result;
  }

  Future<void> pickImage() async {
    if (_selectedImages.length >= 5) {
      Get.snackbar(
        '📸 حد الصور',
        'يمكنك إضافة 5 صور كحد أقصى',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(
          Icons.photo_library,
          color: Colors.white,
          size: 24,
        ),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      final file = File(image.path);
      _selectedImages.add(file);

      print('=== Image Selected ===');
      print('Image path: ${image.path}');
      print('File exists: ${file.existsSync()}');
      print('File size: ${file.lengthSync()} bytes');
      print('Total selected images: ${_selectedImages.length}');
    }
  }

  void removeImage(int index) {
    _selectedImages.removeAt(index);
  }

  Future<void> submitItem() async {
    if (!formKey.currentState!.saveAndValidate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      Get.snackbar(
        '📷 صورة مطلوبة',
        'يرجى إضافة صورة واحدة على الأقل للسلعة',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(
          Icons.photo_camera,
          color: Colors.white,
          size: 24,
        ),
      );
      return;
    }

    try {
      _isLoading.value = true;

      final values = formKey.currentState!.value;

      // تحويل السعر من العربية إلى الإنجليزية
      final originalPrice = values['price']?.toString() ?? '0';
      final priceStr = convertArabicToEnglishNumbers(originalPrice);
      final price = double.tryParse(priceStr) ?? 0.0;

      print('=== Item Price Conversion ===');
      print('Original price: $originalPrice');
      print('Converted price: $priceStr');
      print('Final price: $price');

      // التحقق من صحة السعر
      if (price <= 0) {
        Get.snackbar(
          '❌ خطأ في السعر',
          'يرجى إدخال سعر صحيح أكبر من صفر',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Create FormData for file upload
      final formData = dio.FormData.fromMap({
        'title': values['title'],
        'description': values['description'],
        'category': values['category'],
        'condition': values['condition'],
        'price': price, // استخدام السعر المحول
        'exchange_for': values['exchange_for'] ?? '',
        'location': values['location'],
        'status': 'available', // إضافة حالة السلعة
        'category_id': 1, // إضافة معرف التصنيف (سيتم تحديثه لاحقاً)
        'subcategory_id': 1, // إضافة معرف التصنيف الفرعي (سيتم تحديثه لاحقاً)
        'latitude': 31.5017, // إضافة خط العرض (سيتم تحديثه لاحقاً)
        'longitude': 34.4668, // إضافة خط الطول (سيتم تحديثه لاحقاً)
        'location_name': values['location'], // استخدام الموقع المدخل
      });

      // Add images - API expects only one image
      if (_selectedImages.isNotEmpty) {
        final file = await dio.MultipartFile.fromFile(
          _selectedImages[0].path, // إرسال الصورة الأولى فقط
          filename: 'item_image.jpg',
        );
        formData.files.add(
          MapEntry(
            'image',
            file,
          ),
        );
      }

      print('=== Item FormData Details ===');
      print('FormData fields: ${formData.fields}');
      print('FormData files count: ${formData.files.length}');
      for (var field in formData.fields) {
        print('Field: ${field.key} = ${field.value}');
      }
      for (var file in formData.files) {
        print(
            'File: ${file.key} = ${file.value.filename} (${file.value.length} bytes)');
      }

      // إرسال البيانات مع Content-Type الصحيح للملفات
      final response = await ApiService.to.post('items', data: formData);

      print('=== API Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 201) {
        Get.back();
        Get.snackbar(
          '🎉 تم بنجاح!',
          'تم إضافة السلعة بنجاح وستظهر قريباً في القائمة',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 24,
          ),
          mainButton: TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'حسناً',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      } else {
        print('=== API Error ===');
        print('Unexpected status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        throw Exception('API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('=== Error Details ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');

      String errorMessage = 'فشل في إضافة السلعة، يرجى المحاولة مرة أخرى';

      if (e.toString().contains('422')) {
        errorMessage = 'بيانات غير صحيحة، يرجى التحقق من المعلومات المدخلة';
      } else if (e.toString().contains('401')) {
        errorMessage = 'جلسة منتهية، يرجى تسجيل الدخول مرة أخرى';
      } else if (e.toString().contains('500')) {
        errorMessage = 'خطأ في الخادم، يرجى المحاولة لاحقاً';
      }

      Get.snackbar(
        '❌ حدث خطأ',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(
          Icons.error,
          color: Colors.white,
          size: 24,
        ),
        mainButton: TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            'حسناً',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
