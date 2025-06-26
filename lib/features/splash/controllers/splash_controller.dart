import 'package:get/get.dart';
import 'package:gaza_exchange_app/core/services/storage_service.dart';
import 'package:gaza_exchange_app/core/utils/app_routes.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is logged in
    String? token = await _storageService.getToken();

    if (token != null && token.isNotEmpty) {
      // User is logged in, go to home
      Get.offAllNamed(AppRoutes.home);
    } else {
      // User is not logged in, go to login
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
