class CategoryModel {
  final int id;
  final String name;
  final String nameEn;
  final String? description;
  final String? icon;
  final String? color;
  final bool isActive;
  final int sortOrder;
  final int? parentId;
  final List<CategoryModel>? children;
  final CategoryModel? parent;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameEn,
    this.description,
    this.icon,
    this.color,
    this.isActive = true,
    this.sortOrder = 0,
    this.parentId,
    this.children,
    this.parent,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // فحص إضافي للبيانات
    final id = json['id'] ?? 0;
    final name = (json['name'] ?? '').toString().trim();
    final nameEn = (json['name_en'] ?? '').toString().trim();

    // طباعة معلومات التصنيف للتصحيح
    print('📋 Creating category: ID=$id, Name="$name", NameEn="$nameEn"');

    return CategoryModel(
      id: id,
      name: name,
      nameEn: nameEn,
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
      color: json['color']?.toString(),
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
      parentId: json['parent_id'],
      children: json['children'] != null
          ? List<CategoryModel>.from(
              json['children'].map((x) => CategoryModel.fromJson(x)))
          : null,
      parent: json['parent'] != null
          ? CategoryModel.fromJson(json['parent'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'description': description,
      'icon': icon,
      'color': color,
      'is_active': isActive,
      'sort_order': sortOrder,
      'parent_id': parentId,
      'children': children?.map((x) => x.toJson()).toList(),
      'parent': parent?.toJson(),
    };
  }

  bool get isMainCategory => parentId == null;
  bool get isSubCategory => parentId != null;
  bool get hasChildren => children != null && children!.isNotEmpty;

  // فحص صحة البيانات
  bool get isValid => id > 0 && name.isNotEmpty;

  // الحصول على اسم آمن للعرض
  String get displayName => name.isNotEmpty ? name : 'غير محدد';
}
