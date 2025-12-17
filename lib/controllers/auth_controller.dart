// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  // متغيرات حالة
  var isLoggedIn = false.obs;
  var userName = ''.obs;
  var userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  // تحميل بيانات المستخدم المحفوظة
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;
    userName.value = prefs.getString('userName') ?? '';
    userEmail.value = prefs.getString('userEmail') ?? '';
  }

  // تسجيل الدخول
  Future<bool> login({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      if (email.isNotEmpty && password.length >= 6) {
        setState() {
          isLoggedIn.value = true;
          userName.value = name;
          userEmail.value = email;
        }

        // حفظ البيانات محلياً
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', name);
        await prefs.setString('userEmail', email);

        Get.snackbar(
          'تم بنجاح',
          'تم تسجيل الدخول بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      } else {
        throw 'يرجى إدخال بيانات صحيحة';
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // تسجيل حساب جديد
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // التحقق من صحة البيانات
      if (name.isEmpty) throw 'الاسم مطلوب';
      if (email.isEmpty || !GetUtils.isEmail(email)) {
        throw 'البريد الإلكتروني غير صحيح';
      }
      if (password.length < 6) {
        throw 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
      }
      if (password != confirmPassword) {
        throw 'كلمتا السر غير متطابقتين';
      }

      // محاكاة عملية التسجيل
      // في التطبيق الحقيقي، هنا نرسل البيانات للـ API

      isLoggedIn.value = true;
      userName.value = name;
      userEmail.value = email;

      // حفظ البيانات محلياً
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userName', name);
      await prefs.setString('userEmail', email);

      Get.snackbar(
        'تم التسجيل',
        'تم إنشاء الحساب بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    isLoggedIn.value = false;
    userName.value = '';
    userEmail.value = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userName');
    await prefs.remove('userEmail');

    Get.offAllNamed('/login');
  }
}
