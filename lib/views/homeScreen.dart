import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/main_layout_controller.dart';
import 'package:marsa_app/views/components/apartment_card.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/services/profile_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProfileService _profileService = ProfileService();
  final MainLayoutController controller = Get.put(MainLayoutController());

  String? _avatarUrl;
  String? _firstName;
  String? _lastName;
  bool _isLoading = true;
  bool _logged = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() => _isLoading = true);

      // 1. التحقق من التوكن
      final token = await _profileService.getToken();
      _logged = token != null && token.isNotEmpty;
      print('🔐 حالة تسجيل الدخول: $_logged');

      if (!_logged) {
        print('⚠️ المستخدم غير مسجل');
        setState(() {
          _isLoading = false;
          _avatarUrl = null;
        });
        return;
      }

      // 2. جلب البيانات المحلية أولاً
      print('💾 جلب البيانات المحلية...');
      final userData = await _profileService.getCachedUserData();
      if (userData != null) {
        _updateFromData(userData);
        print('✅ تم تحميل البيانات المحلية');
      }

      // 3. تحديث البيانات من API
      print('🔄 تحديث البيانات من API...');
      final result = await _profileService.getUserProfile();

      if (result['success'] == true && result['data'] != null) {
        final apiData = result['data'] as Map<String, dynamic>;
        _updateFromData(apiData);
        print('✅ تم تحديث البيانات من API');
      } else {
        print('⚠️ فشل تحديث البيانات من API: ${result['message']}');
      }
    } catch (e) {
      print('💥 خطأ في تحميل البروفايل: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('🔍 === انتهاء تحميل البروفايل ===');
    }
  }

  void _updateFromData(Map<String, dynamic> data) {
    // نفس الطريقة المستخدمة في صفحة البروفايل
    String? rawAvatarUrl = data['avatar_url']?.toString();

    if (rawAvatarUrl != null && rawAvatarUrl.isNotEmpty) {
      // بناء URL كامل للصورة بنفس طريقة صفحة البروفايل
      if (rawAvatarUrl.startsWith('http')) {
        _avatarUrl = rawAvatarUrl; // إذا كان URL كاملاً
      } else {
        _avatarUrl = 'http://192.168.1.15:8000/storage/$rawAvatarUrl';
      }
      print('🖼️ رابط الصورة المبنية: $_avatarUrl');
    } else {
      _avatarUrl = null;
      print('⚠️ لا توجد صورة في البيانات');
    }

    _firstName = data['first_name']?.toString();
    _lastName = data['last_name']?.toString();
  }

  String _getInitials() {
    String initials = '';
    if (_firstName != null && _firstName!.isNotEmpty) {
      initials += _firstName![0];
    }
    if (_lastName != null && _lastName!.isNotEmpty) {
      initials += _lastName![0];
    }
    if (initials.isEmpty) initials = 'U';
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    Config.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            actions: [
              Container(
                padding: const EdgeInsets.all(10),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Config.primaryColor.withAlpha(80),
                  child: _buildProfileAvatar(),
                ),
              ),
            ],
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                height: 300,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/background/1.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.white.withAlpha(0)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: 30,
                              offset: const Offset(0, 25),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(
                'مَرسَى',
                style: TextStyle(
                  color: Config.secandryColor,
                  fontFamily: Config.mainFont,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            expandedHeight: 50,
            toolbarHeight: 50,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontFamily: Config.mainFont),
                          decoration: InputDecoration(
                            hintText: "...ابحث عن موقع، مدينة",
                            hintTextDirection: TextDirection.rtl,
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search, color: Colors.grey),
                              onPressed: () {
                                // وظيفة البحث
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ApartmentCardWidget(),
                  ApartmentCardWidget(),
                  ApartmentCardWidget(),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return InkWell(
      onTap: () {
        print('=== معلومات البروفايل في HomeScreen ===');
        print('🔐 حالة تسجيل الدخول: $_logged');
        print('🖼️ رابط الصورة المبنية: $_avatarUrl');
        print('👤 الاسم: $_firstName $_lastName');

        if (!_logged) {
          print('👉 الانتقال لتسجيل الدخول');
          Get.toNamed("/login");
        } else {
          print('👉 الانتقال لصفحة البروفايل');
          controller.goToPage();
        }
      },
      child: _isLoading
          ? CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Config.primaryColor,
                  ),
                ),
              ),
            )
          : !_logged
          ? CircleAvatar(
              radius: 18,
              backgroundColor: Config.primaryColor,
              child: Icon(Icons.login, color: Colors.white, size: 20),
            )
          : _avatarUrl != null && _avatarUrl!.isNotEmpty
          ? CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(_avatarUrl!),
              onBackgroundImageError: (exception, stackTrace) {
                print('❌ خطأ في تحميل الصورة: $exception');
                print('🔗 رابط الصورة: $_avatarUrl');
                // استخدم الأحرف الأولية عند فشل التحميل
                Future.microtask(() {
                  if (mounted) {
                    setState(() => _avatarUrl = null);
                  }
                });
              },
              child: _avatarUrl == null || _avatarUrl!.isEmpty
                  ? Text(
                      _getInitials(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : null,
            )
          : CircleAvatar(
              radius: 18,
              backgroundColor: Config.primaryColor,
              child: Text(
                _getInitials(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
    );
  }
}
