# إصلاح مشكلة رفع الصور على السيرفر

## المشكلة الأصلية

كانت المشكلة أن التطبيق يقوم بتخزين البيانات في قاعدة البيانات وإضافة مسارات الصور، ولكن الصور نفسها لا يتم حفظها على السيرفر. هذا كان بسبب:

1. **عدم توافق API**: الكود كان يستخدم دالة `uploadFile` المصممة لرفع ملف واحد فقط
2. **تنسيق خاطئ**: API الجديد يتوقع مصفوفة من الصور (`images[]`) وليس ملف واحد (`image`)
3. **موديلات قديمة**: الموديلات لم تكن تدعم الصور المتعددة

## الحلول المطبقة

### 1. تحديث ApiService

تم إضافة دوال جديدة لرفع الصور المتعددة:

```dart
// رفع الصور المتعددة للسلع
Future<dio.Response> uploadItemWithImages(
  String path, {
  required List<String> imagePaths,
  required Map<String, dynamic> data,
}) async {
  final formData = dio.FormData.fromMap(data);

  // إضافة الصور المتعددة
  for (int i = 0; i < imagePaths.length; i++) {
    if (imagePaths[i].isNotEmpty) {
      final file = await dio.MultipartFile.fromFile(
        imagePaths[i],
        filename: 'item_image_$i.jpg',
      );
      formData.files.add(MapEntry('images[]', file));
    }
  }

  return await _dio.post(path, data: formData);
}

// رفع الصور المتعددة للعقارات
Future<dio.Response> uploadPropertyWithImages(
  String path, {
  required List<String> imagePaths,
  required Map<String, dynamic> data,
}) async {
  // نفس المنطق للعقارات
}
```

### 2. تحديث ItemsService

تم تحديث دالة `createItem` لاستخدام الدالة الجديدة:

```dart
Future<ItemModel?> createItem(
    Map<String, dynamic> data, List<String> imagePaths) async {
  try {
    final response = await _apiService.uploadItemWithImages(
      'items',
      imagePaths: imagePaths,
      data: data,
    );

    if (response.statusCode == 201) {
      // معالجة الاستجابة
      return ItemModel.fromJson(responseData);
    }
    return null;
  } catch (e) {
    developer.log('Error creating item: $e', name: 'ItemsService');
    return null;
  }
}
```

### 3. تحديث PropertiesService

تم تحديث دالة `createProperty` بنفس الطريقة:

```dart
Future<PropertyModel?> createProperty(
    Map<String, dynamic> data, List<String> imagePaths) async {
  try {
    final response = await _apiService.uploadPropertyWithImages(
      'properties',
      imagePaths: imagePaths,
      data: data,
    );

    if (response.statusCode == 201) {
      // معالجة الاستجابة
      return PropertyModel.fromJson(responseData);
    }
    return null;
  } catch (e) {
    developer.log('Error creating property: $e', name: 'PropertiesService');
    return null;
  }
}
```

### 4. تحديث Controllers

#### AddItemController

تم تحديث `submitItem()` لاستخدام الدالة الجديدة:

```dart
// إنشاء البيانات للسلعة
final itemData = {
  'title': values['title'],
  'description': values['description'],
  'category_id': categoryId,
  'condition': englishCondition,
  'price': price,
  // ... باقي البيانات
};

// تحويل مسارات الصور إلى قائمة
final imagePaths = _selectedImages.map((file) => file.path).toList();

// إرسال البيانات باستخدام الدالة الجديدة
final response = await ApiService.to.uploadItemWithImages(
  'items',
  imagePaths: imagePaths,
  data: itemData,
);
```

#### AddPropertyController

تم تحديث `submitProperty()` بنفس الطريقة:

```dart
// Create data for property
final propertyData = {
  'title': values['title'].toString().trim(),
  'description': values['description'].toString().trim(),
  'address': values['location'].toString().trim(),
  'type': englishPurpose,
  'price': price,
  // ... باقي البيانات
};

// تحويل مسارات الصور إلى قائمة
final imagePaths = _selectedImages.map((file) => file.path).toList();

// إرسال البيانات باستخدام الدالة الجديدة
final response = await ApiService.to.uploadPropertyWithImages(
  'properties',
  imagePaths: imagePaths,
  data: propertyData,
);
```

### 5. تحديث الموديلات

#### ItemModel

تم إضافة دعم للصور المتعددة:

```dart
class ItemModel {
  final String? image; // للتوافق مع الإصدارات القديمة
  final List<ItemImageModel> images; // الصور المتعددة الجديدة
  
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
}

// نموذج لصورة السلعة
class ItemImageModel {
  final int id;
  final int itemId;
  final String image;
  final DateTime? createdAt;

  // Get full image URL
  String? get fullImageUrl {
    if (image.isEmpty) return null;
    
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    
    String imagePath = image.startsWith('/') ? image.substring(1) : image;
    return '${ApiConfig.storageUrl}items/$imagePath';
  }
}
```

#### PropertyModel

تم إضافة نفس الدعم للعقارات:

```dart
class PropertyModel {
  final String? image; // للتوافق مع الإصدارات القديمة
  final List<PropertyImageModel> images; // الصور المتعددة الجديدة
  
  // نفس الدوال المساعدة مثل ItemModel
}

// نموذج لصورة العقار
class PropertyImageModel {
  final int id;
  final int propertyId;
  final String image;
  final DateTime? createdAt;

  // Get full image URL
  String? get fullImageUrl {
    if (image.isEmpty) return null;
    
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    
    String imagePath = image.startsWith('/') ? image.substring(1) : image;
    return '${ApiConfig.storageUrl}properties/$imagePath';
  }
}
```

## المزايا الجديدة

1. **دعم الصور المتعددة**: يمكن الآن رفع عدة صور لكل سلعة أو عقار
2. **توافق مع API الجديد**: يستخدم التنسيق الصحيح `images[]`
3. **توافق مع الإصدارات القديمة**: يدعم الحقل القديم `image` للتوافق
4. **أداء محسن**: رفع الصور يتم في طلب واحد
5. **معالجة أخطاء محسنة**: رسائل خطأ أكثر وضوحاً
6. **تسجيل مفصل**: logs مفصلة لتتبع عملية الرفع

## كيفية الاستخدام

### إضافة سلعة جديدة

```dart
// في AddItemController
final imagePaths = _selectedImages.map((file) => file.path).toList();
final itemData = {
  'title': 'عنوان السلعة',
  'description': 'وصف السلعة',
  'price': 1000.0,
  // ... باقي البيانات
};

final response = await ApiService.to.uploadItemWithImages(
  'items',
  imagePaths: imagePaths,
  data: itemData,
);
```

### إضافة عقار جديد

```dart
// في AddPropertyController
final imagePaths = _selectedImages.map((file) => file.path).toList();
final propertyData = {
  'title': 'عنوان العقار',
  'description': 'وصف العقار',
  'price': 50000.0,
  // ... باقي البيانات
};

final response = await ApiService.to.uploadPropertyWithImages(
  'properties',
  imagePaths: imagePaths,
  data: propertyData,
);
```

## اختبار الحل

1. **اختبار رفع الصور**: تأكد من أن الصور تُحفظ على السيرفر
2. **اختبار عرض الصور**: تأكد من أن الصور تظهر في التطبيق
3. **اختبار التوافق**: تأكد من أن الإصدارات القديمة تعمل
4. **اختبار الأخطاء**: تأكد من معالجة الأخطاء بشكل صحيح

## ملاحظات مهمة

1. **حجم الصور**: الحد الأقصى 2MB لكل صورة
2. **صيغ الصور**: JPEG, PNG, JPG, GIF مدعومة
3. **عدد الصور**: لا يوجد حد أقصى، ولكن يُنصح بعدم تجاوز 10 صور
4. **التوافق**: الكود متوافق مع الإصدارات القديمة من API

## الملفات المحدثة

- `lib/core/services/api_service.dart`
- `lib/core/services/items_service.dart`
- `lib/core/services/properties_service.dart`
- `lib/features/items/controllers/add_item_controller.dart`
- `lib/features/properties/controllers/add_property_controller.dart`
- `lib/features/items/models/item_model.dart`
- `lib/features/properties/models/property_model.dart` 