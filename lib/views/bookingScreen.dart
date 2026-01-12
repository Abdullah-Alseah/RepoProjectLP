import 'package:dio/dio.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/glassContainer.dart';
import 'package:marsa_app/controllers/services/api_service.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/models/apartment_model.dart';
import 'package:marsa_app/models/booking_model.dart';
import 'package:marsa_app/stores/booking_store.dart';
import 'package:marsa_app/views/apartment_bookings_dialog.dart';

class BookingPage extends StatefulWidget {
  final int apartmentId;
  final Apartment apartment;

  BookingPage({super.key, required this.apartmentId, required this.apartment});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _selectedDate;
  DateTime? _endDate;
  late ApiService _apiService;
  late StorageService _storageService;

  // متغيرات الحالة للتحكم في الواجهة
  int selectedRentType = 2; // 0: يومي, 1: أسبوعي, 2: شهري
  int duration = 1;
  bool _isLoading = false;
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;
  String? _userRole;
  final DateFormat _dateFormat = DateFormat('yyyy/MM/dd');

  // Show error message
  void _showError(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: Colors.red.withAlpha(50),
      colorText: Colors.black,
      snackPosition: SnackPosition.TOP,
    );
  }

  // Show success message
  void _showSuccess(String message) {
    Get.snackbar(
      'نجاح',
      message,
      backgroundColor: Colors.green.withAlpha(50),
      colorText: Colors.black,
      snackPosition: SnackPosition.TOP,
    );
  }

  // حساب تواريخ الإيجار بناءً على النوع
  void _calculateEndDate() {
    if (_selectedDate == null) return;

    if (selectedRentType == 0) {
      _endDate = _selectedDate!.add(Duration(days: 1 * duration));
    } else if (selectedRentType == 1) {
      _endDate = _selectedDate!.add(Duration(days: 7 * duration));
    } else {
      _endDate = _selectedDate!.add(Duration(days: 30 * duration));
    }
  }

  // الحصول على نوع الإيجار كنص
  String _getRentTypeText() {
    if (selectedRentType == 0) {
      if (duration == 2) return "يومين";
      if (duration > 1 && duration < 11) {
        return "$duration أيام";
      }
      return "$duration يوم";
    } else if (selectedRentType == 1) {
      if (duration == 2) return "أسبوعين";
      if (duration > 1 && duration < 11) {
        return "$duration أسابيع";
      }
      return "$duration أسبوع";
    } else {
      if (duration == 2) return "شهرين";
      if (duration > 1 && duration < 11) {
        return "$duration أشهر";
      }
      return "$duration شهر";
    }
  }

  // حساب السعر بناءً على نوع الإيجار
  double get price {
    if (selectedRentType == 0) {
      return widget.apartment.price / 30;
    } else if (selectedRentType == 1) {
      return widget.apartment.price / 4.3;
    } else {
      return widget.apartment.price;
    }
  }

  // تنسيق السعر
  String _formatPrice(double price) {
    try {
      return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    } catch (_) {
      return '0';
    }
  }

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _storageService = StorageService();
    // _selectedDate = DateTime.now().add(const Duration(days: 1));
    _calculateEndDate();
    _checkAuthStatus();
  }

  // التحقق من حالة المصادقة
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      final userData = await _storageService.getUserData();

      setState(() {
        _isCheckingAuth = false;
        _isAuthenticated = isLoggedIn;
        _userRole = userData['role'];
      });

      if (!_isAuthenticated) {
        _showError('يرجى تسجيل الدخول أولاً');
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed('/login');
      } else if (_userRole != 'tenant') {
        _showError('يجب أن تكون مستأجراً لإجراء الحجز');
        await Future.delayed(const Duration(seconds: 1));
        Get.back();
      }
    } catch (e) {
      print('❌ خطأ في التحقق من المصادقة: $e');
      setState(() {
        _isCheckingAuth = false;
      });
      _showError('حدث خطأ في التحقق من الهوية');
    }
  }

  // دالة إرسال الحجز إلى API
  Future<void> _submitBooking() async {
    // التحقق من المصادقة أولاً
    if (!_isAuthenticated) {
      _showError('يرجى تسجيل الدخول أولاً');
      Get.toNamed('/login');
      return;
    }

    if (_userRole != 'tenant') {
      _showError('المستخدم الحالي ليس مستأجراً');
      return;
    }

    if (_selectedDate == null) {
      _showError('الرجاء اختيار تاريخ البدء');
      return;
    }

    if (_endDate == null) {
      _showError('حدث خطأ في حساب تاريخ الانتهاء');
      return;
    }

    // التحقق من أن تاريخ البدء ليس في الماضي
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (_selectedDate!.isBefore(yesterday)) {
      _showError('لا يمكن اختيار تاريخ في الماضي');
      return;
    }

    // حساب السعر الإجمالي
    final totalPrice = (duration * price).toDouble();

    setState(() => _isLoading = true);

    try {
      // التحقق مرة أخرى من التوكن قبل الإرسال
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) {
        _showError('جلسة العمل منتهية، يرجى تسجيل الدخول مرة أخرى');
        await _storageService.clearUserData();
        Get.offAllNamed('/login');
        return;
      }

      print('📤 إرسال طلب الحجز...');
      print('🔐 التوكن المستخدم: ${token.substring(0, 20)}...');
      print('🏢 ID الشقة: ${widget.apartment.id}');
      print(
        '📅 تاريخ البدء: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
      );
      print('📅 تاريخ الانتهاء: ${DateFormat('yyyy-MM-dd').format(_endDate!)}');
      print('💰 السعر الإجمالي: $totalPrice');

      final response = await _apiService.dio.post(
        '/bookings',
        data: {
          'apartment_id': widget.apartment.id,
          'start_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          'end_date': DateFormat('yyyy-MM-dd').format(_endDate!),
          'total_price': totalPrice,
        },
      );

      print('✅ استجابة الخادم: ${response.statusCode}');
      print('📋 بيانات الاستجابة: ${response.data}');

      if (response.statusCode == 201) {
        _showSuccess('تم إرسال طلب الحجز بنجاح! في انتظار موافقة المالك.');

        // الانتظار قليلاً ثم العودة للصفحة السابقة
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Get.back(result: true);
        }
      }
    } on DioException catch (e) {
      print('❌ خطأ Dio في إرسال الحجز:');
      print('   📊 Status Code: ${e.response?.statusCode}');
      print('   📋 Response Data: ${e.response?.data}');
      print('   🔗 URL: ${e.requestOptions.path}');
      print('   📝 Method: ${e.requestOptions.method}');
      print('   📦 Request Data: ${e.requestOptions.data}');

      if (e.response?.statusCode == 401) {
        _showError('جلسة العمل منتهية، يرجى تسجيل الدخول مرة أخرى');
        await _storageService.clearUserData();
        Get.offAllNamed('/login');
      } else if (e.response?.statusCode == 403) {
        final message =
            e.response?.data?['message'] ?? 'غير مصرح لك بإجراء الحجز';
        _showError('$message (يجب أن تكون مستأجراً معتمداً)');
      } else if (e.response?.statusCode == 409) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shadowColor: Configuration.primaryColor,
              backgroundColor: Colors.transparent,
              child: ClassContainer(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                isRounded: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'تعارض في الحجز',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: Configuration.mainFont,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Divider(height: 0),
                    Expanded(
                      child: ApartmentBookingsScreen(
                        apartmentId: widget.apartmentId,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        gradient: Configuration.gradientColor.withOpacity(0.7),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'حسناً',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: Configuration.mainFont,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data?['errors'];
        if (errors != null) {
          final errorMessage = _parseValidationErrors(errors);
          _showError('بيانات غير صحيحة: $errorMessage');
        } else {
          _showError('بيانات غير صحيحة. الرجاء التحقق من التواريخ');
        }
      } else {
        _showError('فشل في إرسال طلب الحجز. الرجاء المحاولة لاحقاً');
      }
    } catch (e) {
      print('❌ خطأ غير متوقع: $e');
      _showError('حدث خطأ غير متوقع. الرجاء المحاولة لاحقاً');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // تحويل أخطاء التحقق إلى نص مقروء
  String _parseValidationErrors(dynamic errors) {
    if (errors is Map) {
      final errorMessages = <String>[];
      errors.forEach((key, value) {
        if (value is List) {
          errorMessages.add('${_translateFieldName(key)}: ${value.join(', ')}');
        } else {
          errorMessages.add('${_translateFieldName(key)}: $value');
        }
      });
      return errorMessages.join('، ');
    }
    return errors.toString();
  }

  // ترجمة أسماء الحقول
  String _translateFieldName(String field) {
    const translations = {
      'apartment_id': 'معرف الشقة',
      'start_date': 'تاريخ البدء',
      'end_date': 'تاريخ الانتهاء',
      'total_price': 'السعر الإجمالي',
    };
    return translations[field] ?? field;
  }

  @override
  Widget build(BuildContext context) {
    // عرض شاشة التحميل أثناء التحقق من المصادقة
    if (_isCheckingAuth) {
      return _buildAuthCheckingScreen();
    }

    // عرض شاشة الخطأ إذا لم يكن المستخدم مستأجراً
    if (!_isAuthenticated || _userRole != 'tenant') {
      return _buildUnauthorizedScreen();
    }

    // الواجهة الرئيسية
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              // ... باقي الكود كما هو (بدون تغيير)
              // 1. الجزء العلوي (Header)
              _buildHeader(),
              // المحتوى الرئيسي
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Configuration.heightSize * 0.14),

                    // 2. بطاقة معلومات العقار
                    _buildPropertyCard(),

                    const SizedBox(height: 24),

                    // 3. قسم نوع الإيجار
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("نوع الإيجار"),
                          const SizedBox(height: 8),
                          _buildRentOption(
                            0,
                            "إيجار يومي",
                            "مثالي للإقامات القصيرة",
                            "${_formatPrice(widget.apartment.price / 30)} ل.س",
                          ),
                          const SizedBox(height: 8),
                          _buildRentOption(
                            1,
                            "إيجار أسبوعي",
                            "خصم على السعر اليومي",
                            "${_formatPrice(widget.apartment.price / 4.3)} ل.س",
                          ),
                          const SizedBox(height: 8),
                          _buildRentOption(
                            2,
                            "إيجار شهري",
                            "الأفضل للإقامات الطويلة",
                            "${_formatPrice(widget.apartment.price)} ل.س",
                          ),
                          const SizedBox(height: 24),
                          _buildLabel("تاريخ البدء"),
                          const SizedBox(height: 8),
                          _buildDatePicker(),
                          const SizedBox(height: 16),
                          _buildLabel("المدة"),
                          const SizedBox(height: 8),
                          _buildCounter(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildSummaryCard(),
                    const SizedBox(height: 16),
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                    _buildTermsText(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // شاشة التحقق من المصادقة
  Widget _buildAuthCheckingScreen() {
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
            Text(
              'جاري التحقق من صلاحية الجلسة...',
              style: TextStyle(
                fontFamily: Configuration.mainFont,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // شاشة غير مصرح
  Widget _buildUnauthorizedScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('غير مصرح')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
              const SizedBox(height: 20),
              Text(
                !_isAuthenticated ? 'غير مسجل الدخول' : 'غير مصرح',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: Configuration.mainFont,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                !_isAuthenticated
                    ? 'يجب تسجيل الدخول لحجز الشقة'
                    : 'يجب أن تكون مستأجراً معتمداً لحجز الشقة',
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
                    Get.toNamed('/');
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
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة بناء زر الإرسال
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _isLoading
                ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                : Configuration.gradientColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    "تأكيد الحجز",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: Configuration.mainFont,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // دالة بناء نص الشروط
  Widget _buildTermsText() {
    return Center(
      child: Text(
        _selectedDate != null && _endDate != null
            ? "بالضغط على \"تأكيد الحجز\"، أنت توافق على شروط وأحكام الإيجار وتاريخ ${_dateFormat.format(_endDate!)} ﻷنتهاء الحجز"
            : "بالضغط على \"تأكيد الحجز\"، أنت توافق على شروط وأحكام الإيجار ",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: Configuration.mainFont,
          color: Colors.grey[500],
          fontSize: 11,
        ),
      ),
    );
  }

  // --- Widgets Components ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 30, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: Configuration.gradientColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                "حجز الشقة",
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: Configuration.mainFont,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "املأ البيانات التالية لإتمام حجز الشقة",
            style: TextStyle(
              fontFamily: Configuration.mainFont,
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: Configuration.mainFont,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        fontFamily: Configuration.mainFont,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPropertyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("معلومات العقار"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.apartment.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: Configuration.mainFont,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${widget.apartment.city}، ${widget.apartment.province}، ${widget.apartment.address}',
                        style: TextStyle(
                          fontFamily: Configuration.mainFont,
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSpecItem(
                      Icons.aspect_ratio,
                      "${widget.apartment.rooms * 50} م²",
                    ),
                    const SizedBox(width: 15),
                    _buildSpecItem(
                      Icons.groups_sharp,
                      "${widget.apartment.guests} أشخاص",
                    ),
                    const SizedBox(width: 15),
                    _buildSpecItem(
                      Icons.bed_outlined,
                      "${widget.apartment.rooms} غرف",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Configuration.primaryColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Configuration.primaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: Configuration.mainFont,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRentOption(
    int index,
    String title,
    String subtitle,
    String price,
  ) {
    bool isSelected = selectedRentType == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRentType = index;
          _calculateEndDate();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Configuration.primaryColor : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Configuration.primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Configuration.primaryColor
                      : Colors.grey[400]!,
                ),
                color: isSelected
                    ? Configuration.primaryColor
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.circle, size: 10, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: Configuration.mainFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected ? Colors.black : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: Configuration.mainFont,
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontFamily: Configuration.mainFont,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Configuration.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        // initialDate:
        //     _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Configuration.primaryColor,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
          _calculateEndDate();
        });
      }
    }

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedDate == null
                    ? "يوم / شهر / سنة"
                    : "${_dateFormat.format(_selectedDate!)}",
                style: TextStyle(
                  color: _selectedDate == null
                      ? Colors.grey[500]
                      : Colors.black,
                  fontFamily: Configuration.mainFont,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCounterButton(Icons.remove, () {
            if (duration > 1) {
              setState(() {
                duration--;
                _calculateEndDate();
              });
            }
          }),
          Text(
            _getRentTypeText(),
            style: const TextStyle(
              fontFamily: Configuration.mainFont,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          _buildCounterButton(Icons.add, () {
            setState(() {
              duration++;
              _calculateEndDate();
            });
          }),
        ],
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.black54),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalPrice = (duration * price).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: Configuration.gradientColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildSummaryRow(_getRentTypeText(), "", isWhite: true),
          const SizedBox(height: 8),
          _buildSummaryRow(
            "${_formatPrice(price)} ل.س",
            "سعر ال${selectedRentType == 0
                ? 'يوم'
                : selectedRentType == 1
                ? 'أسبوع'
                : 'شهر'}",
            isWhite: true,
          ),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "الإجمالي",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: Configuration.mainFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${_formatPrice(totalPrice)} ل.س",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: Configuration.mainFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String value, String label, {bool isWhite = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              color: isWhite ? Colors.white70 : Colors.grey[600],
              fontFamily: Configuration.mainFont,
              fontSize: 14,
            ),
          ),
        if (label.isEmpty) const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: isWhite ? Colors.white : Colors.black,
            fontFamily: Configuration.mainFont,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
