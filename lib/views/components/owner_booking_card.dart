import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/models/booking_model.dart';
import 'package:marsa_app/stores/booking_store.dart';

class OwnerBookingCardWidget extends StatefulWidget {
  final Booking booking;
  final int index;
  final VoidCallback? onStatusUpdated;

  const OwnerBookingCardWidget({
    super.key,
    required this.booking,
    required this.index,
    this.onStatusUpdated,
  });

  @override
  State<OwnerBookingCardWidget> createState() => _OwnerBookingCardWidgetState();
}

class _OwnerBookingCardWidgetState extends State<OwnerBookingCardWidget> {
  final BookingStore _bookingStore = BookingStore.instance;
  bool _isProcessing = false;
  bool _isMounted = false;

  // تنسيق التاريخ
  final DateFormat _dateFormat = DateFormat('yyyy/MM/dd');

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    print('🎫 تهيئة بطاقة الحجز #${widget.booking.id}');
  }

  @override
  void dispose() {
    _isMounted = false;
    print('🗑️ إزالة بطاقة الحجز #${widget.booking.id}');
    super.dispose();
  }

  // دالة آمنة لـ setState
  void _safeSetState(VoidCallback fn) {
    if (_isMounted) {
      setState(fn);
    } else {
      print('⚠️ تم تجنب setState بعد dispose للحجز #${widget.booking.id}');
    }
  }

  // تحديث حالة الحجز
  Future<void> _updateBookingStatus(String status) async {
    try {
      print('🔄 تحديث حالة الحجز #${widget.booking.id} إلى: $status');
      _safeSetState(() => _isProcessing = true);

      final result = await _bookingStore.updateBookingStatus(
        bookingId: widget.booking.id,
        status: status,
      );

      // استدعاء callback للتحديث إذا كان موجوداً
      if (widget.onStatusUpdated != null) {
        widget.onStatusUpdated!();
      }

      // لا نحتاج لـ setState هنا لأن الـ store سيحدث القائمة
      _safeSetState(() => _isProcessing = false);

      print('✅ تم تحديث حالة الحجز #${widget.booking.id} بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث الحجز #${widget.booking.id}: $e');

      // التحقق من mount قبل setState
      _safeSetState(() => _isProcessing = false);

      Get.snackbar(
        'خطأ',
        'فشل في تحديث حالة الحجز',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // عرض تفاصيل المستأجر
  void _showTenantDetails() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'معلومات المستأجر',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: Configuration.mainFont,
              ),
            ),
            const SizedBox(height: 15),
            _buildInfoRow('الاسم', widget.booking.tenant.fullName),
            _buildInfoRow('الهاتف', widget.booking.tenant.phone ?? 'غير متوفر'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Configuration.primaryColor,
                ),
                child: const Text(
                  'تم',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: Configuration.mainFont,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
                fontFamily: Configuration.mainFont,
              ),
            ),
          ),
          Text(
            ': $title',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: Configuration.mainFont,
            ),
          ),
        ],
      ),
    );
  }

  // دالة للذهاب إلى تفاصيل الشقة
  void _goToApartmentDetails() {
    Get.toNamed(
      '/ownerApartmentDetails',
      arguments: {
        'apartmentId': widget.booking.apartment.id,
        'apartment': widget.booking.apartment,
      },
    );
  }

  // بناء أزرار الإجراءات
  Widget _buildActionButtons() {
    if (_isProcessing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    switch (widget.booking.status) {
      case 'pending':
        return Column(
          children: [
            const Text(
              'طلب حجز جديد',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontFamily: Configuration.mainFont,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateBookingStatus('confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('قبول الحجز'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateBookingStatus('rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('رفض الحجز'),
                  ),
                ),
              ],
            ),
          ],
        );

      case 'pending_update':
        return Column(
          children: [
            const Text(
              'طلب تحديث التواريخ',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontFamily: Configuration.mainFont,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateBookingStatus('confirmed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('قبول التحديث'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateBookingStatus('rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('رفض التحديث'),
                  ),
                ),
              ],
            ),
          ],
        );

      case 'confirmed':
        return Column(
          children: [
            const Text(
              'حجز مؤكد',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontFamily: Configuration.mainFont,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _updateBookingStatus('cancelled'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'إلغاء الحجز',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: Configuration.mainFont,
                  ),
                ),
              ),
            ),
          ],
        );

      case 'cancelled':
        return Text(
          'تم إلغاء الحجز',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontFamily: Configuration.mainFont,
          ),
        );

      case 'rejected':
        return Text(
          'تم رفض الحجز',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontFamily: Configuration.mainFont,
          ),
        );

      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: widget.booking.statusColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.booking.statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: widget.booking.statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        widget.booking.statusText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.booking.statusColor,
                          fontFamily: Configuration.mainFont,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '#${widget.booking.id}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: Configuration.mainFont,
                    ),
                  ),
                ],
              ),
            ),

            // Booking details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Apartment info
                  Row(
                    children: [
                      Icon(Icons.apartment, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.booking.apartment.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: Configuration.mainFont,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'من',
                                  style: TextStyle(
                                    fontFamily: Configuration.mainFont,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _dateFormat.format(widget.booking.startDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: Configuration.mainFont,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'إلى',
                                  style: TextStyle(
                                    fontFamily: Configuration.mainFont,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _dateFormat.format(widget.booking.endDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: Configuration.mainFont,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.nights_stay,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'المدة',
                                  style: TextStyle(
                                    fontFamily: Configuration.mainFont,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.booking.durationInDays} ليلة',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: Configuration.mainFont,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price and action buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'السعر الكلي',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: Configuration.mainFont,
                        ),
                      ),
                      Text(
                        '${widget.booking.totalPrice.toStringAsFixed(0)} ل.س',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Configuration.primaryColor,
                          fontFamily: Configuration.mainFont,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر عرض تفاصيل الشقة
                      InkWell(
                        onTap: _goToApartmentDetails,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.apartment_outlined,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'عرض الشقة',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontFamily: Configuration.mainFont,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // زر عرض تفاصيل المستأجر
                      InkWell(
                        onTap: _showTenantDetails,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                widget.booking.tenant.fullName,
                                style: const TextStyle(
                                  fontFamily: Configuration.mainFont,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.person, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  if (widget.booking.canCancel &&
                      widget.booking.status != 'cancelled' &&
                      widget.booking.status != 'rejected')
                    _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
