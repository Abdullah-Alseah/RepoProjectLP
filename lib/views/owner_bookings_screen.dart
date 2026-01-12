import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/services/auth_service.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/stores/booking_store.dart';
import 'package:marsa_app/views/components/owner_booking_card.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  final BookingStore _bookingStore = BookingStore.instance;
  final StorageService _storageService = StorageService();

  String _selectedFilter = 'all';
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String _userRole = '';
  int? _ownerId;
  String _userName = '';

  final Map<String, String> _filterOptions = {
    'all': 'الكل',
    'pending': 'قيد الانتظار',
    'confirmed': 'مؤكد',
    'cancelled': 'ملغى',
    'rejected': 'مرفوض',
    'pending_update': 'قيد التحديث',
  };

  @override
  void initState() {
    super.initState();
    print('🚀 تهيئة صفحة حجوزات المالك');
    _checkAuthAndLoadBookings();
  }

  Future<void> _checkAuthAndLoadBookings() async {
    try {
      print('🔐 التحقق من المصادقة...');
      final isLoggedIn = await _storageService.isLoggedIn();

      if (!isLoggedIn) {
        Get.offAllNamed('/login');
        return;
      }

      // الحصول على بيانات المستخدم
      final userData = await _storageService.getUserData();
      final userId = await _storageService.getUserId();
      final userRole = await _storageService.getUserRole();
      final userName = await _storageService.getUserName();

      print('📊 معلومات المستخدم المخزنة:');
      print('   - ID: $userId');
      print('   - الدور: $userRole');
      print('   - الاسم: $userName');
      print('   - بيانات كاملة: $userData');
      print('❌');
      print('❌');
      print('❌');
      print('❌');
      print(userName);
      print('❌');
      print('❌');
      print('❌');
      print('❌');

      // إذا كان ID = 0، نحتاج لجلب البيانات من API
      if (userId == 0) {
        print('⚠️ ID = 0، محاولة جلب البيانات من API...');
        try {
          // 1. محاولة جلب البيانات من /auth/me
          final authService = AuthService();
          final userResult = await authService.getCurrentUser();

          if (userResult['success'] == true && userResult['data'] != null) {
            final apiUserData = userResult['data'];
            final apiUserId = apiUserData['id'];
            final apiUserRole = apiUserData['role'];
            final apiUserName =
                '${apiUserData['first_name']} ${apiUserData['last_name']}';

            print('✅ تم جلب بيانات المستخدم من API:');
            print('   - ID: $apiUserId');
            print('   - الدور: $apiUserRole');
            print('   - الاسم: $apiUserName');

            // حفظ البيانات الجديدة
            await _storageService.saveUserData(apiUserData);

            setState(() {
              _ownerId = apiUserId;
              _userRole = apiUserRole;
              _userName = apiUserName;
            });
          } else {
            print('❌ فشل جلب بيانات المستخدم من API');

            // 2. جرب استخدام ID ثابت للتجربة
            setState(() {
              _ownerId = 17; // ID المالك من بيانات API
              _userRole = 'owner';
              _userName = 'مالك تجريبي';
            });
          }
        } catch (e) {
          print('❌ خطأ في جلب بيانات المستخدم: $e');

          // استخدام ID ثابت للتجربة
          setState(() {
            _ownerId = 17;
            _userRole = 'owner';
            _userName = 'مالك تجريبي';
          });
        }
      } else {
        // إذا كان ID صحيحاً

        setState(() {
          _ownerId = userId;
          _userRole = userRole;
          _userName = userName;
        });
      }

      setState(() {
        _isLoading = false;
        _isAuthenticated = true;
      });

      // التأكد من أن لدينا ID صحيح قبل جلب الحجوزات
      if (_ownerId != null && _ownerId! > 0) {
        print('✅ جاهز لجلب الحجوزات للمالك ID: $_ownerId');
        await _loadOwnerBookings();
      } else {
        print('❌ لا يوجد ID صحيح للمالك');
        Get.snackbar(
          'خطأ',
          'تعذر تحديد هوية المالك',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print('❌ خطأ في التحقق من المصادقة: $e');
      setState(() => _isLoading = false);
      Get.snackbar(
        'خطأ',
        'حدث خطأ في تحميل الحجوزات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _loadOwnerBookings() async {
    try {
      print('📥 جلب حجوزات المالك...');
      await _bookingStore.getOwnerBookings();

      // فحص البيانات بعد التحميل
      _checkDataAfterLoad();
    } catch (e) {
      print('❌ خطأ في جلب حجوزات المالك: $e');
      rethrow;
    }
  }

  void _checkDataAfterLoad() {
    print('🔍 فحص البيانات بعد التحميل:');
    print('   - عدد الحجوزات: ${_bookingStore.bookings.length}');
    print('   - معرف المالك: $_ownerId');
    print('   - اسم المالك: $_userName');

    if (_bookingStore.bookings.isEmpty) {
      print('⚠️ لا توجد حجوزات في القائمة');
    } else {
      print('✅ تم تحميل ${_bookingStore.bookings.length} حجز');
      for (var booking in _bookingStore.bookings) {
        print('   🎫 الحجز #${booking.id}: ${booking.apartment.title}');
        print(
          '      - المالك: ${booking.apartment.owner?.name} (${booking.apartment.owner?.id})',
        );
        print(
          '      - هل ينتمي لي؟: ${booking.apartment.owner?.id == _ownerId}',
        );
      }
    }
  }

  Future<void> _refreshBookings() async {
    print('🔄 تحديث الحجوزات...');
    if (_isAuthenticated && _userRole == 'owner') {
      await _loadOwnerBookings();
    }
  }

  // تصفية حجوزات المالك
  List<dynamic> _getFilteredBookings() {
    print('🔍 فلترة الحجوزات:');
    print('   - الفلتر المحدد: $_selectedFilter');
    print('   - عدد الحجوزات الكلي: ${_bookingStore.bookings.length}');

    // جميع الحجوزات المفلترة مسبقاً للمالك
    final ownerBookings = _bookingStore.bookings;
    print('   - بعد الفلترة الأولية (للمالك): ${ownerBookings.length}');

    if (_selectedFilter == 'all') {
      return ownerBookings;
    }

    final filtered = ownerBookings
        .where((booking) => booking.status == _selectedFilter)
        .toList();

    print('   - بعد فلترة الحالة "$_selectedFilter": ${filtered.length}');
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ بناء واجهة صفحة حجوزات المالك');

    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (!_isAuthenticated || _userRole != 'owner') {
      return _buildUnauthorizedScreen();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Configuration.primaryColor,
          title: const Text(
            'حجوزات الشقق',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: Configuration.mainFont,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshBookings,
              tooltip: 'تحديث',
              color: Colors.white,
            ),
          ],
        ),
        body: RefreshIndicator(
          backgroundColor: Colors.white,
          color: Configuration.primaryColor,
          onRefresh: _refreshBookings,
          child: Column(
            children: [
              // قسم الفلاتر
              if (_bookingStore.error.isEmpty) _buildFilterSection(),

              // معلومات المالك
              if (_bookingStore.error.isEmpty) _buildOwnerInfo(),

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
              'جاري تحميل حجوزات الشقق...',
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
                    ? 'يجب تسجيل الدخول لعرض حجوزات الشقق'
                    : 'يجب أن تكون مالكاً لعرض حجوزات الشقق',
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
                    Get.back();
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

  Widget _buildOwnerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Configuration.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Configuration.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: Configuration.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName.isNotEmpty ? _userName : 'مالك',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Configuration.primaryColor,
                    fontFamily: Configuration.mainFont,
                  ),
                ),
                Text(
                  'معرف المالك: $_ownerId',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: Configuration.mainFont,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Text(
              '${_bookingStore.bookings.length} حجز',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Configuration.primaryColor,
                fontFamily: Configuration.mainFont,
              ),
            ),
          ),
        ],
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
                    print('🔘 تم اختيار الفلتر: ${entry.key}');
                    setState(() => _selectedFilter = entry.key);
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
      print('📱 بناء قائمة الحجوزات (تحميل: ${_bookingStore.isLoading})');

      if (_bookingStore.isLoading) {
        return Center(
          child: Lottie.asset(
            'assets/icons/Sandy Loading.json', // تأكد من صحة المسار
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
        );
      }

      if (_bookingStore.error.isNotEmpty) {
        print('❌ خطأ في الـ store: ${_bookingStore.error}');
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/icons/TomatoError.json'),
                const SizedBox(height: 20),
                const Text(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Configuration.primaryColor,
                  ),
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: Configuration.mainFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final filteredBookings = _getFilteredBookings();
      print('📊 عدد الحجوزات للعرض: ${filteredBookings.length}');

      if (filteredBookings.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apartment, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 20),
                Text(
                  _selectedFilter == 'all'
                      ? 'لا توجد حجوزات لشققك'
                      : 'لا توجد حجوزات بحالة "${_filterOptions[_selectedFilter]}"',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontFamily: Configuration.mainFont,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                if (_bookingStore.bookings.isNotEmpty &&
                    _selectedFilter != 'all')
                  TextButton(
                    onPressed: () {
                      print('↩️ العودة لعرض جميع الحجوزات');
                      setState(() => _selectedFilter = 'all');
                    },
                    child: const Text('عرض جميع الحجوزات'),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _refreshBookings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Configuration.primaryColor,
                  ),
                  child: const Text(
                    'تحديث',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: Configuration.mainFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
          print('🖼️ بناء بطاقة الحجز #${booking.id}');
          return OwnerBookingCardWidget(
            booking: booking,
            index: index,
            onStatusUpdated: _refreshBookings,
          );
        },
      );
    });
  }
}
