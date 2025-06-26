import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'dart:io';
import '../controllers/add_item_controller.dart';

class AddItemView extends GetView<AddItemController> {
  const AddItemView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AddItemController());

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة سلعة جديدة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Section
              Text('صور السلعة', style: Theme.of(context).textTheme.titleLarge),
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
              FormBuilderDropdown<String>(
                name: 'category',
                decoration: const InputDecoration(labelText: 'فئة السلعة'),
                validator: FormBuilderValidators.required(
                  errorText: 'الفئة مطلوبة',
                ),
                items: controller.categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Colors.grey),
            SizedBox(height: 4),
            Text('إضافة صورة', style: TextStyle(fontSize: 10)),
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
