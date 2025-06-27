import 'package:get/get.dart';
import 'package:gaza_exchange_app/core/models/user_model.dart';
import 'package:gaza_exchange_app/core/models/statistics_model.dart';
import 'package:gaza_exchange_app/core/models/recent_activity_model.dart';
import 'api_service.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();

  final ApiService _apiService = Get.find<ApiService>();

  // عرض الملف الشخصي مع الإحصائيات
  Future<UserModel?> getUserProfile() async {
    try {
      final response = await _apiService.getUserProfile();
      if (response.statusCode == 200) {
        final userData = response.data['user'];
        return UserModel.fromJson(userData);
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
        final statsData = response.data['statistics'];
        return StatisticsModel.fromJson(statsData);
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
        final activitiesData = response.data['recent_activity'] as List;
        return activitiesData
            .map((activity) => RecentActivityModel.fromJson(activity))
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
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating user location: $e');
      return false;
    }
  }

  // Get basic profile
  Future<UserModel?> getProfile() async {
    try {
      final response = await _apiService.getProfile();
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      print('Error in getProfile: $e');
      Get.snackbar('خطأ', 'فشل في تحميل الملف الشخصي');
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

      return {
        'user': UserModel.fromJson(response.data['user']),
        'token': response.data['token'],
      };
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

      return {
        'user': UserModel.fromJson(response.data['user']),
        'token': response.data['token'],
      };
    } catch (e) {
      print('Error in login: $e');
      Get.snackbar('خطأ', 'فشل في تسجيل الدخول');
      return null;
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      await _apiService.logout();
      return true;
    } catch (e) {
      print('Error in logout: $e');
      Get.snackbar('خطأ', 'فشل في تسجيل الخروج');
      return false;
    }
  }
}
