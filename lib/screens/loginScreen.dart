import 'package:flutter/material.dart';
import 'package:marsa_app/controllers/auth_controller.dart';
import 'package:marsa_app/screens/RegistrationScreen.dart';
import 'package:marsa_app/screens/verificationScreen.dart';
import 'package:marsa_app/utils/config.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _isPasswordVisible = false.obs;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _isLoading = false.obs;
  final AuthController authController = Get.put(AuthController());

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;

      try {
        final success = await authController.login(
          name: 'مستخدم',
          email: emailController.text,
          password: passwordController.text,
        );

        _isLoading.value = false;

        if (success) {
          Get.to(OTPForm());
        }
      } catch (e) {
        _isLoading.value = false;
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء تسجيل الدخول',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
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
              left: 50,
              right: 50,
              bottom: 0,
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
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
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
                        return 'يرجى إدخال رقم الهاتف أو البريد الإلكتروني';
                      }
                      // تحقق إذا كان رقم هاتف
                      if (GetUtils.isPhoneNumber(value)) {
                        return null;
                      }
                      return 'يجب أن يكون بريد إلكتروني أو رقم هاتف صحيح';
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

                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Get.snackbar(
                          'نسيت كلمة المرور',
                          'هذه الميزة قيد التطوير',
                          snackPosition: SnackPosition.BOTTOM,
                        );
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
                            gradient: Config.gradientColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: _isLoading.value
                                ? SizedBox(
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
                      Text(
                        "ليس لديك حساب؟     ",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: Config.mainFont,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const RegistrationPage());
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text(
                            "إنشاء حساب جديد ",
                            style: TextStyle(
                              color: Config.secandryColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: Config.mainFont,
                            ),
                          ),
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
