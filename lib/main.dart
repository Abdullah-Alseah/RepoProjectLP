// main.dart
import 'package:flutter/material.dart';
import 'package:marsa_app/views/components/apartment_card.dart';
import 'package:marsa_app/views/RegistrationScreen.dart';
import 'package:marsa_app/views/bookingScreen.dart';
import 'package:marsa_app/views/homeScreen.dart';
import 'package:marsa_app/views/loginScreen.dart';
import 'package:marsa_app/views/profile%D9%8DScreen.dart';
import 'package:marsa_app/views/apartmentDetailsScreen.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/main_layout.dart';
import 'package:marsa_app/controllers/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

void main() async {
  // تأكد من تهيئة Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // تهيئة ApiService (غير متزامن بشكل مباشر)
    ApiService().initialize();

    print('✅ تم تهيئة جميع الخدمات بنجاح');
  } catch (e) {
    print('❌ خطأ في تهيئة الخدمات: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentPage = 0;
  final PageController _page = PageController();
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GetMaterialApp(
        navigatorKey: navigatorKey,
        title: 'Marsa App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontFamily: 'Tajawal'),
          ),
          // pre-define input decoration
          inputDecorationTheme: const InputDecorationTheme(
            focusColor: Config.secandryColor,
            border: Config.outlinedBorder,
            focusedBorder: Config.focusBorder,
            errorBorder: Config.errorBorder,
            floatingLabelStyle: TextStyle(color: Config.primaryColor),
            prefixIconColor: Colors.black38,
          ),
          scaffoldBackgroundColor: Colors.white,
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
        ),

        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => MainLayout()),
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/register', page: () => const RegistrationPage()),
          GetPage(name: '/home', page: () => const HomeScreen()),
          GetPage(name: '/bookingApartment', page: () => const BookingPage()),
          GetPage(name: '/profile', page: () => ProfilePage()),
          GetPage(name: '/apartments', page: () => const ApartmentCardWidget()),
          GetPage(
            name: '/apartmentDetails',
            page: () => Apartmentdetailsscreen(),
          ),
        ],
      ),
    );
  }
}
