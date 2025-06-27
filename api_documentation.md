# Gaza Exchange API Documentation

## نظرة عامة

هذا المستند يوضح كيفية استخدام APIs الخاصة بمشروع تبادل السلع والعقارات. جميع الـ APIs تستخدم JSON format وتعيد استجابات JSON.

**Base URL**: `http://localhost:8000/api`

## المصادقة (Authentication)

يستخدم التطبيق Laravel Sanctum للمصادقة. بعد تسجيل الدخول بنجاح، ستحصل على token يجب إرساله مع كل طلب محمي.

**Header المطلوب للطلبات المحمية:**
`Authorization: Bearer {token}`

---

## 🔐 APIs المصادقة

### 1. تسجيل مستخدم جديد

**POST** `/register`

**المعاملات:**
```json
{
    "name": "أحمد محمد",
    "phone": "0599123456",
    "password": "password123",
    "password_confirmation": "password123"
}
```

**الاستجابة الناجحة (201):**
```json
{
    "message": "User registered successfully",
    "user": {
        "id": 1,
        "name": "أحمد محمد",
        "phone": "0599123456",
        "created_at": "2025-01-20T10:30:00.000000Z",
        "updated_at": "2025-01-20T10:30:00.000000Z"
    },
    "token": "1|abcdef123456789..."
}
```

**أخطاء محتملة:**
- `422`: بيانات غير صحيحة
- `500`: خطأ في الخادم

---

### 2. تسجيل الدخول

**POST** `/login`

**المعاملات:**
```json
{
    "phone": "0599123456",
    "password": "password123"
}
```

**الاستجابة الناجحة (200):**
```json
{
    "message": "Login successful",
    "user": {
        "id": 1,
        "name": "أحمد محمد",
        "phone": "0599123456",
        "created_at": "2025-01-20T10:30:00.000000Z",
        "updated_at": "2025-01-20T10:30:00.000000Z"
    },
    "token": "2|xyz789abc123..."
}
```

**أخطاء محتملة:**
- `422`: بيانات تسجيل دخول خاطئة
- `500`: خطأ في الخادم

---

### 3. تسجيل الخروج

**POST** `/logout`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "message": "Logged out successfully"
}
```

---

### 4. عرض الملف الشخصي

**GET** `/profile`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "user": {
        "id": 1,
        "name": "أحمد محمد",
        "phone": "0599123456",
        "created_at": "2025-01-20T10:30:00.000000Z",
        "updated_at": "2025-01-20T10:30:00.000000Z"
    }
}
```

---

## 👤 APIs المستخدم (User)

### 1. عرض الملف الشخصي مع الإحصائيات

**GET** `/user/profile`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "user": {
        "id": 1,
        "name": "أحمد محمد",
        "phone": "0599123456",
        "latitude": 31.5017,
        "longitude": 34.4668,
        "location_name": "غزة، فلسطين",
        "created_at": "2025-01-20T10:30:00.000000Z",
        "updated_at": "2025-01-20T10:30:00.000000Z",
        "items": [
            {
                "id": 1,
                "title": "جهاز كمبيوتر محمول",
                "price": "1200.00",
                "status": "available"
            }
        ],
        "properties": [
            {
                "id": 1,
                "title": "شقة للبيع",
                "price": "85000.00",
                "type": "buy"
            }
        ]
    },
    "items_count": 1,
    "properties_count": 1
}
```

---

### 2. عرض إحصائيات المستخدم

**GET** `/user/statistics`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "statistics": {
        "total_items": 5,
        "total_properties": 3,
        "available_items": 4,
        "sold_items": 1,
        "buy_properties": 2,
        "rent_properties": 1,
        "recent_items_30_days": 2,
        "recent_properties_30_days": 1,
        "total_items_value": "4800.00",
        "total_properties_value": "250000.00",
        "total_value": "254800.00"
    }
}
```

---

### 3. عرض النشاط الأخير

**GET** `/user/recent-activity`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "recent_activity": [
        {
            "id": 3,
            "type": "item",
            "title": "هاتف iPhone 13",
            "price": "800.00",
            "status": "available",
            "created_at": "2025-01-20T15:30:00.000000Z"
        },
        {
            "id": 2,
            "type": "property",
            "title": "فيلا للبيع",
            "price": "120000.00",
            "status": "buy",
            "created_at": "2025-01-20T14:20:00.000000Z"
        },
        {
            "id": 1,
            "type": "item",
            "title": "جهاز كمبيوتر محمول",
            "price": "1200.00",
            "status": "sold",
            "created_at": "2025-01-20T10:30:00.000000Z"
        }
    ]
}
```

---

### 4. تحديث موقع المستخدم

**PUT** `/user/location`

**Headers:** `Authorization: Bearer {token}`

**المعاملات:**
```json
{
    "latitude": 31.5017,
    "longitude": 34.4668,
    "location_name": "غزة، فلسطين"
}
```

**الاستجابة الناجحة (200):**
```json
{
    "message": "Location updated successfully",
    "user": {
        "id": 1,
        "name": "أحمد محمد",
        "latitude": 31.5017,
        "longitude": 34.4668,
        "location_name": "غزة، فلسطين"
    }
}
```

---

## 📂 APIs التصنيفات (Categories)

### 1. عرض جميع التصنيفات الرئيسية

**GET** `/categories`

**الاستجابة الناجحة (200):**
```json
{
    "categories": [
        {
            "id": 1,
            "name": "الإلكترونيات",
            "name_en": "Electronics",
            "description": "جميع أنواع الأجهزة الإلكترونية والكهربائية",
            "icon": "fas fa-laptop",
            "color": "#007bff",
            "is_active": true,
            "sort_order": 1,
            "children": [
                {
                    "id": 7,
                    "name": "الهواتف الذكية",
                    "name_en": "Smartphones",
                    "icon": "fas fa-mobile-alt",
                    "parent_id": 1,
                    "sort_order": 1
                },
                {
                    "id": 8,
                    "name": "الحواسيب المحمولة",
                    "name_en": "Laptops",
                    "icon": "fas fa-laptop",
                    "parent_id": 1,
                    "sort_order": 2
                }
            ]
        }
    ]
}
```

---

### 2. عرض التصنيفات الرئيسية فقط

**GET** `/categories/main`

**الاستجابة الناجحة (200):**
```json
{
    "main_categories": [
        {
            "id": 1,
            "name": "الإلكترونيات",
            "name_en": "Electronics",
            "description": "جميع أنواع الأجهزة الإلكترونية والكهربائية",
            "icon": "fas fa-laptop",
            "color": "#007bff",
            "children": [...]
        }
    ]
}
```

---

### 3. عرض تصنيف محدد

**GET** `/categories/{id}`

**مثال:** `/categories/1`

**الاستجابة الناجحة (200):**
```json
{
    "category": {
        "id": 1,
        "name": "الإلكترونيات",
        "name_en": "Electronics",
        "description": "جميع أنواع الأجهزة الإلكترونية والكهربائية",
        "icon": "fas fa-laptop",
        "color": "#007bff",
        "is_active": true,
        "sort_order": 1,
        "children": [...],
        "parent": null
    }
}
```

---

### 4. عرض التصنيفات الفرعية

**GET** `/categories/{id}/subcategories`

**مثال:** `/categories/1/subcategories`

**الاستجابة الناجحة (200):**
```json
{
    "parent_category": {
        "id": 1,
        "name": "الإلكترونيات",
        "name_en": "Electronics"
    },
    "subcategories": [
        {
            "id": 7,
            "name": "الهواتف الذكية",
            "name_en": "Smartphones",
            "icon": "fas fa-mobile-alt",
            "parent_id": 1,
            "sort_order": 1
        }
    ]
}
```

---

### 5. البحث في التصنيفات

**GET** `/categories/search?q=هاتف`

**الاستجابة الناجحة (200):**
```json
{
    "categories": [
        {
            "id": 7,
            "name": "الهواتف الذكية",
            "name_en": "Smartphones",
            "parent": {
                "id": 1,
                "name": "الإلكترونيات"
            }
        }
    ]
}
```

---

### 6. إنشاء تصنيف جديد (محمي)

**POST** `/categories`

**Headers:** `Authorization: Bearer {token}`

**المعاملات:**
```json
{
    "name": "تصنيف جديد",
    "name_en": "New Category",
    "description": "وصف التصنيف",
    "icon": "fas fa-star",
    "color": "#ff0000",
    "parent_id": null,
    "is_active": true,
    "sort_order": 1
}
```

**الاستجابة الناجحة (201):**
```json
{
    "message": "Category created successfully",
    "category": {
        "id": 10,
        "name": "تصنيف جديد",
        "name_en": "New Category",
        "description": "وصف التصنيف",
        "icon": "fas fa-star",
        "color": "#ff0000",
        "parent_id": null,
        "is_active": true,
        "sort_order": 1
    }
}
```

---

### 7. تحديث تصنيف (محمي)

**PUT** `/categories/{id}`

**Headers:** `Authorization: Bearer {token}`

**المعاملات:**
```json
{
    "name": "تصنيف محدث",
    "color": "#00ff00"
}
```

**الاستجابة الناجحة (200):**
```json
{
    "message": "Category updated successfully",
    "category": {
        "id": 10,
        "name": "تصنيف محدث",
        "color": "#00ff00"
    }
}
```

---

### 8. حذف تصنيف (محمي)

**DELETE** `/categories/{id}`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "message": "Category deleted successfully"
}
```

---

## 📦 APIs السلع (Items)

### 1. عرض جميع السلع

**GET** `/items`

**المعاملات الاختيارية:**
- `category_id`: تصفية حسب التصنيف الرئيسي
- `subcategory_id`: تصفية حسب التصنيف الفرعي
- `status`: تصفية حسب الحالة (available, sold)
- `min_price`: الحد الأدنى للسعر
- `max_price`: الحد الأقصى للسعر
- `search`: البحث في العنوان والوصف
- `latitude`, `longitude`, `radius`: البحث حسب الموقع

**مثال:** `/items?category_id=1&min_price=500&max_price=2000&search=هاتف`

**الاستجابة الناجحة (200):**
```json
[
    {
        "id": 1,
        "user_id": 1,
        "title": "جهاز كمبيوتر محمول Dell",
        "description": "جهاز كمبيوتر محمول Dell Inspiron 15، معالج Intel i7، ذاكرة 16GB، بحالة ممتازة",
        "image": "items/laptop_dell.jpg",
        "price": "1200.00",
        "exchange_for": null,
        "status": "available",
        "category_id": 1,
        "subcategory_id": 8,
        "latitude": 31.5017,
        "longitude": 34.4668,
        "location_name": "غزة، فلسطين",
        "created_at": "2025-01-20T10:30:00.000000Z",
        "updated_at": "2025-01-20T10:30:00.000000Z",
        "user": {
            "id": 1,
            "name": "أحمد محمد",
            "phone": "0599123456"
        },
        "category": {
            "id": 1,
            "name": "الإلكترونيات",
            "name_en": "Electronics"
        },
        "subcategory": {
            "id": 8,
            "name": "الحواسيب المحمولة",
            "name_en": "Laptops"
        }
    }
]
```

---

### 2. عرض السلع القريبة

**GET** `/items/nearby`

**المعاملات المطلوبة:**
- `latitude`: خط العرض
- `longitude`: خط الطول
- `radius`: نصف القطر بالكيلومترات (اختياري، افتراضي 10)

**مثال:** `/items/nearby?latitude=31.5017&longitude=34.4668&radius=5`

**الاستجابة الناجحة (200):**
```json
{
    "nearby_items": [
        {
            "id": 1,
            "title": "جهاز كمبيوتر محمول",
            "price": "1200.00",
            "distance": 2.5,
            "user": {
                "id": 1,
                "name": "أحمد محمد"
            },
            "category": {
                "id": 1,
                "name": "الإلكترونيات"
            }
        }
    ],
    "search_location": {
        "latitude": 31.5017,
        "longitude": 34.4668,
        "radius_km": 5
    }
}
```

---

### 3. عرض السلع الرائجة

**GET** `/items/trending`

**الاستجابة الناجحة (200):**
```json
{
    "trending_items": [
        {
            "id": 1,
            "user_id": 1,
            "title": "هاتف iPhone 13",
            "description": "هاتف آيفون 13 بحالة جيدة جداً، 128GB",
            "image": "items/iphone13.jpg",
            "price": "800.00",
            "exchange_for": null,
            "status": "available",
            "category_id": 1,
            "subcategory_id": 7,
            "latitude": 31.5017,
            "longitude": 34.4668,
            "location_name": "غزة، فلسطين",
            "created_at": "2025-01-20T15:30:00.000000Z",
            "updated_at": "2025-01-20T15:30:00.000000Z",
            "user": {
                "id": 1,
                "name": "أحمد محمد",
                "phone": "0599123456"
            },
            "category": {
                "id": 1,
                "name": "الإلكترونيات",
                "name_en": "Electronics"
            },
            "subcategory": {
                "id": 7,
                "name": "الهواتف الذكية",
                "name_en": "Smartphones"
            }
        }
    ]
}
```

**ملاحظات:**
- يعرض السلع المتاحة من آخر 7 أيام
- إذا لم تكن هناك سلع كافية من آخر 7 أيام، يتم إضافة سلع أقدم
- الحد الأقصى 10 سلع

---

### 4. عرض سلعة محددة

**GET** `/items/{id}`

**مثال:** `/items/1`

**الاستجابة الناجحة (200):**
```json
{
    "id": 1,
    "user_id": 1,
    "title": "جهاز كمبيوتر محمول Dell",
    "description": "جهاز كمبيوتر محمول Dell Inspiron 15، معالج Intel i7، ذاكرة 16GB، بحالة ممتازة",
    "image": "items/laptop_dell.jpg",
    "price": "1200.00",
    "exchange_for": null,
    "status": "available",
    "category_id": 1,
    "subcategory_id": 8,
    "latitude": 31.5017,
    "longitude": 34.4668,
    "location_name": "غزة، فلسطين",
    "created_at": "2025-01-20T10:30:00.000000Z",
    "updated_at": "2025-01-20T10:30:00.000000Z",
    "user": {
        "id": 1,
        "name": "أحمد محمد",
        "phone": "0599123456"
    },
    "category": {
        "id": 1,
        "name": "الإلكترونيات",
        "name_en": "Electronics"
    },
    "subcategory": {
        "id": 8,
        "name": "الحواسيب المحمولة",
        "name_en": "Laptops"
    }
}
```

---

### 5. إضافة سلعة جديدة

**POST** `/items`

**Headers:** `Authorization: Bearer {token}`, `Content-Type: multipart/form-data`

**المعاملات:**
```json
{
    "title": "هاتف iPhone 13",
    "description": "هاتف آيفون 13 بحالة جيدة جداً، 128GB، مع الشاحن والعلبة الأصلية",
    "image": "[ملف الصورة]",
    "price": 800.00,
    "exchange_for": "Samsung Galaxy S22",
    "status": "available",
    "category_id": 1,
    "subcategory_id": 7,
    "latitude": 31.5017,
    "longitude": 34.4668,
    "location_name": "غزة، فلسطين"
}
```

**الاستجابة الناجحة (201):**
```json
{
    "message": "Item created successfully",
    "item": {
        "id": 2,
        "user_id": 1,
        "title": "هاتف iPhone 13",
        "description": "هاتف آيفون 13 بحالة جيدة جداً، 128GB، مع الشاحن والعلبة الأصلية",
        "image": "items/iphone13_abc123.jpg",
        "price": "800.00",
        "exchange_for": "Samsung Galaxy S22",
        "status": "available",
        "category_id": 1,
        "subcategory_id": 7,
        "latitude": 31.5017,
        "longitude": 34.4668,
        "location_name": "غزة، فلسطين",
        "created_at": "2025-01-20T11:00:00.000000Z",
        "updated_at": "2025-01-20T11:00:00.000000Z",
        "user": {
            "id": 1,
            "name": "أحمد محمد",
            "phone": "0599123456"
        },
        "category": {
            "id": 1,
            "name": "الإلكترونيات",
            "name_en": "Electronics"
        },
        "subcategory": {
            "id": 7,
            "name": "الهواتف الذكية",
            "name_en": "Smartphones"
        }
    }
}
```

---

### 6. تحديث سلعة

**PUT** `/items/{id}`

**Headers:** `Authorization: Bearer {token}`, `Content-Type: multipart/form-data`

**المعاملات (جميعها اختيارية):**
```json
{
    "title": "هاتف iPhone 13 Pro",
    "description": "وصف محدث للهاتف",
    "image": "[ملف الصورة الجديد]",
    "price": 850.00,
    "exchange_for": "Samsung Galaxy S23",
    "status": "sold",
    "category_id": 1,
    "subcategory_id": 7,
    "latitude": 31.5017,
    "longitude": 34.4668,
    "location_name": "غزة، فلسطين"
}
```

**الاستجابة الناجحة (200):**
```json
{
    "message": "Item updated successfully",
    "item": {
        "id": 2,
        "user_id": 1,
        "title": "هاتف iPhone 13 Pro",
        "description": "وصف محدث للهاتف",
        "image": "items/iphone13pro_xyz789.jpg",
        "price": "850.00",
        "exchange_for": "Samsung Galaxy S23",
        "status": "sold",
        "category_id": 1,
        "subcategory_id": 7,
        "latitude": 31.5017,
        "longitude": 34.4668,
        "location_name": "غزة، فلسطين",
        "created_at": "2025-01-20T11:00:00.000000Z",
        "updated_at": "2025-01-20T11:30:00.000000Z",
        "user": {
            "id": 1,
            "name": "أحمد محمد",
            "phone": "0599123456"
        },
        "category": {
            "id": 1,
            "name": "الإلكترونيات",
            "name_en": "Electronics"
        },
        "subcategory": {
            "id": 7,
            "name": "الهواتف الذكية",
            "name_en": "Smartphones"
        }
    }
}
```

---

### 7. حذف سلعة

**DELETE** `/items/{id}`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "message": "Item deleted successfully"
}
```

**أخطاء محتملة:**
- `403`: غير مخول (السلعة لا تنتمي للمستخدم)
- `404`: السلعة غير موجودة

---

## 🏠 APIs العقارات (Properties)

### 1. عرض جميع العقارات

**GET** `/properties`

**الاستجابة الناجحة (200):**
```json
[
    {
        "id": 1,
        "user_id": 1,
        "title": "شقة 3 غرف للبيع",
        "description": "شقة مكونة من 3 غرف نوم، صالة، مطبخ، 2 حمام، الطابق الثالث، مساحة 120 متر مربع",
        "image": "properties/apartment_3rooms.jpg",
        "price": "85000.00",
        "address": "حي الرمال، شارع عمر المختار",
        "type": "buy",
        "latitude": 31.5017,
        "longitude": 34.4668,
        "location_name": "غزة، فلسطين",
        "created_at": "2025-01-20T10:30:00.000000Z",
        "updated_at": "2025-01-20T10:30:00.000000Z",
        "user": {
            "id": 1,
            "name": "أحمد محمد",
            "phone": "0599123456"
        }
    }
]
```

---

### 2. عرض عقار محدد

**GET** `/properties/{id}`

**مثال:** `/properties/1`

**الاستجابة الناجحة (200):**
```json
{
    "id": 1,
    "user_id": 1,
    "title": "شقة 3 غرف للبيع",
    "description": "شقة مكونة من 3 غرف نوم، صالة، مطبخ، 2 حمام، الطابق الثالث، مساحة 120 متر مربع",
    "image": "properties/apartment_3rooms.jpg",
    "price": "85000.00",
    "address": "حي الرمال، شارع عمر المختار",
    "type": "buy",
    "latitude": 31.5017,
    "longitude": 34.4668,
    "location_name": "غزة، فلسطين",
    "created_at": "2025-01-20T10:30:00.000000Z",
    "updated_at": "2025-01-20T10:30:00.000000Z",
    "user": {
        "id": 1,
        "name": "أحمد محمد",
        "phone": "0599123456"
    }
}
```

---

### 3. إضافة عقار جديد

**POST** `/properties`

**Headers:** `Authorization: Bearer {token}`, `Content-Type: multipart/form-data`

**المعاملات:**
```json
{
    "title": "فيلا للبيع",
    "description": "فيلا مكونة من طابقين، 5 غرف نوم، 3 حمامات، حديقة كبيرة، مساحة الأرض 300 متر",
    "image": "[ملف الصورة]",
    "price": 120000.00,
    "address": "حي النصر، شارع فلسطين",
    "type": "buy",
    "latitude": 31.5017,
    "longitude": 34.4668,
    "location_name": "غزة، فلسطين"
}
```

**الاستجابة الناجحة (201):**
```json
{
    "message": "Property created successfully",
    "property": {
        "id": 2,
        "user_id": 1,
        "title": "فيلا للبيع",
        "description": "فيلا مكونة من طابقين، 5 غرف نوم، 3 حمامات، حديقة كبيرة، مساحة الأرض 300 متر",
        "image": "properties/villa_abc123.jpg",
        "price": "120000.00",
        "address": "حي النصر، شارع فلسطين",
        "type": "buy",
        "latitude": 31.5017,
        "longitude": 34.4668,
        "location_name": "غزة، فلسطين",
        "created_at": "2025-01-20T11:00:00.000000Z",
        "updated_at": "2025-01-20T11:00:00.000000Z",
        "user": {
            "id": 1,
            "name": "أحمد محمد",
            "phone": "0599123456"
        }
    }
}
```

---

### 4. تحديث عقار

**PUT** `/properties/{id}`

**Headers:** `Authorization: Bearer {token}`, `Content-Type: multipart/form-data`

**المعاملات (جميعها اختيارية):**
```json
{
    "title": "فيلا فاخرة للبيع",
    "description": "وصف محدث للفيلا",
    "image": "[ملف الصورة الجديد]",
    "price": 125000.00,
    "address": "حي النصر، شارع فلسطين - محدث",
    "type": "buy",
    "latitude": 31.5017,
    "longitude": 34.4668,
    "location_name": "غزة، فلسطين"
}
```

**الاستجابة الناجحة (200):**
```json
{
    "message": "Property updated successfully",
    "property": {
        "id": 2,
        "user_id": 1,
        "title": "فيلا فاخرة للبيع",
        "description": "وصف محدث للفيلا",
        "image": "properties/villa_updated_xyz789.jpg",
        "price": "125000.00",
        "address": "حي النصر، شارع فلسطين - محدث",
        "type": "buy",
        "latitude": 31.5017,
        "longitude": 34.4668,
        "location_name": "غزة، فلسطين",
        "created_at": "2025-01-20T11:00:00.000000Z",
        "updated_at": "2025-01-20T11:30:00.000000Z",
        "user": {
            "id": 1,
            "name": "أحمد محمد",
            "phone": "0599123456"
        }
    }
}
```

---

### 5. حذف عقار

**DELETE** `/properties/{id}`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "message": "Property deleted successfully"
}
```

---

## 📄 أكواد الحالة (Status Codes)

| الكود | المعنى | الوصف |
|-------|--------|---------|
| 200 | OK | الطلب نجح |
| 201 | Created | تم إنشاء البيانات بنجاح |
| 400 | Bad Request | طلب خاطئ |
| 401 | Unauthorized | غير مخول |
| 403 | Forbidden | ممنوع |  
| 404 | Not Found | غير موجود |
| 422 | Unprocessable Entity | بيانات غير صحيحة |
| 500 | Internal Server Error | خطأ في الخادم |

---

## 🔧 أمثلة عملية للاستخدام

### مثال 1: تسجيل مستخدم جديد وإضافة سلعة مع التصنيف والموقع

```bash
# 1. تسجيل مستخدم جديد
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "محمد أحمد",
    "phone": "0598765432",
    "password": "password123",
    "password_confirmation": "password123"
  }'

# 2. تحديث موقع المستخدم
curl -X PUT http://localhost:8000/api/user/location \
  -H "Authorization: Bearer 1|your-token-here" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "latitude": 31.5017,
    "longitude": 34.4668,
    "location_name": "غزة، فلسطين"
  }'

# 3. إضافة سلعة مع التصنيف والموقع
curl -X POST http://localhost:8000/api/items \
  -H "Authorization: Bearer 1|your-token-here" \
  -H "Accept: application/json" \
  -F "title=جهاز لابتوب جديد" \
  -F "description=جهاز لابتوب بحالة ممتازة" \
  -F "price=1500" \
  -F "status=available" \
  -F "category_id=1" \
  -F "subcategory_id=8" \
  -F "latitude=31.5017" \
  -F "longitude=34.4668" \
  -F "location_name=غزة، فلسطين" \
  -F "image=@/path/to/image.jpg"
```

### مثال 2: البحث والفلترة المتقدمة

```bash
# عرض جميع السلع في تصنيف الإلكترونيات
curl -X GET "http://localhost:8000/api/items?category_id=1" \
  -H "Accept: application/json"

# البحث عن السلع القريبة
curl -X GET "http://localhost:8000/api/items/nearby?latitude=31.5017&longitude=34.4668&radius=5" \
  -H "Accept: application/json"

# البحث في السلع حسب السعر والكلمة المفتاحية
curl -X GET "http://localhost:8000/api/items?min_price=500&max_price=2000&search=هاتف" \
  -H "Accept: application/json"

# عرض التصنيفات الرئيسية
curl -X GET "http://localhost:8000/api/categories/main" \
  -H "Accept: application/json"

# البحث في التصنيفات
curl -X GET "http://localhost:8000/api/categories/search?q=هاتف" \
  -H "Accept: application/json"
```

### مثال 3: عرض بيانات المستخدم والموقع

```bash
# عرض الملف الشخصي مع الإحصائيات
curl -X GET "http://localhost:8000/api/user/profile" \
  -H "Authorization: Bearer 1|your-token-here" \
  -H "Accept: application/json"

# عرض إحصائيات المستخدم
curl -X GET "http://localhost:8000/api/user/statistics" \
  -H "Authorization: Bearer 1|your-token-here" \
  -H "Accept: application/json"

# عرض النشاط الأخير
curl -X GET "http://localhost:8000/api/user/recent-activity" \
  -H "Authorization: Bearer 1|your-token-here" \
  -H "Accept: application/json"
```

---

## 📋 ملاحظات مهمة

1. **الصور**: يجب أن تكون الصور بصيغة (jpeg, png, jpg, gif) وحجم أقصى 2MB
2. **الأسعار**: يتم حفظ الأسعار كـ decimal بدقة (10,2)
3. **التواريخ**: جميع التواريخ بصيغة ISO 8601
4. **الترميز**: يدعم النص العربي والإنجليزي
5. **الحماية**: جميع العمليات الخاصة تتطلب token صالح
6. **السلع الرائجة**: تعرض السلع المتاحة من آخر 7 أيام، مع إمكانية إضافة سلع أقدم إذا لم تكن كافية
7. **النشاط الأخير**: يعرض آخر 10 أنشطة للمستخدم (سلع وعقارات)
8. **الموقع**: يدعم إحداثيات GPS مع اسم الموقع
9. **التصنيفات**: نظام تصنيفات رئيسية وفرعية مع دعم الأيقونات والألوان
10. **البحث الجغرافي**: يستخدم صيغة Haversine لحساب المسافات
11. **الفلترة المتقدمة**: دعم الفلترة حسب التصنيف، السعر، الحالة، والموقع

---

## ⚠️ أخطاء شائعة وحلولها

### خطأ 401 - Unauthorized
```json
{
    "message": "Unauthenticated."
}
```
**الحل**: تأكد من إرسال token صحيح في header

### خطأ 422 - Validation Error
```json
{
    "message": "The given data was invalid.",
    "errors": {
        "phone": ["The phone has already been taken."],
        "password": ["The password confirmation does not match."]
    }
}
```
**الحل**: تحقق من البيانات المطلوبة وصحتها

### خطأ 403 - Forbidden
```json
{
    "message": "Unauthorized"
}
```
**الحل**: المستخدم لا يملك صلاحية تعديل/حذف هذا العنصر

---

## 🔗 روابط مفيدة

- **Laravel Documentation**: https://laravel.com/docs
- **Laravel Sanctum**: https://laravel.com/docs/sanctum
- **Postman Collection**: [قم بإنشاء collection لاختبار APIs]

---

**تم إنشاء هذا المستند في**: يناير 2025  
**الإصدار**: 2.0  
**المطور**: Gaza Exchange Team