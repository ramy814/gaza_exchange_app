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

  List<File> get selectedImages => _selectedImages;
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
      _selectedImages.add(File(image.path));
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

      // Create FormData for file upload
      final formData = dio.FormData.fromMap({
        'title': values['title'],
        'description': values['description'],
        'category': values['category'],
        'condition': values['condition'],
        'price': values['price'],
        'exchange_for': values['exchange_for'] ?? '',
        'location': values['location'],
      });

      // Add images
      for (int i = 0; i < _selectedImages.length; i++) {
        formData.files.add(
          MapEntry(
            'images[]',
            await dio.MultipartFile.fromFile(_selectedImages[i].path),
          ),
        );
      }

      final response = await ApiService.to.post('items', data: formData);

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
      }
    } catch (e) {
      Get.snackbar(
        '❌ حدث خطأ',
        'فشل في إضافة السلعة، يرجى المحاولة مرة أخرى',
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
