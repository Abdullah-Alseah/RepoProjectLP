import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:marsa_app/controllers/main_layout_controller.dart';
import 'package:marsa_app/controllers/services/test_connection.dart';
import 'package:marsa_app/views/components/apartment_card.dart';
import 'package:marsa_app/stores/apartment_store.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/services/profile_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final MainLayoutController controller = Get.put(MainLayoutController());

  String? _avatarUrl;
  String? _firstName;
  String? _lastName;
  bool _isLoading = true;
  bool _logged = false;
  final ProfileService _profileService = ProfileService();
  final ApartmentStore apartmentStore = ApartmentStore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apartmentStore.fetchApartments();
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
        _avatarUrl =
            'http://${Configuration.baseUrl}:8000/storage/$rawAvatarUrl';
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
    Configuration.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        color: Configuration.primaryColor,
        backgroundColor: Colors.white,
        strokeWidth: 3.0,
        displacement: 40.0,
        edgeOffset: 0,
        notificationPredicate: (ScrollNotification notification) {
          // السماح بالسحب للتحديث فقط عند الوصول للقمة
          return notification.metrics.pixels == 0;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // AppBar الأول
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              actions: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Configuration.primaryColor.withAlpha(80),
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
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/background/3.jpg'),
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
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.white,
                                blurRadius: 30,
                                offset: Offset(0, 25),
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
                    color: Configuration.secandryColor,
                    fontFamily: Configuration.mainFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // AppBar الثاني (للبحث)
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              expandedHeight: 50,
              toolbarHeight: 50,
              // pinned: true,
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
                            style: TextStyle(
                              fontFamily: Configuration.mainFont,
                            ),
                            decoration: InputDecoration(
                              hintText: "...ابحث عن موقع، مدينة",
                              hintTextDirection: TextDirection.rtl,
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
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

            Obx(() {
              if (apartmentStore.isLoading &&
                  apartmentStore.apartments.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/icons/Sandy Loading.json', // تأكد من صحة المسار
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'جاري تحميل الشقق...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (apartmentStore.errorMessage.isNotEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade400,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'حدث خطأ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            apartmentStore.errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              apartmentStore.fetchApartments(refresh: true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Configuration.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (apartmentStore.apartments.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد شقق متاحة',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'يمكنك المحاولة مرة أخرى لاحقاً',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            apartmentStore.fetchApartments(refresh: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Configuration.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('إعادة التحميل'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  // إذا كان هناك المزيد من البيانات وأصبحنا في النهاية
                  if (index == apartmentStore.apartments.length) {
                    if (apartmentStore.hasMore) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              apartmentStore.isLoading
                                  ? Lottie.asset(
                                      'assets/icons/Sandy Loading.json', // تأكد من صحة المسار
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.contain,
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        apartmentStore.loadMoreApartments();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Configuration.primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('تحميل المزيد'),
                                    ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox(height: 10); // مسافة في النهاية
                  }

                  // عرض بطاقة الشقة
                  final apartment = apartmentStore.apartments[index];
                  return ApartmentCardWidget(
                    apartment: apartment,
                    index: index,
                  );
                }, childCount: apartmentStore.apartments.length + 1),
              );
            }),
            SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
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
          controller.goToPage(3);
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
                    Configuration.primaryColor,
                  ),
                ),
              ),
            )
          : !_logged
          ? CircleAvatar(
              radius: 18,
              backgroundColor: Configuration.primaryColor,
              child: const Icon(Icons.login, color: Colors.white, size: 20),
            )
          : _avatarUrl != null && _avatarUrl!.isNotEmpty
          ? CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(_avatarUrl!),
              onBackgroundImageError: (exception, stackTrace) {
                print('❌ خطأ في تحميل الصورة: $exception');
                print('🔗 رابط الصورة: $_avatarUrl');
                Future.microtask(() {
                  if (mounted) {
                    setState(() => _avatarUrl = null);
                  }
                });
              },
              child: _avatarUrl == null || _avatarUrl!.isEmpty
                  ? Text(
                      _getInitials(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : null,
            )
          : CircleAvatar(
              radius: 18,
              backgroundColor: Configuration.primaryColor,
              child: Text(
                _getInitials(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
    );
  }

  Future<void> _refreshData() async {
    // تنفيذ كلتا العمليتين في نفس الوقت
    await Future.wait([
      apartmentStore.fetchApartments(refresh: true),
      _loadProfileData(),
    ]);
  }
}
