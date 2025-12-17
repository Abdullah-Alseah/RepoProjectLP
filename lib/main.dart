import 'package:flutter/material.dart';
import 'package:marsa_app/screens/RegistrationScreen.dart';
import 'package:marsa_app/screens/homeScreen.dart';
import 'package:marsa_app/screens/loginScreen.dart';
import 'package:marsa_app/utils/config.dart';
import 'package:marsa_app/utils/main_layout.dart';

import 'package:get/get.dart';

void main() {
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
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      title: 'Marsa App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // pre-define input decoration
        inputDecorationTheme: const InputDecorationTheme(
          focusColor: Config.secandryColor,
          border: Config.outlinedBorder,
          focusedBorder: Config.focusBorder,
          errorBorder: Config.errorBorder,
          // enabledBorder: Config.outlinedBorder,
          floatingLabelStyle: TextStyle(color: Config.primaryColor),
          prefixIconColor: Colors.black38,
        ),
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          selectedIconTheme: IconThemeData(size: 30),
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
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/Register', page: () => RegistrationPage()),
      ],
    );
  }
}
