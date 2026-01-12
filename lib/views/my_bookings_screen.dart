import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/main_layout_controller.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/stores/booking_store.dart';
import 'package:marsa_app/views/components/booking_card.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingStore _bookingStore = BookingStore.instance;
  final StorageService _storageService = StorageService();
  final MainLayoutController controller = Get.put(MainLayoutController());

  String _selectedFilter = 'all';
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;
  String _userRole = '';
  int? _userId;

  final Map<String, String> _filterOptions = {
    'all': 'الكل',
    'pending': 'قيد الانتظار',
    'confirmed': 'مؤكد',
    'cancelled': 'ملغى',
    'rejected': 'مرفوض',
  };

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadBookings();
  }

  Future<void> _checkAuthAndLoadBookings() async {
    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      final role = await _storageService.getUserRole();
      final userId = await _storageService.getUserId();

      setState(() {
        _isCheckingAuth = false;
        _isAuthenticated = isLoggedIn;
        _userRole = role;
        _userId = userId;
      });

      if (_isAuthenticated && role == 'tenant') {
        await _bookingStore.getUserBookings();
      } else if (!_isAuthenticated) {
        Get.snackbar(
          'يجب تسجيل الدخول',
          'يرجى تسجيل الدخول لعرض الحجوزات',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.offAllNamed('/login');
        });
      } else {
        Get.snackbar(
          'غير مصرح',
          'يجب أن تكون مستأجراً لعرض الحجوزات',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.back();
      }
    } catch (e) {
      print('❌ خطأ في التحقق من المصادقة: $e');
      setState(() => _isCheckingAuth = false);
      Get.snackbar(
        'خطأ',
        'حدث خطأ في تحميل الحجوزات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _refreshBookings() async {
    if (_isAuthenticated && _userRole == 'tenant') {
      await _bookingStore.getUserBookings(
        status: _selectedFilter != 'all' ? _selectedFilter : null,
      );
    }
  }

  // تصفية الحجوزات
  List<dynamic> _getFilteredBookings() {
    if (_selectedFilter == 'all') {
      return _bookingStore.bookings;
    }
    return _bookingStore.bookings
        .where((booking) => booking.status == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return _buildLoadingScreen();
    }

    if (!_isAuthenticated || _userRole != 'tenant') {
      return _buildUnauthorizedScreen();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Configuration.primaryColor,
          title: const Text(
            "الحجوزات",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: Configuration.mainFont,
            ),
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          backgroundColor: Colors.white,
          color: Configuration.primaryColor,
          onRefresh: _refreshBookings,
          child: Column(
            children: [
              // قسم الفلاتر
              if (!_bookingStore.error.isNotEmpty) _buildFilterSection(),
              // قائمة الحجوزات
              Expanded(child: _buildBookingsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
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
              'جاري التحقق من صلاحية الجلسة...',
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

  Widget _buildUnauthorizedScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Configuration.primaryColor,
        title: const Text(
          'غير مصرح',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: Configuration.mainFont,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/icons/TomatoError.json'),
              const SizedBox(height: 20),
              const Text(
                'غير مصرح لك',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: Configuration.mainFont,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                !_isAuthenticated
                    ? 'يجب تسجيل الدخول لعرض الحجوزات'
                    : 'يجب أن تكون مستأجراً لعرض الحجوزات',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: Configuration.mainFont,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (!_isAuthenticated) {
                    Get.offAllNamed('/login');
                  } else {
                    controller.goToPage(0);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Configuration.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: Text(
                  !_isAuthenticated ? 'تسجيل الدخول' : 'العودة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: Configuration.mainFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterOptions.entries.map((entry) {
            final isSelected = _selectedFilter == entry.key;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ChoiceChip(
                backgroundColor: Colors.white,
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedFilter = entry.key;
                      _refreshBookings();
                    });
                  }
                },
                selectedColor: Configuration.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontFamily: Configuration.mainFont,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    return Obx(() {
      if (_bookingStore.isLoading) {
        return Center(
          child: Lottie.asset(
            'assets/icons/Sandy Loading.json', // تأكد من صحة المسار
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        );
      }

      if (_bookingStore.error.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/icons/TomatoError.json'),
                const SizedBox(height: 20),
                Text(
                  'حدث خطأ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: Configuration.mainFont,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _bookingStore.error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: Configuration.mainFont,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _refreshBookings,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        );
      }

      final filteredBookings = _getFilteredBookings();

      if (filteredBookings.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 20),
                Text(
                  _selectedFilter == 'all'
                      ? 'لا توجد حجوزات'
                      : 'لا توجد حجوزات بحالة "${_filterOptions[_selectedFilter]}"',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontFamily: Configuration.mainFont,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                if (_selectedFilter != 'all')
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedFilter = 'all');
                    },
                    child: const Text('عرض جميع الحجوزات'),
                  ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          return BookingCardWidget(booking: booking, index: index);
        },
      );
    });
  }
}
