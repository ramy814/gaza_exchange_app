import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:dio/dio.dart' as dio;

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
    if (token != null) {
      await _getUserProfile();
    }
  }

  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible.value = !_isConfirmPasswordVisible.value;
  }

  // دالة لتحويل الأرقام العربية للإنجليزية
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

    print('=== Number Conversion ===');
    print('Input: $input');
    print('Output: $result');

    return result;
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

      // اختبار الاتصال أولاً
      print('=== Testing Connection ===');
      final isConnected = await ApiService.to.testConnection();
      if (!isConnected) {
        Get.snackbar(
          'خطأ في الاتصال',
          'لا يمكن الاتصال بالسيرفر، تأكد من أن السيرفر يعمل',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
        return;
      }

      final values = loginFormKey.currentState!.value;

      // تحويل الأرقام العربية للإنجليزية
      final phone =
          convertArabicToEnglishNumbers(values['phone'].toString().trim());
      final password =
          convertArabicToEnglishNumbers(values['password'].toString());

      final requestData = {
        'phone': phone,
        'password': password,
      };

      print('=== Login Request Data ===');
      print('Phone: $phone (original: ${values['phone']})');
      print('Password Length: ${password.length}');

      final response = await ApiService.to.login(requestData);

      print('=== Login Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // حفظ بيانات المستخدم والـ token
        final responseData = response.data;

        if (responseData['token'] != null) {
          await StorageService.to
              .writeSecure('auth_token', responseData['token']);
        }

        if (responseData['user'] != null) {
          try {
            await StorageService.to
                .writeSecure('user_data', responseData['user'].toString());
            _user.value = UserModel.fromJson(responseData['user']);
          } catch (parseError) {
            print('=== User Data Parse Error ===');
            print('Error parsing user data: $parseError');
            print('User data: ${responseData['user']}');

            // إذا فشل في تحليل بيانات المستخدم، نستمر مع الـ token فقط
            Get.snackbar(
              'تحذير',
              'تم تسجيل الدخول بنجاح، لكن هناك مشكلة في تحميل البيانات الشخصية',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              icon: const Icon(Icons.warning, color: Colors.white),
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
            );
          }
        }

        Get.snackbar(
          'نجح',
          'تم تسجيل الدخول بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );

        // الانتقال للصفحة الرئيسية
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      print('=== Login Error ===');
      print('Error: $e');

      String errorMessage = 'فشل في تسجيل الدخول';

      if (e is dio.DioException) {
        print('DioError Type: ${e.type}');
        print('DioError Response: ${e.response?.data}');
        print('DioError Status Code: ${e.response?.statusCode}');

        if (e.response?.statusCode == 422) {
          errorMessage = 'رقم الهاتف أو كلمة المرور غير صحيحة';
        } else if (e.response?.statusCode == 500) {
          errorMessage = 'خطأ في الخادم، يرجى المحاولة لاحقاً';
        }
      }

      Get.snackbar(
        'خطأ',
        errorMessage,
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

      // اختبار الاتصال أولاً
      print('=== Testing Connection ===');
      final isConnected = await ApiService.to.testConnection();
      if (!isConnected) {
        Get.snackbar(
          'خطأ في الاتصال',
          'لا يمكن الاتصال بالسيرفر، تأكد من أن السيرفر يعمل',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
        return;
      }

      final values = registerFormKey.currentState!.value;

      // التحقق من الحقول المطلوبة يدوياً
      if (values['name'] == null || values['name'].toString().trim().isEmpty) {
        Get.snackbar('خطأ', 'الاسم مطلوب');
        return;
      }

      if (values['phone'] == null ||
          values['phone'].toString().trim().isEmpty) {
        Get.snackbar('خطأ', 'رقم الهاتف مطلوب');
        return;
      }

      if (values['password'] == null || values['password'].toString().isEmpty) {
        Get.snackbar('خطأ', 'كلمة المرور مطلوبة');
        return;
      }

      if (values['password_confirmation'] == null ||
          values['password_confirmation'].toString().isEmpty) {
        Get.snackbar('خطأ', 'تأكيد كلمة المرور مطلوب');
        return;
      }

      // التحقق من تطابق كلمات المرور
      if (values['password'] != values['password_confirmation']) {
        Get.snackbar('خطأ', 'كلمة المرور غير متطابقة');
        return;
      }

      // تحويل الأرقام العربية للإنجليزية
      final name = values['name'].toString().trim();
      final phone =
          convertArabicToEnglishNumbers(values['phone'].toString().trim());
      final password =
          convertArabicToEnglishNumbers(values['password'].toString());
      final passwordConfirmation = convertArabicToEnglishNumbers(
          values['password_confirmation'].toString());

      // إعداد البيانات حسب متطلبات الـ API
      final requestData = {
        'name': name,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

      print('=== Register Request Data ===');
      print('Name: $name');
      print('Phone: $phone (original: ${values['phone']})');
      print('Password Length: ${password.length}');
      print('Password Confirmation Length: ${passwordConfirmation.length}');

      final response = await ApiService.to.register(requestData);

      print('=== Register Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 201) {
        // حفظ بيانات المستخدم والـ token
        final responseData = response.data;

        if (responseData['token'] != null) {
          await StorageService.to
              .writeSecure('auth_token', responseData['token']);
        }

        if (responseData['user'] != null) {
          try {
            await StorageService.to
                .writeSecure('user_data', responseData['user'].toString());
            _user.value = UserModel.fromJson(responseData['user']);
          } catch (parseError) {
            print('=== User Data Parse Error ===');
            print('Error parsing user data: $parseError');
            print('User data: ${responseData['user']}');

            // إذا فشل في تحليل بيانات المستخدم، نستمر مع الـ token فقط
            Get.snackbar(
              'تحذير',
              'تم إنشاء الحساب بنجاح، لكن هناك مشكلة في تحميل البيانات الشخصية',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              icon: const Icon(Icons.warning, color: Colors.white),
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
            );
          }
        }

        Get.snackbar(
          'نجح',
          'تم إنشاء الحساب بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );

        // الانتقال للصفحة الرئيسية
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      print('=== Register Error ===');
      print('Error: $e');

      String errorMessage = 'فشل في إنشاء الحساب';

      if (e is dio.DioException) {
        print('DioError Type: ${e.type}');
        print('DioError Response: ${e.response?.data}');
        print('DioError Status Code: ${e.response?.statusCode}');

        if (e.response?.statusCode == 422) {
          // خطأ في التحقق من البيانات
          final errors = e.response?.data['errors'];
          if (errors != null) {
            if (errors['phone'] != null) {
              errorMessage = 'رقم الهاتف مستخدم بالفعل';
            } else if (errors['password'] != null) {
              errorMessage = 'كلمة المرور غير صحيحة';
            } else if (errors['name'] != null) {
              errorMessage = 'الاسم غير صحيح';
            } else {
              errorMessage = errors.values.first[0] ?? 'بيانات غير صحيحة';
            }
          }
        } else if (e.response?.statusCode == 500) {
          errorMessage = 'خطأ في الخادم، يرجى المحاولة لاحقاً';
        }
      }

      Get.snackbar(
        'خطأ',
        errorMessage,
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

  Future<void> _getUserProfile() async {
    try {
      final response = await ApiService.to.get('profile');
      if (response.statusCode == 200) {
        _user.value = UserModel.fromJson(response.data['user']);
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.to.post('logout');
      await _clearAuthData();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      print('Logout error: $e');
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
