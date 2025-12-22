import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:marsa_app/main.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:get/get.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? _selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Config.primaryColor,
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
      });
    }
  }

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

  // متغيرات الحالة للتحكم في الواجهة
  int selectedRentType = 2; // 0: يومي, 1: أسبوعي, 2: شهري
  int duration = 3;
  String _typeing() {
    if (selectedRentType == 0) {
      price = priceDay;
      if (duration == 2) return "يومين";
      if (duration > 1 && duration < 11) {
        return "أيام";
      } else
        return "يوم";
    } else if (selectedRentType == 1) {
      price = priceWeek;
      if (duration == 2) return "أسبوعين";
      if (duration > 1 && duration < 11) {
        return "أسابيع";
      } else
        return "أسبوع";
    } else {
      price = priceMonth;
      if (duration == 2) return "شهرين";
      if (duration > 1 && duration < 11) {
        return "أشهر";
      } else
        return "شهر";
    }
  }

  bool isFav = false;
  int price = 0;
  int priceDay = 183;
  int priceWeek = 1200;
  int priceMonth = 5500;

  int area = 180;
  int room = 3;
  int bath = 2;
  String address = "الرياض، حي العليا";
  String nameApartment = "شقة فاخرة في وسط المدينة";
  // الألوان المستخدمة
  final Color primaryColor = Config.primaryColor;
  final Color lightTeal = const Color(0xFFE8F6F5);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              // 1. الجزء العلوي (Header)
              _buildHeader(),
              // المحتوى الرئيسي
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Config.heightSize * 0.14),

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
                            "${priceDay} ريال/يوم",
                          ),
                          const SizedBox(height: 8),
                          _buildRentOption(
                            1,
                            "إيجار أسبوعي",
                            "خصم 5% على السعر اليومي",
                            "${priceWeek} ريال/أسبوع",
                          ),
                          const SizedBox(height: 8),
                          _buildRentOption(
                            2,
                            "إيجار شهري",
                            "الأفضل للإقامات الطويلة",
                            "${priceMonth} ريال/شهر",
                          ),
                          // 4. المدة وتاريخ البدء
                          const SizedBox(height: 24),
                          _buildLabel("المدة"),
                          const SizedBox(height: 8),
                          _buildCounter(),
                          const SizedBox(height: 16),
                          _buildLabel("تاريخ البدء"),
                          const SizedBox(height: 8),
                          // _buildDatePicker(),
                          InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 15,
                              ),
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
                                          : "${_selectedDate!.day} / ${_selectedDate!.month} / ${_selectedDate!.year}",
                                      style: TextStyle(
                                        color: _selectedDate == null
                                            ? Colors.grey[500]
                                            : Colors.black,
                                        fontFamily: Config.mainFont,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 6. ملخص الحجز (البطاقة الخضراء في الأسفل)
                    _buildSummaryCard(),

                    const SizedBox(height: 16),

                    // 7. زر التأكيد
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedDate == null) {
                            _showError('الرجاء اختيار تاريخ الميلاد');
                          }
                          ;
                        },
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
                            gradient: Config.gradientColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "تأكيد الحجز",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: Config.mainFont,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        "بالضغط على \"تأكيد الحجز\"، أنت توافق على شروط وأحكام الإيجار وسياسة الإلغاء للمنصة",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: Config.mainFont,
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // _buildHeader(),
            ],
          ),
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
        gradient: Config.gradientColor,
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
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                "حجز الشقة",
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: Config.mainFont,
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
              fontFamily: Config.mainFont,
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
        fontFamily: Config.mainFont,
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
        fontFamily: Config.mainFont,
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
                  nameApartment,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: Config.mainFont,
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
                    Text(
                      address,
                      style: TextStyle(
                        fontFamily: Config.mainFont,
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSpecItem(Icons.aspect_ratio, "$area م²"),
                    const SizedBox(width: 15),
                    _buildSpecItem(Icons.bathtub_outlined, "حمام $bath"),
                    const SizedBox(width: 15),
                    _buildSpecItem(Icons.bed_outlined, "غرف $room"),
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
        Icon(icon, size: 16, color: Config.primaryColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Config.primaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: Config.mainFont,
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
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Config.primaryColor : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Config.primaryColor.withOpacity(0.1),
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
                  color: isSelected ? Config.primaryColor : Colors.grey[400]!,
                ),
                color: isSelected ? Config.primaryColor : Colors.transparent,
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
                      fontFamily: Config.mainFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected ? Colors.black : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: Config.mainFont,
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
                fontFamily: Config.mainFont,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Config.primaryColor,
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
            if (duration > 1) setState(() => duration--);
          }),
          Text(
            "$duration ${_typeing()}",
            style: const TextStyle(
              fontFamily: Config.mainFont,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          _buildCounterButton(Icons.add, () {
            setState(() => duration++);
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

  Widget _buildTextField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: Config.mainFont,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: Config.mainFont,
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Config.primaryColor, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: Config.gradientColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildSummaryRow("$duration ${_typeing()}", "", isWhite: true),
          const SizedBox(height: 8),
          _buildSummaryRow("ل.س/شهر ${price}", "السعر", isWhite: true),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "الإجمالي",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: Config.mainFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${duration * price} ل.س",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: Config.mainFont,
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
              fontFamily: Config.mainFont,
              fontSize: 14,
            ),
          ),
        if (label.isEmpty) const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: isWhite ? Colors.white : Colors.black,
            fontFamily: Config.mainFont,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
