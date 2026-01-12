import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:marsa_app/controllers/main_layout_controller.dart';
import 'package:marsa_app/controllers/glassContainer.dart';
import 'package:marsa_app/controllers/services/profile_service.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';

class MainLayout extends StatefulWidget {
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final MainLayoutController controller = Get.put(MainLayoutController());
  final StorageService _storageService = StorageService();

  String? _userRole;
  bool _isLoading = true;
  final ProfileService _profileService = ProfileService();
  Future<void> _updateUIFromData(Map<String, dynamic> userData) async {
    _userRole = userData['role']?.toString().trim() ?? 'مستخدم';
  }

  Future<void> _checkUserRole() async {
    try {
      Future.delayed(const Duration(milliseconds: 1500), () async {
        final role = await _storageService.getUserRole();

        setState(() {
          _userRole = role;
          _isLoading = false;
        });

        // تحديث الـController أيضاً إذا كان يحتاج البيانات
        controller.userRole.value = role;
      });
    } catch (e) {
      print('❌ خطأ في التحقق من دور المستخدم: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () async {
      final userData = await _storageService.getUserData();
      await _updateUIFromData(userData);
      _checkUserRole();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Lottie.asset(
            'assets/icons/Sandy Loading.json', // تأكد من صحة المسار
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            // الحصول على الصفحات المناسبة من الـController
            final pages = controller.pages;
            return pages[controller.currentPageIndex.value];
          }),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 30,
                    offset: Offset(0, 25),
                  ),
                ],
              ),
              child: ClassContainer(
                width: double.infinity,
                height: 81,
                child: Obx(
                  () => BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    currentIndex: controller.currentPageIndex.value,
                    onTap: (page) => controller.changePage(page),
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.home_outlined),
                        label: _userRole == 'tenant' ? 'الرئيسية' : 'شققي',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: _userRole == 'tenant' ? 'حجوزاتي' : 'الحجوزات',
                      ),
                      BottomNavigationBarItem(
                        icon: _userRole == 'tenant'
                            ? const Icon(Icons.favorite_border_outlined)
                            : const Icon(Icons.add_box_outlined),
                        label: _userRole == 'tenant' ? 'المفضلة' : 'إضافة شقة',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.person_2_outlined),
                        label: _userRole == 'admin' ? 'لوحة التحكم' : 'حسابي',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
