// lib/stores/apartment_store.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/services/apartment_service.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/models/apartment_model.dart';

class ApartmentStore extends GetxController {
  static ApartmentStore get instance => Get.find<ApartmentStore>();

  // المتغيرات القابلة للملاحظة
  final RxList<Apartment> _apartments = <Apartment>[].obs;
  final Rx<Apartment?> _selectedApartment = Rx<Apartment?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingDetails = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMore = true.obs;

  // البيانات المتاحة للاستخدام في الملفات الأخرى
  List<Apartment> get apartments => _apartments.toList();
  Apartment? get selectedApartment => _selectedApartment.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingDetails => _isLoadingDetails.value;
  String get errorMessage => _errorMessage.value;
  int get currentPage => _currentPage.value;
  bool get hasMore => _hasMore.value;

  // خدمة الشقق
  final ApartmentService _apartmentService = ApartmentService();

  // تهيئة المخزن
  @override
  void onInit() {
    super.onInit();
    fetchApartments();
  }

  // الحصول على الشقق مع التصفية
  Future<void> fetchApartments({
    String? city,
    String? province,
    double? priceMax,
    int? roomsMin,
    int? guestsMin,
    String? search,
    bool refresh = false,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      if (refresh) {
        _currentPage.value = 1;
        _hasMore.value = true;
        _apartments.clear();
      }

      final result = await _apartmentService.getApartments(
        page: _currentPage.value,
        city: city,
        province: province,
        priceMax: priceMax,
        roomsMin: roomsMin,
        guestsMin: guestsMin,
        search: search,
      );

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final List<dynamic> apartmentsData = data['data'] ?? [];

        final List<Apartment> fetchedApartments = [];
        for (var json in apartmentsData) {
          try {
            fetchedApartments.add(Apartment.fromJson(json));
          } catch (e) {
            print('⚠️ خطأ في تحويل بيانات الشقة: $e');
          }
        }

        if (refresh) {
          _apartments.assignAll(fetchedApartments);
        } else {
          _apartments.addAll(fetchedApartments);
        }

        // التحقق إذا كان هناك المزيد من الصفحات
        if (data.containsKey('current_page') && data.containsKey('last_page')) {
          _hasMore.value = data['current_page'] < data['last_page'];
        } else if (data.containsKey('links') && data['links'] is Map) {
          final links = data['links'] as Map<String, dynamic>;
          _hasMore.value = links['next'] != null;
        } else {
          _hasMore.value =
              fetchedApartments.isNotEmpty &&
              fetchedApartments.length >= 15; // إذا كان perPage = 15
        }
      } else {
        _errorMessage.value = result['message'] as String;
        if (result['statusCode'] == 401 || result['statusCode'] == 403) {
          // يمكنك إضافة إعادة توجيه لتسجيل الدخول هنا
        }
      }
    } catch (e) {
      _errorMessage.value = 'حدث خطأ في الاتصال: $e';
      print('💥 خطأ في fetchApartments: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // جلب شقات المالك الحالي
  Future<void> fetchOwnerApartments({
    String? city,
    String? province,
    double? priceMax,
    int? roomsMin,
    int? guestsMin,
    String? search,
    bool refresh = false,
    bool forceRefresh = false,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      if (refresh || forceRefresh) {
        _currentPage.value = 1;
        _hasMore.value = true;
        _apartments.clear();
        print('🔄 مسح القائمة وإعادة التحميل...');
      }

      // التحقق من بيانات المستخدم بطريقة أكثر أماناً
      final storageService = StorageService();
      final userData = await storageService.getUserData();

      print('📊 بيانات المستخدم المسترجعة:');
      print('   ID: ${userData['id']}');
      print('   Role: ${userData['role']}');
      print(
        '   is_approved: ${userData['is_approved']} (نوع: ${userData['is_approved']?.runtimeType})',
      );

      if (userData.isEmpty || userData['id'] == null) {
        _errorMessage.value = 'يجب تسجيل الدخول أولاً';
        print('❌ لا توجد بيانات مستخدم صالحة');
        _isLoading.value = false;
        return;
      }

      // تحقق آمن من دور المستخدم
      final String? userRole = userData['role']?.toString();
      if (userRole == null || userRole != 'owner') {
        _errorMessage.value = 'يجب أن تكون مالكاً لعرض شقاتك';
        print('❌ دور المستخدم غير صالح: $userRole');
        _isLoading.value = false;
        return;
      }

      // تحقق آمن من حالة الموافقة
      final isApproved = _parseIsApproved(userData['is_approved']);
      if (!isApproved) {
        _errorMessage.value = 'حسابك قيد المراجعة. يرجى الانتظار حتى الموافقة';
        print('⚠️ حساب غير مفعل');
        _isLoading.value = false;
        return;
      }

      final int? userId = userData['id'] is int
          ? userData['id'] as int?
          : (userData['id'] is String
                ? int.tryParse(userData['id'] as String)
                : null);

      if (userId == null) {
        _errorMessage.value = 'خطأ في بيانات المستخدم';
        print('❌ ID المستخدم غير صالح: ${userData['id']}');
        _isLoading.value = false;
        return;
      }

      print('👤 جلب شقات المالك ID: $userId');

      try {
        // محاولة جلب الشقات
        final result = await _apartmentService.getOwnerApartments(
          page: _currentPage.value,
          city: city,
          province: province,
          priceMax: priceMax,
          roomsMin: roomsMin,
          guestsMin: guestsMin,
          search: search,
        );

        await _processApartmentResult(result, userId);
      } catch (e) {
        print('⚠️ خطأ في جلب شقات المالك: $e');

        // محاولة بديلة
        try {
          final result = await _apartmentService.getApartments(
            page: _currentPage.value,
            city: city,
            province: province,
            priceMax: priceMax,
            roomsMin: roomsMin,
            guestsMin: guestsMin,
            search: search,
          );

          await _processApartmentResult(result, userId);
        } catch (e2) {
          print('💥 فشل البديل أيضاً: $e2');
          _errorMessage.value = 'فشل جلب الشقات. يرجى المحاولة مرة أخرى';
        }
      }
    } catch (e) {
      _errorMessage.value = 'حدث خطأ في جلب الشقات: $e';
      print('💥 خطأ في fetchOwnerApartments: $e');
      print('Stack trace: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // دالة مساعدة لمعالجة is_approved
  bool _parseIsApproved(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }

    return false;
  }

  bool error = false;
  // دالة مساعدة لمعالجة نتيجة جلب الشقات
  Future<void> _processApartmentResult(
    Map<String, dynamic> result,
    int userId,
  ) async {
    if (result['success'] == true) {
      dynamic data = result['data'];
      List<dynamic> apartmentsData = [];

      // معالجة البيانات المستلمة
      if (data is Map<String, dynamic>) {
        apartmentsData = data['data'] ?? [];
        print('📊 نوع البيانات: Map, عدد العناصر: ${apartmentsData.length}');
      } else if (data is List) {
        apartmentsData = data;
        print('📊 نوع البيانات: List, عدد العناصر: ${apartmentsData.length}');
      } else {
        print('⚠️ نوع بيانات غير معروف: ${data.runtimeType}');
        apartmentsData = [];
      }

      // إذا كان endpoint عاماً، نتصفى محلياً
      final isOwnerSpecific = result['ownerSpecific'] == true;
      if (!isOwnerSpecific) {
        print('🔍 تصفية الشقات محلياً للمالك ID: $userId');
        apartmentsData = apartmentsData.where((apt) {
          try {
            if (apt is Map<String, dynamic>) {
              final ownerData = apt['owner'] as Map<String, dynamic>?;
              if (ownerData == null) {
                print('⚠️ الشقة بدون بيانات مالك: $apt');
                return false;
              }

              final dynamic ownerIdValue = ownerData['id'];
              final int? ownerId;

              if (ownerIdValue is int) {
                ownerId = ownerIdValue;
              } else if (ownerIdValue is String) {
                ownerId = int.tryParse(ownerIdValue);
              } else {
                ownerId = null;
              }

              final isOwnerApartment = ownerId == userId;
              if (isOwnerApartment) {
                print('✅ شقة مملوكة: ${apt['title']}');
              }

              return isOwnerApartment;
            }
            return false;
          } catch (e) {
            print('⚠️ خطأ في تصفية الشقة: $e');
            return false;
          }
        }).toList();
      }

      print('🏡 عدد الشقات بعد التصفية: ${apartmentsData.length}');

      final List<Apartment> fetchedApartments = [];
      for (var json in apartmentsData) {
        try {
          if (json is Map<String, dynamic>) {
            fetchedApartments.add(Apartment.fromJson(json));
          }
        } catch (e) {
          print('⚠️ خطأ في تحويل بيانات الشقة: $e');
          print('📄 بيانات الشقة: $json');
        }
      }

      // تحديث القائمة
      _apartments.assignAll(fetchedApartments);
      print('✅ تم تحديث القائمة بـ ${fetchedApartments.length} شقة');

      // تحديث حالة الترقيم
      _hasMore.value = false; // مؤقتاً حتى نضبط الترقيم
    } else {
      _errorMessage.value = result['message'] as String;
      print('❌ فشل جلب الشقات: ${result['message']}');
      error = true;
    }
  }

  // دالة مساعدة لتحميل المزيد من شقات المالك
  Future<void> loadMoreOwnerApartments() async {
    if (_isLoading.value || !_hasMore.value) return;

    _currentPage.value++;
    await fetchOwnerApartments();
  }

  // تحميل المزيد من الشقق
  Future<void> loadMoreApartments() async {
    if (_isLoading.value || !_hasMore.value) return;

    _currentPage.value++;
    await fetchApartments();
  }

  // الحصول على تفاصيل شقة معينة
  Future<Map<String, dynamic>> getApartmentDetails(int apartmentId) async {
    try {
      _isLoadingDetails.value = true;
      _errorMessage.value = '';

      final result = await _apartmentService.getApartmentDetails(apartmentId);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        _selectedApartment.value = Apartment.fromJson(data);
        return {'success': true, 'data': data};
      } else {
        _errorMessage.value = result['message'] as String;
        return result;
      }
    } catch (e) {
      final error = 'حدث خطأ: $e';
      _errorMessage.value = error;
      print('💥 خطأ في getApartmentDetails: $e');
      return {'success': false, 'message': error};
    } finally {
      _isLoadingDetails.value = false;
    }
  }

  // الحصول على تفاصيل شقة معينة وتحديث المخزن
  Future<void> fetchApartmentDetails(int apartmentId) async {
    final result = await getApartmentDetails(apartmentId);
    if (result['success'] == true) {
      // تحديث القائمة إذا كانت الشقة موجودة فيها
      final index = _apartments.indexWhere((apt) => apt.id == apartmentId);
      if (index != -1 && _selectedApartment.value != null) {
        _apartments[index] = _selectedApartment.value!;
      }
    }
  }

  // إنشاء شقة جديدة
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
      _isLoading.value = true;
      _errorMessage.value = '';

      // تحويل مسارات الصور إلى ملفات
      final List<File> images = imagePaths.map((path) => File(path)).toList();

      // استخدام ApartmentService لإضافة الشقة
      final result = await ApartmentService().createApartment(
        title: title,
        description: description,
        city: city,
        province: province,
        address: address,
        price: price,
        rooms: rooms,
        guests: guests,
        images: images,
        isActive: isActive,
      );

      if (result['success'] == true) {
        // تحديث القائمة
        fetchApartments(refresh: true);
      }

      return result;
    } catch (e) {
      final error = 'حدث خطأ: $e';
      print('💥 خطأ في createApartment: $e');
      return {'success': false, 'message': error};
    } finally {
      _isLoading.value = false;
    }
  }

  // في ApartmentStore
  Future<void> getOwnerApartments() async {
    try {
      _isLoading.value = true;
      // جلب شقق المالك من API
      // يمكنك إضافة منطق API هنا
    } catch (e) {
      print('❌ خطأ في جلب شقق المالك: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  // تحديث شقة
  Future<Map<String, dynamic>> updateApartment(
    int apartmentId, {
    String? title,
    String? description,
    String? city,
    String? province,
    String? address,
    double? price,
    int? rooms,
    int? guests,
    bool? isActive,
    List<String>? newImagePaths,
    List<int>? deleteImages,
    int? mainImageId,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      List<File>? newImages;
      if (newImagePaths != null && newImagePaths.isNotEmpty) {
        newImages = newImagePaths.map((path) => File(path)).toList();
      }

      final result = await _apartmentService.updateApartment(
        apartmentId: apartmentId,
        title: title,
        description: description,
        city: city,
        province: province,
        address: address,
        price: price,
        rooms: rooms,
        guests: guests,
        isActive: isActive,
        newImages: newImages,
        deleteImages: deleteImages,
        mainImageId: mainImageId,
      );

      if (result['success'] == true) {
        // تحديث الشقة في القائمة
        final index = _apartments.indexWhere((apt) => apt.id == apartmentId);
        if (index != -1) {
          final data = result['data'] as Map<String, dynamic>;
          _apartments[index] = Apartment.fromJson(data);
        }

        // تحديث الشقة المحددة إذا كانت هي نفسها
        if (_selectedApartment.value?.id == apartmentId) {
          await fetchApartmentDetails(apartmentId);
        }
      }

      return result;
    } catch (e) {
      final error = 'حدث خطأ: $e';
      print('💥 خطأ في updateApartment: $e');
      return {'success': false, 'message': error};
    } finally {
      _isLoading.value = false;
    }
  }

  // حذف شقة
  // في ApartmentStore.dart - دالة deleteApartment المعدلة
  Future<Map<String, dynamic>> deleteApartment(int apartmentId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _apartmentService.deleteApartment(apartmentId);

      if (result['success'] == true) {
        // حذف الشقة من القائمة المحلية
        _apartments.removeWhere((apt) => apt.id == apartmentId);

        // إذا كانت الشقة المحددة هي نفسها التي تم حذفها
        if (_selectedApartment.value?.id == apartmentId) {
          _selectedApartment.value = null;
        }

        return {
          'success': true,
          'message': result['message'] ?? 'تم حذف الشقة بنجاح',
          'data': result['data'],
        };
      } else {
        _errorMessage.value = result['message'] as String;
        return result;
      }
    } catch (e) {
      final error = 'حدث خطأ في الحذف: $e';
      _errorMessage.value = error;
      print('💥 خطأ في deleteApartment: $e');
      return {'success': false, 'message': error};
    } finally {
      _isLoading.value = false;
    }
  }

  // البحث عن شقة في القائمة المحلية
  Apartment? findApartmentById(int id) {
    return _apartments.firstWhereOrNull((apt) => apt.id == id);
  }

  // البحث في الشقق المحلية
  List<Apartment> searchApartments(String query) {
    if (query.isEmpty) return _apartments.toList();

    final lowerQuery = query.toLowerCase();
    return _apartments.where((apartment) {
      return apartment.title.toLowerCase().contains(lowerQuery) ||
          apartment.description.toLowerCase().contains(lowerQuery) ||
          apartment.city.toLowerCase().contains(lowerQuery) ||
          apartment.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // الحصول على المدن المتاحة
  Future<List<String>> getAvailableCities() async {
    try {
      return await _apartmentService.getAvailableCities();
    } catch (e) {
      print('⚠️ خطأ في getAvailableCities: $e');
      return [];
    }
  }

  // الحصول على المحافظات المتاحة
  Future<List<String>> getAvailableProvinces() async {
    try {
      return await _apartmentService.getAvailableProvinces();
    } catch (e) {
      print('⚠️ خطأ في getAvailableProvinces: $e');
      return [];
    }
  }

  // الحصول على المحافظات بناءً على المدينة
  Future<List<String>> getProvincesByCity(String city) async {
    try {
      return await _apartmentService.getProvincesByCity(city);
    } catch (e) {
      print('⚠️ خطأ في getProvincesByCity: $e');
      return [];
    }
  }

  // تحديث الشقة المحددة
  void selectApartment(Apartment apartment) {
    _selectedApartment.value = apartment;
  }

  // تحديث الشقة المحددة من ID
  Future<void> selectApartmentById(int apartmentId) async {
    final apartment = findApartmentById(apartmentId);
    if (apartment != null) {
      _selectedApartment.value = apartment;
    } else {
      await fetchApartmentDetails(apartmentId);
    }
  }

  // مسح الشقة المحددة
  void clearSelectedApartment() {
    _selectedApartment.value = null;
  }

  // مسح البيانات
  void clearData() {
    _apartments.clear();
    _selectedApartment.value = null;
    _currentPage.value = 1;
    _hasMore.value = true;
    _errorMessage.value = '';
  }

  // تفريغ المخزن
  void disposeStore() {
    clearData();
  }

  // في ApartmentStore.dart - دالة للتحديث الذكي بعد الحذف
  Future<void> refreshAfterDelete(int deletedApartmentId) async {
    try {
      // 1. حذف الشقة من القائمة المحلية فوراً
      _apartments.removeWhere((apt) => apt.id == deletedApartmentId);

      // 2. إزالة الشقة المحددة إذا كانت هي المحذوفة
      if (_selectedApartment.value?.id == deletedApartmentId) {
        _selectedApartment.value = null;
      }

      // 3. إعادة تحميل البيانات من السيرفر للتأكد
      await fetchOwnerApartments(refresh: true);
    } catch (e) {
      print('⚠️ خطأ في refreshAfterDelete: $e');
    }
  }

  // استدعاء هذه الدالة بعد الحذف الناجح
  void onDeleteSuccess(int apartmentId) {
    refreshAfterDelete(apartmentId);
  }

  // في ApartmentStore.dart
  void resetStore() {
    _apartments.clear();
    _selectedApartment.value = null;
    _currentPage.value = 1;
    _hasMore.value = true;
    _errorMessage.value = '';
    print('🔄 تم إعادة تعيين المتجر');
  }

  // استدعاء هذه الدالة عند فتح صفحة شقات المالك
  void initializeOwnerApartments() {
    resetStore();
    fetchOwnerApartments(refresh: true);
  }

  // تحديث شقة في القائمة
  void updateApartmentInList(Apartment updatedApartment) {
    final index = _apartments.indexWhere(
      (apt) => apt.id == updatedApartment.id,
    );
    if (index != -1) {
      _apartments[index] = updatedApartment;
    }
  }

  // الحصول على الشقق المفضلة (إذا كان لديك نظام مفضلة)
  List<Apartment> getFavoriteApartments() {
    // هذه دالة تجريبية، تحتاج لتطبيق منطق المفضلة
    return _apartments.where((apt) => apt.isActive).toList();
  }

  // الحصول على الشقق الخاصة بالمستخدم (إذا كان مالكاً)
  List<Apartment> getUserApartments(int userId) {
    return _apartments.where((apt) => apt.owner?.id == userId).toList();
  }

  // ترتيب الشقق حسب السعر
  void sortApartmentsByPrice({bool ascending = true}) {
    _apartments.sort((a, b) {
      final comparison = a.price.compareTo(b.price);
      return ascending ? comparison : -comparison;
    });
  }

  // ترتيب الشقق حسب التاريخ
  void sortApartmentsByDate({bool newestFirst = true}) {
    _apartments.sort((a, b) {
      final dateA = a.createdAt ?? DateTime.now();
      final dateB = b.createdAt ?? DateTime.now();
      final comparison = dateA.compareTo(dateB);
      return newestFirst ? -comparison : comparison;
    });
  }
}
