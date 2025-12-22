// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:marsa_app/views/RegistrationScreen.dart';
import 'package:marsa_app/controllers/services/auth_service.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _isPasswordVisible = false.obs;
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final _isLoading = false.obs;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;

      // إخفاء لوحة المفاتيح
      FocusScope.of(context).unfocus();

      try {
        final result = await _authService.login(
          phone: phoneController.text.trim(),
          password: passwordController.text,
        );

        _isLoading.value = false;

        if (result['success'] == true) {
          Get.snackbar(
            'نجاح',
            result['message'] ?? 'تم تسجيل الدخول بنجاح',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );

          // حفظ الـ token (إذا كان موجوداً)
          if (result['token'] != null) {
            print('🔐 Token received: ${result['token']}');
            // هنا يمكنك حفظ الـ token في SharedPreferences
            await StorageService.saveToken(result['token']);
          }

          // الانتقال للصفحة الرئيسية
          Future.delayed(const Duration(seconds: 1), () {
            Get.offAllNamed('/'); 
          });
        } else {
          String errorMessage = result['message'] ?? 'فشل تسجيل الدخول';

          if (result['statusCode'] == 401) {
            errorMessage = 'رقم الهاتف أو كلمة المرور غير صحيحة';
          } else if (result['statusCode'] == 403) {
            errorMessage = 'الحساب غير مفعل أو في انتظار الموافقة';
          }

          Get.snackbar(
            'خطأ',
            errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } catch (e) {
        _isLoading.value = false;
        Get.snackbar(
          'خطأ',
          'حدث خطأ في الاتصال بالخادم',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        print('❌ Login error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Config.init(context);
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image
          Container(
            height: 350,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/background/3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Welcome Text (Over the image)
          Positioned(
            top: 200,
            right: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "مرحباً بعودتك",
                  style: TextStyle(
                    color: Config.secandryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: Config.mainFont,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "سجل الدخول للوصول إلى حسابك",
                  style: TextStyle(
                    color: Config.secandryColor,
                    fontSize: 16,
                    fontFamily: Config.mainFont,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // 3. The White Card Container
          Container(
            height: Config.screenHeight! * 0.6,
            margin: const EdgeInsets.only(
              top: 300,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 25,
                  offset: Offset(0, 5),
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // PhoneNumber Field
                  Text(
                    "رقم الهاتف",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Config.secandryColor,
                      fontSize: 16,
                      fontFamily: Config.mainFont,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(fontFamily: Config.mainFont),
                    decoration: InputDecoration(
                      hintText: "09 9999 9999",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: Config.mainFont,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      suffixIcon: Icon(
                        Icons.phone_iphone_outlined,
                        color: Colors.grey[500],
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم الهاتف';
                      }
                      // تنظيف الرقم من المسافات والرموز
                      final cleanedPhone = value.replaceAll(
                        RegExp(r'[^\d+]'),
                        '',
                      );
                      if (cleanedPhone.length < 9) {
                        return 'يجب أن يكون رقم هاتف صحيح';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  Text(
                    "كلمة المرور",
                    style: TextStyle(
                      color: Config.secandryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: Config.mainFont,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Obx(
                    () => TextFormField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible.value,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontFamily: Config.mainFont),
                      decoration: InputDecoration(
                        hintText: "أدخل كلمة المرور",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontFamily: Config.mainFont,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        suffixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey[500],
                        ),
                        prefixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey[500],
                          ),
                          onPressed: () {
                            _isPasswordVisible.value =
                                !_isPasswordVisible.value;
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال كلمة السر';
                        }
                        if (value.length < 6) {
                          return 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        _handleLogin();
                      },
                    ),
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed(
                          '/forgot-password',
                        ); // تحتاج لإنشاء هذه الشاشة
                      },
                      child: Text(
                        "نسيت كلمة المرور؟",
                        style: TextStyle(
                          color: Config.secandryColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: Config.mainFont,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Login Button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading.value ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Config.primaryColor,
                                Config.primaryColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: _isLoading.value
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "تسجيل الدخول",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Config.mainFont,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Create Account Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const RegistrationPage());
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(
                            "إنشاء حساب جديد  ",
                            style: TextStyle(
                              color: Config.secandryColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: Config.mainFont,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "ليس لديك حساب؟     ",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: Config.mainFont,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
