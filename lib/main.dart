import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gaza_exchange_app/core/bindings/initial_bindings.dart';
import 'package:gaza_exchange_app/core/services/storage_service.dart';
import 'package:gaza_exchange_app/core/utils/app_routes.dart';
import 'package:gaza_exchange_app/core/utils/app_theme.dart';
import 'package:gaza_exchange_app/features/splash/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await Get.putAsync(() => StorageService().init());

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gaza Exchange',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialBinding: InitialBindings(),
      initialRoute: '/',
      getPages: AppRoutes.routes,
      home: const SplashView(),
      locale: const Locale('ar', 'PS'),
      fallbackLocale: const Locale('en', 'US'),
      textDirection: TextDirection.rtl,
    );
  }
}
