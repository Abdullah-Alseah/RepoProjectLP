// lib/controllers/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/controllers/services/test_connection.dart';

class ApiService {
  static String baseUrl = 'http://${Configuration.baseUrl}:8000/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  bool _isInitialized = false;
  final StorageService _storageService = StorageService();

  /// تهيئة الـ Dio (متزامن)
  void initialize() {
    if (_isInitialized) return;

    print('🚀 Initializing ApiService with: $baseUrl');

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // إضافة Interceptor للتعامل مع المصادقة
    _setupInterceptors();

    // إضافة LogInterceptor
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    _isInitialized = true;
    print('✅ ApiService initialized successfully');
  }

  /// إعداد الـ Interceptors
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // إضافة التوكن تلقائياً لكل طلب
          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🔐 تم إضافة التوكن إلى الطلب');

            // إضافة معرف المستخدم في الهيدر إذا لزم الأمر
            final userId = await _storageService.getUserId();
            if (userId > 0) {
              options.headers['X-User-Id'] = userId.toString();
            }
          } else {
            print('⚠️ لا يوجد توكن متاح للطلب');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ Response ${response.statusCode}: ${response.requestOptions.path}',
          );

          // حفظ بيانات المستخدم من الاستجابة إذا كانت موجودة
          if (response.data != null &&
              response.data['user'] != null &&
              response.requestOptions.path.contains('/auth/')) {
            _storageService.saveUserData(response.data['user']);
          }

          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          print(
            '❌ Dio Error: ${error.response?.statusCode} - ${error.response?.data}',
          );

          // إذا كان الخطأ 401 (غير مصرح)
          if (error.response?.statusCode == 401) {
            print('🔒 تم رفض الطلب (401). تحقق من صلاحية التوكن');

            // حذف التوكن القديم
            await _storageService.clearUserData();

            // إعادة التوجيه لصفحة تسجيل الدخول إذا كان في سياق واجهة
            if (Get.isDialogOpen == false) {
              Get.offAllNamed('/login');
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// الحصول على Dio
  Dio get dio {
    if (!_isInitialized) {
      initialize();
    }
    return _dio;
  }

Future<Map<String, dynamic>> getLastBooking(int apartmentId) async {
    try {
      final response = await dio.get(
        '/bookings',
        queryParameters: {
          'apartment_id': apartmentId,
          'status': 'confirmed', 
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  /// التحقق من الاتصال
  Future<bool> testConnection() async {
    try {
      final response = await dio.get('/');
      print('✅ Server connection test: ${response.statusCode}');
      return true;
    } catch (e) {
      print('❌ Server connection failed: $e');
      return false;
    }
  }
}
