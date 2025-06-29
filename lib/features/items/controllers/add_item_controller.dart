import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import '../../../core/services/api_service.dart';
import '../../../core/models/category_model.dart';
import '../../../core/utils/validators.dart';
import '../../categories/controllers/category_controller.dart';

class AddItemController extends GetxController {
  final formKey = GlobalKey<FormBuilderState>();
  final RxBool _isLoading = false.obs;
  final RxList<File> _selectedImages = <File>[].obs;
  final RxList<CategoryModel> _subcategories = <CategoryModel>[].obs;
  final RxBool _isSubcategoriesLoading = false.obs;

  bool get isLoading => _isLoading.value;
  List<File> get selectedImages => _selectedImages;
  List<CategoryModel> get categories =>
      CategoryController.to.uniqueMainCategories;
  List<CategoryModel> get subcategories => _subcategories;
  bool get isCategoriesLoading => CategoryController.to.isMainCategoriesLoading;
  bool get isSubcategoriesLoading => _isSubcategoriesLoading.value;

  final List<String> conditions = [
    'جديد',
    'مستعمل - ممتاز',
    'مستعمل - جيد',
    'مستعمل - مقبول',
  ];

  @override
  void onInit() {
    super.onInit();
    // التصنيفات يتم تحميلها تلقائياً في CategoryController
    // طباعة معلومات التصنيفات للتصحيح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CategoryController.to.debugCategories();
    });
  }

  // تحميل التصنيفات الفرعية
  Future<void> loadSubcategories(int categoryId) async {
    try {
      _isSubcategoriesLoading.value = true;
      final subcategories =
          await CategoryController.to.loadSubcategories(categoryId);
      _subcategories.value = subcategories;
      print(
          '📂 Loaded ${subcategories.length} subcategories for category $categoryId');
    } catch (e) {
      print('Error loading subcategories: $e');
      _subcategories.value = [];
    } finally {
      _isSubcategoriesLoading.value = false;
    }
  }

  // الحصول على معرف التصنيف من الاسم
  int? getCategoryId(String categoryName) {
    if (categoryName.isEmpty) return null;

    print('🔍 Looking for category: "$categoryName"');

    // البحث في التصنيفات باستخدام displayName
    final category = categories.firstWhereOrNull(
      (cat) => cat.displayName == categoryName,
    );

    final categoryId = category?.id;
    print('🔍 Found category ID: $categoryId');

    return categoryId;
  }

  // الحصول على معرف التصنيف الفرعي من الاسم
  int? getSubcategoryId(String subcategoryName) {
    if (subcategoryName.isEmpty) return null;

    print('🔍 Looking for subcategory: "$subcategoryName"');

    final subcategory = subcategories.firstWhereOrNull(
      (cat) => cat.displayName == subcategoryName,
    );

    final subcategoryId = subcategory?.id;
    print('🔍 Found subcategory ID: $subcategoryId');

    return subcategoryId;
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

      // تحويل السعر من العربية إلى الإنجليزية باستخدام الدالة العامة
      final originalPrice = values['price']?.toString() ?? '0';
      final priceStr = Validators.convertArabicToEnglishNumbers(originalPrice);
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

      // تحويل حالة السلعة من العربية إلى الإنجليزية
      final arabicCondition =
          values['condition']?.toString() ?? 'مستعمل - ممتاز';
      final englishCondition =
          Validators.convertConditionToEnglish(arabicCondition);

      print('=== Item Condition Conversion ===');
      print('Arabic condition: $arabicCondition');
      print('English condition: $englishCondition');

      // الحصول على معرف التصنيف من الاسم المحدد
      final selectedCategoryName = values['category']?.toString() ?? '';
      final categoryId = getCategoryId(selectedCategoryName);

      print('=== Category Selection ===');
      print('Selected category name: $selectedCategoryName');
      print('Category ID: $categoryId');

      // التحقق من وجود التصنيف
      if (categoryId == null) {
        Get.snackbar(
          '❌ خطأ في التصنيف',
          'يرجى اختيار تصنيف صحيح',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // الحصول على معرف التصنيف الفرعي (إذا تم تحديده)
      final selectedSubcategoryName = values['subcategory']?.toString() ?? '';
      final subcategoryId = getSubcategoryId(selectedSubcategoryName);

      print('=== Subcategory Selection ===');
      print('Selected subcategory name: $selectedSubcategoryName');
      print('Subcategory ID: $subcategoryId');

      // إنشاء البيانات للسلعة
      final itemData = {
        'title': values['title'],
        'description': values['description'],
        'category_id': categoryId,
        'condition': englishCondition,
        'price': price,
        'exchange_for': values['exchange_for'] ?? '',
        'location': values['location'],
        'phone': values['phone'] ?? '',
        'status': 'available',
        'latitude': 31.5017,
        'longitude': 34.4668,
        'location_name': values['location'],
      };

      // إضافة معرف التصنيف الفرعي إذا تم تحديده
      if (subcategoryId != null) {
        itemData['subcategory_id'] = subcategoryId;
      }

      // تحويل مسارات الصور إلى قائمة
      final imagePaths = _selectedImages.map((file) => file.path).toList();

      print('=== Item Data ===');
      print('Item data: $itemData');
      print('Image paths: $imagePaths');

      // إرسال البيانات باستخدام الدالة الجديدة
      final response = await ApiService.to.uploadItemWithImages(
        'items',
        imagePaths: imagePaths,
        data: itemData,
      );

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
        );
      }
    } catch (e) {
      print('=== Error Details ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');

      String errorMessage = 'حدث خطأ أثناء إضافة السلعة';
      if (e is dio.DioException) {
        if (e.response?.statusCode == 422) {
          final errors = e.response?.data['errors'];
          if (errors != null && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first;
            }
          }
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'يرجى تسجيل الدخول مرة أخرى';
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'غير مخول لإضافة سلعة';
        }
      }

      Get.snackbar(
        '❌ خطأ',
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
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
