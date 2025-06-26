import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gaza_exchange_app/core/models/user_model.dart';
import 'dart:convert';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  SharedPreferences? _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Regular storage methods
  Future<bool> write(String key, dynamic value) async {
    if (value is String) {
      return await _prefs!.setString(key, value);
    } else if (value is int) {
      return await _prefs!.setInt(key, value);
    } else if (value is bool) {
      return await _prefs!.setBool(key, value);
    } else if (value is double) {
      return await _prefs!.setDouble(key, value);
    } else if (value is List<String>) {
      return await _prefs!.setStringList(key, value);
    }
    return false;
  }

  T? read<T>(String key) {
    return _prefs!.get(key) as T?;
  }

  Future<bool> remove(String key) async {
    return await _prefs!.remove(key);
  }

  // Secure storage methods
  Future<void> writeSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> readSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  // Token management
  Future<void> saveToken(String token) async {
    await writeSecure('auth_token', token);
  }

  Future<String?> getToken() async {
    return await readSecure('auth_token');
  }

  Future<void> deleteToken() async {
    await deleteSecure('auth_token');
  }

  // User management
  Future<void> saveUser(UserModel user) async {
    await write('user_data', jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final userData = read<String>('user_data');
    if (userData != null) {
      try {
        return UserModel.fromJson(jsonDecode(userData));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> deleteUser() async {
    await remove('user_data');
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs!.clear();
    await clearSecure();
  }
}
