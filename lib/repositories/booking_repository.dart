// lib/repositories/booking_repository.dart
import 'dart:async';
import 'package:dio/dio.dart';
import '../controllers/services/api_service.dart';
import '../models/booking_model.dart';

class BookingRepository {
  final ApiService _apiService = ApiService();

  // إنشاء حجز جديد
  Future<Booking> createBooking({
    required int apartmentId,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/bookings',
        data: {
          'apartment_id': apartmentId,
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
          'total_price': totalPrice,
        },
      );

      return Booking.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('الشقة محجوزة في هذه التواريخ');
      }
      throw Exception(
        'فشل في إنشاء الحجز: ${e.response?.data?['message'] ?? e.message}',
      );
    }
  }

  // جلب جميع حجوزات المستخدم
  Future<List<Booking>> getUserBookings({String? status}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (status != null) queryParams['status'] = status;

      final response = await _apiService.dio.get(
        '/bookings',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final List<dynamic> bookingsData = response.data['data']['data'] ?? [];
      return bookingsData.map((json) => Booking.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        'فشل في جلب الحجوزات: ${e.response?.data?['message'] ?? e.message}',
      );
    }
  }

  // تحديث حالة الحجز (للمالك)
  Future<Booking> updateBookingStatus({
    required int bookingId,
    required String status, // confirmed, rejected, cancelled
  }) async {
    try {
      final response = await _apiService.dio.patch(
        '/bookings/$bookingId',
        data: {'status': status},
      );

      return Booking.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(
        'فشل في تحديث الحجز: ${e.response?.data?['message'] ?? e.message}',
      );
    }
  }

  // إلغاء الحجز (للمستأجر)
  Future<Booking> cancelBooking(int bookingId) async {
    try {
      final response = await _apiService.dio.post(
        '/bookings/$bookingId/cancel',
      );

      return Booking.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(
        'فشل في إلغاء الحجز: ${e.response?.data?['message'] ?? e.message}',
      );
    }
  }

  // طلب تحديث الحجز (للمستأجر)
  Future<Booking> requestBookingUpdate({
    required int bookingId,
    required DateTime newStartDate,
    required DateTime newEndDate,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/bookings/$bookingId/request-update',
        data: {
          'start_date': newStartDate.toIso8601String().split('T')[0],
          'end_date': newEndDate.toIso8601String().split('T')[0],
        },
      );

      return Booking.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(
        'فشل في طلب التحديث: ${e.response?.data?['message'] ?? e.message}',
      );
    }
  }

  // جلب حجوزات شقة معينة بحالة محددة
  Future<List<Booking>> getApartmentBookings({
    required int apartmentId,
    required String status,
  }) async {
    try {
      print('📡 جلب حجوزات الشقة #$apartmentId بحالة: $status');

      final response = await _apiService.dio.get(
        '/bookings',
        queryParameters: {'apartment_id': apartmentId, 'status': status},
      );

      print('✅ استجابة API:');
      print('   - الحالة: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> bookingsData = response.data['data']['data'] ?? [];
        print('   - عدد الحجوزات المستلمة: ${bookingsData.length}');

        // طباعة تفاصيل الحجوزات للتحقق
        if (bookingsData.isNotEmpty) {
          for (var i = 0; i < bookingsData.length; i++) {
            final booking = bookingsData[i];
            print('   🏢 الحجز ${i + 1}:');
            print('      - ID: ${booking['id']}');
            print('      - الشقة ID: ${booking['apartment_id']}');
            print(
              '      - المستأجر: ${booking['tenant']?['first_name']} ${booking['tenant']?['last_name']}',
            );
            print('      - من: ${booking['start_date']}');
            print('      - إلى: ${booking['end_date']}');
            print('      - السعر: ${booking['total_price']}');
          }
        }

        return bookingsData.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception(
          'فشل في جلب حجوزات الشقة - حالة: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ خطأ في جلب حجوزات الشقة:');
      print('   - الرسالة: ${e.message}');
      print('   - الحالة: ${e.response?.statusCode}');
      print('   - البيانات: ${e.response?.data}');

      if (e.response?.statusCode == 404) {
        throw Exception('الشقة غير موجودة');
      } else if (e.response?.statusCode == 401) {
        throw Exception('يجب تسجيل الدخول أولاً');
      } else {
        throw Exception(
          'فشل في جلب حجوزات الشقة: ${e.response?.data?['message'] ?? e.message}',
        );
      }
    } catch (e) {
      print('❌ خطأ غير متوقع: $e');
      throw Exception('حدث خطأ غير متوقع أثناء جلب الحجوزات');
    }
  }

  // التحقق من تواريخ الشقة (هل الشقة متاحة في تواريخ معينة)
  Future<bool> checkApartmentAvailability({
    required int apartmentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      print('🔍 التحقق من توفر الشقة #$apartmentId');
      print('   - من: $startDate');
      print('   - إلى: $endDate');

      // جلب الحجوزات المؤكدة للشقة
      final confirmedBookings = await getApartmentBookings(
        apartmentId: apartmentId,
        status: 'confirmed',
      );

      // جلب الحجوزات قيد الانتظار أيضاً
      final pendingBookings = await getApartmentBookings(
        apartmentId: apartmentId,
        status: 'pending',
      );

      final allBookings = [...confirmedBookings, ...pendingBookings];
      print('   - عدد الحجوزات للشقة: ${allBookings.length}');

      // التحقق من التعارض في التواريخ
      for (final booking in allBookings) {
        final conflictStart = booking.startDate.isBefore(endDate);
        final conflictEnd = booking.endDate.isAfter(startDate);

        if (conflictStart && conflictEnd) {
          print('   ⚠️ تعارض مع الحجز #${booking.id}:');
          print('      - من: ${booking.startDate}');
          print('      - إلى: ${booking.endDate}');
          print('      - المستأجر: ${booking.tenant.fullName}');
          return false; // هناك تعارض
        }
      }

      print('   ✅ الشقة متاحة في التواريخ المطلوبة');
      return true; // الشقة متاحة
    } catch (e) {
      print('❌ خطأ في التحقق من التوفر: $e');
      throw Exception('فشل في التحقق من توفر الشقة');
    }
  }
}
