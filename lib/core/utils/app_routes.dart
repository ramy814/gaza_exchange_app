import 'package:get/get.dart';
import 'package:gaza_exchange_app/features/splash/views/splash_view.dart';
import 'package:gaza_exchange_app/features/auth/views/login_view.dart';
import 'package:gaza_exchange_app/features/auth/views/register_view.dart';
import 'package:gaza_exchange_app/features/home/views/home_view.dart';
import 'package:gaza_exchange_app/features/items/views/items_list_view.dart';
import 'package:gaza_exchange_app/features/items/views/add_item_view.dart';
import 'package:gaza_exchange_app/features/items/views/item_detail_view.dart';
import 'package:gaza_exchange_app/features/items/controllers/item_detail_controller.dart';
import 'package:gaza_exchange_app/features/properties/views/properties_list_view.dart';
import 'package:gaza_exchange_app/features/properties/views/add_property_view.dart';
import 'package:gaza_exchange_app/features/properties/views/property_detail_view.dart';
import 'package:gaza_exchange_app/features/properties/controllers/property_detail_controller.dart';
import 'package:gaza_exchange_app/features/profile/views/profile_view.dart';
import 'package:gaza_exchange_app/features/properties/controllers/properties_controller.dart';
import 'package:gaza_exchange_app/features/home/controllers/home_controller.dart';
import 'package:gaza_exchange_app/features/items/controllers/items_controller.dart';
import 'package:gaza_exchange_app/features/profile/controllers/profile_controller.dart';

class AppRoutes {
  // Route names as static constants
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String items = '/items';
  static const String properties = '/properties';
  static const String profile = '/profile';
  static const String addItem = '/add-item';
  static const String addProperty = '/add-property';
  static const String itemDetail = '/item-detail';
  static const String propertyDetail = '/property-detail';

  static final routes = [
    // Splash route
    GetPage(
      name: splash,
      page: () => const SplashView(),
    ),

    // Home route (الشاشة الرئيسية)
    GetPage(
      name: home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
    ),

    // Auth routes
    GetPage(
      name: login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterView(),
    ),

    // Items routes
    GetPage(
      name: items,
      page: () => const ItemsListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ItemsController());
      }),
    ),

    // Properties routes
    GetPage(
      name: properties,
      page: () => const PropertiesListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PropertiesController());
      }),
    ),

    // Profile route
    GetPage(
      name: profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileController());
      }),
    ),

    // Add item route
    GetPage(name: addItem, page: () => const AddItemView()),

    // Add property route
    GetPage(name: addProperty, page: () => const AddPropertyView()),

    // Item detail route
    GetPage(
      name: '/item-detail/:id',
      page: () => const ItemDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ItemDetailController());
      }),
    ),

    // Property detail route
    GetPage(
      name: '/property-detail/:id',
      page: () => const PropertyDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PropertyDetailController());
      }),
    ),
  ];

  void goToPropertyDetail(int propertyId) {
    Get.toNamed('/property-detail/$propertyId');
  }
}
