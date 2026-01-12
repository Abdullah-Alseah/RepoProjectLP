import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lottie/lottie.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/stores/booking_store.dart';
import 'package:marsa_app/models/booking_model.dart';

class ApartmentBookingsScreen extends StatefulWidget {
  final int apartmentId;

  const ApartmentBookingsScreen({Key? key, required this.apartmentId})
    : super(key: key);

  @override
  _ApartmentBookingsScreenState createState() =>
      _ApartmentBookingsScreenState();
}

class _ApartmentBookingsScreenState extends State<ApartmentBookingsScreen> {
  final BookingStore _bookingStore = Get.find<BookingStore>();
  String _selectedStatus = 'confirmed';
  late Future<void> _loadBookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadBookingsFuture = _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      await _bookingStore.getApartmentBookings(
        apartmentId: widget.apartmentId,
        status: _selectedStatus,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الحجوزات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // إذا كان في وضع مدمج، لا نستخدم Scaffold

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 250, // ارتفاع مناسب للـ Dialog
        ),
        child: _buildCompactBookingsList(),
      ),
    );
  }

  Widget _buildCompactBookingsList() {
    return FutureBuilder(
      future: _loadBookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Lottie.asset('assets/icons/Sandy Loading.json'));
        }

        return Obx(() {
          final bookings = _selectedStatus == 'all'
              ? _bookingStore.apartmentBookings
              : _bookingStore.apartmentBookings
                    .where((booking) => booking.status == _selectedStatus)
                    .toList();

          return ListView.builder(
            shrinkWrap: true,
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Container(
                margin: EdgeInsets.all(8),
                // padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getColor(index).withOpacity(0.3),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  border: Border.all(color: _getColor(index), width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getColor(index),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        border: Border.all(color: _getColor(index), width: 0.5),
                      ),
                      child: Text(
                        'الحجز ${index + 1}',
                        style: TextStyle(
                          fontFamily: Configuration.mainFont,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'تاريخ البداية',
                                    style: TextStyle(
                                      fontFamily: Configuration.mainFont,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'yyyy-MM-dd',
                                ).format(booking.startDate),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_circle_left_outlined,
                          color: Colors.white,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'تاريخ النهاية',
                                    style: TextStyle(
                                      fontFamily: Configuration.mainFont,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'yyyy-MM-dd',
                                ).format(booking.endDate),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  Color _getColor(int index) {
    double hue = (index * 137.5) % 360;
    return HSVColor.fromAHSV(1.0, hue, 0.8, 0.8).toColor();
  }
}
