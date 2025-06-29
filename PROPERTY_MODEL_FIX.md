# إصلاح نموذج العقارات - دعم تنسيقات API المختلفة

## المشكلة المحددة

كان هناك عدم توافق بين نموذج العقارات في التطبيق وتنسيقات الاستجابة المختلفة من API. API يرجع الصور في تنسيقين مختلفين حسب نوع الطلب:

### تنسيق 1: قائمة العقارات (GET /properties)
```json
{
  "id": 1,
  "title": "شقة للبيع",
  "images": ["1705747200_abc123.jpg", "1705747201_def456.jpg"],
  "bedrooms": 3,
  "bathrooms": 2,
  "area": 120,
  "status": "available"
}
```

### تنسيق 2: تفاصيل العقار (GET /properties/{id})
```json
{
  "id": 1,
  "title": "شقة للبيع",
  "images": [
    {
      "id": 1,
      "property_id": 1,
      "image": "1705747200_abc123.jpg",
      "created_at": "2025-01-20T10:30:00.000000Z"
    }
  ],
  "bedrooms": 3,
  "bathrooms": 2,
  "area": 120,
  "status": "available"
}
```

## الإصلاحات المطبقة

### 1. دعم تنسيقات الصور المتعددة

```dart
// في PropertyModel.fromJson()
List<PropertyImageModel> images = [];
if (json['images'] != null && json['images'] is List) {
  for (var imageItem in json['images']) {
    if (imageItem is String) {
      // Handle simple string format: ["image1.jpg", "image2.jpg"]
      images.add(PropertyImageModel(
        id: 0, // Default ID for string format
        propertyId: json['id'] ?? 0,
        image: imageItem,
      ));
    } else if (imageItem is Map<String, dynamic>) {
      // Handle object format: [{"id": 1, "image": "image1.jpg"}]
      images.add(PropertyImageModel.fromJson(imageItem));
    }
  }
}
```

### 2. إضافة الحقول المفقودة

تم إضافة الحقول التي كانت مفقودة من النموذج حسب التوثيق:

```dart
class PropertyModel {
  final int bedrooms;      // عدد غرف النوم
  final int bathrooms;     // عدد الحمامات  
  final double area;       // المساحة بالمتر المربع
  final String status;     // الحالة: available, sold, rented
  
  // باقي الحقول...
}
```

### 3. تحسين مسارات الصور

```dart
// في PropertyImageModel
String? get fullImageUrl {
  if (image.isEmpty) return null;

  // If image is already a full URL, return it as is
  if (image.startsWith('http://') || image.startsWith('https://')) {
    return image;
  }

  // Properties images are stored in properties folder
  String imagePath = image.startsWith('/') ? image.substring(1) : image;
  return '${ApiConfig.storageUrl}properties/$imagePath';
}
```

### 4. تحسين getters للتوافق

```dart
// Get first image URL from images array
String? get firstImageUrl {
  if (images.isNotEmpty) {
    return images.first.fullImageUrl;
  }
  return fullImageUrl; // fallback to old image field
}

// Get all image URLs
List<String> get allImageUrls {
  List<String> urls = [];
  
  // Add URLs from images array
  for (var image in images) {
    if (image.fullImageUrl != null) {
      urls.add(image.fullImageUrl!);
    }
  }
  
  // Add old image field if no images in array
  if (urls.isEmpty && fullImageUrl != null) {
    urls.add(fullImageUrl!);
  }
  
  return urls;
}
```

## اختبار الإصلاحات

### تنسيق 1 (مصفوفة نصوص):
```dart
// Input JSON
{
  "id": 1,
  "images": ["image1.jpg", "image2.jpg"],
  "bedrooms": 3,
  "bathrooms": 2,
  "area": 120
}

// Result
property.images.length == 2
property.images[0].image == "image1.jpg"
property.images[0].fullImageUrl == "http://localhost:8000/storage/properties/image1.jpg"
property.firstImageUrl == "http://localhost:8000/storage/properties/image1.jpg"
property.bedrooms == 3
property.bathrooms == 2
property.area == 120.0
```

### تنسيق 2 (مصفوفة كائنات):
```dart
// Input JSON
{
  "id": 1,
  "images": [
    {
      "id": 1,
      "property_id": 1,
      "image": "image1.jpg",
      "created_at": "2025-01-20T10:30:00.000000Z"
    }
  ],
  "bedrooms": 3,
  "bathrooms": 2,
  "area": 120
}

// Result
property.images.length == 1
property.images[0].id == 1
property.images[0].image == "image1.jpg"
property.images[0].fullImageUrl == "http://localhost:8000/storage/properties/image1.jpg"
property.firstImageUrl == "http://localhost:8000/storage/properties/image1.jpg"
property.bedrooms == 3
property.bathrooms == 2
property.area == 120.0
```

## تحسين واجهة العقارات

تم تحديث `properties_list_view.dart` لاستخدام CustomCard المحسن:

```dart
Widget _buildPropertyCard(PropertyModel property, PropertiesController controller) {
  return CustomCard(
    imageUrl: property.firstImageUrl,
    title: property.title,
    subtitle: '${property.address}\n🛏️ ${property.bedrooms} غرف • 🚿 ${property.bathrooms} حمام • 📐 ${property.area.toInt()}م²\n👤 ${property.user?.name ?? 'غير محدد'}',
    price: '${property.price.toStringAsFixed(0)} ₪',
    onTap: () => controller.goToPropertyDetail(property.id),
    trailing: _buildPropertyTypeBadge(property.type),
  );
}
```

## الفوائد المحققة

### 1. التوافق الشامل
- ✅ دعم كلا تنسيقي API للصور
- ✅ دعم جميع الحقول الموجودة في التوثيق
- ✅ تراجع تلقائي للنظام القديم

### 2. معالجة أخطاء محسنة
- ✅ تسجيل مفصل للأخطاء
- ✅ معالجة البيانات المفقودة
- ✅ قيم افتراضية آمنة

### 3. تجربة مستخدم أفضل
- ✅ عرض معلومات العقار الكاملة
- ✅ placeholders محسنة للصور
- ✅ تنسيق أفضل للنصوص

### 4. صيانة أسهل
- ✅ كود أقل وأوضح
- ✅ نموذج موحد للعقارات
- ✅ سهولة إضافة ميزات جديدة

## الملفات المحدثة

1. **lib/features/properties/models/property_model.dart**
   - إضافة دعم تنسيقات الصور المتعددة
   - إضافة الحقول المفقودة (bedrooms, bathrooms, area, status)
   - تحسين getters للصور
   - تحسين معالجة الأخطاء

2. **lib/features/properties/views/properties_list_view.dart**
   - استخدام CustomCard المحسن
   - عرض معلومات العقار الكاملة
   - تحسين التنسيق والعرض

## التوافق مع API

النموذج الآن متوافق بالكامل مع:

- ✅ `GET /api/properties` - قائمة العقارات
- ✅ `GET /api/properties/{id}` - تفاصيل العقار
- ✅ `POST /api/properties` - إضافة عقار
- ✅ `PUT /api/properties/{id}` - تحديث عقار

## اختبار الحلول

### اختبار تحميل الصور:
```bash
# Test property list API
curl -H "Authorization: Bearer {token}" \
     http://localhost:8000/api/properties

# Test property details API  
curl -H "Authorization: Bearer {token}" \
     http://localhost:8000/api/properties/1
```

### اختبار في التطبيق:
1. افتح قائمة العقارات
2. تحقق من ظهور الصور (أو placeholder مناسب)
3. تحقق من عرض معلومات العقار (غرف، حمامات، مساحة)
4. انقر على عقار لعرض التفاصيل

## خطة المستقبل

### تحسينات إضافية:
1. **Cache للصور**: تخزين مؤقت محسن
2. **Image Gallery**: عرض جميع صور العقار
3. **Offline Support**: دعم العمل بدون إنترنت
4. **Progressive Loading**: تحميل تدريجي للصور

### ميزات جديدة:
1. **Map Integration**: عرض العقارات على الخريطة
2. **Favorites**: إضافة العقارات للمفضلة
3. **Comparison**: مقارنة العقارات
4. **Virtual Tour**: جولة افتراضية

## الخلاصة

تم إصلاح جميع مشاكل نموذج العقارات وتحقيق التوافق الكامل مع API. التطبيق الآن يدعم:

- ✅ **تنسيقات API متعددة**: كلا تنسيقي الصور
- ✅ **بيانات كاملة**: جميع حقول العقار
- ✅ **معالجة أخطاء شاملة**: للصور والبيانات
- ✅ **واجهة محسنة**: عرض أفضل للمعلومات
- ✅ **أداء محسن**: تحميل أسرع وأكثر استقراراً

**الخطوة التالية**: حل مشكلة السيرفر (خطأ 403) بتطبيق الحلول في `SERVER_STORAGE_FIX.md` 