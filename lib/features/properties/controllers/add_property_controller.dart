import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:developer' as developer;
import '../../../core/services/api_service.dart';
import '../../../core/models/category_model.dart';
import '../../../core/utils/validators.dart';
import '../../categories/controllers/category_controller.dart';

class AddPropertyController extends GetxController {
  final formKey = GlobalKey<FormBuilderState>();
  final RxList<File> _selectedImages = <File>[].obs;
  final RxBool _isLoading = false.obs;

  List<File> get selectedImages => _selectedImages;
  bool get isLoading => _isLoading.value;
  List<CategoryModel> get propertyCategories =>
      CategoryController.to.mainCategories;
  bool get isCategoriesLoading => CategoryController.to.isMainCategoriesLoading;

  final List<String> propertyTypes = ['شقة', 'منزل', 'تجاري', 'أرض'];

  final List<String> purposes = ['بيع', 'إيجار', 'تبادل'];

  @override
  void onInit() {
    super.onInit();
    // التصنيفات يتم تحميلها تلقائياً في CategoryController
  }

  // الحصول على معرف التصنيف من الاسم
  int? getCategoryId(String categoryName) {
    return CategoryController.to.getCategoryId(categoryName);
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
    final convertedValue = Validators.convertArabicToEnglishNumbers(value);
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

      // تحويل الأرقام العربية للإنجليزية باستخدام الدالة العامة
      final originalPrice = values['price']?.toString() ?? '0';
      final priceStr = Validators.convertArabicToEnglishNumbers(originalPrice);
      final price = double.tryParse(priceStr) ?? 0.0;

      developer.log('=== Property Price Conversion ===',
          name: 'AddPropertyController');
      developer.log('Original price: $originalPrice',
          name: 'AddPropertyController');
      developer.log('Converted price: $priceStr',
          name: 'AddPropertyController');
      developer.log('Final price: $price', name: 'AddPropertyController');

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

      // تحويل الغرض إلى نوع العملية باستخدام الدالة العامة
      final arabicPurpose = values['purpose']?.toString() ?? 'بيع';
      final englishPurpose =
          Validators.convertPropertyTypeToEnglish(arabicPurpose);

      developer.log('=== Property Purpose Conversion ===',
          name: 'AddPropertyController');
      developer.log('Arabic purpose: $arabicPurpose',
          name: 'AddPropertyController');
      developer.log('English purpose: $englishPurpose',
          name: 'AddPropertyController');

      // طباعة القيم للتأكد
      developer.log('=== Property Data ===', name: 'AddPropertyController');
      developer.log('Title: ${values['title']}', name: 'AddPropertyController');
      developer.log('Description: ${values['description']}',
          name: 'AddPropertyController');
      developer.log('Address: ${values['location']}',
          name: 'AddPropertyController');
      developer.log('Property Type: $propertyType (original: $selectedType)',
          name: 'AddPropertyController');
      developer.log('Purpose Type: $englishPurpose (original: $arabicPurpose)',
          name: 'AddPropertyController');
      developer.log('Price: $price (original: $originalPrice)',
          name: 'AddPropertyController');
      developer.log('Images count: ${_selectedImages.length}',
          name: 'AddPropertyController');

      // Create data for property
      final propertyData = {
        'title': values['title'].toString().trim(),
        'description': values['description'].toString().trim(),
        'location': values['location'].toString().trim(),
        'address': values['location'].toString().trim(),
        'type': englishPurpose,
        'price': price,
        'phone': values['phone'] ?? '',
        'status': 'available',
        'latitude': 31.5017,
        'longitude': 34.4668,
        'bedrooms': 0,
        'bathrooms': 0,
        'area': 0,
      };

      // تحويل مسارات الصور إلى قائمة
      final imagePaths = _selectedImages.map((file) => file.path).toList();

      developer.log('=== Property Data ===', name: 'AddPropertyController');
      developer.log('Property data: $propertyData',
          name: 'AddPropertyController');
      developer.log('Image paths: $imagePaths', name: 'AddPropertyController');

      // إرسال البيانات باستخدام الدالة الجديدة
      final response = await ApiService.to.uploadPropertyWithImages(
        'properties',
        imagePaths: imagePaths,
        data: propertyData,
      );

      developer.log('=== API Response ===', name: 'AddPropertyController');
      developer.log('Status Code: ${response.statusCode}',
          name: 'AddPropertyController');
      developer.log('Response Data: ${response.data}',
          name: 'AddPropertyController');

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
      developer.log('=== Error Details ===', name: 'AddPropertyController');
      developer.log('Error: $e', name: 'AddPropertyController');
      if (e is dio.DioException) {
        developer.log('DioError Type: ${e.type}',
            name: 'AddPropertyController');
        developer.log('DioError Response: ${e.response?.data}',
            name: 'AddPropertyController');
        developer.log('DioError Status Code: ${e.response?.statusCode}',
            name: 'AddPropertyController');
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
