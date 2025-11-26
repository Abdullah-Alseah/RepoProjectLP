import 'package:flutter/material.dart';

class Config {
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
  static const spaceSmall = SizedBox(height: 25);
  static final spaceMedium = SizedBox(height: screenHeight! * 0.05);
  static final spaceBig = SizedBox(height: screenHeight! * 0.08);

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
    colors: [
      primaryColor,
      secandryColor,
    ],
    begin: Alignment.topLeft, // بداية التدرج
    end: Alignment.bottomRight, // نهاية التدرج
  );

  static Gradient spacialGradientColor = LinearGradient(
    colors: [
      Colors.orangeAccent,
      Colors.deepOrange,
    ],
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
}
