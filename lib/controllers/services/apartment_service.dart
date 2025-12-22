// lib/services/apartment_service.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:marsa_app/controllers/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApartmentService {
  final ApiService _apiService = ApiService();
  Dio get _dio => _apiService.dio;

  // جلب جميع الشقق مع الفلاتر
  Future<Map<String, dynamic>> getApartments({
    String? city,
    String? province,
    double? priceMax,
    int? roomsMin,
    int? guestsMin,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      print('🏢 جلب قائمة الشقق...');

      // بناء query parameters
      Map<String, dynamic> queryParams = {'page': page};

      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (province != null && province.isNotEmpty)
        queryParams['province'] = province;
      if (priceMax != null) queryParams['price_max'] = priceMax;
      if (roomsMin != null) queryParams['rooms_min'] = roomsMin;
      if (guestsMin != null) queryParams['guests_min'] = guestsMin;

      Response response = await _dio.get(
        '/apartments',
        queryParameters: queryParams,
      );

      print('✅ تم جلب الشقق: ${response.statusCode}');

      return {
        'success': true,
        'data': response.data,
        'apartments': response.data['data'] ?? [],
        'pagination': {
          'current_page': response.data['current_page'] ?? 1,
          'last_page': response.data['last_page'] ?? 1,
          'total': response.data['total'] ?? 0,
          'per_page': response.data['per_page'] ?? 15,
        },
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ فشل جلب الشقق: ${e.message}');
      return _handleError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع: $e');
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  // جلب تفاصيل شقة معينة
  Future<Map<String, dynamic>> getApartmentDetails(int id) async {
    try {
      print('🔍 جلب تفاصيل الشقة ID: $id');

      Response response = await _dio.get('/apartments/$id');

      print('✅ تم جلب تفاصيل الشقة: ${response.statusCode}');

      return {
        'success': true,
        'data': response.data,
        'apartment': response.data['data'] ?? response.data,
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ فشل جلب تفاصيل الشقة: ${e.message}');
      return _handleError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع: $e');
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  // إضافة شقة جديدة
  Future<Map<String, dynamic>> createApartment({
    required String title,
    required String description,
    required String city,
    required String province,
    required String address,
    required double price,
    required int rooms,
    required int guests,
    required List<String> imagePaths,
    bool isActive = true,
  }) async {
    try {
      print('➕ إضافة شقة جديدة...');

      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'يرجى تسجيل الدخول أولاً'};
      }

      FormData formData = FormData.fromMap({
        'title': title,
        'description': description,
        'city': city,
        'province': province,
        'address': address,
        'price': price,
        'rooms': rooms,
        'guests': guests,
        'is_active': isActive,
      });

      // إضافة الصور
      for (int i = 0; i < imagePaths.length; i++) {
        formData.files.add(
          MapEntry(
            'images[]',
            await MultipartFile.fromFile(
              imagePaths[i],
              filename:
                  'apartment_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
            ),
          ),
        );
      }

      Response response = await _dio.post(
        '/apartments',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ تم إضافة الشقة: ${response.statusCode}');

      return {
        'success': true,
        'data': response.data,
        'message': 'تم إضافة الشقة بنجاح',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ فشل إضافة الشقة: ${e.message}');
      return _handleError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع: $e');
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  // تحديث شقة موجودة
  Future<Map<String, dynamic>> updateApartment({
    required int id,
    String? title,
    String? description,
    String? city,
    String? province,
    String? address,
    double? price,
    int? rooms,
    int? guests,
    bool? isActive,
    List<String>? newImages,
    List<int>? deleteImageIds,
    int? mainImageId,
  }) async {
    try {
      print('✏️ تحديث الشقة ID: $id');

      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'يرجى تسجيل الدخول أولاً'};
      }

      FormData formData = FormData.fromMap({
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (city != null) 'city': city,
        if (province != null) 'province': province,
        if (address != null) 'address': address,
        if (price != null) 'price': price,
        if (rooms != null) 'rooms': rooms,
        if (guests != null) 'guests': guests,
        if (isActive != null) 'is_active': isActive,
        if (deleteImageIds != null) 'delete_images': deleteImageIds,
        if (mainImageId != null) 'main_image': mainImageId,
      });

      // إضافة الصور الجديدة
      if (newImages != null && newImages.isNotEmpty) {
        for (int i = 0; i < newImages.length; i++) {
          formData.files.add(
            MapEntry(
              'images[]',
              await MultipartFile.fromFile(
                newImages[i],
                filename:
                    'apartment_update_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
              ),
            ),
          );
        }
      }

      Response response = await _dio.post(
        '/apartments/$id',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ تم تحديث الشقة: ${response.statusCode}');

      return {
        'success': true,
        'data': response.data,
        'message': 'تم تحديث الشقة بنجاح',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ فشل تحديث الشقة: ${e.message}');
      return _handleError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع: $e');
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  // حذف شقة
  Future<Map<String, dynamic>> deleteApartment(int id) async {
    try {
      print('🗑️ حذف الشقة ID: $id');

      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'يرجى تسجيل الدخول أولاً'};
      }

      Response response = await _dio.delete(
        '/apartments/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ تم حذف الشقة: ${response.statusCode}');

      return {
        'success': true,
        'data': response.data,
        'message': 'تم حذف الشقة بنجاح',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ فشل حذف الشقة: ${e.message}');
      return _handleError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع: $e');
      return {'success': false, 'message': 'حدث خطأ غير متوقع'};
    }
  }

  // جلب التوكن
  Future<String?> _getToken() async {
    try {
      // يمكنك استخدام ProfileService أو SharedPreferences مباشرة
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('❌ خطأ في جلب التوكن: $e');
      return null;
    }
  }

  // معالجة الأخطاء
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
      } else if (statusCode == 403) {
        errorMessage = 'غير مصرح لك بهذا الإجراء';
      } else if (statusCode == 404) {
        errorMessage = 'الشقة غير موجودة';
      } else if (statusCode == 422) {
        errorMessage = 'بيانات غير صالحة';
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
