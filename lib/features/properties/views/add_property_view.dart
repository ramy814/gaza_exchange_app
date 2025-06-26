import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'dart:io';
import '../controllers/add_property_controller.dart';

class AddPropertyView extends GetView<AddPropertyController> {
  const AddPropertyView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AddPropertyController());

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عقار جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Section
              Text('صور العقار', style: Theme.of(context).textTheme.titleLarge),
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
                  labelText: 'عنوان العقار',
                  hintText: 'أدخل عنوان واضح للعقار',
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

              // Type and Purpose Row
              Row(
                children: [
                  Expanded(
                    child: FormBuilderDropdown<String>(
                      name: 'type',
                      decoration: const InputDecoration(
                        labelText: 'نوع العقار',
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: 'النوع مطلوب',
                      ),
                      items: controller.propertyTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderDropdown<String>(
                      name: 'purpose',
                      decoration: const InputDecoration(labelText: 'الغرض'),
                      validator: FormBuilderValidators.required(
                        errorText: 'الغرض مطلوب',
                      ),
                      items: controller.purposes
                          .map(
                            (purpose) => DropdownMenuItem(
                              value: purpose,
                              child: Text(purpose),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Price
              FormBuilderTextField(
                name: 'price',
                decoration: const InputDecoration(
                  labelText: 'السعر (شيكل)',
                  hintText: 'أدخل سعر العقار',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'السعر مطلوب'),
                  (value) {
                    if (value == null || value.isEmpty) return null;

                    // تحويل الأرقام للإنجليزية للتحقق
                    final controller = Get.find<AddPropertyController>();
                    final convertedValue =
                        controller.convertArabicToEnglishNumbers(value);
                    final numValue = double.tryParse(convertedValue);

                    if (numValue == null) {
                      return 'يجب أن يكون رقم صحيح';
                    }

                    if (numValue <= 0) {
                      return 'السعر يجب أن يكون أكبر من صفر';
                    }

                    return null;
                  },
                ]),
              ),

              const SizedBox(height: 16),

              // Description
              FormBuilderTextField(
                name: 'description',
                decoration: const InputDecoration(
                  labelText: 'وصف العقار',
                  hintText:
                      'أدخل وصف تفصيلي للعقار (يمكن تضمين عدد الغرف والحمامات والمساحة هنا)',
                ),
                maxLines: 4,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'الوصف مطلوب'),
                  FormBuilderValidators.minLength(
                    10,
                    errorText: 'الوصف قصير جداً',
                  ),
                ]),
              ),

              const SizedBox(height: 16),

              // Location (will be sent as address)
              FormBuilderTextField(
                name: 'location',
                decoration: const InputDecoration(
                  labelText: 'عنوان العقار',
                  hintText:
                      'أدخل عنوان العقار (مثال: حي الرمال، شارع عمر المختار)',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'العنوان مطلوب',
                  ),
                  FormBuilderValidators.minLength(
                    5,
                    errorText: 'العنوان قصير جداً',
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
                        controller.isLoading ? null : controller.submitProperty,
                    child: controller.isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('نشر العقار'),
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
