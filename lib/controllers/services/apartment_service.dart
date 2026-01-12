// lib/services/apartment_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:marsa_app/controllers/services/api_service.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';

class ApartmentService {
  final ApiService _apiService = ApiService();

  // الحصول على قائمة الشقق مع التصفية
  Future<Map<String, dynamic>> getApartments({
    int page = 1,
    int perPage = 15,
    String? city,
    String? province,
    double? priceMax,
    int? roomsMin,
    int? guestsMin,
    String? search,
    String? sortBy,
    String? sortOrder = 'desc',
  }) async {
    try {
      final Map<String, dynamic> params = {'page': page, 'per_page': perPage};

      // إضافة عوامل التصفية كما في Laravel controller
      if (city != null && city.isNotEmpty) params['city'] = city;
      if (province != null && province.isNotEmpty)
        params['province'] = province;
      if (priceMax != null) params['price_max'] = priceMax;
      if (roomsMin != null) params['rooms_min'] = roomsMin;
      if (guestsMin != null) params['guests_min'] = guestsMin;
      if (search != null && search.isNotEmpty) params['search'] = search;

      // إضافة الترتيب إذا كان موجوداً
      if (sortBy != null && sortBy.isNotEmpty) params['sort_by'] = sortBy;
      if (sortOrder != null && sortOrder.isNotEmpty)
        params['sort_order'] = sortOrder;

      print('📡 إرسال طلب لجلب الشقق: $params');

      final response = await _apiService.dio.get(
        '/apartments',
        queryParameters: params,
      );

      print('✅ استجابة جلب الشقق: ${response.statusCode}');
      print('📊 البيانات المستلمة: ${response.data}');

      // تحقق من هيكل الاستجابة
      final responseData = response.data;
      dynamic apartmentsData;

      if (responseData is Map && responseData.containsKey('data')) {
        // إذا كان هناك مفتاح 'data' في الاستجابة
        apartmentsData = responseData['data'];
      } else {
        // خلاف ذلك، استخدم الاستجابة كاملة
        apartmentsData = responseData;
      }

      return {
        'success': true,
        'data': apartmentsData,
        'message': responseData['message'] ?? 'تم جلب الشقق بنجاح',
        'statusCode': response.statusCode,
        'pagination': responseData['meta'] ?? responseData, // بيانات الترقيم
      };
    } on DioException catch (e) {
      print('❌ خطأ Dio في getApartments: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع في getApartments: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع: $e',
        'error': e.toString(),
      };
    }
  }


  // الحصول على تفاصيل شقة معينة
  Future<Map<String, dynamic>> getApartmentDetails(int apartmentId) async {
    try {
      print('📡 جلب تفاصيل الشقة ID: $apartmentId');

      final response = await _apiService.dio.get('/apartments/$apartmentId');

      print('✅ استجابة تفاصيل الشقة: ${response.statusCode}');
      print('📊 البيانات المستلمة: ${response.data}');

      final responseData = response.data;

      // تحقق من هيكل الاستجابة
      dynamic apartmentData;
      if (responseData is Map && responseData.containsKey('data')) {
        apartmentData = responseData['data'];
      } else {
        apartmentData = responseData;
      }

      return {
        'success': true,
        'data': apartmentData,
        'message': responseData['message'] ?? 'تم جلب بيانات الشقة بنجاح',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ خطأ Dio في getApartmentDetails: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع في getApartmentDetails: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع: $e',
        'error': e.toString(),
      };
    }
  }

  // إنشاء شقة جديدة - تم التعديل لمطابقة Laravel API
  Future<Map<String, dynamic>> createApartment({
    required String title,
    required String description,
    required String city,
    required String province,
    required String address,
    required double price,
    required int rooms,
    required int guests,
    required List<File> images,
    bool isActive = true,
  }) async {
    try {
      print('📡 إنشاء شقة جديدة: $title');
      print('📍 الموقع: $city, $province');
      print('💰 السعر: $price');
      print('🛏️ الغرف: $rooms');
      print('👥 الضيوف: $guests');
      print('🖼️ عدد الصور: ${images.length}');

      final formData = FormData();

      // إضافة البيانات النصية - بنفس أسماء الحقول في Laravel
      formData.fields.addAll([
        MapEntry('title', title),
        MapEntry('description', description),
        MapEntry('city', city),
        MapEntry('province', province),
        MapEntry('address', address),
        MapEntry('price', price.toString()),
        MapEntry('rooms', rooms.toString()),
        MapEntry('guests', guests.toString()),
        MapEntry('is_active', isActive ? '1' : '0'),
      ]);

      // إضافة الصور - يجب أن تكون باسم 'images[]' كما في Laravel
      for (var i = 0; i < images.length; i++) {
        final file = images[i];
        if (await file.exists()) {
          formData.files.add(
            MapEntry(
              'images[]', // استخدام [] لنقل مصفوفة من الصور
              await MultipartFile.fromFile(
                file.path,
                filename:
                    'apartment_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
              ),
            ),
          );
          print('➕ إضافة صورة [$i]: ${file.path}');
        } else {
          print('⚠️ الملف غير موجود: ${file.path}');
        }
      }

      // إرسال الطلب
      final response = await _apiService.dio.post(
        '/apartments',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      print('✅ تم إنشاء الشقة بنجاح: ${response.statusCode}');
      print('📊 استجابة الخادم: ${response.data}');

      final responseData = response.data;
      dynamic apartmentData;

      if (responseData is Map && responseData.containsKey('data')) {
        apartmentData = responseData['data'];
      } else {
        apartmentData = responseData;
      }

      return {
        'success': true,
        'data': apartmentData,
        'message': responseData['message'] ?? 'تم إنشاء الشقة بنجاح',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ خطأ Dio في createApartment: ${e.message}');
      if (e.response != null) {
        print('📄 تفاصيل الخطأ: ${e.response!.data}');
      }
      return _handleDioError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع في createApartment: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع: $e',
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateApartment({
    required int apartmentId,
    String? title,
    String? description,
    String? city,
    String? province,
    String? address,
    double? price,
    int? rooms,
    int? guests,
    bool? isActive,
    List<File>? newImages,
    List<int>? deleteImages,
    int? mainImageId,
  }) async {
    try {
      print('📡 تحديث الشقة ID: $apartmentId');

      final formData = FormData();

      final Map<String, dynamic> updates = {};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (city != null) updates['city'] = city;
      if (province != null) updates['province'] = province;
      if (address != null) updates['address'] = address;
      if (price != null) updates['price'] = price.toString();
      if (rooms != null) updates['rooms'] = rooms.toString();
      if (guests != null) updates['guests'] = guests.toString();
      if (isActive != null) updates['is_active'] = isActive ? '1' : '0';

      // إضافة الحقول
      for (final entry in updates.entries) {
        formData.fields.add(MapEntry(entry.key, entry.value));
      }

      // إضافة الصور الجديدة
      if (newImages != null && newImages.isNotEmpty) {
        for (var i = 0; i < newImages.length; i++) {
          final file = newImages[i];
          if (await file.exists()) {
            formData.files.add(
              MapEntry(
                'images[]',
                await MultipartFile.fromFile(
                  file.path,
                  filename:
                      'apartment_update_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
                ),
              ),
            );
            print('➕ إضافة صورة جديدة [$i]: ${file.path}');
          }
        }
      }

      // إضافة الصور للحذف
      if (deleteImages != null && deleteImages.isNotEmpty) {
        for (var i = 0; i < deleteImages.length; i++) {
          formData.fields.add(
            MapEntry('delete_images[]', deleteImages[i].toString()),
          );
          print('🗑️ حذف صورة ID: ${deleteImages[i]}');
        }
      }

      // تحديد الصورة الرئيسية
      if (mainImageId != null) {
        formData.fields.add(MapEntry('main_image', mainImageId.toString()));
        print('⭐ تعيين الصورة الرئيسية ID: $mainImageId');
      }

      // إضافة _method لـ Laravel لاستخدام PUT
      formData.fields.add(const MapEntry('_method', 'PUT'));

      // إرسال الطلب باستخدام POST مع _method=PUT
      final response = await _apiService.dio.post(
        '/apartments/$apartmentId',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      print('✅ تم تحديث الشقة بنجاح: ${response.statusCode}');
      print('📊 استجابة الخادم: ${response.data}');

      final responseData = response.data;
      dynamic apartmentData;

      if (responseData is Map && responseData.containsKey('data')) {
        apartmentData = responseData['data'];
      } else {
        apartmentData = responseData;
      }

      return {
        'success': true,
        'data': apartmentData,
        'message': responseData['message'] ?? 'تم تحديث الشقة بنجاح',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ خطأ Dio في updateApartment: ${e.message}');
      if (e.response != null) {
        print('📄 تفاصيل الخطأ: ${e.response!.data}');
      }
      return _handleDioError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع في updateApartment: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع: $e',
        'error': e.toString(),
      };
    }
  }

  // حذف شقة
  Future<Map<String, dynamic>> deleteApartment(int apartmentId) async {
    try {
      print('📡 حذف الشقة ID: $apartmentId');

      final response = await _apiService.dio.delete('/apartments/$apartmentId');

      print('✅ تم حذف الشقة بنجاح: ${response.statusCode}');
      print('📊 استجابة الخادم: ${response.data}');

      final responseData = response.data;

      return {
        'success': true,
        'data': responseData,
        'message': responseData['message'] ?? 'تم حذف الشقة بنجاح',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ خطأ Dio في deleteApartment: ${e.message}');
      return _handleDioError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع في deleteApartment: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع: $e',
        'error': e.toString(),
      };
    }
  }

  // جلب شقات المالك فقط
  Future<Map<String, dynamic>> getOwnerApartments({
    int page = 1,
    int perPage = 15,
    String? city,
    String? province,
    double? priceMax,
    int? roomsMin,
    int? guestsMin,
    String? search,
    String? sortBy,
    String? sortOrder = 'desc',
  }) async {
    try {
      print('🏠 جلب شقات المالك...');

      final Map<String, dynamic> params = {'page': page, 'per_page': perPage};

      if (city != null && city.isNotEmpty) params['city'] = city;
      if (province != null && province.isNotEmpty)
        params['province'] = province;
      if (priceMax != null) params['price_max'] = priceMax;
      if (roomsMin != null) params['rooms_min'] = roomsMin;
      if (guestsMin != null) params['guests_min'] = guestsMin;
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (sortBy != null && sortBy.isNotEmpty) params['sort_by'] = sortBy;
      if (sortOrder != null && sortOrder.isNotEmpty)
        params['sort_order'] = sortOrder;

      print('📡 معاملات البحث: $params');

      // محاولة استخدام endpoint مختلف
      String endpoint;
      bool ownerSpecific = false;

      try {
        // الخيار 1: endpoint خاص بالمستخدم
        endpoint = '/user/apartments';
        print('🔍 محاولة استخدام: $endpoint');
        ownerSpecific = true;
      } catch (e) {
        // الخيار 2: endpoint عام مع معامل owner
        endpoint = '/apartments';
        print('⚠️ استخدام endpoint عام: $endpoint');
        params['owner'] = 'me'; // أو 'my'
      }

      final response = await _apiService.dio.get(
        endpoint,
        queryParameters: params,
      );

      print('✅ استجابة شقات المالك: ${response.statusCode}');

      final responseData = response.data;

      return {
        'success': true,
        'data': responseData,
        'ownerSpecific': ownerSpecific,
        'message': responseData['message'] ?? 'تم جلب شقات المالك بنجاح',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      print('❌ خطأ Dio في getOwnerApartments: ${e.message}');

      // إذا كان الخطأ 404، جرب endpoint مختلف
      if (e.response?.statusCode == 404) {
        print('🔄 جرب endpoint مختلف...');
        return await _getOwnerApartmentsFallback(
          page: page,
          perPage: perPage,
          city: city,
          province: province,
          priceMax: priceMax,
          roomsMin: roomsMin,
          guestsMin: guestsMin,
          search: search,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );
      }

      return _handleDioError(e);
    } catch (e) {
      print('💥 خطأ غير متوقع في getOwnerApartments: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع: $e',
        'error': e.toString(),
        'ownerSpecific': false,
      };
    }
  }

  // دالة بديلة لجلب شقات المالك
  Future<Map<String, dynamic>> _getOwnerApartmentsFallback({
    int page = 1,
    int perPage = 15,
    String? city,
    String? province,
    double? priceMax,
    int? roomsMin,
    int? guestsMin,
    String? search,
    String? sortBy,
    String? sortOrder = 'desc',
  }) async {
    try {
      print('🔄 استخدام الطريقة البديلة لجلب شقات المالك...');

      // جلب جميع الشقات ثم التصفية محلياً
      final allApartmentsResult = await getApartments(
        page: page,
        perPage: perPage,
        city: city,
        province: province,
        priceMax: priceMax,
        roomsMin: roomsMin,
        guestsMin: guestsMin,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (allApartmentsResult['success'] == true) {
        return {
          'success': true,
          'data': allApartmentsResult['data'],
          'ownerSpecific': false, // تمت التصفية محلياً
          'message': 'تم جلب الشقات بنجاح (تصفية محلية)',
          'statusCode': 200,
        };
      } else {
        return allApartmentsResult;
      }
    } catch (e) {
      print('💥 خطأ في الطريقة البديلة: $e');
      return {
        'success': false,
        'message': 'فشل جلب شقات المالك',
        'error': e.toString(),
        'ownerSpecific': false,
      };
    }
  }
  // الحصول على شقق المالك
  // Future<Map<String, dynamic>> getOwnerApartments({
  //   int page = 1,
  //   int perPage = 15,
  // }) async {
  //   try {
  //     print('📡 جلب شقق المالك');

  //     final response = await _apiService.dio.get(
  //       '/owner/apartments', // تأكد من هذا الـ endpoint في Laravel
  //       queryParameters: {'page': page, 'per_page': perPage},
  //     );

  //     print('✅ استجابة شقق المالك: ${response.statusCode}');

  //     final responseData = response.data;
  //     dynamic apartmentsData;

  //     if (responseData is Map && responseData.containsKey('data')) {
  //       apartmentsData = responseData['data'];
  //     } else {
  //       apartmentsData = responseData;
  //     }

  //     return {
  //       'success': true,
  //       'data': apartmentsData,
  //       'message': responseData['message'] ?? 'تم جلب شقق المالك بنجاح',
  //       'statusCode': response.statusCode,
  //     };
  //   } on DioException catch (e) {
  //     print('❌ خطأ Dio في getOwnerApartments: ${e.message}');
  //     return _handleDioError(e);
  //   } catch (e) {
  //     print('💥 خطأ غير متوقع في getOwnerApartments: $e');
  //     return {
  //       'success': false,
  //       'message': 'حدث خطأ غير متوقع: $e',
  //       'error': e.toString(),
  //     };
  //   }
  // }

  // الحصول على المدن المتاحة (طريقة بديلة)
  Future<List<String>> getAvailableCities() async {
    try {
      final response = await _apiService.dio.get(
        '/apartments/cities', // تأكد من وجود هذا الـ endpoint في Laravel
      );

      final responseData = response.data;
      List<String> cities = [];

      if (responseData is Map && responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is List) {
          cities = data.map((city) => city.toString()).toList();
        }
      } else if (responseData is List) {
        cities = responseData.map((city) => city.toString()).toList();
      }

      print('🏙️ المدن المتاحة: $cities');
      return cities;
    } catch (e) {
      print('⚠️ خطأ في getAvailableCities: $e');
      return [];
    }
  }

  // الحصول على المحافظات المتاحة (طريقة بديلة)
  Future<List<String>> getAvailableProvinces() async {
    try {
      final response = await _apiService.dio.get(
        '/apartments/provinces', // تأكد من وجود هذا الـ endpoint في Laravel
      );

      final responseData = response.data;
      List<String> provinces = [];

      if (responseData is Map && responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is List) {
          provinces = data.map((province) => province.toString()).toList();
        }
      } else if (responseData is List) {
        provinces = responseData
            .map((province) => province.toString())
            .toList();
      }

      print('📍 المحافظات المتاحة: $provinces');
      return provinces;
    } catch (e) {
      print('⚠️ خطأ في getAvailableProvinces: $e');
      return [];
    }
  }

  // الحصول على المحافظات بناءً على المدينة
  Future<List<String>> getProvincesByCity(String city) async {
    try {
      final response = await _apiService.dio.get(
        '/apartments/provinces/$city', // تأكد من وجود هذا الـ endpoint في Laravel
      );

      final responseData = response.data;
      List<String> provinces = [];

      if (responseData is Map && responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is List) {
          provinces = data.map((province) => province.toString()).toList();
        }
      } else if (responseData is List) {
        provinces = responseData
            .map((province) => province.toString())
            .toList();
      }

      print('📍 المحافظات لمدينة $city: $provinces');
      return provinces;
    } catch (e) {
      print('⚠️ خطأ في getProvincesByCity: $e');

      // بديل: الحصول من جميع الشقق
      try {
        final allApartments = await getApartments(city: city);
        if (allApartments['success'] == true) {
          final data = allApartments['data'];
          if (data is Map && data.containsKey('data')) {
            final apartments = data['data'] as List;
            final provincesSet = <String>{};
            for (var apt in apartments) {
              if (apt['province'] != null) {
                provincesSet.add(apt['province'].toString());
              }
            }
            return provincesSet.toList();
          }
        }
      } catch (_) {
        // تجاهل الخطأ
      }

      return [];
    }
  }

  // معالجة أخطاء Dio - محسنة
  Map<String, dynamic> _handleDioError(DioException e) {
    String errorMessage = 'حدث خطأ في الاتصال';
    int? statusCode;
    dynamic errorData;
    Map<String, dynamic>? errors;

    if (e.response != null) {
      statusCode = e.response!.statusCode;
      errorData = e.response!.data;

      print('📊 معلومات الخطأ من الخادم:');
      print('   📍 Status Code: $statusCode');
      print('   📄 Response Data: $errorData');
      print('   🔗 URL: ${e.requestOptions.uri}');
      print('   📝 Method: ${e.requestOptions.method}');

      // محاولة استخراج رسالة الخطأ
      if (errorData is Map<String, dynamic>) {
        // Laravel Validation Errors
        if (errorData.containsKey('errors')) {
          errors = errorData['errors'] as Map<String, dynamic>;

          // الحصول على أول خطأ
          if (errors.isNotEmpty) {
            final firstErrorKey = errors.keys.first;
            final firstErrorList = errors[firstErrorKey];
            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              errorMessage = firstErrorList.first.toString();
            } else if (firstErrorList is String) {
              errorMessage = firstErrorList;
            }
          }
        }

        // Laravel API Response
        if (errorData.containsKey('message')) {
          final message = errorData['message'];
          if (message is String) {
            errorMessage = message;
          } else if (message is List && message.isNotEmpty) {
            errorMessage = message.first.toString();
          }
        }
      } else if (errorData is String) {
        try {
          final jsonError = json.decode(errorData);
          if (jsonError is Map && jsonError.containsKey('message')) {
            errorMessage = jsonError['message'].toString();
          } else {
            errorMessage = errorData;
          }
        } catch (_) {
          errorMessage = errorData;
        }
      }

      // معالجة الأخطاء الشائعة
      switch (statusCode) {
        case 400:
          errorMessage = errorMessage.contains('Bad Request')
              ? 'طلب غير صالح'
              : errorMessage;
          break;
        case 401:
          errorMessage = 'غير مصرح. يرجى تسجيل الدخول';
          break;
        case 403:
          errorMessage = 'ممنوع الوصول. ليس لديك الصلاحية';
          break;
        case 404:
          errorMessage = 'لم يتم العثور على المورد';
          break;
        case 422:
          errorMessage = 'بيانات غير صالحة: $errorMessage';
          break;
        case 500:
          errorMessage = 'خطأ في الخادم الداخلي';
          break;
        case 502:
          errorMessage = 'خطأ في البوابة';
          break;
        case 503:
          errorMessage = 'الخدمة غير متوفرة حاليًا';
          break;
        case 504:
          errorMessage = 'انتهت مهلة البوابة';
          break;
      }
    } else {
      // أخطاء الشبكة
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'انتهت مهلة الاتصال بالخادم';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'انتهت مهلة استلام البيانات';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'انتهت مهلة إرسال البيانات';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'تعذر الاتصال بالخادم. تأكد من اتصال الإنترنت';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'تم إلغاء الطلب';
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'شهادة غير صالحة';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'استجابة غير صالحة من الخادم';
          break;
        case DioExceptionType.unknown:
          errorMessage = 'خطأ غير معروف: ${e.error}';
          break;
      }
    }

    print('❌ رسالة الخطأ النهائية: $errorMessage');

    return {
      'success': false,
      'message': errorMessage,
      'statusCode': statusCode,
      'error': e.error?.toString(),
      'errors': errors,
      'data': errorData,
      'dioErrorType': e.type.toString(),
    };
  }

  // دالة مساعدة لتحويل الملفات إلى MultipartFile
  Future<MultipartFile> _fileToMultipart(File file, String fieldName) async {
    return await MultipartFile.fromFile(
      file.path,
      filename: '${fieldName}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }
}
