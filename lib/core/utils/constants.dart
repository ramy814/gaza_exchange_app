class AppConstants {
  // Environment configuration
  static const bool isDevelopment = true; // Set to false for production

  // API URLs
  static const String baseUrl = 'http://localhost:8000/api/';

  // App Info
  static const String appName = 'تبادل غزة';
  static const String appVersion = '2.0.0';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String userLocationKey = 'user_location';

  // Limits
  static const int maxItemImages = 5;
  static const int maxPropertyImages = 8;
  static const int maxDescriptionLength = 500;
  static const int maxImageSizeMB = 2;
  static const int maxSearchRadius = 50; // km
  static const int defaultSearchRadius = 10; // km

  // Item Status
  static const String itemStatusAvailable = 'available';
  static const String itemStatusSold = 'sold';

  // Property Types
  static const String propertyTypeBuy = 'buy';
  static const String propertyTypeRent = 'rent';
  static const String propertyTypeExchange = 'exchange';

  // Gaza Areas
  static const List<String> gazaAreas = [
    'غزة',
    'الشمال',
    'دير البلح',
    'خان يونس',
    'رفح',
  ];

  // Default Values
  static const double defaultRadius = 10.0; // km
  static const int defaultPageSize = 20;

  // Image Settings
  static const int maxImageSize = 2 * 1024 * 1024; // 2MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];

  // Location Settings
  static const double defaultLatitude = 31.5017;
  static const double defaultLongitude = 34.4668;
  static const String defaultLocationName = 'غزة، فلسطين';

  // Property Types
  static const List<String> propertyTypes = ['شقة', 'منزل', 'تجاري', 'أرض'];

  // Purposes
  static const List<String> purposes = ['بيع', 'إيجار', 'تبادل'];

  // Error Messages
  static const String networkError = 'خطأ في الاتصال بالشبكة';
  static const String serverError = 'خطأ في الخادم';
  static const String unauthorizedError = 'غير مخول للقيام بهذا الإجراء';
  static const String validationError = 'بيانات غير صحيحة';
  static const String notFoundError = 'البيانات المطلوبة غير موجودة';

  // Success Messages
  static const String itemCreatedSuccess = 'تم إنشاء السلعة بنجاح';
  static const String itemUpdatedSuccess = 'تم تحديث السلعة بنجاح';
  static const String itemDeletedSuccess = 'تم حذف السلعة بنجاح';
  static const String propertyCreatedSuccess = 'تم إنشاء العقار بنجاح';
  static const String propertyUpdatedSuccess = 'تم تحديث العقار بنجاح';
  static const String propertyDeletedSuccess = 'تم حذف العقار بنجاح';
  static const String locationUpdatedSuccess = 'تم تحديث الموقع بنجاح';
}
