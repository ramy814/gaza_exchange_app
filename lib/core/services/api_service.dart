import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' hide Response;
import 'storage_service.dart';
import '../utils/api_config.dart';
import 'dart:developer' as developer;
import 'dart:typed_data';

class ApiService extends GetxService {
  static ApiService get to => Get.find();

  late dio.Dio _dio;

  // Use the baseUrl from ApiConfig
  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await StorageService.to.readSecure('auth_token');
          print('🌐 API Request to: ${options.path}');
          print('🌐 Token available: ${token != null}');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🌐 Added Authorization header with token');
          } else {
            print('🌐 No token available for request');
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally
          print(
              '🌐 API Error for ${error.requestOptions.path}: ${error.response?.statusCode}');
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

  // Upload multiple images for items
  Future<dio.Response> uploadItemWithImages(
    String path, {
    required List<String> imagePaths,
    required Map<String, dynamic> data,
  }) async {
    final formData = dio.FormData.fromMap(data);

    // إضافة الصور المتعددة
    for (int i = 0; i < imagePaths.length; i++) {
      if (imagePaths[i].isNotEmpty) {
        final file = await dio.MultipartFile.fromFile(
          imagePaths[i],
          filename: 'item_image_$i.jpg',
        );
        formData.files.add(MapEntry('images[]', file));
      }
    }

    print('🌐 Uploading item with ${imagePaths.length} images');
    print('🌐 FormData fields: ${formData.fields}');
    print('🌐 FormData files count: ${formData.files.length}');

    return await _dio.post(path, data: formData);
  }

  // Upload multiple images for properties
  Future<dio.Response> uploadPropertyWithImages(
    String path, {
    required List<String> imagePaths,
    required Map<String, dynamic> data,
  }) async {
    final formData = dio.FormData.fromMap(data);

    // إضافة الصور المتعددة
    for (int i = 0; i < imagePaths.length; i++) {
      if (imagePaths[i].isNotEmpty) {
        final file = await dio.MultipartFile.fromFile(
          imagePaths[i],
          filename: 'property_image_$i.jpg',
        );
        formData.files.add(MapEntry('images[]', file));
      }
    }

    print('🌐 Uploading property with ${imagePaths.length} images');
    print('🌐 FormData fields: ${formData.fields}');
    print('🌐 FormData files count: ${formData.files.length}');

    return await _dio.post(path, data: formData);
  }

  // دالة لاختبار الاتصال بالسيرفر
  Future<bool> testConnection() async {
    print('🌐 Testing connection to: $baseUrl');
    // Try multiple endpoints to test connection
    final endpoints = ['categories', 'health', ''];
    for (String endpoint in endpoints) {
      try {
        print('🌐 Testing endpoint: $endpoint');
        final response = await _dio.get(endpoint);
        print('🌐 Connection test successful: ${response.statusCode}');
        return response.statusCode == 200;
      } catch (e) {
        print('🌐 Connection test failed for $endpoint: $e');
        if (e is dio.DioException) {
          print('🌐 Error type: ${e.type}');
          print('🌐 Error message: ${e.message}');
          if (e.response != null) {
            print('🌐 Response status: ${e.response!.statusCode}');
            print('🌐 Response data: ${e.response!.data}');
          }
        }
      }
    }
    print('🌐 All connection tests failed');
    return false;
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
    print('🌐 Profile URL: ${baseUrl}user/profile');
    return await _dio.get('user/profile');
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

  // Get image through API endpoint (for private storage)
  Future<Uint8List?> getImageBytes(String imagePath) async {
    try {
      final response = await _dio.get(
        'image',
        queryParameters: {'path': imagePath},
        options: dio.Options(
          responseType: dio.ResponseType.bytes,
          headers: {
            'Accept': 'image/*',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      }
      return null;
    } catch (e) {
      developer.log('❌ Error fetching image: $e', name: 'ApiService');
      return null;
    }
  }

  // Get image URL for API endpoint
  String getImageApiUrl(String imagePath) {
    // Remove leading slash if present
    String cleanPath =
        imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '${ApiConfig.baseUrl}image?path=$cleanPath';
  }
}
