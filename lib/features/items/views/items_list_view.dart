import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/items_controller.dart';
import '../models/item_model.dart';
import '../../../core/utils/app_theme.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/custom_card.dart';
import '../../../core/utils/app_routes.dart';

class ItemsListView extends GetView<ItemsController> {
  const ItemsListView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ItemsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('السلع المتاحة'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.addItem),
            icon: const Icon(Icons.add),
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن السلع...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: controller.searchItems,
            ),
          ),

          // Filter Info
          _buildFilterInfo(),

          // Categories Filter
          SizedBox(
            height: 50,
            child: Obx(() {
              if (controller.isCategoriesLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  final isSelected =
                      controller.selectedCategoryId == category.id.toString();

                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (_) =>
                          controller.filterByCategory(category.id.toString()),
                      selectedColor:
                          AppTheme.primaryColor.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.primaryColor,
                    ),
                  );
                },
              );
            }),
          ),

          const SizedBox(height: 16),

          // Items List
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.items.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد سلع متاحة حالياً',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshItems,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: controller.items.length,
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
                    return _buildItemCard(item);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAllNamed(AppRoutes.home);
              break;
            case 1:
              // Already on items
              break;
            case 2:
              Get.offAllNamed(AppRoutes.properties);
              break;
            case 3:
              Get.offAllNamed(AppRoutes.profile);
              break;
          }
        },
      ),
    );
  }

  Widget _buildFilterInfo() {
    return Obx(() {
      if (!controller.hasActiveFilters) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list,
                color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'عرض ${controller.resultsCount} نتيجة',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (controller.searchQuery.isNotEmpty)
              Chip(
                label: Text('"${controller.searchQuery}"'),
                backgroundColor: Colors.white,
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => controller.searchItems(''),
              ),
            const SizedBox(width: 8),
            if (controller.selectedCategoryId.isNotEmpty &&
                controller.selectedCategoryId != '0')
              Chip(
                label: Text(controller.selectedCategoryName),
                backgroundColor: Colors.white,
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => controller.filterByCategory('0'),
              ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: controller.clearFilters,
              child: const Text('مسح الكل'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildItemCard(ItemModel item) {
    return CustomCard(
      imageUrl: item.firstImageUrl,
      title: item.title,
      subtitle:
          '${item.description}\n${item.user?.name ?? 'غير محدد'} • ${item.category?.name ?? 'غير محدد'}',
      price: '${item.price.toStringAsFixed(0)} ₪',
      onTap: () => controller.goToItemDetail(item.id),
    );
  }
}
