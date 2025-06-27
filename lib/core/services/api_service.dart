import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' hide Response;
import 'storage_service.dart';

class ApiService extends GetxService {
  static ApiService get to => Get.find();

  late dio.Dio _dio;

  // خيارات متعددة للـ baseUrl حسب البيئة
  // اختر المناسب حسب جهازك:

  // للـ iOS Simulator أو Web
  final String baseUrl = 'http://localhost:8000/api/';

  // للـ Android Emulator
  // final String baseUrl = 'http://10.0.2.2:8000/api/';

  // للـ Android Device (استخدم IP جهازك)
  // final String baseUrl = 'http://192.168.1.100:8000/api/';

  // للـ iOS Device (استخدم IP جهازك)
  // final String baseUrl = 'http://192.168.1.100:8000/api/';

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await StorageService.to.readSecure('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally
          _handleError(error);
          handler.next(error);
        },
      ),
    );

    // إضافة interceptor للـ debug
    _dio.interceptors.add(dio.LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('🌐 API: $obj'),
    ));
  }

  void _handleError(dio.DioException error) {
    switch (error.response?.statusCode) {
      case 401:
        // Unauthorized - logout user
        Get.find<StorageService>().clearSecure();
        if (Get.currentRoute != '/login') {
          Get.offAllNamed('/login');
        }
        break;
      case 422:
        // Validation errors
        final errors = error.response?.data['errors'];
        if (errors != null) {
          final errorMessage = errors.values.first.toString();
          Get.snackbar('خطأ في البيانات', errorMessage);
        } else {
          Get.snackbar('خطأ', 'بيانات غير صحيحة');
        }
        break;
      case 403:
        Get.snackbar('خطأ', 'غير مخول للقيام بهذا الإجراء');
        break;
      case 404:
        Get.snackbar('خطأ', 'البيانات المطلوبة غير موجودة');
        break;
      case 500:
        Get.snackbar('خطأ', 'خطأ في الخادم، يرجى المحاولة لاحقاً');
        break;
      default:
        Get.snackbar('خطأ', 'حدث خطأ غير متوقع');
    }
  }

  // HTTP Methods
  Future<dio.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<dio.Response> post(String path, {dynamic data}) async {
    print('🌐 POST Request to: $path');
    print('🌐 Data type: ${data.runtimeType}');

    // إذا كانت البيانات FormData، لا نضبط Content-Type
    if (data is dio.FormData) {
      print(
          '🌐 Sending FormData with ${data.fields.length} fields and ${data.files.length} files');
      for (var field in data.fields) {
        print('🌐 Field: ${field.key} = ${field.value}');
      }
      for (var file in data.files) {
        print(
            '🌐 File: ${file.key} = ${file.value.filename} (${file.value.length} bytes)');
      }

      return await _dio.post(
        path,
        data: data,
        options: dio.Options(
          headers: {
            'Accept': 'application/json',
            // لا نضبط Content-Type هنا لأن Dio سيفعل ذلك تلقائياً لـ FormData
          },
        ),
      );
    }

    // للبيانات العادية، نستخدم Content-Type الافتراضي
    print('🌐 Sending JSON data: $data');
    return await _dio.post(path, data: data);
  }

  Future<dio.Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<dio.Response> delete(String path) async {
    return await _dio.delete(path);
  }

  // Upload file with FormData
  Future<dio.Response> uploadFile(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
  }) async {
    final Map<String, dynamic> formDataMap = {};

    // إضافة الملف فقط إذا كان موجوداً وليس فارغاً
    if (filePath.isNotEmpty) {
      formDataMap[fieldName] = await dio.MultipartFile.fromFile(filePath);
    }

    // إضافة البيانات الإضافية
    if (additionalData != null) {
      formDataMap.addAll(additionalData);
    }

    final formData = dio.FormData.fromMap(formDataMap);
    return await _dio.post(path, data: formData);
  }

  // دالة لاختبار الاتصال بالسيرفر
  Future<bool> testConnection() async {
    try {
      print('🌐 Testing connection to: ${baseUrl}categories');
      final response = await _dio.get('categories');
      print('🌐 Connection test successful: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('🌐 Connection test failed: $e');
      return false;
    }
  }

  // Authentication APIs
  Future<dio.Response> register(Map<String, dynamic> data) async {
    print('🌐 Register URL: ${baseUrl}register');
    print('🌐 Register Data: $data');
    return await _dio.post('register', data: data);
  }

  Future<dio.Response> login(Map<String, dynamic> data) async {
    print('🌐 Login URL: ${baseUrl}login');
    print('🌐 Login Data: $data');
    return await _dio.post('login', data: data);
  }

  Future<dio.Response> logout() async {
    print('🌐 Logout URL: ${baseUrl}logout');
    return await _dio.post('logout');
  }

  Future<dio.Response> getProfile() async {
    print('🌐 Profile URL: ${baseUrl}profile');
    return await _dio.get('profile');
  }

  // User APIs
  Future<dio.Response> getUserProfile() async {
    return await _dio.get('user/profile');
  }

  Future<dio.Response> getUserStatistics() async {
    return await _dio.get('user/statistics');
  }

  Future<dio.Response> getUserRecentActivity() async {
    return await _dio.get('user/recent-activity');
  }

  Future<dio.Response> updateUserLocation(Map<String, dynamic> data) async {
    return await _dio.put('user/location', data: data);
  }

  // Categories APIs
  Future<dio.Response> getAllCategories() async {
    return await _dio.get('categories');
  }

  Future<dio.Response> getMainCategories() async {
    return await _dio.get('categories/main');
  }

  Future<dio.Response> getCategory(int id) async {
    return await _dio.get('categories/$id');
  }

  Future<dio.Response> getSubcategories(int categoryId) async {
    return await _dio.get('categories/$categoryId/subcategories');
  }

  Future<dio.Response> searchCategories(String query) async {
    return await _dio.get('categories/search', queryParameters: {'q': query});
  }

  Future<dio.Response> createCategory(Map<String, dynamic> data) async {
    return await _dio.post('categories', data: data);
  }

  Future<dio.Response> updateCategory(int id, Map<String, dynamic> data) async {
    return await _dio.put('categories/$id', data: data);
  }

  Future<dio.Response> deleteCategory(int id) async {
    return await _dio.delete('categories/$id');
  }

  // Items APIs
  Future<dio.Response> getAllItems({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get('items', queryParameters: queryParameters);
  }

  Future<dio.Response> getNearbyItems({
    required double latitude,
    required double longitude,
    double radius = 10,
  }) async {
    return await _dio.get('items/nearby', queryParameters: {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    });
  }

  Future<dio.Response> getTrendingItems() async {
    return await _dio.get('items/trending');
  }

  Future<dio.Response> getItem(int id) async {
    return await _dio.get('items/$id');
  }

  Future<dio.Response> createItem(dio.FormData formData) async {
    return await _dio.post('items', data: formData);
  }

  Future<dio.Response> updateItem(int id, dio.FormData formData) async {
    return await _dio.put('items/$id', data: formData);
  }

  Future<dio.Response> deleteItem(int id) async {
    return await _dio.delete('items/$id');
  }

  // Properties APIs
  Future<dio.Response> getAllProperties({
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get('properties', queryParameters: queryParameters);
  }

  Future<dio.Response> getProperty(int id) async {
    return await _dio.get('properties/$id');
  }

  Future<dio.Response> createProperty(dio.FormData formData) async {
    return await _dio.post('properties', data: formData);
  }

  Future<dio.Response> updateProperty(int id, dio.FormData formData) async {
    return await _dio.put('properties/$id', data: formData);
  }

  Future<dio.Response> deleteProperty(int id) async {
    return await _dio.delete('properties/$id');
  }
}
