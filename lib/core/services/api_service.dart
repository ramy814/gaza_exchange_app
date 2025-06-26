import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' hide Response;
import 'storage_service.dart';

class ApiService extends GetxService {
  static ApiService get to => Get.find();

  late dio.Dio _dio;
  final String baseUrl = 'http://localhost:8000/api/';

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
    final formData = dio.FormData.fromMap({
      fieldName: await dio.MultipartFile.fromFile(filePath),
      ...?additionalData,
    });

    return await _dio.post(path, data: formData);
  }

  // User APIs
  Future<dio.Response> getUserProfile() async {
    return await _dio.get('/user/profile');
  }

  Future<dio.Response> getUserStatistics() async {
    return await _dio.get('/user/statistics');
  }

  Future<dio.Response> getUserRecentActivity() async {
    return await _dio.get('/user/recent-activity');
  }

  // Items APIs
  Future<dio.Response> getAllItems() async {
    return await _dio.get('/items');
  }

  Future<dio.Response> getTrendingItems() async {
    return await _dio.get('/items/trending');
  }

  Future<dio.Response> getItem(int id) async {
    return await _dio.get('/items/$id');
  }

  Future<dio.Response> createItem(dio.FormData formData) async {
    return await _dio.post('/items', data: formData);
  }

  Future<dio.Response> updateItem(int id, dio.FormData formData) async {
    return await _dio.put('/items/$id', data: formData);
  }

  Future<dio.Response> deleteItem(int id) async {
    return await _dio.delete('/items/$id');
  }

  // Properties APIs
  Future<dio.Response> getAllProperties() async {
    return await _dio.get('/properties');
  }

  Future<dio.Response> getProperty(int id) async {
    return await _dio.get('/properties/$id');
  }

  Future<dio.Response> createProperty(dio.FormData formData) async {
    return await _dio.post('/properties', data: formData);
  }

  Future<dio.Response> updateProperty(int id, dio.FormData formData) async {
    return await _dio.put('/properties/$id', data: formData);
  }

  Future<dio.Response> deleteProperty(int id) async {
    return await _dio.delete('/properties/$id');
  }
}
