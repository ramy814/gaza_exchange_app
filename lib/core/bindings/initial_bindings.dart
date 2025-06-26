import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../features/auth/controllers/auth_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);

    // Controllers
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
