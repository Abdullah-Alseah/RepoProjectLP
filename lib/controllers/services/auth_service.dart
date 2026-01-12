// lib/services/auth_service.dart
import 'dart:io';
import 'package:marsa_app/controllers/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' show Get;
import 'package:marsa_app/controllers/services/storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  late Dio _dio;
  bool isLoggedIn = false;
  AuthService() {
    // نستخدم المستقبل للحصول على Dio بعد تهيئته
    _initializeDio();
  }

  Future<void> _initializeDio() async {
    _dio = await _apiService.dio;
    isLoggedIn = await true;
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String confirmPassword,
    required DateTime dateOfBirth,
    File? avatarImage,
    required File idDocumentImage,
    required String role,
  }) async {
    try {
      // تأكد من تهيئة Dio
      await _initializeDio();
      isLoggedIn = true;
      print('🚀 بدء عملية التسجيل...');
      print('📱 الرقم: $phone');
      print('📅 تاريخ الميلاد: ${dateOfBirth.toIso8601String().split('T')[0]}');
      print('🖼️ صورة الهوية: ${idDocumentImage.path}');
      print('🖼️ صورة الملف الشخصي: ${avatarImage?.path ?? "غير محددة"}');

      FormData formData = FormData.fromMap({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'password': password,
        'password_confirmation': confirmPassword,
        'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
        'role': role,
        'id_document_url': await MultipartFile.fromFile(
          idDocumentImage.path,
          filename: 'id_document_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      if (avatarImage != null) {
        formData.files.add(
          MapEntry(
            'avatar_url',
            await MultipartFile.fromFile(
              avatarImage.path,
              filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }

      print('📤 إرسال الطلب إلى: ${_dio.options.baseUrl}/auth/register');

      Response response = await _dio.post(
        '/auth/register',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      print('✅ استجابة ناجحة: ${response.statusCode}');
      print('📄 البيانات: ${response.data}');

      return {
        'success': true,
        'data': response.data,
        'message': response.data['message'] ?? 'تم التسجيل بنجاح',
      };
    } on DioException catch (e) {
      print('❌ خطأ DioException:');
      print('🔴 النوع: ${e.type}');
      print('🔴 الرسالة: ${e.message}');
      print('🔴 الاستجابة: ${e.response?.data}');
      print('🔴 Status Code: ${e.response?.statusCode}');

      return _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ خطأ غير متوقع:');
      print('🔴 الرسالة: ${e.toString()}');
      print('🔴 Stack Trace: $stackTrace');

      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع: ${e.toString()}',
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      await _initializeDio();

      print('🔐 بدء التحقق من OTP...');
      print('📱 الرقم: $phone');
      print('🔢 OTP: $otp');
      print('🌐 الإرسال إلى: ${_dio.options.baseUrl}/auth/verify');

      // تأكد من أن OTP مكون من 5 أرقام
      if (otp.length != 5) {
        return {'success': false, 'message': 'رمز التحقق يجب أن يكون 5 أرقام'};
      }

      Response response = await _dio.post(
        '/auth/verify',
        data: {'phone': phone, 'otp': otp},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('✅ استجابة التحقق: ${response.statusCode}');
      print('📄 البيانات: ${response.data}');

      return {
        'success': true,
        'data': response.data,
        'message': response.data['message'] ?? 'تم التحقق بنجاح',
        'user': response.data['user'] ?? response.data['data'],
      };
    } on DioException catch (e) {
      print('❌ خطأ في التحقق من OTP:');
      print('   النوع: ${e.type}');
      print('   الرسالة: ${e.message}');
      print('   URL: ${e.requestOptions.uri}');

      if (e.response != null) {
        print('   Status Code: ${e.response!.statusCode}');
        print('   استجابة الخادم: ${e.response!.data}');

        // معالجة أخطاء محددة من Laravel
        if (e.response!.statusCode == 404) {
          return {
            'success': false,
            'message': 'الرقم غير مسجل في النظام',
            'statusCode': 404,
          };
        } else if (e.response!.statusCode == 400) {
          return {
            'success': false,
            'message': 'رمز التحقق غير صحيح أو منتهي الصلاحية',
            'statusCode': 400,
          };
        } else if (e.response!.statusCode == 422) {
          final errors = e.response!.data['errors'];
          if (errors != null && errors is Map) {
            String errorMessage = 'خطأ في البيانات';
            if (errors['otp'] != null && errors['otp'].isNotEmpty) {
              errorMessage = errors['otp'].first;
            } else if (errors['phone'] != null && errors['phone'].isNotEmpty) {
              errorMessage = errors['phone'].first;
            }
            return {
              'success': false,
              'message': errorMessage,
              'statusCode': 422,
              'errors': errors,
            };
          }
        }
      }

      return _handleDioError(e);
    } catch (e, stackTrace) {
      print('💥 خطأ غير متوقع في التحقق:');
      print('   $e');
      print('   $stackTrace');

      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع في التحقق',
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> resendOtp({required String phone}) async {
    try {
      await _initializeDio();

      Response response = await _dio.post(
        '/auth/resend-otp',
        data: {'phone': phone},
      );

      return {
        'success': true,
        'data': response.data,
        'message': response.data['message'] ?? 'تم إرسال رمز التحقق',
      };
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // دالة login يجب أن ترجع بيانات المستخدم
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      print('📡 إرسال طلب تسجيل الدخول: $phone');

      final response = await ApiService().dio.post(
        '/auth/login',
        data: {'phone': phone, 'password': password},
      );

      print('✅ استجابة تسجيل الدخول: ${response.statusCode}');
      print('📦 بيانات الاستجابة: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // تحقق من هيكل الاستجابة
        print('🔍 هيكل استجابة API:');
        print('   - access_token: ${responseData['access_token'] != null}');
        print('   - token: ${responseData['token'] != null}');
        print('   - user: ${responseData['user'] != null}');
        print('   - data: ${responseData['data'] != null}');

        // استخراج التوكن من أماكن مختلفة محتملة
        String? token =
            responseData['access_token'] ??
            responseData['token'] ??
            responseData['data']?['token'];

        // استخراج بيانات المستخدم من أماكن مختلفة محتملة
        Map<String, dynamic>? userData =
            responseData['user'] ??
            responseData['data']?['user'] ??
            responseData['data'];

        if (token == null) {
          print('⚠️ تحذير: لا يوجد توكن في الاستجابة');
        }

        if (userData == null) {
          print('⚠️ تحذير: لا توجد بيانات مستخدم في الاستجابة');

          // إذا لم تكن هناك بيانات مستخدم، جرب الحصول من auth/me
          try {
            print('🔍 محاولة جلب بيانات المستخدم من /auth/me');
            final meResponse = await ApiService().dio.get('/auth/me');
            if (meResponse.statusCode == 200) {
              userData = meResponse.data['data'] ?? meResponse.data;
              print('✅ تم جلب بيانات المستخدم من /auth/me');
            }
          } catch (e) {
            print('❌ فشل جلب بيانات المستخدم من /auth/me: $e');
          }
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'تم تسجيل الدخول بنجاح',
          'token': token,
          'user': userData,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'فشل تسجيل الدخول',
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      print('❌ خطأ في تسجيل الدخول:');
      print('   - الرسالة: ${e.message}');
      print('   - الحالة: ${e.response?.statusCode}');
      print('   - البيانات: ${e.response?.data}');

      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'حدث خطأ في الاتصال',
        'statusCode': e.response?.statusCode ?? 500,
      };
    } catch (e) {
      print('❌ خطأ غير متوقع في تسجيل الدخول: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع',
        'statusCode': 500,
      };
    }
  }

  // جلب بيانات المستخدم الحالي
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      print('👤 جلب بيانات المستخدم الحالي...');
      final response = await ApiService().dio.get('/auth/me');

      if (response.statusCode == 200) {
        print('✅ بيانات المستخدم:');
        print(
          '   - الاسم: ${response.data['data']?['first_name']} ${response.data['data']?['last_name']}',
        );
        print('   - ID: ${response.data['data']?['id']}');
        print('   - الدور: ${response.data['data']?['role']}');

        return {
          'success': true,
          'data': response.data['data'] ?? response.data,
        };
      } else {
        return {'success': false, 'message': 'فشل جلب بيانات المستخدم'};
      }
    } on DioException catch (e) {
      print('❌ خطأ في جلب بيانات المستخدم: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'فشل جلب بيانات المستخدم',
      };
    }
  }

  // تحديث بيانات المستخدم في التخزين
  Future<void> updateStoredUserData() async {
    try {
      final userResult = await getCurrentUser();

      if (userResult['success'] == true && userResult['data'] != null) {
        final storageService = StorageService();
        await storageService.saveUserData(userResult['data']);

        print('✅ تم تحديث بيانات المستخدم في التخزين');
        print('   - ID: ${userResult['data']['id']}');
        print(
          '   - الاسم: ${userResult['data']['first_name']} ${userResult['data']['last_name']}',
        );
      } else {
        print('⚠️ لم يتم تحديث بيانات المستخدم: ${userResult['message']}');
      }
    } catch (e) {
      print('❌ خطأ في تحديث بيانات المستخدم: $e');
    }
  }

  // في auth_service.dart - تحديث دالة _handleDioError
  Map<String, dynamic> _handleDioError(DioException e) {
    String errorMessage = 'Connection error occurred';
    int? statusCode;
    Map<String, dynamic>? errors;

    if (e.response != null) {
      statusCode = e.response!.statusCode;
      final responseData = e.response!.data;

      print('   Status Code: $statusCode');
      print('   Response Data: $responseData');

      if (responseData is Map) {
        // معالجة أخطاء Laravel
        if (responseData.containsKey('errors')) {
          errors = responseData['errors'];
          if (errors != null && errors is Map && errors.isNotEmpty) {
            // الحصول على أول خطأ
            final firstErrorKey = errors.keys.first;
            final firstError = errors[firstErrorKey];
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first;
            }
          }
        } else if (responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
      }

      // رسائل مخصصة لـ status codes
      if (statusCode == 401) {
        errorMessage = 'رقم الهاتف أو كلمة المرور غير صحيحة';
      } else if (statusCode == 403) {
        errorMessage = 'الحساب غير مفعل أو في انتظار الموافقة';
      } else if (statusCode == 404) {
        errorMessage = 'الحساب غير موجود';
      } else if (statusCode == 422) {
        errorMessage = 'بيانات غير صالحة';
      }
    } else {
      // أخطاء الشبكة
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'انتهت مهلة استلام الرد. الخادم يأخذ وقتاً طويلاً';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'انتهت مهلة إرسال البيانات';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'خطأ في الاتصال. لا يمكن الاتصال بالخادم';
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'خطأ في الشهادة. تحقق من إعدادات الخادم';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'رد غير صالح من الخادم';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'تم إلغاء الطلب';
          break;
        default:
          errorMessage = 'خطأ في الشبكة: ${e.message}';
      }
    }

    print('   Final Error Message: $errorMessage');

    return {
      'success': false,
      'message': errorMessage,
      'statusCode': statusCode,
      'errors': errors,
      'dioErrorType': e.type.toString(),
      'error': e.toString(),
    };
  }
}
