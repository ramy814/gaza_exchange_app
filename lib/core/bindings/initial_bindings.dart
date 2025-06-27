import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/exchange_rate_service.dart';
import '../services/user_service.dart';
import '../services/category_service.dart';
import '../services/items_service.dart';
import '../services/properties_service.dart';
import '../../features/auth/controllers/auth_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<ExchangeRateService>(() => ExchangeRateService(), fenix: true);
    Get.lazyPut<UserService>(() => UserService(), fenix: true);
    Get.lazyPut<CategoryService>(() => CategoryService(), fenix: true);
    Get.lazyPut<ItemsService>(() => ItemsService(), fenix: true);
    Get.lazyPut<PropertiesService>(() => PropertiesService(), fenix: true);

    // Controllers
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
