import 'package:get/get.dart';
import 'package:dio/dio.dart';

class ErrorHandler {
  static void handleError(dynamic error) {
    String message = 'حدث خطأ غير متوقع';

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'انتهت مهلة الاتصال، تحقق من الإنترنت';
          break;
        case DioExceptionType.badResponse:
          message = _handleHttpError(error.response?.statusCode);
          break;
        case DioExceptionType.cancel:
          message = 'تم إلغاء الطلب';
          break;
        case DioExceptionType.unknown:
          message = 'لا يوجد اتصال بالإنترنت';
          break;
        default:
          message = 'حدث خطأ في الشبكة';
      }
    }

    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  static String _handleHttpError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'طلب غير صحيح';
      case 401:
        return 'غير مخول للوصول';
      case 403:
        return 'ممنوع الوصول';
      case 404:
        return 'المورد غير موجود';
      case 422:
        return 'بيانات غير صحيحة';
      case 500:
        return 'خطأ في الخادم';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
