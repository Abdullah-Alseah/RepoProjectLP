import 'package:flutter/material.dart';
import 'package:marsa_app/utils/config.dart';
import 'package:marsa_app/utils/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // this is for push navigator
  static final navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Marsa App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // pre-define input decoration
        // inputDecorationTheme: const InputDecorationTheme(
        //   focusColor: Config.primaryColor,
        //   border: Config.outlinedBorder,
        //   focusedBorder: Config.focusBorder,
        //   errorBorder: Config.errorBorder,
        //   enabledBorder: Config.outlinedBorder,
        //   floatingLabelStyle: TextStyle(color: Config.primaryColor),
        //   prefixIconColor: Colors.black38,
        // ),
        // scaffoldBackgroundColor: Colors.white,
        // bottomNavigationBarTheme: BottomNavigationBarThemeData(
        //   backgroundColor: Config.primaryColor,
        //   selectedItemColor: Colors.white,
        //   showSelectedLabels: true,
        //   showUnselectedLabels: false,
        //   unselectedItemColor: Colors.grey.shade700,
        //   elevation: 10,
        //   type: BottomNavigationBarType.fixed,
        // ),
      ),

      initialRoute: '/',
      routes: {
        // this is initial route of the app
        // which is auth page (login and sign up)
        // '/': (context) => const AuthPage(),

        // this is for main layout after login

        //  اﻷساسي بعد انشاء صفحة تسجيل الدخول
        // 'main': (context) => const MainLayout(),

        // مؤقت لحين أنشاء صفحة تسجيل الدخول
        '/': (context) => MainLayout(),
      },
    );
  }
}
