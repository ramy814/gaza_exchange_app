import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FormBuilder(
          key: controller.registerFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Welcome Text
              Text(
                'مرحباً بك!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'قم بإنشاء حساب جديد للبدء في استخدام التطبيق',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),

              const SizedBox(height: 40),

              // Name Field
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  hintText: 'أدخل اسمك الكامل',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'الاسم مطلوب',
                  ),
                  FormBuilderValidators.minLength(
                    3,
                    errorText: 'الاسم قصير جداً',
                  ),
                  FormBuilderValidators.maxLength(
                    50,
                    errorText: 'الاسم طويل جداً',
                  ),
                ]),
              ),

              const SizedBox(height: 20),

              // Phone Field
              FormBuilderTextField(
                name: 'phone',
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  hintText: '0599123456',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'رقم الهاتف مطلوب',
                  ),
                  (value) {
                    if (value == null || value.isEmpty) return null;

                    // تحويل الأرقام للإنجليزية للتحقق
                    final convertedValue =
                        controller.convertArabicToEnglishNumbers(value);

                    // التحقق من صيغة رقم الهاتف الفلسطيني
                    final phoneRegex = RegExp(r'^05[0-9]{8}$');
                    if (!phoneRegex.hasMatch(convertedValue)) {
                      return 'رقم الهاتف غير صحيح (مثال: 0599123456)';
                    }

                    return null;
                  },
                ]),
              ),

              const SizedBox(height: 20),

              // Password Field
              Obx(
                () => FormBuilderTextField(
                  name: 'password',
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    hintText: 'أدخل كلمة مرور قوية',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: !controller.isPasswordVisible,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                      errorText: 'كلمة المرور مطلوبة',
                    ),
                    FormBuilderValidators.minLength(
                      6,
                      errorText: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                    ),
                    (value) {
                      if (value == null || value.isEmpty) return null;

                      // تحويل الأرقام للإنجليزية للتحقق
                      final convertedValue =
                          controller.convertArabicToEnglishNumbers(value);

                      // طباعة للتأكد من القيم
                      print('=== Password Field Validation ===');
                      print('Original value: $value');
                      print('Converted value: $convertedValue');

                      // التحقق من قوة كلمة المرور
                      if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])')
                          .hasMatch(convertedValue)) {
                        return 'كلمة المرور يجب أن تحتوي على أحرف وأرقام';
                      }

                      // إعادة التحقق من تأكيد كلمة المرور إذا كان موجوداً
                      final formValues =
                          controller.registerFormKey.currentState?.value;
                      if (formValues != null) {
                        final confirmation =
                            formValues['password_confirmation'];
                        if (confirmation != null &&
                            confirmation.toString().isNotEmpty) {
                          final convertedConfirmation =
                              controller.convertArabicToEnglishNumbers(
                                  confirmation.toString());
                          print('Confirmation: $confirmation');
                          print(
                              'Converted confirmation: $convertedConfirmation');
                          if (convertedValue != convertedConfirmation) {
                            print('Passwords do not match!');
                            // تحديث validation لتأكيد كلمة المرور
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              controller.registerFormKey.currentState
                                  ?.validate();
                            });
                          } else {
                            print('Passwords match!');
                          }
                        }
                      }

                      return null;
                    },
                  ]),
                ),
              ),

              const SizedBox(height: 20),

              // Password Confirmation Field
              Obx(
                () => FormBuilderTextField(
                  name: 'password_confirmation',
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    hintText: 'أعد إدخال كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: !controller.isConfirmPasswordVisible,
                  validator: (value) {
                    final formValues =
                        controller.registerFormKey.currentState?.value;

                    if (value == null || value.isEmpty) return null;
                    if (formValues == null) return null;

                    // الحصول على كلمة المرور الأصلية
                    final password = formValues['password'];
                    if (password == null || password.toString().isEmpty) {
                      return null; // لا نتحقق إذا لم يتم إدخال كلمة المرور بعد
                    }

                    // تحويل الأرقام للإنجليزية للمقارنة
                    final convertedValue =
                        controller.convertArabicToEnglishNumbers(value);
                    final convertedPassword = controller
                        .convertArabicToEnglishNumbers(password.toString());

                    // طباعة للتأكد من القيم
                    print('=== Password Validation ===');
                    print('Original value: $value');
                    print('Original password: $password');
                    print('Converted value: $convertedValue');
                    print('Converted password: $convertedPassword');
                    print('Are equal: ${convertedValue == convertedPassword}');

                    if (convertedValue != convertedPassword) {
                      return 'كلمة المرور غير متطابقة';
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Register Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading ? null : controller.register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('جاري إنشاء الحساب...'),
                            ],
                          )
                        : const Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لديك حساب بالفعل؟'),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
