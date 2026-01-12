import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marsa_app/controllers/services/api_service.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/models/apartment_model.dart';

class FavoriteStore extends GetxController {
  static final FavoriteStore instance = FavoriteStore._internal();
  factory FavoriteStore() => instance;
  FavoriteStore._internal();

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // تخزين ID الشقق المفضلة بشكل دائم
  final RxSet<int> _favoriteIds = <int>{}.obs;
  final RxList<Apartment> _favoriteApartments = <Apartment>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  List<Apartment> get favorites => _favoriteApartments.toList();
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  // 🔑 مفتاح التخزين المحلي
  static const String _favoriteIdsKey = 'favorite_ids';

  @override
  void onInit() {
    super.onInit();
    _loadFavoriteIds();
  }

  // تحميل ID المفضلة من التخزين المحلي
  Future<void> _loadFavoriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_favoriteIdsKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> idsList = json.decode(jsonString);
        _favoriteIds.addAll(
          idsList.map((id) => int.parse(id.toString())).toSet(),
        );
        print('📦 تم تحميل ${_favoriteIds.length} مفضلة من التخزين المحلي');
      }
    } catch (e) {
      print('⚠️ خطأ في تحميل المفضلة المحلية: $e');
    }
  }

  // حفظ ID المفضلة في التخزين المحلي
  Future<void> _saveFavoriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_favoriteIds.toList());
      await prefs.setString(_favoriteIdsKey, jsonString);
      print('💾 تم حفظ ${_favoriteIds.length} مفضلة في التخزين المحلي');
    } catch (e) {
      print('⚠️ خطأ في حفظ المفضلة المحلية: $e');
    }
  }

  // التحقق من حالة المفضلة لشقة معينة
  bool isFavorite(int apartmentId) {
    return _favoriteIds.contains(apartmentId);
  }

  // الحصول على جميع ID المفضلة
  Set<int> get favoriteIds => _favoriteIds.toSet();

  // جلب جميع المفضلة من السيرفر
  Future<void> getFavorites() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      print('⭐ جلب الشقق المفضلة من السيرفر...');

      final response = await _apiService.dio.get('/favorites');

      if (response.statusCode == 200) {
        final List<dynamic> apartmentsData =
            response.data['data']['data'] ?? [];

        // تحديث قائمة الشقق
        _favoriteApartments.value = apartmentsData.map((json) {
          return Apartment.fromJson(json);
        }).toList();

        // تحديث مجموعة ID المفضلة
        final newIds = _favoriteApartments.map((a) => a.id).toSet();
        _favoriteIds.clear();
        _favoriteIds.addAll(newIds);

        // حفظ في التخزين المحلي
        await _saveFavoriteIds();

        print('✅ تم جلب ${_favoriteApartments.length} شقة مفضلة من السيرفر');
      } else {
        throw Exception('فشل في جلب المفضلة');
      }
    } on DioException catch (e) {
      print('❌ خطأ في جلب المفضلة: ${e.message}');
      if (e.response?.statusCode == 401) {
        _error.value = 'انتهت صلاحية الجلسة';
      } else {
        _error.value = e.response?.data?['message'] ?? e.message ?? 'حدث خطأ';
      }
      rethrow;
    } catch (e) {
      print('❌ خطأ في جلب المفضلة: $e');
      _error.value = e.toString();
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  // إضافة إلى المفضلة
  Future<bool> addToFavorite(int apartmentId) async {
    try {
      print('⭐ إضافة الشقة #$apartmentId إلى المفضلة...');

      final response = await _apiService.dio.post('/favorites/$apartmentId');

      if (response.statusCode == 201) {
        // تحديث الحالة المحلية فوراً
        _favoriteIds.add(apartmentId);
        await _saveFavoriteIds();

        // إضافة الشقة إلى القائمة إذا لم تكن موجودة
        final apartment = Apartment.fromJson(response.data['data']);
        if (!_favoriteApartments.any((a) => a.id == apartmentId)) {
          _favoriteApartments.add(apartment);
        }

        // إشعار تحديث للـ UI
        update();

        print('✅ تم إضافة الشقة #$apartmentId إلى المفضلة');
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('❌ خطأ في إضافة المفضلة: ${e.message}');

      if (e.response?.statusCode == 409) {
        // إذا كانت موجودة بالفعل، نحدّث الحالة المحلية
        _favoriteIds.add(apartmentId);
        await _saveFavoriteIds();
        update();
      }

      throw e;
    } catch (e) {
      print('❌ خطأ في إضافة المفضلة: $e');
      throw e;
    }
  }

  // إزالة من المفضلة
  Future<bool> removeFromFavorite(int apartmentId) async {
    try {
      print('🗑️ إزالة الشقة #$apartmentId من المفضلة...');

      // 🔒 حفظ الإشارة للعنصر قبل الإزالة
      final apartmentToRemove = _favoriteApartments.firstWhere(
        (a) => a.id == apartmentId,
        orElse: () => Apartment(
          id: 0,
          title: '',
          description: '',
          city: '',
          province: '',
          address: '',
          price: 0,
          rooms: 0,
          guests: 0,
          isActive: true,
          images: [],
          owner: Owner(
            id: 0,
            name: '',
            email: '',
            phone: '',
            role: '',
            isApproved: true,
            avatarUrl: '',
            idDocumentUrl: '',
          ),
          reviews: [],
        ),
      );

      final response = await _apiService.dio.delete('/favorites/$apartmentId');

      if (response.statusCode == 200) {
        // ⏳ تأخير تحديث الـ UI قليلاً لمنع مشاكل التزامن
        await Future.delayed(const Duration(milliseconds: 50));

        // تحديث الحالة المحلية
        _favoriteIds.remove(apartmentId);

        // إزالة الشقة من القائمة بأمان
        _favoriteApartments.removeWhere((a) => a.id == apartmentId);

        // حفظ في التخزين المحلي
        await _saveFavoriteIds();

        // 🔄 استخدام GetX الآمن للتحديث
        WidgetsBinding.instance.addPostFrameCallback((_) {
          update();
        });

        print('✅ تم إزالة الشقة #$apartmentId من المفضلة');
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('❌ خطأ في إزالة المفضلة: ${e.message}');

      if (e.response?.statusCode == 404) {
        // إذا لم تكن موجودة، نحدّث الحالة المحلية فقط
        _favoriteIds.remove(apartmentId);
        await _saveFavoriteIds();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          update();
        });
      }

      return false;
    } catch (e) {
      print('❌ خطأ في إزالة المفضلة: $e');
      return false;
    }
  }

  // تبديل حالة المفضلة
  Future<void> toggleFavorite(int apartmentId) async {
    // تخزين الحالة الأصلية للتراجع إذا لزم الأمر
    final bool originalState = isFavorite(apartmentId);
    bool? operationSuccessful;

    print('🔄 تبديل المفضلة للشقة #$apartmentId');
    print('   - الحالة الأصلية: $originalState');

    try {
      // تحديث الحالة المحلية أولاً (لتجربة مستخدم أفضل)
      if (originalState) {
        _favoriteIds.remove(apartmentId);
        _favoriteApartments.removeWhere((a) => a.id == apartmentId);
      } else {
        _favoriteIds.add(apartmentId);
      }

      // تحديث الـ UI
      update();

      // الاتصال بالسيرفر
      if (originalState) {
        operationSuccessful = await removeFromFavorite(apartmentId);
      } else {
        operationSuccessful = await addToFavorite(apartmentId);
      }

      if (operationSuccessful == true) {
        print(
          '✅ تم ${originalState ? 'إزالة' : 'إضافة'} الشقة #$apartmentId بنجاح',
        );
      } else {
        throw Exception('فشل العملية على السيرفر');
      }
    } catch (e) {
      print('💥 خطأ في تبديل المفضلة: $e');

      // التراجع عن التغيير المحلي في حالة الخطأ
      if (operationSuccessful != true) {
        if (originalState) {
          // كان مفضلاً وفشلت الإزالة، نعيده
          _favoriteIds.add(apartmentId);
        } else {
          // لم يكن مفضلاً وفشلت الإضافة، نزيله
          _favoriteIds.remove(apartmentId);
          _favoriteApartments.removeWhere((a) => a.id == apartmentId);
        }

        // تحديث الـ UI
        update();

        print('↩️ تم التراجع عن تغيير المفضلة للشقة #$apartmentId');
      }

      rethrow;
    }
  }

  // التحقق من حالة المفضلة من السيرفر
  Future<void> checkFavoriteStatus(int apartmentId) async {
    try {
      print('🔍 التحقق من حالة المفضلة للشقة #$apartmentId...');

      final response = await _apiService.dio.get(
        '/favorites/check/$apartmentId',
      );

      if (response.statusCode == 200) {
        final isFavorite = response.data['data']['is_favorite'] ?? false;

        // تحديث الحالة المحلية بناءً على السيرفر
        if (isFavorite) {
          _favoriteIds.add(apartmentId);
        } else {
          _favoriteIds.remove(apartmentId);
        }

        await _saveFavoriteIds();
        update();

        print('✅ حالة المفضلة للشقة #$apartmentId: $isFavorite');
      }
    } catch (e) {
      print('⚠️ خطأ في التحقق من حالة المفضلة: $e');
      // لا نغير الحالة المحلية في حالة الخطأ
    }
  }

  // التحقق المتزامن للعديد من الشقق
  Future<void> checkMultipleFavoriteStatus(List<int> apartmentIds) async {
    for (final id in apartmentIds) {
      await checkFavoriteStatus(id);
    }
  }

  // مسح جميع المفضلة
  void clearFavorites() {
    _favoriteIds.clear();
    _favoriteApartments.clear();
    _saveFavoriteIds();
    print('🗑️ تم مسح جميع المفضلة');
  }
}
