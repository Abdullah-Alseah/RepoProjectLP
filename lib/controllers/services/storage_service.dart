import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // مفاتيح التخزين
  static const String _tokenKey = 'auth_token';
  static const String _userPhoneKey = 'user_phone';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userDataKey = 'user_data';

  // متغيرات مؤقتة للتخزين
  Map<String, dynamic>? _cachedUserData;
  String? _cachedToken;
  int? _cachedUserId;
  String? _cachedUserRole;
  String? _cachedUserName;

  /// حفظ توكن المصادقة
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// الحصول على التوكن
  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  /// حفظ بيانات المستخدم الكاملة
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // التأكد من أن is_approved يتم تخزينه بشكل صحيح
      if (userData.containsKey('is_approved')) {
        final dynamic isApprovedValue = userData['is_approved'];

        // تحويل إلى bool للتخزين الموحد
        if (isApprovedValue is bool) {
          // لا يحتاج لتغيير
        } else if (isApprovedValue is int) {
          userData['is_approved'] = isApprovedValue == 1;
        } else if (isApprovedValue is String) {
          userData['is_approved'] =
              isApprovedValue.toLowerCase() == 'true' || isApprovedValue == '1';
        }
      }

      final String userDataString = json.encode(userData);
      final bool saved = await prefs.setString('user_data', userDataString);

      if (saved) {
        print('✅ تم حفظ بيانات المستخدم بنجاح:');
        print('   👤 ID: ${userData['id']}');
        print('   👤 الاسم: ${userData['name'] ?? userData['first_name']}');
        print('   🎭 الدور: ${userData['role']}');
        print('   ✅ is_approved: ${userData['is_approved']}');
      }

      return saved;
    } catch (e) {
      print('💥 خطأ في حفظ بيانات المستخدم: $e');
      return false;
    }
  }

  /// الحصول على بيانات المستخدم
  Future<Map<String, dynamic>> getUserData() async {
    try {
      Future.delayed(const Duration(milliseconds: 4500));
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String? userDataString = prefs.getString('user_data');

      if (userDataString == null || userDataString.isEmpty) {
        print('📋 لا توجد بيانات مستخدم في التخزين');
        return {};
      }

      final Map<String, dynamic> userData = json.decode(userDataString);

      // معالجة حقل is_approved
      if (userData.containsKey('is_approved')) {
        final dynamic isApprovedValue = userData['is_approved'];

        if (isApprovedValue is bool) {
          // الحالة جيدة
        } else if (isApprovedValue is int) {
          userData['is_approved'] = isApprovedValue == 1;
        } else if (isApprovedValue is String) {
          userData['is_approved'] =
              isApprovedValue.toLowerCase() == 'true' || isApprovedValue == '1';
        } else {
          userData['is_approved'] = false; // قيمة افتراضية
        }
      } else {
        userData['is_approved'] = false; // قيمة افتراضية
      }

      print('📋 بيانات المستخدم المسترجعة:');
      print('   👤 ID: ${userData['id']}');
      print('   👤 الاسم: ${userData['name'] ?? userData['first_name']}');
      print('   🎭 الدور: ${userData['role']}');
      print(
        '   ✅ is_approved: ${userData['is_approved']} (نوع: ${userData['is_approved'].runtimeType})',
      );

      return userData;
    } catch (e) {
      print('💥 خطأ في استرجاع بيانات المستخدم: $e');
      return {};
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

  /// الحصول على معرف المستخدم
  Future<int> getUserId() async {
    if (_cachedUserId != null) {
      print('🔢 استرجاع ID من الكاش: $_cachedUserId');
      return _cachedUserId!;
    }

    final prefs = await SharedPreferences.getInstance();
    _cachedUserId = prefs.getInt(_userIdKey) ?? 0;
    print('🔢 استرجاع ID من التخزين: $_cachedUserId');
    return _cachedUserId!;
  }

  /// الحصول على دور المستخدم
  Future<String> getUserRole() async {
    if (_cachedUserRole != null) return _cachedUserRole!;

    final prefs = await SharedPreferences.getInstance();
    _cachedUserRole = prefs.getString(_userRoleKey) ?? '';
    return _cachedUserRole!;
  }

  /// الحصول على اسم المستخدم
  Future<String> getUserName() async {
    // أولاً: جرب من التخزين المؤقت
    if (_cachedUserName != null) return _cachedUserName!;

    // ثانياً: جرب من بيانات المستخدم الكاملة (JSON)
    final userData = await getUserData();
    if (userData.isNotEmpty) {
      final name = userData['name']?.toString();
      final firstName = userData['first_name']?.toString();
      final lastName = userData['last_name']?.toString();

      if (name != null && name.isNotEmpty) {
        _cachedUserName = name;
        return _cachedUserName!;
      } else if (firstName != null || lastName != null) {
        _cachedUserName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
        return _cachedUserName!;
      }
    }

    // ثالثاً: جرب من المفتاح المنفصل
    final prefs = await SharedPreferences.getInstance();
    _cachedUserName = prefs.getString(_userNameKey) ?? '';
    return _cachedUserName!;
  }

  /// حفظ اسم المستخدم بشكل منفصل
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    // تحديث التخزين المؤقت
    _instance._cachedUserName = name;
  }

  /// الحصول على هاتف المستخدم
  Future<String> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhoneKey) ?? '';
  }

  /// الحصول على بريد المستخدم
  Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey) ?? '';
  }

  /// التحقق من تسجيل الدخول
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final hasToken = token != null && token.isNotEmpty;
    print('🔐 التحقق من تسجيل الدخول: $hasToken');
    return hasToken;
  }

  /// التحقق إذا كان المستخدم مالكاً
  Future<bool> isOwner() async {
    final role = await getUserRole();
    final isOwner = role == 'owner';
    print('👑 التحقق إذا كان المستخدم مالكاً: $isOwner');
    return isOwner;
  }

  /// التحقق إذا كان المستخدم مستأجراً
  Future<bool> isTenant() async {
    final role = await getUserRole();
    return role == 'tenant';
  }

  /// مسح جميع بيانات المستخدم
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userDataKey);

    _clearCache();
    print('🗑️ تم مسح جميع بيانات المستخدم');
  }

  /// تحديث بيانات محددة للمستخدم
  Future<void> updateUserData(Map<String, dynamic> updates) async {
    final currentData = await getUserData();
    final newData = {...currentData, ...updates};
    await saveUserData(newData);
  }

  /// مسح التخزين المؤقت
  void _clearCache() {
    _cachedUserData = null;
    _cachedToken = null;
    _cachedUserId = null;
    _cachedUserRole = null;
    _cachedUserName = null;
    print('🧹 تم مسح التخزين المؤقت');
  }

  /// دالة فحص البيانات المخزنة
  Future<void> debugStorage() async {
    final prefs = await SharedPreferences.getInstance();

    print('🔍 فحص بيانات التخزين:');
    print('   - token: ${prefs.getString(_tokenKey)?.substring(0, 20)}...');
    print('   - user_id: ${prefs.getInt(_userIdKey)}');
    print('   - user_role: ${prefs.getString(_userRoleKey)}');
    print('   - user_name: ${prefs.getString(_userNameKey)}');
    print(
      '   - user_data: ${prefs.getString(_userDataKey)?.substring(0, 100)}...',
    );
  }
}
