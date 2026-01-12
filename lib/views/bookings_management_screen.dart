import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/views/my_bookings_screen.dart';
import 'package:marsa_app/views/owner_bookings_screen.dart';

class BookingsManagementScreen extends StatefulWidget {
  const BookingsManagementScreen({super.key});

  @override
  State<BookingsManagementScreen> createState() =>
      _BookingsManagementScreenState();
}

class _BookingsManagementScreenState extends State<BookingsManagementScreen> {
  final StorageService _storageService = StorageService();
  String _userRole = '';
  bool _isLoading = true;
  Widget _currentWidget = Container();

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final isLoggedIn = await _storageService.isLoggedIn();

      if (!isLoggedIn) {
        Get.offAllNamed('/login');
        return;
      }

      final role = await _storageService.getUserRole();

      setState(() {
        _userRole = role;
        _isLoading = false;
      });

      // توجيه مباشر حسب الدور
      if (role == 'owner') {
        setState(() {
          _currentWidget = const OwnerBookingsScreen();
        });
      } else if (role == 'tenant') {
        setState(() {
          _currentWidget = const MyBookingsScreen();
        });
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
      setState(() {
        _isLoading = false;
        _currentWidget = _buildErrorWidget(e.toString());
      });
    }
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          Text(
            'حدث خطأ: $error',
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _currentWidget = Container();
              });
              _checkUserRole();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/icons/Sandy Loading.json', // تأكد من صحة المسار
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text(
                'جاري التوجيه إلى صفحة الحجوزات المناسبة...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: Configuration.mainFont,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // عرض الـ widget المناسب حسب الدور
    return _currentWidget;
  }
}
