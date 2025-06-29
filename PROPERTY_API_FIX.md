# إصلاح مشكلة API العقارات - خطأ 422 و 500

## المشكلة

عند إضافة عقار جديد، كان السيرفر يرجع أخطاء مختلفة:

### خطأ 422:
```json
{
  "success": false,
  "message": "Validation failed",
  "data": null,
  "errors": {
    "type": ["The selected type is invalid."],
    "location": ["The location field is required."]
  }
}
```

### خطأ 500:
```
SQLSTATE[HY000]: General error: 1364 Field 'address' doesn't have a default value
```

## سبب المشكلة

1. **قيمة نوع العقار غير مدعومة**: التطبيق كان يرسل `exchange` بينما السيرفر يدعم `buy` و `rent` فقط
2. **تضارب في أسماء الحقول**: 
   - **API validation** يتوقع `location` 
   - **قاعدة البيانات** تتوقع `address`
   - هذا تضارب في السيرفر نفسه!

## الحلول المطبقة

### 1. تصحيح اسم حقل الموقع

**الحل النهائي - إرسال كلا الحقلين:**
```dart
final propertyData = {
  'location': values['location'].toString().trim(), // للـ validation
  'address': values['location'].toString().trim(), // لقاعدة البيانات
  // ...
};
```

**لماذا هذا الحل؟**
- API validation يرفض الطلب إذا لم يجد `location`
- قاعدة البيانات ترفض الإدراج إذا لم تجد `address`
- الحل الوحيد هو إرسال كلا الحقلين بنفس القيمة

### 2. تصحيح دالة تحويل نوع العقار

**بعد الإصلاح:**
```dart
static String convertPropertyTypeToEnglish(String arabicType) {
  const Map<String, String> typeMap = {
    'بيع': 'buy',
    'إيجار': 'rent',
    'تبادل': 'buy', // تحويل التبادل إلى بيع لأن السيرفر لا يدعم exchange
  };
  return typeMap[arabicType] ?? 'buy';
}
```

### 3. إضافة الحقول المطلوبة

تم إضافة الحقول التي يتوقعها السيرفر:

```dart
final propertyData = {
  'title': values['title'].toString().trim(),
  'description': values['description'].toString().trim(),
  'location': values['location'].toString().trim(), // للـ validation
  'address': values['location'].toString().trim(), // لقاعدة البيانات
  'type': englishPurpose, // buy أو rent فقط
  'price': price,
  'phone': values['phone'] ?? '',
  'status': 'available',
  'latitude': 31.5017,
  'longitude': 34.4668,
  'bedrooms': 0, // قيم افتراضية
  'bathrooms': 0, // قيم افتراضية  
  'area': 0, // قيم افتراضية
};
```

## البيانات المرسلة الآن

بعد الإصلاح، البيانات المرسلة للسيرفر تكون:

```json
{
  "title": "فثسفسي",
  "description": "سيسيسيسييذيذ",
  "location": "سيسيس",
  "address": "سيسيس",
  "type": "buy",
  "price": 3233.0,
  "phone": "٣٤٥٣٤٥٣٤٥٣٤",
  "status": "available",
  "latitude": 31.5017,
  "longitude": 34.4668,
  "bedrooms": 0,
  "bathrooms": 0,
  "area": 0
}
```

## ملاحظات مهمة

1. **أنواع العقارات المدعومة**: `buy` و `rent` فقط
2. **حقل الموقع**: يجب إرسال **كلا الحقلين** `location` و `address` بنفس القيمة
   - `location`: مطلوب للـ API validation
   - `address`: مطلوب لقاعدة البيانات
3. **الحقول الإضافية**: تم إضافة `bedrooms`, `bathrooms`, `area` كقيم افتراضية
4. **التبادل**: يتم تحويله تلقائياً إلى "بيع" لأن السيرفر لا يدعم نوع "تبادل"
5. **تضارب السيرفر**: هناك تضارب في السيرفر بين validation API وقاعدة البيانات

## الاختبار

لاختبار الإصلاح:

1. افتح التطبيق
2. اذهب إلى صفحة إضافة عقار
3. املأ البيانات واختر "تبادل" كنوع العقار
4. أضف صورتين على الأقل
5. اضغط على "نشر العقار"
6. يجب أن يتم إنشاء العقار بنجاح

## الملفات المحدثة

- `lib/features/properties/controllers/add_property_controller.dart`
- `lib/core/utils/validators.dart`

## متطلبات السيرفر الفعلية

حسب التجربة الفعلية، السيرفر يتوقع:

```json
{
  "title": "string (required)",
  "description": "string (required)",
  "location": "string (required for validation)",
  "address": "string (required for database)",
  "type": "buy|rent (required)",
  "price": "number (required)",
  "phone": "string (optional)",
  "status": "available|sold|rented (optional)",
  "latitude": "number (optional)",
  "longitude": "number (optional)",
  "bedrooms": "number (optional)",
  "bathrooms": "number (optional)",
  "area": "number (optional)"
}
```

**ملاحظة مهمة**: يجب إرسال كلا الحقلين `location` و `address` بنفس القيمة لتجنب أخطاء 422 و 500.

## نصائح للمطورين

1. **تحقق من قاعدة البيانات**: تأكد من أسماء الأعمدة الفعلية
2. **اختبر جميع الحالات**: اختبر جميع أنواع العقارات المختلفة
3. **معالجة الأخطاء**: تأكد من معالجة أخطاء 422 و 500 بشكل مناسب
4. **التحقق من الحقول**: تأكد من أن جميع الحقول المطلوبة موجودة

## التحديثات المستقبلية

لتحسين التطبيق في المستقبل:

1. **توحيد أسماء الحقول**: جعل API validation وقاعدة البيانات يستخدمان نفس أسماء الحقول
2. **دعم نوع التبادل**: إضافة دعم `exchange` في السيرفر
3. **تحسين رسائل الخطأ**: رسائل خطأ أكثر وضوحاً للمطورين

## التحديثات المستقبلية

إذا أراد السيرفر دعم نوع "تبادل" في المستقبل:

1. أضف `exchange` إلى قائمة الأنواع المدعومة في السيرفر
2. حدث دالة `convertPropertyTypeToEnglish` لترجع `exchange` بدلاً من `buy`
3. حدث دالة `convertPropertyTypeToArabic` لتدعم `exchange`
4. حدث دالة `isValidPropertyType` لتشمل `exchange` 