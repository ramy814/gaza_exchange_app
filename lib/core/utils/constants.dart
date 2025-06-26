class AppConstants {
  // API
  static const String baseUrl = 'https://your-api-base-url.com/api/';

  // App Info
  static const String appName = 'تبادل غزة';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // Limits
  static const int maxItemImages = 5;
  static const int maxPropertyImages = 8;
  static const int maxDescriptionLength = 500;

  // Gaza Areas
  static const List<String> gazaAreas = [
    'غزة',
    'الشمال',
    'دير البلح',
    'خان يونس',
    'رفح',
  ];

  // Categories
  static const List<String> itemCategories = [
    'مواد غذائية',
    'إلكترونيات',
    'أثاث',
    'ملابس',
    'أدوات منزلية',
    'كتب',
    'ألعاب',
    'رياضة',
    'أخرى',
  ];

  static const List<String> propertyTypes = ['شقة', 'منزل', 'تجاري', 'أرض'];

  static const List<String> purposes = ['إيجار', 'تبادل'];
}
