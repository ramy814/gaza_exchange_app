import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../controllers/auth_controller.dart';
import '../../../core/utils/validators.dart';

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
                  hintText: 'أحمد محمد',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الاسم مطلوب';
                  }
                  if (value.length < 2) {
                    return 'الاسم يجب أن يكون حرفين على الأقل';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'رقم الهاتف مطلوب';
                  }
                  // تحويل الأرقام العربية إلى الإنجليزية للتحقق
                  final cleanValue =
                      Validators.convertArabicToEnglishNumbers(value);
                  final phoneRegex = RegExp(r'^(059|056)\d{7}$');
                  if (!phoneRegex.hasMatch(cleanValue)) {
                    return 'رقم الهاتف غير صحيح';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Password Field
              Obx(
                () => FormBuilderTextField(
                  name: 'password',
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    hintText: 'أدخل كلمة المرور',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: !controller.isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'كلمة المرور مطلوبة';
                    }
                    // تحويل الأرقام العربية إلى الإنجليزية للتحقق
                    final cleanValue =
                        Validators.convertArabicToEnglishNumbers(value);
                    if (cleanValue.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
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
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: !controller.isConfirmPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'تأكيد كلمة المرور مطلوب';
                    }

                    // الحصول على كلمة المرور من النموذج
                    final password = controller.registerFormKey.currentState
                            ?.fields['password']?.value
                            ?.toString() ??
                        '';

                    // تحويل الأرقام العربية إلى الإنجليزية للتحقق
                    final cleanValue =
                        Validators.convertArabicToEnglishNumbers(value);
                    final cleanPassword =
                        Validators.convertArabicToEnglishNumbers(password);

                    if (cleanValue != cleanPassword) {
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
