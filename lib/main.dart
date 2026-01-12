// main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/main_layout.dart';
import 'package:marsa_app/controllers/services/api_service.dart';
import 'package:marsa_app/controllers/services/profile_service.dart';

import 'package:marsa_app/models/apartment_model.dart';
import 'package:marsa_app/stores/apartment_store.dart';
import 'package:marsa_app/stores/booking_store.dart';
import 'package:marsa_app/stores/favorite_store.dart';
import 'package:marsa_app/views/RegistrationScreen.dart';

import 'package:marsa_app/views/apartmentDetailsScreen.dart';
import 'package:marsa_app/views/bookingScreen.dart';
import 'package:marsa_app/views/components/splash_screen.dart';
import 'package:marsa_app/views/edit_owner_apartment.dart';
import 'package:marsa_app/views/homeScreen.dart';
import 'package:marsa_app/views/loginScreen.dart';
import 'package:marsa_app/views/owner_apartment_details_screen.dart';
import 'package:marsa_app/views/profileScreen.dart';

// متغير عام لتتبع حالة التهيئة
class AppInitialization {
  static bool isInitialized = false;
  static bool isLoggedIn = false;
  static ProfileService? profileService;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. تهيئة الخدمات الأساسية
    ApiService().initialize();

    // 2. إنشاء instance من ProfileService
    AppInitialization.profileService = ProfileService();

    // 3. التحقق من حالة تسجيل الدخول
    AppInitialization.isLoggedIn = await AppInitialization.profileService!
        .isLoggedIn();

    // 4. تهيئة الـ stores
    Get.put(ApartmentStore(), permanent: true);
    Get.put(FavoriteStore.instance, permanent: true);
    Get.put(BookingStore.instance, permanent: true);

    AppInitialization.isInitialized = true;
    print('✅ تم تهيئة جميع الخدمات بنجاح');
    print('🔐 حالة تسجيل الدخول: ${AppInitialization.isLoggedIn}');
  } catch (e) {
    print('❌ خطأ في تهيئة التطبيق: $e');
    AppInitialization.isInitialized = false;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GetMaterialApp(
        title: 'Marsa App',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: '/splash',
        getPages: _buildRoutes(),
        unknownRoute: _buildNotFoundRoute(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Tajawal')),
      inputDecorationTheme: const InputDecorationTheme(
        focusColor: Configuration.secandryColor,
        border: Configuration.outlinedBorder,
        focusedBorder: Configuration.focusBorder,
        errorBorder: Configuration.errorBorder,
        floatingLabelStyle: TextStyle(color: Configuration.primaryColor),
        prefixIconColor: Colors.black38,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        selectedIconTheme: const IconThemeData(size: 30),
        showSelectedLabels: true,
        showUnselectedLabels: false,
        unselectedItemColor: Colors.grey.shade700,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  List<GetPage> _buildRoutes() {
    return [
      GetPage(
        name: '/splash',
        page: () {
          final nextScreen = AppInitialization.isLoggedIn
              ? MainLayout()
              : const HomeScreen();
          return SplashScreen(nextScreen: nextScreen);
        },
      ),

      GetPage(name: '/', page: () => MainLayout()),
      GetPage(name: '/login', page: () => const LoginScreen()),
      GetPage(name: '/register', page: () => const RegistrationPage()),
      GetPage(name: '/home', page: () => const HomeScreen()),
      GetPage(name: '/profile', page: () => ProfilePage()),
      _buildApartmentDetailsRoute(),
      _buildOwnerApartmentDetailsRoute(),
      _buildeditApartmentRoute(),
    ];
  }

  GetPage _buildApartmentDetailsRoute() {
    return GetPage(
      name: '/apartmentDetails',
      page: () {
        final arguments = Get.arguments;
        if (arguments != null && arguments is Map) {
          return ApartmentDetailsScreen(
            apartmentId: arguments['apartmentId'] as int? ?? 0,
            apartment: arguments['apartment'] as Apartment?,
          );
        }
        return _buildErrorScreen('لم يتم تمرير بيانات الشقة');
      },
    );
  }

  GetPage _buildeditApartmentRoute() {
    return GetPage(
      name: '/editApartment',
      page: () {
        final arguments = Get.arguments;
        if (arguments != null && arguments is Map) {
          return EditApartmentPage(
            apartmentId: arguments['apartmentId'] as int? ?? 0,
            apartment: arguments['apartment'] as Apartment?,
          );
        }
        return _buildErrorScreen('لم يتم تمرير بيانات الشقة');
      },
    );
  }

  GetPage _buildOwnerApartmentDetailsRoute() {
    return GetPage(
      name: '/ownerApartmentDetails',
      page: () {
        final arguments = Get.arguments;
        if (arguments != null && arguments is Map) {
          return OwnerApartmentDetailsScreen(
            apartmentId: arguments['apartmentId'] as int? ?? 0,
            apartment: arguments['apartment'] as Apartment?,
          );
        }
        return _buildErrorScreen('لم يتم تمرير بيانات الشقة');
      },
      transition: Transition.rightToLeft,
    );
  }

  GetPage _buildNotFoundRoute() {
    return GetPage(
      name: '/notfound',
      page: () => _buildErrorScreen('الصفحة التي تبحث عنها غير موجودة'),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('خطأ')),
      body: Center(child: Text(message)),
    );
  }
}
