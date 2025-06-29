import 'package:get/get.dart';
import 'package:gaza_exchange_app/core/models/user_model.dart';
import 'package:gaza_exchange_app/core/models/statistics_model.dart';
import 'package:gaza_exchange_app/core/models/recent_activity_model.dart';
import 'package:gaza_exchange_app/core/models/api_response_model.dart';
import 'api_service.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();

  final ApiService _apiService = Get.find<ApiService>();

  // عرض الملف الشخصي مع الإحصائيات
  Future<UserModel?> getUserProfile() async {
    try {
      final response = await _apiService.getUserProfile();
      if (response.statusCode == 200) {
        final responseData = response.data;
        dynamic userData;
        if (responseData['data'] != null &&
            responseData['data']['user'] != null) {
          userData = responseData['data']['user'];
        } else if (responseData['user'] != null) {
          userData = responseData['user'];
        } else {
          userData = null;
        }
        if (userData != null) {
          return UserModel.fromJson(userData);
        }
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // عرض إحصائيات المستخدم
  Future<StatisticsModel?> getUserStatistics() async {
    try {
      final response = await _apiService.getUserStatistics();
      if (response.statusCode == 200) {
        final responseData = response.data;
        dynamic statsData;
        if (responseData['data'] != null &&
            responseData['data']['statistics'] != null) {
          statsData = responseData['data']['statistics'];
        } else if (responseData['statistics'] != null) {
          statsData = responseData['statistics'];
        } else {
          statsData = null;
        }
        if (statsData != null) {
          return StatisticsModel.fromJson(statsData);
        }
      }
      return null;
    } catch (e) {
      print('Error getting user statistics: $e');
      return null;
    }
  }

  // عرض النشاط الأخير
  Future<List<RecentActivityModel>> getUserRecentActivity() async {
    try {
      final response = await _apiService.getUserRecentActivity();
      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> activities = [];
        if (responseData['data'] != null &&
            responseData['data']['recent_activity'] != null) {
          activities = responseData['data']['recent_activity'] as List;
        } else if (responseData['recent_activity'] != null) {
          activities = responseData['recent_activity'] as List;
        }
        return activities
            .map((item) => RecentActivityModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting recent activity: $e');
      return [];
    }
  }

  // تحديث موقع المستخدم
  Future<bool> updateUserLocation({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      final response = await _apiService.updateUserLocation({
        'latitude': latitude,
        'longitude': longitude,
        'location_name': locationName,
      });
      if (response.statusCode == 200) {
        final responseData = response.data;
        bool success = false;
        if (responseData['success'] != null) {
          success = responseData['success'] == true;
        }
        return success;
      }
      return false;
    } catch (e) {
      print('Error updating user location: $e');
      return false;
    }
  }

  // Get basic profile
  Future<UserModel?> getProfile() async {
    try {
      final response = await _apiService.getProfile();
      if (response.statusCode == 200) {
        final responseData = response.data;
        dynamic userData;
        if (responseData['data'] != null &&
            responseData['data']['user'] != null) {
          userData = responseData['data']['user'];
        } else if (responseData['user'] != null) {
          userData = responseData['user'];
        } else {
          userData = null;
        }
        if (userData != null) {
          return UserModel.fromJson(userData);
        }
      }
      return null;
    } catch (e) {
      print('Error in getProfile: $e');
      return null;
    }
  }

  // Register new user
  Future<Map<String, dynamic>?> register({
    required String name,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiService.register({
        'name': name,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      if (response.statusCode == 200) {
        final apiResponse = ApiResponseModel.fromJson(
          response.data,
          (json) => json, // البيانات تحتوي على user و token
        );

        if (apiResponse.success && apiResponse.data != null) {
          final data = apiResponse.data as Map<String, dynamic>;
          return {
            'user': UserModel.fromJson(data['user']),
            'token': data['token'],
          };
        } else {
          print('Error: ${apiResponse.message}');
          Get.snackbar('خطأ', apiResponse.message ?? 'فشل في تسجيل المستخدم');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error in register: $e');
      Get.snackbar('خطأ', 'فشل في تسجيل المستخدم');
      return null;
    }
  }

  // Login user
  Future<Map<String, dynamic>?> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiService.login({
        'phone': phone,
        'password': password,
      });

      if (response.statusCode == 200) {
        final apiResponse = ApiResponseModel.fromJson(
          response.data,
          (json) => json, // البيانات تحتوي على user و token
        );

        if (apiResponse.success && apiResponse.data != null) {
          final data = apiResponse.data as Map<String, dynamic>;
          return {
            'user': UserModel.fromJson(data['user']),
            'token': data['token'],
          };
        } else {
          print('Error: ${apiResponse.message}');
          Get.snackbar('خطأ', apiResponse.message ?? 'فشل في تسجيل الدخول');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error in login: $e');
      Get.snackbar('خطأ', 'فشل في تسجيل الدخول');
      return null;
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      final response = await _apiService.logout();
      if (response.statusCode == 200) {
        final apiResponse = ApiResponseModel.fromJson(response.data, null);
        return apiResponse.success;
      }
      return false;
    } catch (e) {
      print('Error in logout: $e');
      Get.snackbar('خطأ', 'فشل في تسجيل الخروج');
      return false;
    }
  }
}
