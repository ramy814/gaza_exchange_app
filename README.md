# تطبيق تبادل السلع والعقارات - غزة

تطبيق Flutter متكامل لتبادل السلع والعقارات في قطاع غزة مع دعم التصنيفات والبحث الجغرافي.

## المميزات الرئيسية

### 🔐 نظام المصادقة
- تسجيل مستخدمين جدد
- تسجيل الدخول والخروج
- إدارة الملف الشخصي
- تحديث معلومات الموقع

### 📱 واجهة المستخدم
- تصميم عصري ومتجاوب
- دعم اللغة العربية
- واجهة سهلة الاستخدام
- تجربة مستخدم محسنة

### 🏷️ نظام التصنيفات
- تصنيفات رئيسية وفرعية
- دعم الأيقونات والألوان
- البحث في التصنيفات
- إدارة التصنيفات (للمديرين)

### 📦 إدارة السلع
- إضافة سلع جديدة مع الصور
- تحديث وحذف السلع
- البحث والفلترة المتقدمة
- عرض السلع القريبة
- السلع الرائجة

### 🏠 إدارة العقارات
- إضافة عقارات للبيع/الإيجار
- تحديث وحذف العقارات
- البحث حسب النوع والسعر
- عرض تفاصيل العقار

### 📍 الخدمات الجغرافية
- تحديد الموقع الحالي
- البحث حسب المسافة
- عرض السلع القريبة
- حساب المسافات

### 📊 الإحصائيات والنشاط
- إحصائيات المستخدم
- النشاط الأخير
- تتبع السلع والعقارات
- قيم إجمالية

## التقنيات المستخدمة

### Frontend
- **Flutter**: إطار العمل الرئيسي
- **GetX**: إدارة الحالة والتنقل
- **Dio**: طلبات HTTP
- **Shared Preferences**: التخزين المحلي
- **Flutter Secure Storage**: التخزين الآمن

### Location Services
- **Geolocator**: الحصول على الموقع
- **Geocoding**: تحويل الإحداثيات إلى أسماء

### UI/UX
- **Material Design**: تصميم الواجهة
- **Cached Network Image**: تحميل الصور
- **Image Picker**: اختيار الصور
- **Form Builder**: نماذج البيانات

## هيكل المشروع

```
lib/
├── core/
│   ├── bindings/          # ربط الخدمات
│   ├── models/           # نماذج البيانات
│   ├── services/         # خدمات API
│   └── utils/            # أدوات مساعدة
├── features/
│   ├── auth/             # المصادقة
│   ├── home/             # الصفحة الرئيسية
│   ├── items/            # إدارة السلع
│   ├── properties/       # إدارة العقارات
│   ├── profile/          # الملف الشخصي
│   └── splash/           # شاشة البداية
└── widgets/              # مكونات قابلة لإعادة الاستخدام
```

## API Endpoints

### المصادقة
- `POST /register` - تسجيل مستخدم جديد
- `POST /login` - تسجيل الدخول
- `POST /logout` - تسجيل الخروج
- `GET /profile` - عرض الملف الشخصي

### المستخدم
- `GET /user/profile` - الملف الشخصي مع الإحصائيات
- `GET /user/statistics` - إحصائيات المستخدم
- `GET /user/recent-activity` - النشاط الأخير
- `PUT /user/location` - تحديث الموقع

### التصنيفات
- `GET /categories` - جميع التصنيفات
- `GET /categories/main` - التصنيفات الرئيسية
- `GET /categories/{id}` - تصنيف محدد
- `GET /categories/{id}/subcategories` - التصنيفات الفرعية
- `GET /categories/search` - البحث في التصنيفات

### السلع
- `GET /items` - جميع السلع
- `GET /items/nearby` - السلع القريبة
- `GET /items/trending` - السلع الرائجة
- `GET /items/{id}` - سلعة محددة
- `POST /items` - إضافة سلعة
- `PUT /items/{id}` - تحديث سلعة
- `DELETE /items/{id}` - حذف سلعة

### العقارات
- `GET /properties` - جميع العقارات
- `GET /properties/{id}` - عقار محدد
- `POST /properties` - إضافة عقار
- `PUT /properties/{id}` - تحديث عقار
- `DELETE /properties/{id}` - حذف عقار

## التثبيت والتشغيل

### المتطلبات
- Flutter SDK 3.10.0 أو أحدث
- Dart SDK 3.1.0 أو أحدث
- Android Studio / VS Code

### خطوات التثبيت

1. **استنساخ المشروع**
```bash
git clone https://github.com/your-username/gaza_exchange_app.git
cd gaza_exchange_app
```

2. **تثبيت التبعيات**
```bash
flutter pub get
```

3. **تكوين API**
- تحديث `baseUrl` في `lib/core/services/api_service.dart`
- التأكد من تشغيل الخادم على `http://localhost:8000`

4. **تشغيل التطبيق**
```bash
flutter run
```

### إعدادات Android

أضف الأذونات المطلوبة في `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### إعدادات iOS

أضف الأذونات المطلوبة في `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>يحتاج التطبيق إلى الوصول لموقعك لعرض السلع القريبة</string>
<key>NSCameraUsageDescription</key>
<string>يحتاج التطبيق إلى الوصول للكاميرا لالتقاط صور السلع</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>يحتاج التطبيق إلى الوصول لمكتبة الصور لاختيار صور السلع</string>
```

## المميزات الجديدة في الإصدار 2.0

### 🔄 تحديثات API
- تحسين استجابة API
- إضافة معالجة أخطاء محسنة
- دعم التحميل التدريجي
- تحسين أداء الطلبات

### 📍 خدمات الموقع المحسنة
- دقة أعلى في تحديد الموقع
- تحسين حساب المسافات
- دعم البحث الجغرافي المتقدم
- تحديث تلقائي للموقع

### 🎨 تحسينات الواجهة
- تصميم أكثر عصرية
- تحسين تجربة المستخدم
- دعم أفضل للأجهزة المختلفة
- تحسين أداء التطبيق

### 🔒 الأمان والخصوصية
- تشفير البيانات الحساسة
- تحسين إدارة الجلسات
- حماية أفضل للمعلومات الشخصية
- تحديث آليات المصادقة

## المساهمة

نرحب بمساهماتكم! يرجى اتباع الخطوات التالية:

1. Fork المشروع
2. إنشاء فرع جديد للميزة
3. إجراء التغييرات المطلوبة
4. إضافة اختبارات إذا لزم الأمر
5. إرسال Pull Request

## الترخيص

هذا المشروع مرخص تحت رخصة MIT. راجع ملف `LICENSE` للتفاصيل.

## الدعم

إذا واجهت أي مشاكل أو لديك أسئلة:

- افتح Issue جديد على GitHub
- راجع الوثائق في `api_documentation.md`
- تواصل مع فريق التطوير

## الإصدارات

### v2.0.0 (الحالي)
- تحديث شامل لـ API
- تحسين خدمات الموقع
- إضافة ميزات جديدة
- تحسين الأداء والأمان

### v1.0.0
- الإصدار الأولي
- الميزات الأساسية
- دعم المصادقة والسلع والعقارات

---

**تم تطوير هذا التطبيق بواسطة فريق Gaza Exchange**
