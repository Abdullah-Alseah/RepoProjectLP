// lib/widgets/booking_card_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/services/test_connection.dart';
import 'package:marsa_app/models/booking_model.dart';
import 'package:marsa_app/stores/booking_store.dart';

class BookingCardWidget extends StatefulWidget {
  final Booking booking;
  final int? index;

  const BookingCardWidget({super.key, required this.booking, this.index});

  @override
  State<BookingCardWidget> createState() => _BookingCardWidgetState();
}

class _BookingCardWidgetState extends State<BookingCardWidget> {
  bool _isLoading = false;
  final BookingStore _bookingStore = BookingStore.instance;
  TestConnection testConnection = new TestConnection();
  // دالة محسنة لبناء URL الصورة
  String _buildImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    String finalUrl;
    if (imagePath.startsWith('storage/')) {
      finalUrl = 'http://${Configuration.baseUrl}:80000/$imagePath';
    } else if (imagePath.startsWith('apartments/')) {
      finalUrl = 'http://${Configuration.baseUrl}:8000/storage/$imagePath';
    } else {
      finalUrl = 'http://${Configuration.baseUrl}:8000/storage/apartments/$imagePath';
    }

    return finalUrl;
  }

  // الحصول على الصورة الرئيسية
  String _getMainImage() {
    try {
      if (widget.booking.apartment.images.isEmpty) return '';

      final mainImage = widget.booking.apartment.images.firstWhere(
        (img) => img.isMain,
        orElse: () => widget.booking.apartment.images.first,
      );

      return _buildImageUrl(mainImage.url);
    } catch (e) {
      return '';
    }
  }

  // دالة لتنسيق السعر
  String _formatPrice(double price) {
    try {
      return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ل.س';
    } catch (_) {
      return '0 ل.س';
    }
  }

  // دالة للحصول على العنوان
  String _getFullAddress() {
    try {
      final city = widget.booking.apartment.city.isNotEmpty
          ? widget.booking.apartment.city
          : '';
      final province = widget.booking.apartment.province.isNotEmpty
          ? widget.booking.apartment.province
          : '';
      final address = widget.booking.apartment.address.isNotEmpty
          ? widget.booking.apartment.address
          : '';

      final parts = [
        city,
        province,
        address,
      ].where((part) => part.isNotEmpty).toList();
      return parts.join('، ');
    } catch (e) {
      return 'العنوان غير متوفر';
    }
  }

  // إلغاء الحجز
  Future<void> _cancelBooking() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: const Text('هل أنت متأكد من إلغاء هذا الحجز؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('تأكيد', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _bookingStore.cancelBooking(widget.booking.id);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // فتح تفاصيل الحجز
  void _openBookingDetails() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تفاصيل الحجز #${widget.booking.id}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: Configuration.mainFont,
              ),
            ),
            const SizedBox(height: 15),
            _buildDetailRow('الشقة:', widget.booking.apartment.title),
            _buildDetailRow(
              'من:',
              DateFormat('yyyy/MM/dd').format(widget.booking.startDate),
            ),
            _buildDetailRow(
              'إلى:',
              DateFormat('yyyy/MM/dd').format(widget.booking.endDate),
            ),
            _buildDetailRow('المدة:', '${widget.booking.durationInDays} يوم'),
            _buildDetailRow(
              'السعر الإجمالي:',
              _formatPrice(widget.booking.totalPrice),
            ),
            _buildDetailRow(
              'الحالة:',
              widget.booking.statusText,
              color: widget.booking.statusColor,
            ),
            const SizedBox(height: 20),
            if (widget.booking.canCancel)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _cancelBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('إلغاء الحجز'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: Configuration.mainFont,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color ?? Colors.black,
              fontFamily: Configuration.mainFont,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = _formatPrice(widget.booking.totalPrice);
    final address = _getFullAddress();
    final nameApartment = widget.booking.apartment.title;
    final room = widget.booking.apartment.rooms.toString();
    final guests = widget.booking.apartment.guests.toString();
    final area = '${widget.booking.apartment.rooms * 50} م²';
    final mainImageUrl = _getMainImage();
    final startDate = DateFormat('yyyy/MM/dd').format(widget.booking.startDate);
    final endDate = DateFormat('yyyy/MM/dd').format(widget.booking.endDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: InkWell(
        onTap: _openBookingDetails,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildImageAndOverlays(mainImageUrl, startDate, endDate),
              _buildDetailsSection(
                price: price,
                address: address,
                nameApartment: nameApartment,
                room: room,
                guests: guests,
                area: area,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageAndOverlays(
    String imageUrl,
    String startDate,
    String endDate,
  ) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Stack(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultImage();
                    },
                  )
                : _buildDefaultImage(),
          ),
          // بادجة الحالة
          Positioned(
            top: 15,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.booking.statusColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.booking.statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: Configuration.mainFont,
                ),
              ),
            ),
          ),
          // التواريخ
          Positioned(
            bottom: 10,
            right: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'من',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontFamily: Configuration.mainFont,
                        ),
                      ),
                      Text(
                        startDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: Configuration.mainFont,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'إلى',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontFamily: Configuration.mainFont,
                        ),
                      ),
                      Text(
                        endDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: Configuration.mainFont,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      color: Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apartment, size: 50, color: Colors.grey.shade500),
          const SizedBox(height: 8),
          Text(
            widget.booking.apartment.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              fontFamily: Configuration.mainFont,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection({
    required String price,
    required String address,
    required String nameApartment,
    required String room,
    required String guests,
    required String area,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nameApartment,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: Configuration.mainFont,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: Configuration.mainFont,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _specItem(Icons.king_bed_outlined, '$room غرف'),
              const SizedBox(width: 15),
              _specItem(Icons.groups_sharp, '$guests أشخاص'),
              const SizedBox(width: 15),
              _specItem(Icons.aspect_ratio, area),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(height: 1),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Configuration.primaryColor,
                      fontFamily: Configuration.mainFont,
                    ),
                  ),
                  Text(
                    'الإجمالي',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: Configuration.mainFont,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Configuration.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: _openBookingDetails,
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _specItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Configuration.primaryColor, size: 18),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            fontFamily: Configuration.mainFont,
          ),
        ),
      ],
    );
  }
}
