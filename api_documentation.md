# Gaza Exchange API Documentation

## نظرة عامة

هذا المستند يوضح كيفية استخدام APIs الخاصة بمشروع تبادل السلع والعقارات. جميع الـ APIs تستخدم JSON format وتعيد استجابات JSON موحدة.

**Base URL**: `http://localhost:8000/api`

## تنسيق الاستجابة الموحد

جميع الاستجابات تتبع النمط الموحد التالي:

```json
{
    "success": true/false,
    "message": "رسالة توضيحية",
    "data": {...},
    "errors": null/[...]
}
```

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
    "success": true,
    "message": "User registered successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "أحمد محمد",
            "phone": "0599123456",
            "created_at": "2025-01-20T10:30:00.000000Z",
            "updated_at": "2025-01-20T10:30:00.000000Z"
        },
        "token": "1|abcdef123456789..."
    },
    "errors": null
}
```

**أخطاء محتملة (422):**
```json
{
    "success": false,
    "message": "Validation failed",
    "data": null,
    "errors": {
        "phone": ["The phone has already been taken."],
        "password": ["The password confirmation does not match."]
    }
}
```

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
    "success": true,
    "message": "Login successful",
    "data": {
        "user": {
            "id": 1,
            "name": "أحمد محمد",
            "phone": "0599123456",
            "created_at": "2025-01-20T10:30:00.000000Z",
            "updated_at": "2025-01-20T10:30:00.000000Z"
        },
        "token": "2|xyz789abc123..."
    },
    "errors": null
}
```

**أخطاء محتملة (422):**
```json
{
    "success": false,
    "message": "Invalid credentials",
    "data": null,
    "errors": {
        "phone": ["Invalid phone or password"]
    }
}
```

---

### 3. تسجيل الخروج

**POST** `/logout`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Logged out successfully",
    "data": null,
    "errors": null
}
```

---

### 4. عرض الملف الشخصي

**GET** `/profile`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Profile retrieved successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "أحمد محمد",
            "phone": "0599123456",
            "created_at": "2025-01-20T10:30:00.000000Z",
            "updated_at": "2025-01-20T10:30:00.000000Z"
        }
    },
    "errors": null
}
```

---

## 👤 APIs المستخدم (User)

### 1. عرض جميع المستخدمين

**GET** `/users`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Users retrieved successfully",
    "data": {
        "users": [
            {
                "id": 1,
                "name": "أحمد محمد",
                "phone": "0599123456",
                "items": [...],
                "properties": [...]
            }
        ]
    },
    "errors": null
}
```

---

### 2. عرض مستخدم محدد

**GET** `/users/{id}`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "User retrieved successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "أحمد محمد",
            "phone": "0599123456",
            "items": [...],
            "properties": [...]
        }
    },
    "errors": null
}
```

**خطأ (404):**
```json
{
    "success": false,
    "message": "User not found",
    "data": null,
    "errors": null
}
```

---

### 3. تحديث بيانات المستخدم

**PUT** `/users/{id}`

**Headers:** `Authorization: Bearer {token}`

**المعاملات:**
```json
{
    "name": "أحمد محمد محدث",
    "phone": "0599123457",
    "location": "غزة، فلسطين"
}
```

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "User updated successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "أحمد محمد محدث",
            "phone": "0599123457",
            "location": "غزة، فلسطين"
        }
    },
    "errors": null
}
```

---

### 4. حذف مستخدم

**DELETE** `/users/{id}`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "User deleted successfully",
    "data": null,
    "errors": null
}
```

---

### 5. عرض الملف الشخصي مع الإحصائيات

**GET** `/user/profile`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Profile retrieved successfully",
    "data": {
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
    },
    "errors": null
}
```

---

### 6. عرض إحصائيات المستخدم

**GET** `/user/statistics`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Statistics retrieved successfully",
    "data": {
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
    },
    "errors": null
}
```

---

### 7. عرض النشاط الأخير

**GET** `/user/recent-activity`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Recent activity retrieved successfully",
    "data": {
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
    },
    "errors": null
}
```

---

### 8. تحديث موقع المستخدم

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
    "success": true,
    "message": "Location updated successfully",
    "data": {
        "user": {
            "id": 1,
            "name": "أحمد محمد",
            "latitude": 31.5017,
            "longitude": 34.4668,
            "location_name": "غزة، فلسطين"
        }
    },
    "errors": null
}
```

---

## 📂 APIs التصنيفات (Categories)

### 1. عرض جميع التصنيفات الرئيسية

**GET** `/categories`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Categories retrieved successfully",
    "data": {
        "categories": [
            {
                "id": 1,
                "name": "الإلكترونيات",
                "description": "جميع أنواع الأجهزة الإلكترونية والكهربائية",
                "icon": "fas fa-laptop",
                "parent_id": null,
                "children": [
                    {
                        "id": 7,
                        "name": "الهواتف الذكية",
                        "description": "جميع أنواع الهواتف الذكية",
                        "icon": "fas fa-mobile-alt",
                        "parent_id": 1
                    },
                    {
                        "id": 8,
                        "name": "الحواسيب المحمولة",
                        "description": "جميع أنواع الحواسيب المحمولة",
                        "icon": "fas fa-laptop",
                        "parent_id": 1
                    }
                ]
            }
        ]
    },
    "errors": null
}
```

---

### 2. عرض تصنيف محدد

**GET** `/categories/{id}`

**مثال:** `/categories/1`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Category retrieved successfully",
    "data": {
        "category": {
            "id": 1,
            "name": "الإلكترونيات",
            "description": "جميع أنواع الأجهزة الإلكترونية والكهربائية",
            "icon": "fas fa-laptop",
            "parent_id": null,
            "children": [...],
            "parent": null
        }
    },
    "errors": null
}
```

**خطأ (404):**
```json
{
    "success": false,
    "message": "Category not found",
    "data": null,
    "errors": null
}
```

---

### 3. إنشاء تصنيف جديد

**POST** `/categories`

**Headers:** `Authorization: Bearer {token}`

**المعاملات:**
```json
{
    "name": "تصنيف جديد",
    "description": "وصف التصنيف",
    "icon": "fas fa-star",
    "parent_id": null
}
```

**الاستجابة الناجحة (201):**
```json
{
    "success": true,
    "message": "Category created successfully",
    "data": {
        "category": {
            "id": 10,
            "name": "تصنيف جديد",
            "description": "وصف التصنيف",
            "icon": "fas fa-star",
            "parent_id": null
        }
    },
    "errors": null
}
```

---

### 4. تحديث تصنيف

**PUT** `/categories/{id}`

**Headers:** `Authorization: Bearer {token}`

**المعاملات:**
```json
{
    "name": "تصنيف محدث",
    "description": "وصف محدث"
}
```

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Category updated successfully",
    "data": {
        "category": {
            "id": 10,
            "name": "تصنيف محدث",
            "description": "وصف محدث"
        }
    },
    "errors": null
}
```

---

### 5. حذف تصنيف

**DELETE** `/categories/{id}`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Category deleted successfully",
    "data": null,
    "errors": null
}
```

**خطأ (422):**
```json
{
    "success": false,
    "message": "Cannot delete category with subcategories",
    "data": null,
    "errors": null
}
```

---

### 6. عرض التصنيفات الفرعية

**GET** `/categories/{id}/subcategories`

**مثال:** `/categories/1/subcategories`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Subcategories retrieved successfully",
    "data": {
        "subcategories": [
            {
                "id": 7,
                "name": "الهواتف الذكية",
                "description": "جميع أنواع الهواتف الذكية",
                "icon": "fas fa-mobile-alt",
                "parent_id": 1
            }
        ]
    },
    "errors": null
}
```

---

## 📦 APIs السلع (Items)

> **ملاحظة مهمة حول الصور:**  
> تم تحديث النظام لدعم حفظ عدة صور لكل سلعة. عند إرسال حقل `images` كمصفوفة، سيتم حفظ كل صورة في جدول منفصل وربطها بالسلعة. عند جلب بيانات السلعة، ستظهر جميع الصور المرتبطة بها في حقل `images`.

### 1. عرض جميع السلع

**GET** `/items`

**المعاملات الاختيارية:**
- `category_id`: تصفية حسب التصنيف
- `location`: تصفية حسب الموقع
- `min_price`: الحد الأدنى للسعر
- `max_price`: الحد الأقصى للسعر
- `status`: تصفية حسب الحالة (available, sold, reserved)

**مثال:** `/items?category_id=1&min_price=500&max_price=2000&status=available`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Items retrieved successfully",
    "data": {
        "items": [
            {
                "id": 1,
                "user_id": 1,
                "title": "جهاز كمبيوتر محمول Dell",
                "description": "جهاز كمبيوتر محمول Dell Inspiron 15، معالج Intel i7، ذاكرة 16GB، بحالة ممتازة",
                "price": "1200.00",
                "category_id": 1,
                "location": "غزة، فلسطين",
                "condition": "used",
                "status": "available",
                "images": ["1705747200_abc123.jpg", "1705747201_def456.jpg"],
                "created_at": "2025-01-20T10:30:00.000000Z",
                "updated_at": "2025-01-20T10:30:00.000000Z",
                "user": {
                    "id": 1,
                    "name": "أحمد محمد",
                    "phone": "0599123456"
                },
                "category": {
                    "id": 1,
                    "name": "الإلكترونيات"
                }
            }
        ],
        "pagination": {
            "current_page": 1,
            "last_page": 5,
            "per_page": 15,
            "total": 75
        }
    },
    "errors": null
}
```

---

### 2. عرض السلع الرائجة

**GET** `/items/trending`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Trending items retrieved successfully",
    "data": {
        "trending_items": [
            {
                "id": 1,
                "user_id": 1,
                "title": "هاتف iPhone 13",
                "description": "هاتف آيفون 13 بحالة جيدة جداً، 128GB",
                "price": "800.00",
                "category_id": 1,
                "location": "غزة، فلسطين",
                "condition": "used",
                "status": "available",
                "images": ["1705747200_abc123.jpg"],
                "views": 150,
                "created_at": "2025-01-20T15:30:00.000000Z",
                "user": {
                    "id": 1,
                    "name": "أحمد محمد",
                    "phone": "0599123456"
                },
                "category": {
                    "id": 1,
                    "name": "الإلكترونيات"
                }
            }
        ]
    },
    "errors": null
}
```

---

### 3. البحث في السلع

**GET** `/items/search?query=هاتف`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Search results retrieved successfully",
    "data": {
        "items": [
            {
                "id": 1,
                "title": "هاتف iPhone 13",
                "description": "هاتف آيفون 13 بحالة جيدة جداً",
                "price": "800.00",
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
        "pagination": {
            "current_page": 1,
            "last_page": 1,
            "per_page": 15,
            "total": 1
        }
    },
    "errors": null
}
```

---

### 4. عرض سلعة محددة

**GET** `/items/{id}`

**مثال:** `/items/1`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Item retrieved successfully",
    "data": {
        "item": {
            "id": 1,
            "user_id": 1,
            "title": "جهاز كمبيوتر محمول Dell",
            "description": "جهاز كمبيوتر محمول Dell Inspiron 15، معالج Intel i7، ذاكرة 16GB، بحالة ممتازة",
            "price": "1200.00",
            "category_id": 1,
            "location": "غزة، فلسطين",
            "condition": "used",
            "status": "available",
            "created_at": "2025-01-20T10:30:00.000000Z",
            "updated_at": "2025-01-20T10:30:00.000000Z",
            "user": {
                "id": 1,
                "name": "أحمد محمد",
                "phone": "0599123456"
            },
            "category": {
                "id": 1,
                "name": "الإلكترونيات"
            },
            "images": [
                {
                    "id": 1,
                    "item_id": 1,
                    "image": "1705747200_abc123.jpg",
                    "created_at": "2025-01-20T10:30:00.000000Z",
                    "updated_at": "2025-01-20T10:30:00.000000Z"
                },
                {
                    "id": 2,
                    "item_id": 1,
                    "image": "1705747201_def456.jpg",
                    "created_at": "2025-01-20T10:30:00.000000Z",
                    "updated_at": "2025-01-20T10:30:00.000000Z"
                }
            ]
        }
    },
    "errors": null
}
```

---

### 5. إضافة سلعة جديدة

**POST** `/items`

**Headers:** `Authorization: Bearer {token}`

**المعاملات:**
```json
{
    "title": "جهاز لابتوب جديد",
    "description": "جهاز لابتوب بحالة ممتازة",
    "price": 1500,
    "category_id": 1,
    "location": "غزة، فلسطين",
    "phone": "0599123456",
    "condition": "used",
    "status": "available",
    "images": ["1705747200_abc123.jpg", "1705747201_def456.jpg"]
}
```

**الاستجابة الناجحة (201):**
```json
{
    "success": true,
    "message": "Item created successfully",
    "data": {
        "item": {
            "id": 2,
            "user_id": 1,
            "title": "جهاز لابتوب جديد",
            "description": "جهاز لابتوب بحالة ممتازة",
            "price": "1500.00",
            "category_id": 1,
            "location": "غزة، فلسطين",
            "phone": "0599123456",
            "condition": "used",
            "status": "available",
            "created_at": "2025-01-20T11:00:00.000000Z",
            "updated_at": "2025-01-20T11:00:00.000000Z",
            "user": {
                "id": 1,
                "name": "أحمد محمد",
                "phone": "0599123456"
            },
            "category": {
                "id": 1,
                "name": "الإلكترونيات"
            },
            "images": [
                {
                    "id": 3,
                    "item_id": 2,
                    "image": "1705747200_abc123.jpg",
                    "created_at": "2025-01-20T11:00:00.000000Z",
                    "updated_at": "2025-01-20T11:00:00.000000Z"
                },
                {
                    "id": 4,
                    "item_id": 2,
                    "image": "1705747201_def456.jpg",
                    "created_at": "2025-01-20T11:00:00.000000Z",
                    "updated_at": "2025-01-20T11:00:00.000000Z"
                }
            ]
        }
    },
    "errors": null
}
```

---

### 6. تحديث سلعة

**PUT** `/items/{id}`

**Headers:** `Authorization: Bearer {token}`

**المعاملات (جميعها اختيارية):**
```json
{
    "title": "هاتف iPhone 13 Pro",
    "description": "وصف محدث للهاتف",
    "price": 850.00,
    "category_id": 1,
    "location": "غزة، فلسطين",
    "phone": "0599123456",
    "condition": "used",
    "status": "sold",
    "images": ["1705747200_abc123.jpg", "1705747201_def456.jpg"]
}
```

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Item updated successfully",
    "data": {
        "item": {
            "id": 2,
            "user_id": 1,
            "title": "هاتف iPhone 13 Pro",
            "description": "وصف محدث للهاتف",
            "price": "850.00",
            "category_id": 1,
            "location": "غزة، فلسطين",
            "phone": "0599123456",
            "condition": "used",
            "status": "sold",
            "images": ["1705747200_abc123.jpg", "1705747201_def456.jpg"],
            "created_at": "2025-01-20T11:00:00.000000Z",
            "updated_at": "2025-01-20T11:30:00.000000Z",
            "user": {
                "id": 1,
                "name": "أحمد محمد",
                "phone": "0599123456"
            },
            "category": {
                "id": 1,
                "name": "الإلكترونيات"
            }
        }
    },
    "errors": null
}
```

**خطأ (403):**
```json
{
    "success": false,
    "message": "You can only update your own items",
    "data": null,
    "errors": null
}
```

---

### 7. حذف سلعة

**DELETE** `/items/{id}`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Item deleted successfully",
    "data": null,
    "errors": null
}
```

---

## 🏠 APIs العقارات (Properties)

> **ملاحظة مهمة حول الصور:**  
> تم تحديث النظام لدعم حفظ عدة صور لكل عقار. عند إرسال حقل `images` كمصفوفة، سيتم حفظ كل صورة في جدول منفصل وربطها بالعقار. عند جلب بيانات العقار، ستظهر جميع الصور المرتبطة به في حقل `images`.

### 1. عرض جميع العقارات

**GET** `/properties`

**المعاملات الاختيارية:**
- `type`: تصفية حسب النوع (buy, rent)
- `location`: تصفية حسب الموقع
- `min_price`: الحد الأدنى للسعر
- `max_price`: الحد الأقصى للسعر
- `status`: تصفية حسب الحالة (available, sold, rented)

**مثال:** `/properties?type=buy&min_price=50000&max_price=150000&status=available`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Properties retrieved successfully",
    "data": {
        "properties": [
            {
                "id": 1,
                "user_id": 1,
                "title": "شقة 3 غرف للبيع",
                "description": "شقة مكونة من 3 غرف نوم، صالة، مطبخ، 2 حمام، الطابق الثالث، مساحة 120 متر مربع",
                "price": "85000.00",
                "type": "buy",
                "location": "غزة، فلسطين",
                "bedrooms": 3,
                "bathrooms": 2,
                "area": 120,
                "status": "available",
                "images": ["1705747200_abc123.jpg", "1705747201_def456.jpg"],
                "created_at": "2025-01-20T10:30:00.000000Z",
                "updated_at": "2025-01-20T10:30:00.000000Z",
                "user": {
                    "id": 1,
                    "name": "أحمد محمد",
                    "phone": "0599123456"
                }
            }
        ],
        "pagination": {
            "current_page": 1,
            "last_page": 3,
            "per_page": 15,
            "total": 45
        }
    },
    "errors": null
}
```

---

### 2. البحث في العقارات

**GET** `/properties/search?query=شقة`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Search results retrieved successfully",
    "data": {
        "properties": [
            {
                "id": 1,
                "title": "شقة 3 غرف للبيع",
                "description": "شقة مكونة من 3 غرف نوم",
                "price": "85000.00",
                "type": "buy",
                "location": "غزة، فلسطين",
                "user": {
                    "id": 1,
                    "name": "أحمد محمد"
                }
            }
        ],
        "pagination": {
            "current_page": 1,
            "last_page": 1,
            "per_page": 15,
            "total": 1
        }
    },
    "errors": null
}
```

---

### 3. عرض عقار محدد

**GET** `/properties/{id}`

**مثال:** `/properties/1`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Property retrieved successfully",
    "data": {
        "property": {
            "id": 1,
            "user_id": 1,
            "title": "شقة 3 غرف للبيع",
            "description": "شقة مكونة من 3 غرف نوم، صالة، مطبخ، 2 حمام، الطابق الثالث، مساحة 120 متر مربع",
            "price": "85000.00",
            "type": "buy",
            "location": "غزة، فلسطين",
            "bedrooms": 3,
            "bathrooms": 2,
            "area": 120,
            "status": "available",
            "created_at": "2025-01-20T10:30:00.000000Z",
            "updated_at": "2025-01-20T10:30:00.000000Z",
            "user": {
                "id": 1,
                "name": "أحمد محمد",
                "phone": "0599123456"
            },
            "images": [
                {
                    "id": 1,
                    "property_id": 1,
                    "image": "1705747200_abc123.jpg",
                    "created_at": "2025-01-20T10:30:00.000000Z",
                    "updated_at": "2025-01-20T10:30:00.000000Z"
                },
                {
                    "id": 2,
                    "property_id": 1,
                    "image": "1705747201_def456.jpg",
                    "created_at": "2025-01-20T10:30:00.000000Z",
                    "updated_at": "2025-01-20T10:30:00.000000Z"
                }
            ]
        }
    },
    "errors": null
}
```

---

### 4. إضافة عقار جديد

**POST** `/properties`

**Headers:** `Authorization: Bearer {token}`

**المعاملات:**
```json
{
    "title": "فيلا للبيع",
    "description": "فيلا مكونة من طابقين، 5 غرف نوم، 3 حمامات، حديقة كبيرة، مساحة الأرض 300 متر",
    "price": 120000.00,
    "type": "buy",
    "location": "غزة، فلسطين",
    "phone": "0599123456",
    "bedrooms": 5,
    "bathrooms": 3,
    "area": 300,
    "status": "available",
    "images": ["1705747200_abc123.jpg", "1705747201_def456.jpg"]
}
```

**الاستجابة الناجحة (201):**
```json
{
    "success": true,
    "message": "Property created successfully",
    "data": {
        "property": {
            "id": 2,
            "user_id": 1,
            "title": "فيلا للبيع",
            "description": "فيلا مكونة من طابقين، 5 غرف نوم، 3 حمامات، حديقة كبيرة، مساحة الأرض 300 متر",
            "price": "120000.00",
            "type": "buy",
            "location": "غزة، فلسطين",
            "phone": "0599123456",
            "bedrooms": 5,
            "bathrooms": 3,
            "area": 300,
            "status": "available",
            "created_at": "2025-01-20T11:00:00.000000Z",
            "updated_at": "2025-01-20T11:00:00.000000Z",
            "user": {
                "id": 1,
                "name": "أحمد محمد",
                "phone": "0599123456"
            },
            "images": [
                {
                    "id": 3,
                    "property_id": 2,
                    "image": "1705747200_abc123.jpg",
                    "created_at": "2025-01-20T11:00:00.000000Z",
                    "updated_at": "2025-01-20T11:00:00.000000Z"
                },
                {
                    "id": 4,
                    "property_id": 2,
                    "image": "1705747201_def456.jpg",
                    "created_at": "2025-01-20T11:00:00.000000Z",
                    "updated_at": "2025-01-20T11:00:00.000000Z"
                }
            ]
        }
    },
    "errors": null
}
```

---

### 5. تحديث عقار

**PUT** `/properties/{id}`

**Headers:** `Authorization: Bearer {token}`

**المعاملات (جميعها اختيارية):**
```json
{
    "title": "فيلا فاخرة للبيع",
    "description": "وصف محدث للفيلا",
    "price": 125000.00,
    "type": "buy",
    "location": "غزة، فلسطين",
    "phone": "0599123456",
    "bedrooms": 5,
    "bathrooms": 3,
    "area": 300,
    "status": "sold",
    "images": ["1705747200_abc123.jpg", "1705747201_def456.jpg"]
}
```

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Property updated successfully",
    "data": {
        "property": {
            "id": 2,
            "user_id": 1,
            "title": "فيلا فاخرة للبيع",
            "description": "وصف محدث للفيلا",
            "price": "125000.00",
            "type": "buy",
            "location": "غزة، فلسطين",
            "phone": "0599123456",
            "bedrooms": 5,
            "bathrooms": 3,
            "area": 300,
            "status": "sold",
            "images": ["1705747200_abc123.jpg", "1705747201_def456.jpg"],
            "created_at": "2025-01-20T11:00:00.000000Z",
            "updated_at": "2025-01-20T11:30:00.000000Z",
            "user": {
                "id": 1,
                "name": "أحمد محمد",
                "phone": "0599123456"
            }
        }
    },
    "errors": null
}
```

---

### 6. حذف عقار

**DELETE** `/properties/{id}`

**Headers:** `Authorization: Bearer {token}`

**الاستجابة الناجحة (200):**
```json
{
    "success": true,
    "message": "Property deleted successfully",
    "data": null,
    "errors": null
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

### مثال 1: تسجيل مستخدم جديد وإضافة سلعة

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

# 3. إضافة سلعة جديدة
curl -X POST http://localhost:8000/api/items \
  -H "Authorization: Bearer 1|your-token-here" \
  -H "Accept: application/json" \
  -F "title=جهاز لابتوب جديد" \
  -F "description=جهاز لابتوب بحالة ممتازة" \
  -F "price=1500" \
  -F "category_id=1" \
  -F "location=غزة، فلسطين" \
  -F "phone=0599123456" \
  -F "condition=used" \
  -F "status=available" \
  -F "images[]=@image1.jpg" \
  -F "images[]=@image2.jpg"
```

### مثال 2: البحث والفلترة

```bash
# عرض جميع السلع في تصنيف الإلكترونيات
curl -X GET "http://localhost:8000/api/items?category_id=1&status=available" \
  -H "Accept: application/json"

# البحث في السلع حسب السعر والكلمة المفتاحية
curl -X GET "http://localhost:8000/api/items/search?query=هاتف" \
  -H "Accept: application/json"

# عرض السلع الرائجة
curl -X GET "http://localhost:8000/api/items/trending" \
  -H "Accept: application/json"

# عرض العقارات للبيع
curl -X GET "http://localhost:8000/api/properties?type=buy&status=available" \
  -H "Accept: application/json"

# البحث في العقارات
curl -X GET "http://localhost:8000/api/properties/search?query=شقة" \
  -H "Accept: application/json"

# إضافة عقار جديد مع الصور
curl -X POST http://localhost:8000/api/properties \
  -H "Authorization: Bearer 1|your-token-here" \
  -H "Accept: application/json" \
  -F "title=فيلا للبيع" \
  -F "description=فيلا مكونة من طابقين، 5 غرف نوم، 3 حمامات" \
  -F "price=120000" \
  -F "type=buy" \
  -F "location=غزة، فلسطين" \
  -F "phone=0599123456" \
  -F "bedrooms=5" \
  -F "bathrooms=3" \
  -F "area=300" \
  -F "status=available" \
  -F "images[]=@villa1.jpg" \
  -F "images[]=@villa2.jpg"
```

### مثال 3: إدارة المستخدم

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

# عرض جميع المستخدمين
curl -X GET "http://localhost:8000/api/users" \
  -H "Authorization: Bearer 1|your-token-here" \
  -H "Accept: application/json"

# حذف صورة محددة من سلعة
curl -X DELETE "http://localhost:8000/api/items/1/images/2" \
  -H "Authorization: Bearer 1|your-token-here" \
  -H "Accept: application/json"

# حذف صورة محددة من عقار
curl -X DELETE "http://localhost:8000/api/properties/1/images/3" \
  -H "Authorization: Bearer 1|your-token-here" \
  -H "Accept: application/json"
```

---

## 📋 ملاحظات مهمة

1. **تنسيق الاستجابة الموحد**: جميع الاستجابات تتبع النمط الموحد مع حقول `success`, `message`, `data`, و `errors`
2. **الصور المتعددة**: تم تحديث النظام لدعم عدة صور لكل سلعة أو عقار مع حفظها في الملفات
3. **الأسعار**: يتم حفظ الأسعار كـ decimal بدقة (10,2)
4. **التواريخ**: جميع التواريخ بصيغة ISO 8601
5. **الترميز**: يدعم النص العربي والإنجليزي
6. **الحماية**: جميع العمليات الخاصة تتطلب token صالح
7. **السلع الرائجة**: تعرض السلع حسب عدد المشاهدات
8. **النشاط الأخير**: يعرض آخر 10 أنشطة للمستخدم (سلع وعقارات)
9. **الموقع**: يدعم إحداثيات GPS مع اسم الموقع
10. **التصنيفات**: نظام تصنيفات رئيسية وفرعية مع دعم الأيقونات
11. **التصفية المتقدمة**: دعم التصفية حسب التصنيف، السعر، الحالة، والموقع
12. **التصفح**: جميع قوائم العناصر تدعم التصفح مع معلومات الصفحات
13. **حجم الصور**: الحد الأقصى 2MB لكل صورة
14. **صيغ الصور**: JPEG, PNG, JPG, GIF مدعومة

---

## ⚠️ أخطاء شائعة وحلولها

### خطأ 401 - Unauthorized
```json
{
    "success": false,
    "message": "Unauthenticated.",
    "data": null,
    "errors": null
}
```
**الحل**: تأكد من إرسال token صحيح في header

### خطأ 422 - Validation Error
```json
{
    "success": false,
    "message": "Validation failed",
    "data": null,
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
    "success": false,
    "message": "You can only update your own items",
    "data": null,
    "errors": null
}
```
**الحل**: المستخدم لا يملك صلاحية تعديل/حذف هذا العنصر

### خطأ 404 - Not Found
```json
{
    "success": false,
    "message": "Item not found",
    "data": null,
    "errors": null
}
```
**الحل**: العنصر المطلوب غير موجود

---

## 🔗 روابط مفيدة

- **Laravel Documentation**: https://laravel.com/docs
- **Laravel Sanctum**: https://laravel.com/docs/sanctum
- **Postman Collection**: [قم بإنشاء collection لاختبار APIs]

---

**تم إنشاء هذا المستند في**: يناير 2025  
**الإصدار**: 3.2  
**المطور**: Gaza Exchange Team

---

## 🆕 التحديثات الجديدة (يناير 2025)

### دعم الصور المتعددة للسلع والعقارات

تم تحديث النظام لدعم حفظ عدة صور لكل سلعة أو عقار بدلاً من صورة واحدة فقط.

#### التغييرات التقنية:

1. **جداول قاعدة البيانات الجديدة:**
   - `item_images`: لحفظ مسارات صور السلع
   - `property_images`: لحفظ مسارات صور العقارات

2. **الموديلات الجديدة:**
   - `ItemImage`: موديل لصور السلع
   - `PropertyImage`: موديل لصور العقارات

3. **العلاقات المضافة:**
   - `Item` → `hasMany(ItemImage)`
   - `Property` → `hasMany(PropertyImage)`

4. **تخزين الملفات:**
   - الصور تُحفظ في `storage/app/public/items/` للسلع
   - الصور تُحفظ في `storage/app/public/properties/` للعقارات
   - قاعدة البيانات تحتوي على أسماء الملفات فقط

#### كيفية الاستخدام:

**رفع الصور (multipart/form-data):**
```bash
curl -X POST http://localhost:8000/api/items \
  -H "Authorization: Bearer {token}" \
  -F "title=سلعة جديدة" \
  -F "description=وصف السلعة" \
  -F "price=1000" \
  -F "category_id=1" \
  -F "location=غزة، فلسطين" \
  -F "phone=0599123456" \
  -F "condition=used" \
  -F "status=available" \
  -F "images[]=@image1.jpg" \
  -F "images[]=@image2.jpg" \
  -F "images[]=@image3.jpg"
```

**استقبال الصور:**
```json
{
    "id": 1,
    "title": "سلعة جديدة",
    "images": [
        {
            "id": 1,
            "item_id": 1,
            "image": "1705747200_abc123.jpg",
            "image_url": "/storage/items/1705747200_abc123.jpg",
            "created_at": "2025-01-20T10:30:00.000000Z"
        },
        {
            "id": 2,
            "item_id": 1,
            "image": "1705747201_def456.jpg",
            "image_url": "/storage/items/1705747201_def456.jpg",
            "created_at": "2025-01-20T10:30:00.000000Z"
        }
    ]
}
```

**الوصول للصور:**
```
http://localhost:8000/storage/items/1705747200_abc123.jpg
http://localhost:8000/storage/properties/1705747201_def456.jpg
```

#### APIs المحدثة:

- **GET** `/items` - يعرض الصور مع كل سلعة مع الروابط الكاملة
- **GET** `/items/{id}` - يعرض الصور مع السلعة المحددة مع الروابط الكاملة
- **POST** `/items` - يحفظ الصور المتعددة في الملفات
- **PUT** `/items/{id}` - يحدث الصور المتعددة
- **DELETE** `/items/{id}` - يحذف السلعة وجميع صورها
- **DELETE** `/items/{id}/images/{image_id}` - يحذف صورة محددة
- **GET** `/items/trending` - يعرض الصور مع السلع الرائجة مع الروابط الكاملة
- **GET** `/items/search` - يعرض الصور مع نتائج البحث مع الروابط الكاملة
- **GET** `/properties` - يعرض الصور مع كل عقار مع الروابط الكاملة
- **GET** `/properties/{id}` - يعرض الصور مع العقار المحدد مع الروابط الكاملة
- **POST** `/properties` - يحفظ الصور المتعددة في الملفات
- **PUT** `/properties/{id}` - يحدث الصور المتعددة
- **DELETE** `/properties/{id}` - يحذف العقار وجميع صوره
- **DELETE** `/properties/{id}/images/{image_id}` - يحذف صورة محددة
- **GET** `/properties/search` - يعرض الصور مع نتائج البحث مع الروابط الكاملة

#### المزايا:

1. **مرونة أكبر**: إمكانية إضافة عدد غير محدود من الصور
2. **تنظيم أفضل**: كل صورة لها معرف فريد وتاريخ إنشاء
3. **أداء محسن**: تحميل الصور عند الحاجة فقط
4. **سهولة الإدارة**: إمكانية حذف أو تحديث صور محددة
5. **حفظ آمن**: الصور تُحفظ في الملفات وليس في قاعدة البيانات
6. **أسماء فريدة**: كل صورة لها اسم فريد لتجنب التعارض
7. **حجم محدود**: الحد الأقصى لحجم الصورة 2MB
8. **صيغ مدعومة**: JPEG, PNG, JPG, GIF

#### متطلبات الصور:

- **الحجم الأقصى**: 2MB لكل صورة
- **الصيغ المدعومة**: JPEG, PNG, JPG, GIF
- **الطريقة**: multipart/form-data
- **الحقل**: images[] (مصفوفة)

---

## 🚀 التحسينات الأخيرة (ديسمبر 2025)

### تحسين عرض الصور مع الروابط الكاملة

تم إجراء تحسينات جوهرية على نظام الصور لضمان عرضها بشكل صحيح في جميع الاستجابات.

#### التحسينات المضافة:

1. **إضافة الروابط الكاملة للصور:**
   - تم إضافة حقل `image_url` لجميع نماذج الصور
   - الآن كل صورة تُعرض مع رابطها الكامل للوصول المباشر
   - لا حاجة لبناء الرابط يدوياً في التطبيق

2. **تحسين نماذج الصور:**
   ```php
   // في ItemImage و PropertyImage models
   protected $appends = ['image_url'];
   
   public function getImageUrlAttribute()
   {
       return Storage::url('items/' . $this->image);
   }
   ```

3. **إصلاح تضارب الروابط:**
   - تم إعادة ترتيب الروابط في `routes/api.php`
   - فصل الروابط العامة عن المحمية لتجنب التضارب
   - إضافة روابط البحث المفقودة

#### مثال على الاستجابة الجديدة:

**قبل التحسين:**
```json
{
    "images": [
        {
            "id": 1,
            "image": "1705747200_abc123.jpg"
        }
    ]
}
```

**بعد التحسين:**
```json
{
    "images": [
        {
            "id": 1,
            "image": "1705747200_abc123.jpg",
            "image_url": "/storage/items/1705747200_abc123.jpg"
        }
    ]
}
```

#### فوائد التحسينات:

1. **سهولة الاستخدام**: الروابط جاهزة للاستخدام المباشر
2. **توحيد الاستجابات**: جميع APIs تُرجع الصور بنفس الطريقة
3. **أداء أفضل**: عدم الحاجة لمعالجة الروابط في العميل
4. **موثوقية أعلى**: ضمان عدم تضارب الروابط
5. **سهولة الصيانة**: كود أكثر تنظيماً ووضوحاً

#### الروابط المحدثة:

**الروابط العامة:**
- `GET /api/items` - عرض جميع السلع مع الصور
- `GET /api/items/trending` - السلع الرائجة مع الصور  
- `GET /api/items/search` - البحث في السلع مع الصور
- `GET /api/items/{id}` - عرض سلعة محددة مع الصور
- `GET /api/properties` - عرض جميع العقارات مع الصور
- `GET /api/properties/search` - البحث في العقارات مع الصور
- `GET /api/properties/{id}` - عرض عقار محدد مع الصور

**الروابط المحمية:**
- `POST /api/items` - إضافة سلعة مع الصور
- `PUT /api/items/{id}` - تحديث سلعة مع الصور
- `DELETE /api/items/{id}` - حذف سلعة وصورها
- `DELETE /api/items/{id}/images/{image_id}` - حذف صورة محددة من سلعة
- `POST /api/properties` - إضافة عقار مع الصور
- `PUT /api/properties/{id}` - تحديث عقار مع الصور
- `DELETE /api/properties/{id}` - حذف العقار وجميع صوره
- `DELETE /api/properties/{id}/images/{image_id}` - حذف صورة محددة من عقار

#### اختبار التحسينات:

تم إجراء اختبارات شاملة للتأكد من:
- ✅ عرض الصور بالروابط الصحيحة في جميع APIs
- ✅ عدم وجود تضارب في الروابط
- ✅ توحيد تنسيق الاستجابات
- ✅ الأداء الأمثل للنظام

#### ملاحظة للمطورين:

يمكن الآن استخدام حقل `image_url` مباشرة في العميل دون الحاجة لمعالجة إضافية:

```javascript
// JavaScript Example
const images = item.images;
images.forEach(image => {
    const imgElement = document.createElement('img');
    imgElement.src = image.image_url; // استخدام مباشر للرابط
    document.body.appendChild(imgElement);
});
```

```dart
// Flutter/Dart Example
Widget buildImageList(List<ItemImage> images) {
  return ListView.builder(
    itemCount: images.length,
    itemBuilder: (context, index) {
      return Image.network(
        images[index].imageUrl, // استخدام مباشر للرابط
        fit: BoxFit.cover,
      );
    },
  );
}
```

---

## 📌 ملاحظات الإصدار الحالي

- **تاريخ الإصدار**: ديسمبر 2025
- **رقم الإصدار**: 3.2.1  
- **نوع التحديث**: تحسينات وإصلاحات
- **التوافق**: متوافق تماماً مع الإصدارات السابقة
- **المطلوب**: لا حاجة لتحديث العميل، التحسينات تلقائية