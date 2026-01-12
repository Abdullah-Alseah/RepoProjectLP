import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:marsa_app/controllers/callNumber.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/sendMail.dart';
import 'package:marsa_app/controllers/services/profile_service.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/controllers/services/test_connection.dart';
import 'package:marsa_app/models/apartment_model.dart';
import 'package:marsa_app/stores/apartment_store.dart';
import 'package:marsa_app/stores/favorite_store.dart';
import 'package:marsa_app/views/bookingScreen.dart';

class ApartmentDetailsScreen extends StatefulWidget {
  final int apartmentId;
  final Apartment? apartment;

  const ApartmentDetailsScreen({
    super.key,
    required this.apartmentId,
    this.apartment,
  });

  @override
  State<ApartmentDetailsScreen> createState() => _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> {
  final ProfileService _profileService = ProfileService();
  final ApartmentStore _apartmentStore = ApartmentStore.instance;
  final FavoriteStore _favoriteStore = FavoriteStore.instance;
  final StorageService _storageService = StorageService();

  bool _isMounted = false;
  bool _isPageLoading = true; // تحميل الصفحة
  bool _isFavoriteLoading = false; // تحميل المفضلة فقط
  bool _logged = false;
  int _currentImageIndex = 0;
  Apartment? _apartment;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadProfileData();
      await _loadApartmentData();

      if (_logged && _apartment != null) {
        await _favoriteStore.checkFavoriteStatus(_apartment!.id);
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (_isMounted) {
      setState(fn);
    }
  }

  Future<void> _loadProfileData() async {
    try {
      _authToken = await _profileService.getToken();
      _logged = _authToken != null && _authToken!.isNotEmpty;
    } catch (e) {
      print('⚠️ خطأ في تحميل البروفايل: $e');
    }
  }

  Future<void> _loadApartmentData() async {
    try {
      _safeSetState(() => _isPageLoading = true);

      // إذا تم تمرير بيانات الشقة مباشرة، استخدمها
      if (widget.apartment != null) {
        _apartment = widget.apartment;
      } else {
        // أو جلب البيانات من الـ API
        final result = await _apartmentStore.getApartmentDetails(
          widget.apartmentId,
        );
        if (result['success'] == true && result['data'] != null) {
          _apartment = Apartment.fromJson(
            result['data'] as Map<String, dynamic>,
          );
        } else {
          Get.snackbar(
            'خطأ',
            'تعذر تحميل بيانات الشقة',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          Get.back();
          return;
        }
      }
    } catch (e) {
      print('💥 خطأ في تحميل بيانات الشقة: $e');
      Get.snackbar(
        'خطأ',
        'تعذر تحميل بيانات الشقة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back();
    } finally {
      if (_isMounted) {
        _safeSetState(() => _isPageLoading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (!_logged) {
      Get.snackbar(
        'يرجى تسجيل حساب أولاً',
        'لا يمكن إضافة إلى المفضلة بدون تسجيل حساب',
        backgroundColor: Configuration.primaryColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.toNamed('/login');
      return;
    }

    // التحقق من دور المستخدم
    final userRole = await _storageService.getUserRole();
    if (userRole != 'tenant') {
      Get.snackbar(
        'غير مسموح',
        'فقط المستأجرون يمكنهم إضافة مفضلة',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // ✅ التحقق من وجود apartment
    if (_apartment == null) {
      print('⚠️ الشقة غير موجودة لتغيير حالة المفضلة');
      return;
    }

    // ✅ الحصول على الحالة الحالية من الـ Store
    final currentState = _favoriteStore.isFavorite(_apartment!.id);

    print('🖱️ نقرة على زر المفضلة للشقة #${_apartment!.id}');
    print('   - الحالة الحالية في الـ Store: $currentState');

    try {
      _safeSetState(() => _isFavoriteLoading = true);

      // ✅ استخدام toggleFavorite من الـ Store
      await _favoriteStore.toggleFavorite(_apartment!.id);

      print('   - ${currentState ? '🗑️ أزيلت' : '✅ أضيفت'} من المفضلة');
    } catch (e) {
      print('💥 خطأ في تعديل المفضلة: $e');
      print('   - نوع الخطأ: ${e.runtimeType}');

      Get.snackbar(
        'خطأ',
        'فشل في تحديث المفضلة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      if (_isMounted) {
        _safeSetState(() => _isFavoriteLoading = false);
      }
    }
  }

  Widget _buildFavoriteButton() {
    return GetBuilder<FavoriteStore>(
      builder: (store) {
        final isFavorite = _apartment != null
            ? store.isFavorite(_apartment!.id)
            : false;

        return GestureDetector(
          onTap: _toggleFavorite,
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isFavoriteLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                  )
                : Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                    size: 24,
                  ),
          ),
        );
      },
    );
  }

  String _buildImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';

    if (imagePath.startsWith('http')) return imagePath;

    final baseUrl = 'http://${Configuration.baseUrl}:8000';

    if (imagePath.startsWith('storage/')) {
      return '$baseUrl/$imagePath';
    } else if (imagePath.startsWith('apartments/')) {
      return '$baseUrl/storage/$imagePath';
    }

    return '$baseUrl/storage/apartments/$imagePath';
  }

  List<String> _getAllImages() {
    if (_apartment == null || _apartment!.images.isEmpty) {
      return [];
    }

    return _apartment!.images.map((img) => _buildImageUrl(img.url)).toList();
  }

  String _formatPrice(double price) {
    try {
      return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    } catch (_) {
      return '0';
    }
  }

  Map<String, String> _getPrices() {
    if (_apartment == null) {
      return {'month': '0', 'week': '0', 'day': '0'};
    }

    final price = _apartment!.price;
    final priceMonth = (price).round(); // شهري
    final priceWeek = (price / 7).round(); // أسبوعي
    final priceDay = (price / 30).round(); // يومي

    return {
      'month': _formatPrice(priceMonth.toDouble()),
      'week': _formatPrice(priceWeek.toDouble()),
      'day': _formatPrice(priceDay.toDouble()),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isPageLoading) {
      return _buildLoadingScreen();
    }

    if (_apartment == null) {
      return _buildErrorScreen();
    }

    final images = _getAllImages();
    final prices = _getPrices();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageHeader(images),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleSection(),
                        const SizedBox(height: 12),
                        _buildQuickSpecs(),
                        const SizedBox(height: 20),
                        _buildPriceCard(prices),
                        const SizedBox(height: 25),
                        _buildSectionTitle("الوصف"),
                        const SizedBox(height: 10),
                        _buildDescription(),
                        const SizedBox(height: 25),
                        _buildSectionTitle("صور الشقة"),
                        const SizedBox(height: 10),
                        _buildImageGallery(images),
                        const SizedBox(height: 25),
                        _buildSectionTitle("المالك"),
                        const SizedBox(height: 15),
                        _buildOwnerCard(),
                        const SizedBox(height: 90), // مساحة لزر الحجز
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildBookingButton(),
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
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
              'جاري تحميل بيانات الشقة...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: Configuration.mainFont,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              const Text(
                'تعذر تحميل بيانات الشقة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: Configuration.mainFont,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'حدث خطأ في تحميل البيانات',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: Configuration.mainFont,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Configuration.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('العودة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader(List<String> images) {
    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          // الصورة الرئيسية
          if (images.isNotEmpty)
            PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) {
                _safeSetState(() => _currentImageIndex = index);
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 350,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Lottie.asset(
                        'assets/icons/Sandy Loading.json', // تأكد من صحة المسار
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  cacheManager: CacheManager(
                    Config(
                      "apartment_detail_images",
                      stalePeriod: const Duration(days: 7),
                      maxNrOfCacheObjects: 50,
                    ),
                  ),
                  httpHeaders: _authToken != null && _authToken!.isNotEmpty
                      ? {'Authorization': 'Bearer $_authToken'}
                      : null,
                );
              },
            )
          else
            Container(
              height: 350,
              color: Colors.grey.shade200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apartment,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _apartment?.title ?? 'لا توجد صور',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontFamily: Configuration.mainFont,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // مؤشر الصفحات
          if (images.length > 1)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_currentImageIndex + 1} / ${images.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: Configuration.mainFont,
                  ),
                ),
              ),
            ),

          // زر المفضلة
          Positioned(top: 30, right: 0, child: _buildFavoriteButton()),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _apartment?.title ?? 'بدون عنوان',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: Configuration.mainFont,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _apartment != null
                    ? '${_apartment!.city}، ${_apartment!.province}، ${_apartment!.address}'
                    : 'العنوان غير متوفر',
                style: TextStyle(
                  fontFamily: Configuration.mainFont,
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickSpecs() {
    if (_apartment == null) return const SizedBox();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildSpecBadge(Icons.aspect_ratio, '${_apartment!.rooms * 50} م²'),
        _buildSpecBadge(Icons.groups_sharp, '${_apartment!.guests} أشخاص'),
        _buildSpecBadge(Icons.bed_outlined, '${_apartment!.rooms} غرف'),
        if (_apartment!.isActive) _buildSpecBadge(Icons.check_circle, 'متاحة'),
      ],
    );
  }

  Widget _buildSpecBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Configuration.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Configuration.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: Configuration.mainFont,
              color: Configuration.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(Map<String, String> prices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPriceItem('الإيجار الشهري', '${prices['month']} ل.س'),
            _buildPriceItem('الإيجار الأسبوعي', '${prices['week']} ل.س'),
            _buildPriceItem('الإيجار اليومي', '${prices['day']} ل.س'),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceItem(String title, String price) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Configuration.primaryColor.withOpacity(0.9),
              Configuration.primaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: Configuration.mainFont,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: Configuration.mainFont,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _apartment?.description ?? 'لا يوجد وصف',
        style: TextStyle(
          fontFamily: Configuration.mainFont,
          color: Colors.black87,
          height: 1.6,
          fontSize: 14,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    if (images.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'لا توجد صور إضافية',
            style: TextStyle(
              color: Colors.grey,
              fontFamily: Configuration.mainFont,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _safeSetState(() => _currentImageIndex = index);
            },
            child: Container(
              width: 120,
              height: 100,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == images.length - 1 ? 0 : 8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _currentImageIndex == index
                      ? Configuration.primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Lottie.asset(
                        'assets/icons/Sandy Loading.json', // تأكد من صحة المسار
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOwnerCard() {
    if (_apartment == null || _apartment!.owner == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Text(
            'معلومات المالك غير متاحة',
            style: TextStyle(
              fontFamily: Configuration.mainFont,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    final owner = _apartment!.owner!;
    final ownerPhone = owner.phone ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Configuration.primaryColor.withOpacity(0.1),
                backgroundImage: NetworkImage(owner.avatarUrl!),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      owner.name,
                      style: TextStyle(
                        fontFamily: Configuration.mainFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (ownerPhone.isNotEmpty) ...[
                      Text(
                        ownerPhone,
                        style: TextStyle(
                          fontFamily: Configuration.mainFont,
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (owner.isApproved)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    'موثّق',
                    style: TextStyle(
                      fontFamily: Configuration.mainFont,
                      color: Colors.green.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (ownerPhone.isNotEmpty) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      openWhatsApp(
                        ownerPhone,
                        message: "مرحباً، أود الاستفسار عن الشقة",
                      );
                    },
                    icon: const Icon(FontAwesomeIcons.whatsapp, size: 18),
                    label: const Text('محادثة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Configuration.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (owner.email.isNotEmpty) {
                      callNumber(ownerPhone);
                    }
                  },
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('اتصال'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: SizedBox(
        height: 55,
        child: ElevatedButton(
          onPressed: _isPageLoading
              ? null
              : () {
                  if (_logged) {
                    Get.to(
                      () => BookingPage(
                        apartmentId: _apartment!.id,
                        apartment: _apartment!,
                      ),
                    );
                  } else {
                    Get.snackbar(
                      'يرجى تسجيل حساب أولاً',
                      'لا يمكن حجز شقة بدون تسجيل حساب',
                      backgroundColor: Configuration.primaryColor,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    Get.toNamed('/login');
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: Configuration.gradientColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Configuration.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              alignment: Alignment.center,
              child: _isPageLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      "حجز الشقة",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: Configuration.mainFont,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 40,
      left: 16,
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.black45,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: Configuration.mainFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
