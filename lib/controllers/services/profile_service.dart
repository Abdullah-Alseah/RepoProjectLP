/// lib/services/profile_service.dart
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:marsa_app/controllers/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  // استخدام Singleton pattern لضمان وجود نسخة واحدة فقط
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;

  final ApiService _apiService = ApiService();
  late Dio _dio;
  SharedPreferences? _prefs;
  Completer<void>? _initCompleter;
  bool _isInitializing = false;
  bool get isInitialized => _prefs != null;

  ProfileService._internal() {
    _dio = _apiService.dio;
    _lazyInit();
  }

  /// تهيئة متأخرة عند أول استخدام
  void _lazyInit() {
  }

  Future<void> _ensurePrefsInitialized() async {
    // إذا كانت مُهيأة بالفعل، لا تفعل شيئاً
    if (_prefs != null) return;

    // إذا كان هناك عملية تهيئة جارية، انتظرها
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    // بدء عملية تهيئة جديدة
    _initCompleter = Completer<void>();
    _isInitializing = true;

    try {
      print('🔧 تهيئة SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      print('✅ تم تهيئة SharedPreferences بنجاح');
      _initCompleter!.complete();
    } catch (e) {
      print('❌ فشل تهيئة SharedPreferences: $e');
      _initCompleter!.completeError(e);
    } finally {
      _isInitializing = false;
      _initCompleter = null;
    }
  }

  /// Getter آمن للوصول إلى SharedPreferences
  Future<SharedPreferences> get _sharedPrefs async {
    await _ensurePrefsInitialized();
    return _prefs!;
  }

  /// جلب بيانات المستخدم من API
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      print('👤 جلب بيانات المستخدم...');

      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'يرجى تسجيل الدخول أولاً',
          'statusCode': 401,
        };
      }

      Response response = await _dio.get(
        '/auth/user',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ تم جلب البيانات: ${response.statusCode}');

      // حفظ البيانات محلياً
      if (response.data != null) {
        await _saveUserData(response.data);
      }

      return {
        'success': true,
        'data': response.data,
        'message': 'تم جلب البيانات بنجاح',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ فشل جلب البيانات: ${e.message}');
      return _handleError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع: $e');
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  /// تحديث بيانات المستخدم
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    File? avatarImage,
    File? idDocumentImage,
    DateTime? dateOfBirth,
    String? mode,
    String? dir,
  }) async {
    try {
      print('🔄 تحديث بيانات المستخدم...');

      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'يرجى تسجيل الدخول أولاً'};
      }

      FormData formData = FormData.fromMap({
        if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
        if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
        if (dateOfBirth != null)
          'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
        if (mode != null && mode.isNotEmpty) 'mode': mode,
        if (dir != null && dir.isNotEmpty) 'dir': dir,
      });

      // إضافة صورة الملف الشخصي
      if (avatarImage != null) {
        final extension = avatarImage.path.split('.').last;
        formData.files.add(
          MapEntry(
            'avatar_url',
            await MultipartFile.fromFile(
              avatarImage.path,
              filename:
                  'avatar_${DateTime.now().millisecondsSinceEpoch}.$extension',
            ),
          ),
        );
      }

      // إضافة صورة الهوية
      if (idDocumentImage != null) {
        final extension = idDocumentImage.path.split('.').last;
        formData.files.add(
          MapEntry(
            'id_document_url',
            await MultipartFile.fromFile(
              idDocumentImage.path,
              filename:
                  'id_document_${DateTime.now().millisecondsSinceEpoch}.$extension',
            ),
          ),
        );
      }

      Response response = await _dio.post(
        '/auth/update-user-info',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ تم التحديث: ${response.statusCode}');

      // تحديث البيانات المحلية
      if (response.data != null) {
        await _saveUserData(response.data);
      }

      return {
        'success': true,
        'data': response.data,
        'message': 'تم تحديث البيانات بنجاح',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ فشل التحديث: ${e.message}');
      return _handleError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع: $e');
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  /// تغيير كلمة المرور
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      print('🔐 تغيير كلمة المرور...');

      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'يرجى تسجيل الدخول أولاً'};
      }

      Response response = await _dio.post(
        '/auth/new-password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ تم تغيير كلمة المرور: ${response.statusCode}');

      return {
        'success': true,
        'data': response.data,
        'message': 'تم تغيير كلمة المرور بنجاح',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ فشل تغيير كلمة المرور: ${e.message}');
      return _handleError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع: $e');
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  /// تسجيل الخروج
  Future<Map<String, dynamic>> logout() async {
    try {
      print('🚪 تسجيل الخروج...');

      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'لا يوجد جلسة نشطة'};
      }

      Response response = await _dio.post(
        '/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ تم تسجيل الخروج: ${response.statusCode}');

      // مسح جميع البيانات المحلية
      await clearUserData();
      await clearToken();

      return {
        'success': true,
        'data': response.data,
        'message': 'تم تسجيل الخروج بنجاح',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ فشل تسجيل الخروج: ${e.message}');

      // حتى إذا فشل API، نظف البيانات المحلية
      await clearUserData();
      await clearToken();

      return _handleError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع: $e');

      await clearUserData();
      await clearToken();

      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  // === دوال مساعدة للتخزين المحلي ===

  /// حفظ بيانات المستخدم في SharedPreferences
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await _sharedPrefs;
    await prefs.setString('user_data', jsonEncode(userData));
    await prefs.setString('user_first_name', userData['first_name'] ?? '');
    await prefs.setString('user_last_name', userData['last_name'] ?? '');
    await prefs.setString('user_phone', userData['phone'] ?? '');
    await prefs.setString('user_avatar', userData['avatar_url'] ?? '');
    await prefs.setString('user_created_at', userData['created_at'] ?? '');
    await prefs.setString('user_role', userData['role'] ?? '');
  }

  /// جلب البيانات المخزنة محلياً
  Future<Map<String, dynamic>?> getCachedUserData() async {
    try {
      final prefs = await _sharedPrefs;
      final userDataString = prefs.getString('user_data');
      if (userDataString != null && userDataString.isNotEmpty) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (e) {
      print('❌ خطأ في جلب البيانات المخزنة: $e');
      return null;
    }
  }

  /// جلب الاسم الأول
  Future<String?> getFirstName() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString('user_first_name');
    } catch (e) {
      print('❌ خطأ في جلب الاسم الأول: $e');
      return null;
    }
  }

  /// جلب الاسم الأخير
  Future<String?> getLastName() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString('user_last_name');
    } catch (e) {
      print('❌ خطأ في جلب الاسم الأخير: $e');
      return null;
    }
  }

  /// جلب رقم الهاتف
  Future<String?> getPhone() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString('user_phone');
    } catch (e) {
      print('❌ خطأ في جلب رقم الهاتف: $e');
      return null;
    }
  }

  /// جلب رابط الصورة الشخصية
  Future<String?> getAvatarUrl() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString('user_avatar');
    } catch (e) {
      print('❌ خطأ في جلب رابط الصورة: $e');
      return null;
    }
  }

  /// جلب تاريخ الإنشاء
  Future<String?> getCreatedAt() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString('user_created_at');
    } catch (e) {
      print('❌ خطأ في جلب تاريخ الإنشاء: $e');
      return null;
    }
  }

    //// جلب حالة تسجيل الدخول 
Future<bool> checkLoginStatus() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('❌ خطأ في التحقق من حالة تسجيل الدخول: $e');
      return false;
    }
  }
  /// جلب الدور
  Future<String?> getRole() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString('user_role');
    } catch (e) {
      print('❌ خطأ في جلب الدور: $e');
      return null;
    }
  }

  /// مسح جميع بيانات المستخدم المحلية
  Future<void> clearUserData() async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.remove('user_data');
      await prefs.remove('user_first_name');
      await prefs.remove('user_last_name');
      await prefs.remove('user_phone');
      await prefs.remove('user_avatar');
      await prefs.remove('user_created_at');
      await prefs.remove('user_role');
    } catch (e) {
      print('❌ خطأ في مسح البيانات المحلية: $e');
    }
  }

  // إدارة الـ token

  /// حفظ التوكن
  Future<void> saveToken(String token) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setString('auth_token', token);
      // تحديث headers في Dio
      _dio.options.headers['Authorization'] = 'Bearer $token';
      print('✅ تم حفظ التوكن');
    } catch (e) {
      print('❌ خطأ في حفظ التوكن: $e');
    }
  }

  /// جلب التوكن
  Future<String?> getToken() async {
    try {
      final prefs = await _sharedPrefs;
      final token = prefs.getString('auth_token');
      return token;
    } catch (e) {
      print('❌ خطأ في جلب التوكن: $e');
      return null;
    }
  }

  /// مسح التوكن
  Future<void> clearToken() async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.remove('auth_token');
      // إزالة header من Dio
      _dio.options.headers.remove('Authorization');
      print('✅ تم مسح التوكن');
    } catch (e) {
      print('❌ خطأ في مسح التوكن: $e');
    }
  }

  /// التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('❌ خطأ في التحقق من تسجيل الدخول: $e');
      return false;
    }
  }

  /// تهيئة الخدمة (للاستدعاء الخارجي إذا لزم الأمر)
  Future<void> initialize() async {
    await _ensurePrefsInitialized();
  }

  /// معالجة الأخطاء
  Map<String, dynamic> _handleError(DioException e) {
    String errorMessage = 'حدث خطأ في الاتصال';
    int? statusCode;

    if (e.response != null) {
      statusCode = e.response!.statusCode;
      final responseData = e.response!.data;

      if (responseData is Map) {
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else if (responseData.containsKey('errors')) {
          final errors = responseData['errors'];
          if (errors != null && errors is Map && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first;
            }
          }
        }
      }

      if (statusCode == 401) {
        errorMessage = 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى';
        // تنظيف البيانات المحلية بشكل غير متزامن
        Future.microtask(() {
          clearUserData();
          clearToken();
        });
      } else if (statusCode == 422) {
        errorMessage = 'بيانات غير صالحة';
      } else if (statusCode == 403) {
        errorMessage = 'غير مصرح لك بهذا الإجراء';
      }
    } else {
      if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'لا يمكن الاتصال بالخادم. تحقق من اتصالك بالإنترنت';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'انتهت مهلة الاتصال';
      }
    }

    return {
      'success': false,
      'message': errorMessage,
      'statusCode': statusCode,
      'dioErrorType': e.type.toString(),
    };
  }
}
