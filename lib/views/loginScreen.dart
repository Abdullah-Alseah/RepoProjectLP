// lib/screens/login_screen.dart
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:marsa_app/views/RegistrationScreen.dart';
import 'package:marsa_app/controllers/services/auth_service.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final _isLoading2 = false.obs;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // 🔍 فحص المفاتيح الأساسية قبل البدء
    if (_formKey.currentState == null) {
      print('❌ _formKey.currentState is null');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في تهيئة النموذج',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (context == null) {
      print('❌ context is null');
      return;
    }

    // ✅ التحقق من صحة النموذج
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isLoading.value = true;

    try {
      // إخفاء لوحة المفاتيح مع فحص إضافي
      final currentFocus = FocusScope.of(context);
      if (currentFocus.hasFocus) {
        currentFocus.unfocus();
      }

      final String phone = phoneController.text.trim();
      final String password = passwordController.text;

      // 🔍 التحقق من المدخلات
      if (phone.isEmpty || password.isEmpty) {
        Get.snackbar(
          'خطأ',
          'يرجى إدخال رقم الهاتف وكلمة المرور',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        _isLoading.value = false;
        return;
      }

      print('📱 محاولة تسجيل الدخول بالرقم: $phone');

      final result = await _authService.login(phone: phone, password: password);

      _isLoading.value = false;

      // 🔍 فحص استجابة الـ API
      print('📊 نتيجة تسجيل الدخول:');
      print('   - success: ${result['success']}');
      print('   - message: ${result['message']}');
      print('   - token exists: ${result['token'] != null}');
      print('   - user exists: ${result['user'] != null}');
      print('   - statusCode: ${result['statusCode']}');

      if (result['success'] == true) {
        Get.snackbar(
          'نجاح',
          result['message']?.toString() ?? 'تم تسجيل الدخول بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // 🔐 حفظ التوكن إذا كان موجوداً
        if (result['token'] != null && result['token'].toString().isNotEmpty) {
          final token = result['token'].toString();
          print(
            '🔐 Token received: ${token.substring(0, min(token.length, 20))}...',
          );
          await StorageService.saveToken(token);
        } else {
          print('⚠️  لا يوجد توكن في الاستجابة');
        }

        // 👤 حفظ بيانات المستخدم
        if (result['user'] != null && result['user'] is Map<String, dynamic>) {
          final Map<String, dynamic> userData = Map<String, dynamic>.from(
            result['user'] as Map<String, dynamic>,
          );

          print('👤 بيانات المستخدم المستلمة:');
          print('   - ID: ${userData['id']}');
          print('   - Name: ${userData['first_name']}');
          print('   - Role: ${userData['role']}');
          print('   - Email: ${userData['email']}');
          print('   - Phone: ${userData['phone']}');

          // 🔥 إضافة التوكن إلى بيانات المستخدم إذا كان موجوداً
          if (result['token'] != null) {
            userData['token'] = result['token'];
          }

          // ✅ معالجة حقل is_approved لضمان أنه bool
          if (userData.containsKey('is_approved')) {
            final dynamic isApproved = userData['is_approved'];
            if (isApproved is bool) {
              // لا يحتاج لتغيير
            } else if (isApproved is int) {
              userData['is_approved'] = isApproved == 1;
            } else if (isApproved is String) {
              userData['is_approved'] =
                  isApproved.toLowerCase() == 'true' || isApproved == '1';
            } else {
              userData['is_approved'] = false;
            }
          } else {
            userData['is_approved'] = false;
          }

          // 💾 حفظ بيانات المستخدم الكاملة
          try {
            final bool saved = await StorageService().saveUserData(userData);

            if (saved) {
              print('✅ تم حفظ بيانات المستخدم بنجاح في SharedPreferences');

              // 📝 حفظ البيانات أيضاً في مفاتيح منفصلة لضمان التوافق
              final prefs = await SharedPreferences.getInstance();

              // حفظ الاسم
              final firstName = userData['first_name']?.toString() ?? '';
              final lastName = userData['last_name']?.toString() ?? '';
              await prefs.setString('user_name', '$firstName $lastName'.trim());

              // حفظ الدور
              await prefs.setString(
                'user_role',
                userData['role']?.toString() ?? '',
              );

              // حفظ الـ ID
              if (userData['id'] != null) {
                if (userData['id'] is int) {
                  await prefs.setInt('user_id', userData['id'] as int);
                } else {
                  final id = int.tryParse(userData['id'].toString()) ?? 0;
                  await prefs.setInt('user_id', id);
                }
              }

              // حفظ البريد الإلكتروني
              await prefs.setString(
                'user_email',
                userData['email']?.toString() ?? '',
              );

              // حفظ رقم الهاتف
              await prefs.setString(
                'user_phone',
                userData['phone']?.toString() ?? '',
              );

              print('📋 تم حفظ البيانات المنفصلة أيضًا');
            } else {
              print('⚠️  حدث خطأ في حفظ بيانات المستخدم');
            }
          } catch (storageError) {
            print('❌ خطأ في حفظ البيانات: $storageError');
          }
        } else {
          print('⚠️  لا توجد بيانات مستخدم في الاستجابة');

          // إذا لم تكن هناك بيانات مستخدم، إنشاء بيانات افتراضية
          try {
            final Map<String, dynamic> defaultData = {
              'phone': phone,
              'role': 'tenant', // قيمة افتراضية
              'is_approved': false,
            };
            await StorageService().saveUserData(defaultData);
          } catch (e) {
            print('❌ خطأ في حفظ البيانات الافتراضية: $e');
          }
        }

        // 🔍 فحص التخزين للتأكد
        try {
          await StorageService().debugStorage();
        } catch (e) {
          print('⚠️  خطأ في فحص التخزين: $e');
        }

        // 🏠 الانتقال للصفحة الرئيسية بعد تأكيد الحفظ
        print('🚀 الانتقال للصفحة الرئيسية...');
        await Future.delayed(const Duration(milliseconds: 800));

        Get.offAllNamed('/', arguments: {'fromLogin': true});
      } else {
        String errorMessage =
            result['message']?.toString() ?? 'فشل تسجيل الدخول';

        if (result['statusCode'] == 401) {
          errorMessage = 'رقم الهاتف أو كلمة المرور غير صحيحة';
        } else if (result['statusCode'] == 403) {
          errorMessage = 'الحساب غير مفعل أو في انتظار الموافقة';
        } else if (result['statusCode'] == 422) {
          errorMessage = 'بيانات الدخول غير صحيحة';
        }

        Get.snackbar(
          'خطأ',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      _isLoading.value = false;
      print('❌ Login error: $e');
      print('❌ Stack trace: ${e.toString()}');

      String errorMessage = 'حدث خطأ في الاتصال بالخادم';
      if (e is DioException) {
        errorMessage =
            e.response?.data?['message']?.toString() ??
            e.message ??
            'خطأ في الاتصال بالخادم';
      }

      Get.snackbar(
        'خطأ',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Configuration.init(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image
          Container(
            height: 350,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/background/login.jpg'),
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
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: Configuration.mainFont,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "سجل الدخول للوصول إلى حسابك",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: Configuration.mainFont,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // 3. The White Card Container
          Container(
            height: Configuration.screenHeight! * 0.6,
            margin: const EdgeInsets.only(
              top: 300,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            padding: const EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: 8,
            ),
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
            child: SingleChildScrollView(
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
                        color: Configuration.secandryColor,
                        fontSize: 16,
                        fontFamily: Configuration.mainFont,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(fontFamily: Configuration.mainFont),
                      decoration: InputDecoration(
                        hintText: "09 9999 9999",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontFamily: Configuration.mainFont,
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
                        color: Configuration.secandryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: Configuration.mainFont,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Obx(
                      () => TextFormField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible.value,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(fontFamily: Configuration.mainFont),
                        decoration: InputDecoration(
                          hintText: "أدخل كلمة المرور",
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: Configuration.mainFont,
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
                            color: Configuration.secandryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: Configuration.mainFont,
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
                                  Configuration.primaryColor,
                                  Configuration.primaryColor.withOpacity(0.8),
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
                                        fontFamily: Configuration.mainFont,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Guest Login Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            _isLoading2.value = true;
                            Future.delayed(
                              const Duration(milliseconds: 1500),
                              () {
                                Get.toNamed('/home');
                              },
                            );
                          },
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
                                colors: [
                                  const Color.fromARGB(255, 56, 56, 56),
                                  const Color.fromARGB(255, 126, 126, 126),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: _isLoading2.value
                                  ? SizedBox(
                                      height: screenHeight * 0.03,
                                      width: screenHeight * 0.03,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      "تسجيل كزائر",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Configuration.mainFont,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
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
                                color: Configuration.secandryColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: Configuration.mainFont,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "ليس لديك حساب؟     ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontFamily: Configuration.mainFont,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
