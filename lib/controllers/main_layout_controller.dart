import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marsa_app/views/homeScreen.dart';
import 'package:marsa_app/views/loginScreen.dart';
import 'package:marsa_app/views/privacy.dart';
import 'package:marsa_app/views/profileٍScreen.dart';

class MainLayoutController extends GetxController {
  var currentPageIndex = 0.obs;

  final List<Widget> pages = [
    // Add your pages here
    HomeScreen(),
    LoginScreen(),
    PrivacyPage(),
    ProfilePage(),
  ];
  void changePage(int index) {
    currentPageIndex.value = index;
  }

  void goToPage() {
    currentPageIndex.value = 3;
  }
}
