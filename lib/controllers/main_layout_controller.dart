// main_layout_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/services/profile_service.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/views/bookings_management_screen.dart';
import 'package:marsa_app/views/owner_bookings_screen.dart';
import 'package:marsa_app/views/favorites_screen.dart';
import 'package:marsa_app/views/my_bookings_screen.dart';
import 'package:marsa_app/views/profileScreen.dart';
import 'package:marsa_app/views/homeScreen.dart';
import 'package:marsa_app/views/owner_apartments.dart';
import 'package:marsa_app/views/addApartmentScreen.dart';

class MainLayoutController extends GetxController {
  var currentPageIndex = 0.obs;
  var userRole = ''.obs;
  var isLoading = true.obs;
  var message = ''.obs;

  final StorageService _storageService = StorageService();
  // الصفحات المختلفة حسب الدور
  final List<Widget> tenantPages = [
    HomeScreen(),
    MyBookingsScreen(),
    FavoritesScreen(),
    ProfilePage(),
  ];

  final List<Widget> ownerPages = [
    OwnerApartmentsPage(),
    OwnerBookingsScreen(),
    AddApartmentPage(),
    ProfilePage(),
  ];

  final List<Widget> adminPages = [
    HomeScreen(),
    BookingsManagementScreen(),
    AddApartmentPage(),
    ProfilePage(),
  ];
  final ProfileService _profileService = ProfileService();
  Future<void> _updateUIFromData(Map<String, dynamic> userData) async {
    userRole.value = userData['role']?.toString().trim() ?? 'مستخدم';
  }

  Future<void> checkUserRole() async {
    try {
      isLoading.value = true;

      // final role = await _storageService.getUserRole();
      // userRole.value = role;

      if (userRole.value == 'owner') {
        message.value = 'owner';
      } else if (userRole.value == 'tenant') {
        message.value = 'tenant';
      } else if (userRole.value == 'admin') {
        message.value = 'admin';
      } else {
        Get.snackbar(
          'خطأ',
          'دور المستخدم غير معروف',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.back();
      }
    } catch (e) {
      print('❌ خطأ في التحقق من دور المستخدم: $e');
      Get.snackbar('خطأ', 'حدث خطأ في تحميل البيانات');
    } finally {
      isLoading.value = false;
    }
  }

  List<Widget> get pages {
    switch (userRole.value) {
      case 'owner':
        return ownerPages;
      case 'tenant':
        return tenantPages;
      case 'admin':
        return adminPages;
      default:
        return tenantPages;
    }
  }

  void changePage(int index) {
    currentPageIndex.value = index;
  }

  void goToPage(int pageIndex) {
    currentPageIndex.value = pageIndex;
  }

  @override
  void onInit() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      final userData = await _storageService.getUserData();
      await _updateUIFromData(userData);
      checkUserRole();
    });
    super.onInit();
  }
}
