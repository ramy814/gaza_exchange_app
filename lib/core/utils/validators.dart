class Validators {
  // Phone validation for Palestinian numbers
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    // Palestinian phone number format: 059xxxxxxxx or 056xxxxxxxx
    final phoneRegex = RegExp(r'^(059|056)\d{7}$');
    if (!phoneRegex.hasMatch(value)) {
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

    final price = double.tryParse(value);
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

  // مصادقة رقم الهاتف الفلسطيني
  static bool isValidPhone(String phone) {
    // رقم هاتف فلسطيني: يبدأ بـ 059 أو 056 أو 057
    final phoneRegex = RegExp(r'^(059|056|057)\d{7}$');
    return phoneRegex.hasMatch(phone);
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
    final priceRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!priceRegex.hasMatch(price)) return false;

    final priceValue = double.tryParse(price);
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
    return ['buy', 'rent', 'exchange'].contains(type);
  }

  // مصادقة حالة السلعة
  static bool isValidItemStatus(String status) {
    return ['available', 'sold'].contains(status);
  }

  // رسائل الخطأ
  static String getPhoneErrorMessage() {
    return 'يرجى إدخال رقم هاتف صحيح (مثال: 0599123456)';
  }

  static String getPasswordErrorMessage() {
    return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
  }

  static String getEmailErrorMessage() {
    return 'يرجى إدخال بريد إلكتروني صحيح';
  }

  static String getNameErrorMessage() {
    return 'الاسم يجب أن يكون حرفين على الأقل';
  }

  static String getTitleErrorMessage() {
    return 'العنوان يجب أن يكون 3 أحرف على الأقل';
  }

  static String getDescriptionErrorMessage() {
    return 'الوصف يجب أن يكون 10 أحرف على الأقل';
  }

  static String getPriceErrorMessage() {
    return 'يرجى إدخال سعر صحيح أكبر من صفر';
  }

  static String getLocationErrorMessage() {
    return 'يرجى تحديد موقع صحيح';
  }
}
