import 'package:flutter_test/flutter_test.dart';
import 'package:gaza_exchange_app/core/models/api_response_model.dart';
import 'package:gaza_exchange_app/core/models/user_model.dart';

void main() {
  group('API Response Model Tests', () {
    test('should parse new API response format correctly', () {
      final json = {
        'success': true,
        'message': 'Login successful',
        'data': {
          'user': {
            'id': 1,
            'name': 'أحمد محمد علي',
            'phone': '0599123456',
            'phone_verified_at': null,
            'latitude': '31.50170000',
            'longitude': '34.46680000',
            'location_name': 'غزة، فلسطين',
            'created_at': '2025-06-27T08:10:56.000000Z',
            'updated_at': '2025-06-27T08:10:56.000000Z',
          },
          'token': '15|PP3ccA7KbgBJakoyDG8DvhhNQuoIqpseBLKAGI99ac1a0da4',
        },
        'errors': null,
      };

      final apiResponse = ApiResponseModel.fromJson(
        json,
        (data) => UserModel.fromJson(data['user']),
      );

      expect(apiResponse.success, true);
      expect(apiResponse.message, 'Login successful');
      expect(apiResponse.errors, null);
      expect(apiResponse.data, isA<UserModel>());
      expect(apiResponse.data!.name, 'أحمد محمد علي');
      expect(apiResponse.data!.phone, '0599123456');
    });

    test('should parse old API response format correctly', () {
      final json = {
        'user': {
          'id': 1,
          'name': 'أحمد محمد علي',
          'phone': '0599123456',
          'phone_verified_at': null,
          'latitude': '31.50170000',
          'longitude': '34.46680000',
          'location_name': 'غزة، فلسطين',
          'created_at': '2025-06-27T08:10:56.000000Z',
          'updated_at': '2025-06-27T08:10:56.000000Z',
        },
        'token': '15|PP3ccA7KbgBJakoyDG8DvhhNQuoIqpseBLKAGI99ac1a0da4',
      };

      final apiResponse = ApiResponseModel.fromJson(
        json,
        (data) => UserModel.fromJson(data['user']),
      );

      expect(apiResponse.success, true);
      expect(apiResponse.data, isA<UserModel>());
      expect(apiResponse.data!.name, 'أحمد محمد علي');
      expect(apiResponse.data!.phone, '0599123456');
    });

    test('should handle error response correctly', () {
      final json = {
        'success': false,
        'message': 'Invalid credentials',
        'data': null,
        'errors': {
          'phone': ['The phone field is required.'],
        },
      };

      final apiResponse = ApiResponseModel.fromJson(
        json,
        (json) => UserModel.fromJson(json),
      );

      expect(apiResponse.success, false);
      expect(apiResponse.message, 'Invalid credentials');
      expect(apiResponse.data, null);
      expect(apiResponse.errors, isA<Map<String, dynamic>>());
      expect(apiResponse.errors!['phone'], isA<List>());
    });
  });
}
