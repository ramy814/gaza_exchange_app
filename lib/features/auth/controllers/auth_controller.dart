import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../core/utils/validators.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isPasswordVisible = false.obs;
  final RxBool _isConfirmPasswordVisible = false.obs;

  UserModel? get user => _user.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _user.value != null;
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible.value;

  final loginFormKey = GlobalKey<FormBuilderState>();
  final registerFormKey = GlobalKey<FormBuilderState>();

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await StorageService.to.readSecure('auth_token');
    developer.log('🔍 Checking auth status...', name: 'AuthController');
    developer.log('🔍 Token available: ${token != null}',
        name: 'AuthController');
    if (token != null) {
      developer.log('🔍 Token found, getting user profile...',
          name: 'AuthController');
      await _getUserProfile();
    } else {
      developer.log('🔍 No token found, user not authenticated',
          name: 'AuthController');
    }
  }

  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible.value = !_isConfirmPasswordVisible.value;
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.saveAndValidate()) {
      Get.snackbar(
        'خطأ في النموذج',
        'يرجى التحقق من جميع الحقول المطلوبة',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    try {
      _isLoading.value = true;

      final values = loginFormKey.currentState!.value;

      // تحويل الأرقام العربية إلى الإنجليزية باستخدام الدالة العامة
      final phone = Validators.convertArabicToEnglishNumbers(
          values['phone'].toString().trim());
      final password = Validators.convertArabicToEnglishNumbers(
          values['password'].toString());

      developer.log('=== Login Data ===', name: 'AuthController');
      developer.log('Phone: $phone', name: 'AuthController');
      developer.log('Password: $password', name: 'AuthController');

      final response = await ApiService.to.login({
        'phone': phone,
        'password': password,
      });

      developer.log('=== Login Response ===', name: 'AuthController');
      developer.log('Status Code: ${response.statusCode}',
          name: 'AuthController');
      developer.log('Response Data: ${response.data}', name: 'AuthController');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final token = data['token'];
        final user = data['user'];

        // حفظ البيانات
        await StorageService.to.writeSecure('auth_token', token);
        await StorageService.to.writeSecure('user_data', user.toString());

        Get.offAllNamed(AppRoutes.home);
        Get.snackbar(
          '🎉 تم تسجيل الدخول بنجاح',
          'مرحباً بك في تطبيق تبادل غزة',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
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
      developer.log('=== Login Error ===', name: 'AuthController');
      developer.log('Error type: ${e.runtimeType}', name: 'AuthController');
      developer.log('Error message: $e', name: 'AuthController');

      String errorMessage = 'حدث خطأ أثناء تسجيل الدخول';
      if (e.toString().contains('422')) {
        errorMessage = 'رقم الهاتف أو كلمة المرور غير صحيحة';
      } else if (e.toString().contains('401')) {
        errorMessage = 'بيانات غير صحيحة';
      } else if (e.toString().contains('500')) {
        errorMessage = 'خطأ في الخادم، يرجى المحاولة لاحقاً';
      }

      Get.snackbar(
        '❌ خطأ في تسجيل الدخول',
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

  Future<void> register() async {
    if (!registerFormKey.currentState!.saveAndValidate()) {
      Get.snackbar(
        'خطأ في النموذج',
        'يرجى التحقق من جميع الحقول المطلوبة',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    try {
      _isLoading.value = true;

      final values = registerFormKey.currentState!.value;

      // تحويل الأرقام العربية إلى الإنجليزية باستخدام الدالة العامة
      final name = values['name'].toString().trim();
      final phone = Validators.convertArabicToEnglishNumbers(
          values['phone'].toString().trim());
      final password = Validators.convertArabicToEnglishNumbers(
          values['password'].toString());
      final passwordConfirmation = Validators.convertArabicToEnglishNumbers(
          values['password_confirmation'].toString());

      developer.log('=== Register Data ===', name: 'AuthController');
      developer.log('Name: $name', name: 'AuthController');
      developer.log('Phone: $phone', name: 'AuthController');
      developer.log('Password: $password', name: 'AuthController');
      developer.log('Password Confirmation: $passwordConfirmation',
          name: 'AuthController');

      // التحقق من تطابق كلمتي المرور
      if (password != passwordConfirmation) {
        Get.snackbar(
          '❌ خطأ',
          'كلمتا المرور غير متطابقتين',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final response = await ApiService.to.register({
        'name': name,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      developer.log('=== Register Response ===', name: 'AuthController');
      developer.log('Status Code: ${response.statusCode}',
          name: 'AuthController');
      developer.log('Response Data: ${response.data}', name: 'AuthController');

      if (response.statusCode == 201) {
        final data = response.data['data'];
        final token = data['token'];
        final user = data['user'];

        // حفظ البيانات
        await StorageService.to.writeSecure('auth_token', token);
        await StorageService.to.writeSecure('user_data', user.toString());

        Get.offAllNamed(AppRoutes.home);
        Get.snackbar(
          '🎉 تم التسجيل بنجاح',
          'مرحباً بك في تطبيق تبادل غزة',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
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
      developer.log('=== Register Error ===', name: 'AuthController');
      developer.log('Error type: ${e.runtimeType}', name: 'AuthController');
      developer.log('Error message: $e', name: 'AuthController');

      String errorMessage = 'حدث خطأ أثناء التسجيل';
      if (e.toString().contains('422')) {
        errorMessage = 'بيانات غير صحيحة، يرجى التحقق من المعلومات المدخلة';
      } else if (e.toString().contains('409')) {
        errorMessage = 'رقم الهاتف مسجل مسبقاً';
      } else if (e.toString().contains('500')) {
        errorMessage = 'خطأ في الخادم، يرجى المحاولة لاحقاً';
      }

      Get.snackbar(
        '❌ خطأ في التسجيل',
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

  Future<void> _getUserProfile() async {
    try {
      final response = await ApiService.to.get('user/profile');
      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle both old and new API response formats
        Map<String, dynamic> userData;

        if (responseData['data'] != null) {
          // New format: {success, message, data: {user}, errors}
          userData = responseData['data']['user'] ?? {};
        } else {
          // Old format: {user}
          userData = responseData['user'] ?? {};
        }

        if (userData.isNotEmpty) {
          _user.value = UserModel.fromJson(userData);
        }
      }
    } catch (e) {
      developer.log('Error getting user profile: $e', name: 'AuthController');
      await logout();
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.to.post('logout');
      await _clearAuthData();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      developer.log('Logout error: $e', name: 'AuthController');
      // حتى لو فشل الطلب، نقوم بحذف البيانات المحلية
      await _clearAuthData();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _clearAuthData() async {
    await StorageService.to.deleteSecure('auth_token');
    await StorageService.to.deleteSecure('user_data');
    _user.value = null;
  }
}
