import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'dart:io';
import 'package:marsa_app/controllers/services/test_connection.dart';

class Configuration {
  // static String baseUrl = "127.0.0.1";
  // static String baseUrl = "localhost";
  static String baseUrl = "192.168.1.7";
  // static String baseUrl = "192.168.57.197";

  static const bool debugMode = true;
  static const int apiTimeout = 30; // ثواني

  static MediaQueryData? mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;

  // Width and Height initialization
  static init(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData!.size.width;
    screenHeight = mediaQueryData!.size.height;
  }

  static get widthSize {
    return screenWidth;
  }

  static get heightSize {
    return screenHeight;
  }

  // define spacing height
  static const spaceSmall = SizedBox(height: 10);
  static final spaceMedium = SizedBox(height: 15);
  static final spaceBig = SizedBox(height: 30);

  // textform field border
  static const outlinedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: primaryColor),
  );

  static const errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: Colors.red),
  );

  static const primaryColor = Color.fromARGB(255, 0, 47, 58);
  static const secandryColor = Color.fromARGB(255, 0, 74, 88);
  static Gradient gradientColor = LinearGradient(
    colors: [primaryColor, secandryColor],
    begin: Alignment.topLeft, // بداية التدرج
    end: Alignment.bottomRight, // نهاية التدرج
  );

  static Gradient spacialGradientColor = LinearGradient(
    colors: [Colors.orangeAccent, Colors.deepOrange],
    begin: Alignment.topLeft, // بداية التدرج
    end: Alignment.bottomRight, // نهاية التدرج
  );

  static Gradient noGradientColor = LinearGradient(
    colors: [
      Colors.transparent,
      Colors.transparent,
    ], // قائمة الألوان للانتقال بينها
    begin: Alignment.topLeft, // بداية التدرج
    end: Alignment.bottomRight, // نهاية التدرج
  );

  static const mainFont = "Tajawal";

  static int pageCurrent = 0;
}

class CurrentPage extends GetxController {
  var pageIndex = 0.obs;

  void updatePageIndex(int index) {
    pageIndex.value = index;
  }
}
