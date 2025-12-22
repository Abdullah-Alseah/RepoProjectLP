// lib/services/api_service.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

class ApiService {
  static String baseUrl = 'http://192.168.1.15:8000/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  bool _isInitialized = false;
  Completer<void>? _initCompleter;

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

    // إضافة LogInterceptor فقط
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

  /// الحصول على Dio (غير متزامن للتحقق من التهيئة)
  Dio get dio {
    if (!_isInitialized) {
      initialize();
    }
    return _dio;
  }

  /// تهيئة Dio بشكل غير متزامن (للاستخدام إذا لزم الأمر)
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;

    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();
    initialize();
    _initCompleter!.complete();
    _initCompleter = null;
  }

  // إعداد التوكن للمصادقة
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  // تغيير الـ baseUrl
  void updateBaseUrl(String newUrl) {
    baseUrl = newUrl;
    dio.options.baseUrl = baseUrl;
    print('🔄 Base URL updated to: $baseUrl');
  }

  // اختبار الاتصال
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
