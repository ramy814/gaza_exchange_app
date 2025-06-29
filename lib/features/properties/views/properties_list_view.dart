import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:gaza_exchange_app/core/utils/app_theme.dart';
import 'package:gaza_exchange_app/features/properties/controllers/properties_controller.dart';
import 'package:gaza_exchange_app/features/properties/models/property_model.dart';
import 'package:gaza_exchange_app/widgets/bottom_nav_bar.dart';
import 'package:gaza_exchange_app/widgets/custom_card.dart';
import 'package:gaza_exchange_app/core/utils/app_routes.dart';

class PropertiesListView extends StatelessWidget {
  const PropertiesListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PropertiesController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('العقارات'),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(AppRoutes.addProperty),
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
                hintText: 'ابحث عن العقارات...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: controller.searchProperties,
            ),
          ),

          // Type Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.propertyTypes.length,
              itemBuilder: (context, index) {
                final type = controller.propertyTypes[index];
                return Obx(
                  () => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(type),
                      selected: controller.selectedType.value == type,
                      onSelected: (_) => controller.filterByType(type),
                      selectedColor:
                          AppTheme.accentColor.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.accentColor,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Properties List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('جاري تحميل العقارات...'),
                    ],
                  ),
                );
              }

              if (controller.filteredProperties.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_work_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.properties.isEmpty
                            ? 'لا توجد عقارات متاحة حالياً'
                            : 'لا توجد عقارات تطابق البحث',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: controller.refreshProperties,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshProperties,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: controller.filteredProperties.length,
                  itemBuilder: (context, index) {
                    final property = controller.filteredProperties[index];
                    return _buildPropertyCard(property, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAllNamed(AppRoutes.home);
              break;
            case 1:
              Get.offAllNamed(AppRoutes.items);
              break;
            case 2:
              // Already on properties
              break;
            case 3:
              Get.offAllNamed(AppRoutes.profile);
              break;
          }
        },
      ),
    );
  }

  Widget _buildPropertyCard(
      PropertyModel property, PropertiesController controller) {
    return CustomCard(
      imageUrl: property.firstImageUrl,
      title: property.title,
      subtitle:
          '${property.address}\n🛏️ ${property.bedrooms} غرف • 🚿 ${property.bathrooms} حمام • 📐 ${property.area.toInt()}م²\n👤 ${property.user?.name ?? 'غير محدد'}',
      price: '${property.price.toStringAsFixed(0)} ₪',
      onTap: () => controller.goToPropertyDetail(property.id),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: property.type == 'buy'
              ? AppTheme.primaryColor
              : AppTheme.accentColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          property.type == 'buy' ? 'للبيع' : 'للإيجار',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
