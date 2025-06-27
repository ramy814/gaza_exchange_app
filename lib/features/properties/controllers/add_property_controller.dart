import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:io';
import '../../../core/services/api_service.dart';

class AddPropertyController extends GetxController {
  final formKey = GlobalKey<FormBuilderState>();
  final RxList<File> _selectedImages = <File>[].obs;
  final RxBool _isLoading = false.obs;

  List<File> get selectedImages => _selectedImages;
  bool get isLoading => _isLoading.value;

  final List<String> propertyTypes = ['شقة', 'منزل', 'تجاري', 'أرض'];

  final List<String> purposes = ['بيع', 'إيجار', 'تبادل'];

  // دالة محسنة لتحويل الأرقام العربية للإنجليزية
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

  // دالة للتحقق من صحة الأرقام العربية والإنجليزية
  String? validateNumber(String? value,
      {required String fieldName, double minValue = 0}) {
    if (value == null || value.isEmpty) return null;

    // التحقق من الأرقام العربية والإنجليزية
    final arabicNumbers = RegExp(r'^[٠-٩]+$');
    final englishNumbers = RegExp(r'^[0-9]+$');
    if (!arabicNumbers.hasMatch(value) && !englishNumbers.hasMatch(value)) {
      return 'يجب أن يكون رقم';
    }

    // تحويل للإنجليزية للتحقق من القيمة
    final convertedValue = convertArabicToEnglishNumbers(value);
    final numValue = double.tryParse(convertedValue);

    if (numValue == null || numValue < minValue) {
      return minValue == 0
          ? '$fieldName لا يمكن أن يكون سالب'
          : '$fieldName يجب أن يكون أكبر من $minValue';
    }

    return null;
  }

  Future<void> pickImage() async {
    if (_selectedImages.length >= 8) {
      Get.snackbar('تنبيه', 'يمكنك إضافة 8 صور كحد أقصى');
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
      _selectedImages.add(File(image.path));
    }
  }

  void removeImage(int index) {
    _selectedImages.removeAt(index);
  }

  Future<void> submitProperty() async {
    if (!formKey.currentState!.saveAndValidate()) {
      Get.snackbar(
        'خطأ في النموذج',
        'يرجى التحقق من جميع الحقول المطلوبة',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    final values = formKey.currentState!.value;

    // التحقق من الحقول المطلوبة يدوياً
    if (values['title'] == null || values['title'].toString().trim().isEmpty) {
      Get.snackbar('خطأ', 'عنوان العقار مطلوب');
      return;
    }

    if (values['location'] == null ||
        values['location'].toString().trim().isEmpty) {
      Get.snackbar('خطأ', 'عنوان العقار مطلوب');
      return;
    }

    if (values['description'] == null ||
        values['description'].toString().trim().isEmpty) {
      Get.snackbar('خطأ', 'وصف العقار مطلوب');
      return;
    }

    if (_selectedImages.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إضافة صورة واحدة على الأقل',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    try {
      _isLoading.value = true;

      // تحويل الأرقام العربية للإنجليزية
      final priceStr =
          convertArabicToEnglishNumbers(values['price']?.toString() ?? '0');
      final price = double.tryParse(priceStr) ?? 0.0;

      // استخدام نوع العقار المحدد من المستخدم
      final selectedType = values['type']?.toString() ?? 'شقة';

      // تحويل نوع العقار إلى القيمة المتوقعة من API
      String propertyType;
      switch (selectedType) {
        case 'شقة':
          propertyType = 'apartment';
          break;
        case 'منزل':
          propertyType = 'house';
          break;
        case 'تجاري':
          propertyType = 'commercial';
          break;
        case 'أرض':
          propertyType = 'land';
          break;
        default:
          propertyType = 'apartment';
      }

      // تحويل الغرض إلى نوع العملية
      String purposeType = 'buy'; // القيمة الافتراضية
      if (values['purpose'] == 'بيع') {
        purposeType = 'buy';
      } else if (values['purpose'] == 'إيجار') {
        purposeType = 'rent';
      } else if (values['purpose'] == 'تبادل') {
        purposeType = 'exchange';
      }

      // طباعة القيم للتأكد
      print('=== Property Data ===');
      print('Title: ${values['title']}');
      print('Description: ${values['description']}');
      print('Address: ${values['location']}');
      print('Property Type: $propertyType (original: $selectedType)');
      print('Purpose Type: $purposeType (original: ${values['purpose']})');
      print('Price: $price (original: ${values['price']})');
      print('Images count: ${_selectedImages.length}');

      // Create FormData for file upload حسب متطلبات الـ API
      final formData = dio.FormData.fromMap({
        'title': values['title'].toString().trim(),
        'description': values['description'].toString().trim(),
        'address': values['location'].toString().trim(),
        'type': purposeType, // إرسال نوع العملية (بيع، إيجار، تبادل)
        'price': price,
      });

      // Add only the first image (API supports single image)
      if (_selectedImages.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'image', // استخدام image بدلاً من images[]
            await dio.MultipartFile.fromFile(_selectedImages[0].path),
          ),
        );
      }

      print('=== Sending FormData ===');
      print('FormData fields: ${formData.fields}');
      print('FormData files: ${formData.files.length}');
      print('=== Detailed FormData ===');
      for (var field in formData.fields) {
        print('Field: ${field.key} = ${field.value}');
      }
      for (var file in formData.files) {
        print('File: ${file.key} = ${file.value.filename}');
      }

      final response = await ApiService.to.post('properties', data: formData);

      print('=== API Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 201) {
        Get.back();
        Get.snackbar(
          'نجح',
          'تم نشر العقار بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          mainButton: TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white)),
          ),
        );
      }
    } catch (e) {
      print('=== Error Details ===');
      print('Error: $e');
      if (e is dio.DioException) {
        print('DioError Type: ${e.type}');
        print('DioError Response: ${e.response?.data}');
        print('DioError Status Code: ${e.response?.statusCode}');
      }

      Get.snackbar(
        'خطأ',
        'فشل في نشر العقار: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
