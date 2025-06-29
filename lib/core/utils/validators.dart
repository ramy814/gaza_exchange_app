// Remove the unused import
// import 'package:get/get.dart';

class Validators {
  // ===== دوال تحويل الأرقام =====

  // دالة لتحويل الأرقام العربية إلى الإنجليزية
  static String convertArabicToEnglishNumbers(String input) {
    return input
        .replaceAll('٠', '0')
        .replaceAll('١', '1')
        .replaceAll('٢', '2')
        .replaceAll('٣', '3')
        .replaceAll('٤', '4')
        .replaceAll('٥', '5')
        .replaceAll('٦', '6')
        .replaceAll('٧', '7')
        .replaceAll('٨', '8')
        .replaceAll('٩', '9');
  }

  // دالة لتحويل الأرقام الإنجليزية إلى العربية
  static String convertEnglishToArabicNumbers(String input) {
    if (input.isEmpty) return input;

    const Map<String, String> englishToArabic = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };

    String result = input;
    englishToArabic.forEach((english, arabic) {
      result = result.replaceAll(english, arabic);
    });

    return result;
  }

  // ===== دوال تحويل حالات السلع =====

  // دالة لتحويل حالة السلعة من العربية إلى الإنجليزية
  static String convertConditionToEnglish(String arabicCondition) {
    const Map<String, String> conditionMap = {
      'جديد': 'new',
      'مستعمل - ممتاز': 'used',
      'مستعمل - جيد': 'used',
      'مستعمل - مقبول': 'used',
    };

    return conditionMap[arabicCondition] ?? 'used';
  }

  // دالة لتحويل حالة السلعة من الإنجليزية إلى العربية
  static String convertConditionToArabic(String englishCondition) {
    const Map<String, String> conditionMap = {
      'new': 'جديد',
      'used': 'مستعمل - ممتاز',
    };

    return conditionMap[englishCondition] ?? 'مستعمل - ممتاز';
  }

  // ===== دوال تحويل أنواع العقارات =====

  // دالة لتحويل نوع العقار من العربية إلى الإنجليزية
  static String convertPropertyTypeToEnglish(String arabicType) {
    const Map<String, String> typeMap = {
      'بيع': 'buy',
      'إيجار': 'rent',
      'تبادل': 'buy', // تحويل التبادل إلى بيع لأن السيرفر لا يدعم exchange
    };

    return typeMap[arabicType] ?? 'buy';
  }

  // دالة لتحويل نوع العقار من الإنجليزية إلى العربية
  static String convertPropertyTypeToArabic(String englishType) {
    const Map<String, String> typeMap = {
      'buy': 'بيع',
      'rent': 'إيجار',
    };

    return typeMap[englishType] ?? 'بيع';
  }

  // ===== دوال تحويل حالات السلع =====

  // دالة لتحويل حالة السلعة من العربية إلى الإنجليزية
  static String convertItemStatusToEnglish(String arabicStatus) {
    const Map<String, String> statusMap = {
      'متاح': 'available',
      'مباع': 'sold',
      'محجوز': 'reserved',
    };

    return statusMap[arabicStatus] ?? 'available';
  }

  // دالة لتحويل حالة السلعة من الإنجليزية إلى العربية
  static String convertItemStatusToArabic(String englishStatus) {
    const Map<String, String> statusMap = {
      'available': 'متاح',
      'sold': 'مباع',
      'reserved': 'محجوز',
    };

    return statusMap[englishStatus] ?? 'متاح';
  }

  // ===== دوال مساعدة =====

  // دالة لتنظيف النص من الأحرف غير المرغوبة
  static String cleanText(String text) {
    // إزالة الأحرف الخاصة والرموز غير المرغوبة
    return text.trim().replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '');
  }

  // ===== دوال التحقق من صحة البيانات =====

  // Phone validation for Palestinian numbers
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    // تحويل الأرقام العربية إلى الإنجليزية أولاً
    String cleanValue = convertArabicToEnglishNumbers(value);

    // Palestinian phone number format: 059xxxxxxxx or 056xxxxxxxx
    final phoneRegex = RegExp(r'^(059|056)\d{7}$');
    if (!phoneRegex.hasMatch(cleanValue)) {
      return 'رقم الهاتف غير صحيح';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    return null;
  }

  // Password confirmation validation
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (value != password) {
      return 'كلمة المرور غير متطابقة';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }

    if (value.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }

    return null;
  }

  // Title validation
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'العنوان مطلوب';
    }

    if (value.length < 3) {
      return 'العنوان يجب أن يكون 3 أحرف على الأقل';
    }

    if (value.length > 100) {
      return 'العنوان يجب أن يكون أقل من 100 حرف';
    }

    return null;
  }

  // Description validation
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'الوصف مطلوب';
    }

    if (value.length < 10) {
      return 'الوصف يجب أن يكون 10 أحرف على الأقل';
    }

    if (value.length > 500) {
      return 'الوصف يجب أن يكون أقل من 500 حرف';
    }

    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'السعر مطلوب';
    }

    // تحويل الأرقام العربية إلى الإنجليزية أولاً
    String cleanValue = convertArabicToEnglishNumbers(value);
    final price = double.tryParse(cleanValue);
    if (price == null || price <= 0) {
      return 'السعر يجب أن يكون رقم موجب';
    }

    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'العنوان مطلوب';
    }

    if (value.length < 5) {
      return 'العنوان يجب أن يكون 5 أحرف على الأقل';
    }

    return null;
  }

  // Latitude validation
  static String? validateLatitude(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final lat = double.tryParse(value);
    if (lat == null || lat < -90 || lat > 90) {
      return 'خط العرض غير صحيح';
    }

    return null;
  }

  // Longitude validation
  static String? validateLongitude(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final lng = double.tryParse(value);
    if (lng == null || lng < -180 || lng > 180) {
      return 'خط الطول غير صحيح';
    }

    return null;
  }

  // Search query validation
  static String? validateSearchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return 'نص البحث مطلوب';
    }

    if (value.length < 2) {
      return 'نص البحث يجب أن يكون حرفين على الأقل';
    }

    return null;
  }

  // Category validation
  static String? validateCategory(int? value) {
    if (value == null || value <= 0) {
      return 'التصنيف مطلوب';
    }

    return null;
  }

  // Image validation
  static String? validateImage(String? value) {
    if (value == null || value.isEmpty) {
      return 'الصورة مطلوبة';
    }

    // Check if file exists and is an image
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
    final hasValidExtension = imageExtensions.any(
      (ext) => value.toLowerCase().endsWith(ext),
    );

    if (!hasValidExtension) {
      return 'يجب أن تكون الصورة بصيغة jpg, jpeg, png, أو gif';
    }

    return null;
  }

  // Exchange for validation
  static String? validateExchangeFor(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    if (value.length < 3) {
      return 'نص التبادل يجب أن يكون 3 أحرف على الأقل';
    }

    return null;
  }

  // Location name validation
  static String? validateLocationName(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    if (value.length < 3) {
      return 'اسم الموقع يجب أن يكون 3 أحرف على الأقل';
    }

    return null;
  }

  // ===== دوال التحقق البولينية =====

  // مصادقة رقم الهاتف الفلسطيني
  static bool isValidPhone(String phone) {
    // تحويل الأرقام العربية إلى الإنجليزية أولاً
    String cleanPhone = convertArabicToEnglishNumbers(phone);

    // رقم هاتف فلسطيني: يبدأ بـ 059 أو 056 أو 057
    final phoneRegex = RegExp(r'^(059|056|057)\d{7}$');
    return phoneRegex.hasMatch(cleanPhone);
  }

  // مصادقة كلمة المرور
  static bool isValidPassword(String password) {
    // كلمة مرور قوية: 8 أحرف على الأقل، تحتوي على حروف وأرقام
    return password.length >= 8;
  }

  // مصادقة البريد الإلكتروني
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // مصادقة الاسم
  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  // مصادقة العنوان
  static bool isValidTitle(String title) {
    return title.trim().length >= 3;
  }

  // مصادقة الوصف
  static bool isValidDescription(String description) {
    return description.trim().length >= 10;
  }

  // مصادقة السعر
  static bool isValidPrice(String price) {
    // تحويل الأرقام العربية إلى الإنجليزية أولاً
    String cleanPrice = convertArabicToEnglishNumbers(price);

    final priceRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!priceRegex.hasMatch(cleanPrice)) return false;

    final priceValue = double.tryParse(cleanPrice);
    return priceValue != null && priceValue > 0;
  }

  // مصادقة الإحداثيات
  static bool isValidLatitude(double latitude) {
    return latitude >= -90 && latitude <= 90;
  }

  static bool isValidLongitude(double longitude) {
    return longitude >= -180 && longitude <= 180;
  }

  // مصادقة نصف القطر
  static bool isValidRadius(double radius) {
    return radius > 0 && radius <= 100; // أقصى 100 كم
  }

  // مصادقة نوع العقار
  static bool isValidPropertyType(String type) {
    return ['buy', 'rent'].contains(type);
  }

  // مصادقة حالة السلعة
  static bool isValidItemStatus(String status) {
    return ['available', 'sold'].contains(status);
  }
}
