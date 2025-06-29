import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'dart:io';
import '../controllers/add_item_controller.dart';
import '../../../core/utils/app_theme.dart';

class AddItemView extends GetView<AddItemController> {
  const AddItemView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AddItemController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة سلعة جديدة'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Section
              Text('صور السلعة', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'يمكنك إضافة حتى 5 صور للسلعة',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 12),

              Obx(
                () => SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.selectedImages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.selectedImages.length) {
                        return _buildAddImageCard(context);
                      }
                      return _buildImageCard(
                        controller.selectedImages[index],
                        index,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              FormBuilderTextField(
                name: 'title',
                decoration: const InputDecoration(
                  labelText: 'عنوان السلعة',
                  hintText: 'أدخل عنوان واضح للسلعة',
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'العنوان مطلوب'),
                  FormBuilderValidators.minLength(
                    3,
                    errorText: 'العنوان قصير جداً',
                  ),
                ]),
              ),

              const SizedBox(height: 16),

              // Category
              Obx(
                () => controller.isCategoriesLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.categories.isEmpty
                        ? const Center(
                            child: Text('لا توجد تصنيفات متاحة'),
                          )
                        : FormBuilderDropdown<String>(
                            name: 'category',
                            decoration: const InputDecoration(
                                labelText: 'التصنيف الرئيسي'),
                            validator: FormBuilderValidators.required(
                              errorText: 'التصنيف الرئيسي مطلوب',
                            ),
                            items: controller.categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category.displayName,
                                    child: Text(category.displayName),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                final categoryId =
                                    controller.getCategoryId(value);
                                if (categoryId != null) {
                                  controller.loadSubcategories(categoryId);
                                }
                              }
                            },
                          ),
              ),

              const SizedBox(height: 16),

              // Subcategory
              Obx(
                () => controller.isSubcategoriesLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.subcategories.isNotEmpty
                        ? FormBuilderDropdown<String>(
                            name: 'subcategory',
                            decoration: const InputDecoration(
                                labelText: 'التصنيف الفرعي (اختياري)'),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('اختر التصنيف الفرعي'),
                              ),
                              ...controller.subcategories
                                  .map(
                                    (subcategory) => DropdownMenuItem(
                                      value: subcategory.displayName,
                                      child: Text(subcategory.displayName),
                                    ),
                                  )
                                  .toList(),
                            ],
                          )
                        : const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              // Condition
              FormBuilderDropdown<String>(
                name: 'condition',
                decoration: const InputDecoration(labelText: 'حالة السلعة'),
                validator: FormBuilderValidators.required(
                  errorText: 'حالة السلعة مطلوبة',
                ),
                items: controller.conditions
                    .map(
                      (condition) => DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 16),

              // Description
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(
                  labelText: 'وصف السلعة',
                  hintText: 'أدخل وصف تفصيلي للسلعة',
                ),
                maxLines: 4,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'الوصف مطلوب'),
                ]),
              ),

              const SizedBox(height: 16),

              // Price
              FormBuilderTextField(
                name: 'price',
                decoration: const InputDecoration(
                  labelText: 'السعر (₪)',
                  hintText: 'أدخل سعر السلعة',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'السعر مطلوب'),
                  (value) {
                    if (value == null || value.isEmpty) return null;
                    // التحقق من الأرقام العربية والإنجليزية
                    final arabicNumbers = RegExp(r'^[٠-٩]+$');
                    final englishNumbers = RegExp(r'^[0-9]+$');
                    if (!arabicNumbers.hasMatch(value) &&
                        !englishNumbers.hasMatch(value)) {
                      return 'يجب أن يكون السعر أرقام فقط';
                    }
                    return null;
                  },
                ]),
              ),

              const SizedBox(height: 16),

              // Exchange For (اختياري)
              FormBuilderTextField(
                name: 'exchange_for',
                decoration: const InputDecoration(
                  labelText: 'مقابل (اختياري)',
                  hintText: 'ما تريد مقابل هذه السلعة',
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
              ),

              const SizedBox(height: 16),

              // Location
              FormBuilderTextField(
                name: 'location',
                decoration: const InputDecoration(
                  labelText: 'الموقع',
                  hintText: 'أدخل موقع السلعة',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: FormBuilderValidators.required(
                  errorText: 'الموقع مطلوب',
                ),
              ),

              const SizedBox(height: 16),

              // Phone
              FormBuilderTextField(
                name: 'phone',
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف للتواصل',
                  hintText: 'أدخل رقم الهاتف',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'رقم الهاتف مطلوب'),
                  FormBuilderValidators.minLength(
                    10,
                    errorText: 'رقم الهاتف قصير جداً',
                  ),
                ]),
              ),

              const SizedBox(height: 32),

              // Submit Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading ? null : controller.submitItem,
                    child: controller.isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('نشر السلعة'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddImageCard(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: controller.pickImage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo, color: Colors.grey),
            const SizedBox(height: 4),
            const Text('إضافة صورة', style: TextStyle(fontSize: 10)),
            const SizedBox(height: 2),
            Obx(() => Text(
                  '${controller.selectedImages.length}/5',
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(File image, int index) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              image,
              width: 100,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: GestureDetector(
              onTap: () => controller.removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
