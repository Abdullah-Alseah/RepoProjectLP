import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/services/api_service.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/models/booking_model.dart';

class BookingStore extends GetxController {
  static final BookingStore instance = BookingStore._internal();
  factory BookingStore() => instance;
  BookingStore._internal();

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  final RxList<Booking> _bookings = <Booking>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  List<Booking> get bookings => _bookings.toList();
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  // جلب حجوزات المالك (الإصدار المحسن)
  Future<void> getOwnerBookings({String? status}) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      // 1. التحقق من التوكن أولاً
      final token = await _storageService.getToken();
      print('🔍 فحص التوكن في getOwnerBookings:');
      print('   - هل يوجد توكن؟: ${token != null && token.isNotEmpty}');

      // التحقق من تسجيل الدخول
      final isLoggedIn = await _storageService.isLoggedIn();
      print('   - هل المستخدم مسجل دخول؟: $isLoggedIn');

      if (!isLoggedIn) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      // 2. طباعة معرف المستخدم
      final userId = await _storageService.getUserId();
      final userRole = await _storageService.getUserRole();
      print('   - معرف المستخدم: $userId');
      print('   - دور المستخدم: $userRole');

      // 3. جلب جميع الحجوزات بدون معاملات role
      print('📡 جلب جميع الحجوزات...');

      final Map<String, dynamic> queryParams = {};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiService.dio.get(
        '/bookings',
        queryParameters: queryParams,
      );

      print('✅ استجابة API:');
      print('   - الحالة: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> bookingsData = response.data['data']['data'] ?? [];
        print('   - عدد الحجوزات المستلمة: ${bookingsData.length}');

        // طباعة تفاصيل الحجوزات للتحقق
        if (bookingsData.isNotEmpty) {
          print('📋 تفاصيل الحجوزات المستلمة:');
          for (var i = 0; i < min(bookingsData.length, 3); i++) {
            final booking = bookingsData[i];
            print('   🔸 الحجز ${i + 1}:');
            print('      - ID: ${booking['id']}');
            print('      - حالة: ${booking['status']}');
            print('      - apartment_id: ${booking['apartment_id']}');
            print('      - owner_id: ${booking['apartment']?['owner_id']}');
            print(
              '      - اسم المالك: ${booking['apartment']?['owner']?['first_name']} ${booking['apartment']?['owner']?['last_name']}',
            );
          }
        }

        // تحويل جميع البيانات
        final allBookings = bookingsData.map((json) {
          return Booking.fromJson(json);
        }).toList();

        print('✅ تم تحويل ${allBookings.length} حجز');

        // 4. فلترة الحجوزات للمالك الحالي فقط
        print('🔍 بدء فلترة الحجوزات للمالك ID: $userId');

        final ownerBookings = allBookings.where((booking) {
          // التحقق إذا كان المالك موجوداً في بيانات الشقة
          if (booking.apartment.owner != null) {
            final isOwner = booking.apartment.owner.id == userId;
            if (isOwner) {
              print(
                '   ✅ الحجز #${booking.id}: ينتمي للمالك ${booking.apartment.owner.name}',
              );
            }
            return isOwner;
          }

          // إذا لم يكن المالك موجوداً، استخدم owner_id من البيانات الخام
          try {
            final bookingData = bookingsData.firstWhere(
              (b) => b['id'] == booking.id,
              orElse: () => {},
            );

            final ownerId = bookingData['apartment']?['owner_id'];
            if (ownerId != null && ownerId == userId) {
              print('   ✅ الحجز #${booking.id}: ينتمي للمالك (من owner_id)');
              return true;
            }
          } catch (e) {
            print('   ⚠️ خطأ في البحث عن بيانات الحجز: $e');
          }

          return false;
        }).toList();

        print(
          '🎯 النتيجة: ${ownerBookings.length} حجز للمالك من أصل ${allBookings.length}',
        );

        // 5. حفظ الحجوزات المفلترة
        _bookings.value = ownerBookings;

        // 6. إذا لم تكن هناك حجوزات، تحقق من سبب ذلك
        if (ownerBookings.isEmpty && allBookings.isNotEmpty) {
          print('⚠️ تحذير: هناك حجوزات ولكن لا تخص المالك الحالي');
          print('📊 تحليل معرفات المالكين:');

          for (var i = 0; i < allBookings.length; i++) {
            final booking = allBookings[i];
            final rawBooking = bookingsData[i];
            print('   🔸 الحجز ${i + 1}:');
            print('      - ID: ${booking.id}');
            print('      - apartment.owner.id: ${booking.apartment.owner?.id}');
            print(
              '      - apartment.owner.name: ${booking.apartment.owner?.name}',
            );
            print(
              '      - apartment.owner_id (من JSON): ${rawBooking['apartment']?['owner_id']}',
            );
            print('      - معرفي: $userId');
            print(
              '      - هل ينتمي لي؟: ${booking.apartment.owner?.id == userId}',
            );
          }
        }
      } else {
        print('❌ حالة غير متوقعة: ${response.statusCode}');
        print('❌ بيانات الاستجابة: ${response.data}');
        throw Exception(
          'فشل في جلب حجوزات المالك - حالة: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ خطأ Dio في جلب حجوزات المالك:');
      print('   - الرسالة: ${e.message}');
      print('   - الحالة: ${e.response?.statusCode}');
      print('   - البيانات: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        _error.value = 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى';
        Get.offAllNamed('/login');
      } else if (e.response?.statusCode == 403) {
        _error.value = 'غير مصرح لك بالوصول إلى حجوزات المالك';
      } else {
        _error.value =
            e.response?.data?['message'] ?? e.message ?? 'حدث خطأ غير معروف';
      }
      rethrow;
    } catch (e) {
      print('❌ خطأ عام في جلب حجوزات المالك: $e');
      print('   - نوع الخطأ: ${e.runtimeType}');
      _error.value = e.toString();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  // جلب جميع حجوزات المستخدم
  Future<void> getUserBookings({String? status}) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      // التحقق من تسجيل الدخول
      final isLoggedIn = await _storageService.isLoggedIn();
      if (!isLoggedIn) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      // إعداد معاملات البحث
      final Map<String, dynamic> queryParams = {};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      print('📡 جلب حجوزات المستخدم...');
      final response = await _apiService.dio.get(
        '/bookings',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> bookingsData = response.data['data']['data'] ?? [];
        print('✅ تم استلام ${bookingsData.length} حجز');

        _bookings.value = bookingsData.map((json) {
          return Booking.fromJson(json);
        }).toList();

        print('✅ تم تحميل ${_bookings.length} حجز');
      } else {
        throw Exception('فشل في جلب الحجوزات');
      }
    } on DioException catch (e) {
      print('❌ خطأ في جلب الحجوزات: ${e.message}');
      if (e.response?.statusCode == 401) {
        _error.value = 'انتهت صلاحية الجلسة';
        Get.offAllNamed('/login');
      } else {
        _error.value = e.response?.data?['message'] ?? e.message ?? 'حدث خطأ';
      }
      rethrow;
    } catch (e) {
      print('❌ خطأ في جلب الحجوزات: $e');
      _error.value = e.toString();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  // تحديث حالة الحجز (للمالك)
  // تحديث حالة الحجز (للمالك)
  Future<void> updateBookingStatus({
    required int bookingId,
    required String status,
  }) async {
    try {
      _isLoading.value = true;

      print('🔄 تحديث حالة الحجز #$bookingId إلى: $status');
      final response = await _apiService.dio.patch(
        '/bookings/$bookingId',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        // تحديث الحجز في القائمة
        final index = _bookings.indexWhere(
          (booking) => booking.id == bookingId,
        );

        if (index != -1) {
          final updatedBooking = Booking.fromJson(response.data['data']);
          _bookings[index] = updatedBooking;
          print('✅ تم تحديث الحجز #$bookingId في القائمة');
        } else {
          print('⚠️ الحجز #$bookingId غير موجود في القائمة');
        }

        // استخدام Get.back() بدلاً من Get.snackbar إذا كان في BottomSheet
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }

        Get.snackbar(
          'نجاح',
          'تم تحديث حالة الحجز بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
        );

        return;
      } else {
        print('❌ فشل تحديث الحجز - الحالة: ${response.statusCode}');
        throw Exception('فشل في تحديث الحجز');
      }
    } on DioException catch (e) {
      print('❌ خطأ في تحديث حالة الحجز: ${e.message}');
      print('📌 بيانات الخطأ: ${e.response?.data}');

      // خطأ في الاتصال بالخادم
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        Get.snackbar(
          'خطأ في الاتصال',
          'فشل الاتصال بالخادم، يرجى المحاولة لاحقاً',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'خطأ',
          e.response?.data?['message'] ?? 'فشل في تحديث حالة الحجز',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
      rethrow;
    } catch (e) {
      print('❌ خطأ غير متوقع في تحديث حالة الحجز: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      rethrow;
    } finally {
      // استخدام Future.delayed لضمان تحديث UI
      Future.delayed(const Duration(milliseconds: 300), () {
        _isLoading.value = false;
      });
    }
  }

  // إلغاء حجز
  Future<void> cancelBooking(int bookingId) async {
    try {
      _isLoading.value = true;

      print('🗑️ إلغاء الحجز #$bookingId');
      final response = await _apiService.dio.post(
        '/bookings/$bookingId/cancel',
      );

      if (response.statusCode == 200) {
        // تحديث الحجز في القائمة
        final index = _bookings.indexWhere(
          (booking) => booking.id == bookingId,
        );
        if (index != -1) {
          final updatedBooking = Booking.fromJson(response.data['data']);
          _bookings[index] = updatedBooking;
          print('✅ تم تحديث الحجر #$bookingId بعد الإلغاء');
        }

        Get.snackbar(
          'نجاح',
          'تم إلغاء الحجز بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('فشل في إلغاء الحجز');
      }
    } on DioException catch (e) {
      print('❌ خطأ في إلغاء الحجز: ${e.message}');
      Get.snackbar(
        'خطأ',
        e.response?.data?['message'] ?? 'فشل في إلغاء الحجز',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } catch (e) {
      print('❌ خطأ في إلغاء الحجز: $e');
      Get.snackbar(
        'خطأ',
        'فشل في إلغاء الحجز',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  // طلب تحديث حجز
  Future<void> requestBookingUpdate({
    required int bookingId,
    required DateTime newStartDate,
    required DateTime newEndDate,
  }) async {
    try {
      _isLoading.value = true;

      print('📝 طلب تحديث الحجز #$bookingId');
      final response = await _apiService.dio.post(
        '/bookings/$bookingId/request-update',
        data: {
          'start_date': newStartDate.toIso8601String().split('T')[0],
          'end_date': newEndDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        // تحديث الحجز في القائمة
        final index = _bookings.indexWhere(
          (booking) => booking.id == bookingId,
        );
        if (index != -1) {
          final updatedBooking = Booking.fromJson(response.data['data']);
          _bookings[index] = updatedBooking;
          print('✅ تم تحديث الحجر #$bookingId بعد طلب التحديث');
        }

        Get.snackbar(
          'نجاح',
          'تم إرسال طلب التحديث بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('فشل في طلب تحديث الحجز');
      }
    } on DioException catch (e) {
      print('❌ خطأ في طلب تحديث الحجز: ${e.message}');
      Get.snackbar(
        'خطأ',
        e.response?.data?['message'] ?? 'فشل في طلب تحديث الحجز',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } catch (e) {
      print('❌ خطأ في طلب تحديث الحجز: $e');
      Get.snackbar(
        'خطأ',
        'فشل في طلب تحديث الحجز',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  // تصفية الحجوزات حسب الحالة
  List<Booking> filterByStatus(String status) {
    if (status == 'all') {
      return _bookings.toList();
    }
    return _bookings.where((booking) => booking.status == status).toList();
  }

  // الحصول على حجوزات قادمة
  List<Booking> get upcomingBookings {
    final now = DateTime.now();
    return _bookings.where((booking) => booking.isUpcoming).toList();
  }

  // الحصول على حجوزات سابقة
  List<Booking> get pastBookings {
    final now = DateTime.now();
    return _bookings.where((booking) => booking.isPast).toList();
  }

  // الحصول على حجوزات حالية
  List<Booking> get currentBookings {
    final now = DateTime.now();
    return _bookings.where((booking) => booking.isCurrent).toList();
  }

  // مسح القائمة
  void clearBookings() {
    _bookings.clear();
    print('🗑️ تم مسح جميع الحجوزات من القائمة');
  }

  // دالة فحص سريعة
  Future<void> debugBookings() async {
    final userId = await _storageService.getUserId();
    print('🔍 فحص سريع للبيانات:');
    print('   - معرفي: $userId');
    print('   - عدد الحجوزات: ${_bookings.length}');

    for (var i = 0; i < _bookings.length; i++) {
      final booking = _bookings[i];
      print('   🎫 الحجز ${i + 1}:');
      print('      - ID: ${booking.id}');
      print('      - حالة: ${booking.status}');
      print(
        '      - المالك: ${booking.apartment.owner?.name} (${booking.apartment.owner?.id})',
      );
      print('      - هل ينتمي لي؟: ${booking.apartment.owner?.id == userId}');
    }
  }

  // بعد الدوال الموجودة أضف:

  // حجوزات شقة معينة بحالة محددة
  final RxList<Booking> _apartmentBookings = <Booking>[].obs;
  List<Booking> get apartmentBookings => _apartmentBookings.toList();

  Future<void> getApartmentBookings({
    required int apartmentId,
    required String status,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      print('🏢 جلب حجوزات الشقة #$apartmentId بحالة: $status');

      // التحقق من تسجيل الدخول
      final isLoggedIn = await _storageService.isLoggedIn();
      if (!isLoggedIn) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      // إعداد معاملات البحث
      final Map<String, dynamic> queryParams = {
        'apartment_id': apartmentId,
        'status': status,
      };

      final response = await _apiService.dio.get(
        '/bookings',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> bookingsData = response.data['data']['data'] ?? [];
        print('✅ تم استلام ${bookingsData.length} حجز للشقة');

        _apartmentBookings.value = bookingsData.map((json) {
          return Booking.fromJson(json);
        }).toList();

        // طباعة تفاصيل الحجوزات للتحقق
        if (_apartmentBookings.isNotEmpty) {
          print('📋 تفاصيل حجوزات الشقة #$apartmentId:');
          for (final booking in _apartmentBookings) {
            print('   🎫 الحجز #${booking.id}:');
            print('      - المستأجر: ${booking.tenant.fullName}');
            print('      - من: ${_formatDate(booking.startDate)}');
            print('      - إلى: ${_formatDate(booking.endDate)}');
            print('      - السعر: ${booking.totalPrice} ريال');
            print('      - المدة: ${booking.durationInDays} يوم');
          }
        }
      } else {
        throw Exception('فشل في جلب حجوزات الشقة');
      }
    } on DioException catch (e) {
      print('❌ خطأ في جلب حجوزات الشقة: ${e.message}');
      if (e.response?.statusCode == 401) {
        _error.value = 'انتهت صلاحية الجلسة';
        Get.offAllNamed('/login');
      } else {
        _error.value = e.response?.data?['message'] ?? e.message ?? 'حدث خطأ';
      }
      rethrow;
    } catch (e) {
      print('❌ خطأ في جلب حجوزات الشقة: $e');
      _error.value = e.toString();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  // دالة مساعدة لتنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // مسح حجوزات الشقة
  void clearApartmentBookings() {
    _apartmentBookings.clear();
    print('🗑️ تم مسح حجوزات الشقة من القائمة');
  }
}
