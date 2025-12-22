// lib/screens/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/services/profile_service.dart';
import 'package:marsa_app/controllers/services/auth_service.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/views/verificationScreen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool notificationsEnabled = true;
  bool isLoading = false;
  bool _isInitialLoad = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _logged = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _selectedImage;
  String? _currentProfileImage;
  String _memberSince = 'جاري التحميل...';
  String _userRole = 'مستخدم';

  final ProfileService _profileService = ProfileService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndInitialize();
  }

  /// التحقق من حالة تسجيل الدخول ثم تهيئة البيانات
  Future<void> _checkLoginStatusAndInitialize() async {
    print('🔍 === التحقق من حالة تسجيل الدخول في صفحة البروفايل ===');

    try {
      // التحقق من حالة تسجيل الدخول أولاً
      _logged = await _profileService.isLoggedIn();
      print('🔐 حالة تسجيل الدخول: $_logged');
      // إذا كان مسجلاً، قم بتهيئة البيانات
      await _initializeProfileData();
    } catch (e) {
      print('💥 خطأ في التحقق من حالة تسجيل الدخول: $e');
      _logged = false;

      Get.snackbar(
        'خطأ',
        'حدث خطأ في التحقق من حالة تسجيل الدخول',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // إعادة التوجيه لتسجيل الدخول في حالة الخطأ
      Future.delayed(Duration.zero, () {
        if (mounted) {
          Get.offAllNamed('/login');
        }
      });
    }
  }

  /// تهيئة و تحميل بيانات البروفايل
  Future<void> _initializeProfileData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // ثم محاولة تحديث البيانات من API
      await _refreshFromApi();
      // انتظر قليلاً لضمان تهيئة الخدمات
      await Future.delayed(const Duration(milliseconds: 100));

      // تحميل البيانات المخزنة محلياً أولاً (للحصول على تجربة سريعة)
      await _loadCachedData();

      setState(() {
        _isInitialLoad = false;
      });
    } catch (e, stackTrace) {
      print('❌ خطأ في تهيئة بيانات البروفايل: $e');
      print('🔍 Stack Trace: $stackTrace');

      setState(() {
        _hasError = true;
        _errorMessage = 'فشل تحميل البيانات: ${e.toString()}';
        _memberSince = 'غير متوفر';
        _userRole = 'غير معروف';
      });

      Get.snackbar(
        'خطأ',
        'حدث خطأ في تحميل البيانات. حاول مرة أخرى.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// تحميل البيانات المخزنة محلياً
  Future<void> _loadCachedData() async {
    try {
      final firstName = await _profileService.getFirstName();
      final lastName = await _profileService.getLastName();
      final phone = await _profileService.getPhone();
      final avatar = await _profileService.getAvatarUrl();
      final createdAt = await _profileService.getCreatedAt();
      final role = await _profileService.getRole();

      if (mounted) {
        setState(() {
          _firstNameController.text = firstName?.trim() ?? '';
          _lastNameController.text = lastName?.trim() ?? '';
          _phoneController.text = phone?.trim() ?? '';
          _currentProfileImage = avatar;
          _userRole = role?.trim() ?? 'مستخدم';

          if (createdAt != null && createdAt.isNotEmpty) {
            try {
              final date = DateTime.parse(createdAt);
              _memberSince = 'عضو منذ ${_formatDate(date)}';
            } catch (e) {
              _memberSince = 'عضو منذ فترة';
            }
          } else {
            _memberSince = 'عضو جديد';
          }
        });
      }
    } catch (e) {
      print('⚠️ تحذير: فشل تحميل البيانات المخزنة: $e');
      // نستمر دون إظهار خطأ للمستخدم
    }
  }

  /// تحديث البيانات من API
  Future<void> _refreshFromApi() async {
    try {
      final result = await _profileService.getUserProfile();

      if (result['success'] == true && result['data'] != null) {
        await _updateUIFromData(result['data']);
        // isLogged = true;
        Get.snackbar(
          'تم التحديث',
          'تم تحديث البيانات بنجاح',
          backgroundColor: Colors.green.withAlpha(50),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else if (result['statusCode'] == 401) {
        // حالة انتهاء الجلسة
      } else if (result['message'] != null) {
        print('⚠️ تحذير API: ${result['message']}');
        // isLogged = false;
      }
    } catch (e) {
      // isLogged = false;
      print('⚠️ تحذير: فشل تحديث البيانات من API: $e');
    }
  }

  /// تحديث الواجهة من بيانات API
  Future<void> _updateUIFromData(Map<String, dynamic> userData) async {
    if (!mounted) return;

    setState(() {
      _firstNameController.text =
          userData['first_name']?.toString().trim() ?? '';
      _lastNameController.text = userData['last_name']?.toString().trim() ?? '';
      _phoneController.text = userData['phone']?.toString().trim() ?? '';
      _currentProfileImage = userData['avatar_url']?.toString();
      _userRole = userData['role']?.toString().trim() ?? 'مستخدم';

      if (userData['created_at'] != null) {
        try {
          final createdAt = DateTime.parse(userData['created_at'].toString());
          _memberSince = 'عضو منذ ${_formatDate(createdAt)}';
        } catch (e) {
          _memberSince = 'عضو منذ فترة';
        }
      }
    });
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// اختيار صورة من المعرض
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('❌ خطأ في اختيار الصورة: $e');
      Get.snackbar(
        'خطأ',
        'فشل اختيار الصورة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// حفظ التغييرات
  Future<void> _saveChanges() async {
    if (isLoading) return;

    // التحقق من البيانات
    if (_firstNameController.text.isEmpty) {
      Get.snackbar('خطأ', 'الاسم الأول مطلوب');
      return;
    }

    if (_lastNameController.text.isEmpty) {
      Get.snackbar('خطأ', 'الاسم الأخير مطلوب');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await _profileService.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        avatarImage: _selectedImage,
      );

      setState(() {
        isLoading = false;
      });

      if (result['success'] == true) {
        _reloadData();
        Get.snackbar(
          'نجاح',
          result['message'] ?? 'تم حفظ التغييرات بنجاح',
          backgroundColor: Colors.green.withAlpha(50),
          colorText: Colors.white,
        );

        setState(() {
          isEditing = false;
          _selectedImage = null;
        });

        // تحديث الصورة الحالية إذا كان هناك رابط جديد
        if (result['data'] != null && result['data']['avatar_url'] != null) {
          setState(() {
            _currentProfileImage = result['data']['avatar_url'];
          });
        }

        // تحديث البيانات المحلية
        await _loadCachedData();
      } else {
        Get.snackbar(
          'خطأ',
          result['message'] ?? 'فشل حفظ التغييرات',
          backgroundColor: Colors.red.withAlpha(50),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع أثناء الحفظ',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// تسجيل الخروج
  Future<void> _handleLogout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        isLoading = true;
      });

      try {
        final result = await _profileService.logout();

        if (result['success'] == true) {
          Get.offAllNamed('/login');
          Get.snackbar(
            'نجاح',
            result['message'] ?? 'تم تسجيل الخروج بنجاح',
            backgroundColor: Colors.green.withAlpha(50),
            colorText: Colors.black,
          );
        } else {
          // حتى إذا فشل API، ننقل المستخدم للتسجيل
          Get.offAllNamed('/login');
          Get.snackbar(
            'تم تسجيل الخروج',
            'تم تسجيل الخروج من الجهاز المحلي',
            backgroundColor: Colors.orange.withAlpha(50),
            colorText: Colors.black,
          );
        }
      } catch (e) {
        Get.offAllNamed('/login');
        Get.snackbar(
          'تم تسجيل الخروج',
          'تم تسجيل الخروج من الجهاز المحلي',
          backgroundColor: Colors.orange.withAlpha(50),
          colorText: Colors.black,
        );
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  /// عرض معلومات الدور
  void _showRoleInfo() {
    Get.dialog(
      AlertDialog(
        title: const Text('معلومات الحساب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الدور: $_userRole',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: Config.mainFont,
              ),
            ),
            const SizedBox(height: 8),
            Text(_memberSince),
            const SizedBox(height: 16),
            const Text(
              'يمكنك التواصل مع الدعم لتغيير الدور أو تعديل البيانات',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: Config.mainFont,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'حسناً',
              style: TextStyle(fontFamily: Config.mainFont),
            ),
          ),
        ],
      ),
    );
  }

  /// الحصول على الاسم الكامل
  String get _fullName {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty && lastName.isEmpty) {
      return 'لا يوجد اسم';
    }

    return '$firstName $lastName'.trim();
  }

  /// إعادة تحميل البيانات
  Future<void> _reloadData() async {
    await _initializeProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return _logged
        ? Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Stack(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: Config.gradientColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: _isInitialLoad && isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // شريط العنوان العلوي
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 20,
                                    top: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "الملف الشخصي",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          if (_hasError)
                                            IconButton(
                                              icon: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.refresh,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                              onPressed: _reloadData,
                                            ),
                                          IconButton(
                                            icon: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.refresh,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                            onPressed: _reloadData,
                                          ),
                                          const SizedBox(width: 8),
                                          if (!isEditing)
                                            IconButton(
                                              icon: Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  isEditing = true;
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // بطاقة المستخدم الرئيسية
                                _buildUserCard(),

                                const SizedBox(height: 20),

                                // قسم الإعدادات
                                const Text(
                                  "الإعدادات",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildSettingsTile(
                                        Icons.notifications_none,
                                        "الإشعارات",
                                        isSwitch: true,
                                      ),
                                      _buildDivider(),
                                      _buildSettingsTile(
                                        Icons.lock_outline,
                                        "تغيير كلمة المرور",
                                        onTap: _showChangePasswordDialog,
                                      ),
                                      _buildDivider(),
                                      _buildSettingsTile(
                                        Icons.security_outlined,
                                        "الخصوصية والأمان",
                                        onTap: () {},
                                      ),
                                      _buildDivider(),
                                      _buildSettingsTile(
                                        Icons.help_outline,
                                        "المساعدة والدعم",
                                        onTap: () {},
                                      ),
                                      _buildDivider(),
                                      _buildSettingsTile(
                                        Icons.info_outline,
                                        "عن التطبيق",
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // زر تسجيل الخروج
                                Container(
                                  width: double.infinity,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(40),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: TextButton.icon(
                                    onPressed: isLoading ? null : _handleLogout,
                                    icon: const Icon(
                                      Icons.logout,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      "تسجيل الخروج",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 70),
                              ],
                            ),
                          ),
                  ),

                  // مؤشر التحميل العلوي
                  if (isLoading && !_isInitialLoad)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Config.primaryColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "يرجى تسجيل الحساب أولاً",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              Container(
                width: double.infinity,
                height: 55,
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(40),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextButton.icon(
                  onPressed: isLoading ? null : () => Get.offAllNamed('/login'),
                  icon: const Icon(Icons.login, color: Colors.orange),
                  label: const Text(
                    "تسجيل الحساب",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(alignment: Alignment.center),
                ),
              ),
            ],
          );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // الصورة الشخصية
              GestureDetector(
                onTap: isEditing ? _pickImage : null,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: _getProfileImage(),
                      backgroundColor: Colors.grey[200],
                    ),
                    if (isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Config.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _memberSince,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _userRole,
                        style: TextStyle(
                          color: _getRoleColor(),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // الحقول
          _buildInfoRow(
            Icons.person_outline,
            'الاسم الأول',
            _firstNameController,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.person_outline,
            'الاسم الأخير',
            _lastNameController,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.phone_outlined,
            'رقم الهاتف',
            _phoneController,
            enabled: false,
          ),

          // أزرار الحفظ والإلغاء
          if (isEditing) ...[
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Config.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "حفظ التغييرات",
                            style: TextStyle(
                              fontFamily: Config.mainFont,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              isEditing = false;
                              _selectedImage = null;
                              _loadCachedData(); // استعادة البيانات الأصلية
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      "إلغاء",
                      style: TextStyle(fontFamily: Config.mainFont),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getRoleColor() {
    switch (_userRole.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'owner':
        return Colors.blue;
      case 'tenant':
        return Colors.green;
      case 'manager':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  ImageProvider _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_currentProfileImage != null &&
        _currentProfileImage!.isNotEmpty) {
      // بناء URL كامل للصورة

      final fullImageUrl =
          'http://192.168.1.15:8000/storage/$_currentProfileImage';
      print('Loading profile image from URL: $fullImageUrl');
      return NetworkImage(fullImageUrl);
    }
    return const AssetImage('assets/marsa/logo Marsa.png');
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[100],
            child: Icon(icon, color: Colors.grey[600], size: 18),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                isEditing && enabled
                    ? SizedBox(
                        height: 55,
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: Config.mainFont,
                          ),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFE8F6F5),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 0,
                            ),
                            // isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        controller.text.isNotEmpty
                            ? controller.text
                            : 'غير محدد',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title, {
    bool isSwitch = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[100],
        child: Icon(icon, color: Colors.grey[700], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: isSwitch
          ? Switch(
              value: notificationsEnabled,
              activeColor: Config.primaryColor,
              onChanged: (val) {
                setState(() {
                  notificationsEnabled = val;
                });
              },
            )
          : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      indent: 60,
      endIndent: 20,
      color: Colors.black12,
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shadowColor: Config.primaryColor,
        title: const Text(
          'تغيير كلمة المرور',
          style: TextStyle(fontFamily: Config.mainFont),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: TextStyle(fontFamily: Config.mainFont),
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
                labelStyle: TextStyle(fontFamily: Config.mainFont),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: TextStyle(fontFamily: Config.mainFont),
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                labelStyle: TextStyle(fontFamily: Config.mainFont),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: TextStyle(fontFamily: Config.mainFont),
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                labelStyle: TextStyle(fontFamily: Config.mainFont),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: Config.mainFont),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Config.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                Get.snackbar('خطأ', 'كلمات المرور غير متطابقة');
                return;
              }

              if (newPasswordController.text.length < 6) {
                Get.snackbar('خطأ', 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
                return;
              }

              setState(() {
                isLoading = true;
              });

              final result = await _profileService.changePassword(
                currentPassword: currentPasswordController.text,
                newPassword: newPasswordController.text,
                confirmPassword: confirmPasswordController.text,
              );

              Get.back();

              setState(() {
                isLoading = false;
              });

              if (result['success'] == true) {
                Get.snackbar(
                  'نجاح',
                  'تم تغيير كلمة المرور بنجاح',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'خطأ',
                  result['message'] ?? 'فشل تغيير كلمة المرور',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              'تغيير',
              style: TextStyle(fontFamily: Config.mainFont),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
