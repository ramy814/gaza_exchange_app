# تطبيق تبادل غزة - Gaza Exchange App

تطبيق Flutter للتبادل والبيع في غزة، يعمل مع Laravel API.

## 🚀 المميزات

- تسجيل الدخول برقم الهاتف
- إدارة السلع والعقارات
- تصميم عربي بألوان غزة
- يعمل مع Laravel API

## 🔧 متطلبات التشغيل

1. **Flutter 3.29.2+**
2. **Laravel Backend** على `http://localhost:8000/api`
3. **Chrome أو Android Emulator**

## 🛠️ التثبيت

```bash
git clone <repository-url>
cd gaza_exchange_app
flutter pub get
flutter run -d chrome
```

## 🔐 بيانات تسجيل الدخول

### تسجيل حساب جديد:
- الاسم: أي اسم
- رقم الهاتف: أي رقم
- كلمة المرور: 6 أحرف أو أكثر

### تسجيل الدخول:
- رقم الهاتف: الرقم المسجل
- كلمة المرور: كلمة المرور المسجلة

## 📡 API Endpoints

- `POST /api/register` - تسجيل مستخدم
- `POST /api/login` - تسجيل الدخول
- `GET /api/items` - عرض السلع
- `GET /api/properties` - عرض العقارات

## 🎨 الألوان

- الأخضر الأساسي: `#2E7D32`
- البرتقالي: `#FF6B35`
- الأحمر الناعم: `#E53935`

## 📁 هيكل المشروع

```
lib/
├── core/          # الخدمات والنماذج الأساسية
├── features/      # الميزات (auth, items, properties)
└── widgets/       # المكونات المشتركة
```

## 🔧 الإعدادات

تغيير Base URL في `lib/core/services/api_service.dart`:
```dart
final String baseUrl = 'http://localhost:8000/api/';
```

---

**تم التطوير بواسطة**: فريق تبادل غزة  
**آخر تحديث**: يناير 2025
