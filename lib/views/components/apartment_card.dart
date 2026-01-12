import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/services/profile_service.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/models/apartment_model.dart';
import 'package:marsa_app/stores/apartment_store.dart';
import 'package:marsa_app/stores/favorite_store.dart';
import 'package:marsa_app/views/bookingScreen.dart';

class ApartmentCardWidget extends StatefulWidget {
  final Apartment apartment;
  final int? index;
  final VoidCallback? onFavoriteChanged;

  const ApartmentCardWidget({
    super.key,
    required this.apartment,
    this.index,
    this.onFavoriteChanged,
  });

  @override
  State<ApartmentCardWidget> createState() => _ApartmentCardWidgetState();
}

class _ApartmentCardWidgetState extends State<ApartmentCardWidget> {
  bool isFav = false;
  bool _isLoading = false;
  bool _logged = false;
  String? _authToken;

  bool _isInitialized = false;
  bool _isCheckingFavorite = false;

  CancelToken? _cancelToken;
  Future<Uint8List>? _imageFuture;

  final ProfileService _profileService = ProfileService();
  final ApartmentStore _apartmentStore = ApartmentStore.instance;
  final FavoriteStore _favoriteStore = FavoriteStore.instance;
  final StorageService _storageService = StorageService();
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _isInitialized = true;
    _cancelToken = CancelToken();

    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    try {
      await _loadProfileData();
      await _checkIfFavorite();
    } catch (e) {
      print('⚠️ خطأ في التهيئة: $e');
    }
  }

  Future<void> _loadProfileData() async {
    if (!mounted) return;

    try {
      if (mounted) {
        setState(() => _isLoading = true);
      }

      _authToken = await _storageService.getToken();
      _logged = _authToken != null && _authToken!.isNotEmpty;

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('💥 خطأ في تحميل البروفايل: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkIfFavorite() async {
    if (!mounted) return;

    try {
      if (mounted) {
        setState(() => _isCheckingFavorite = true);
      }

      if (!_logged) {
        if (mounted) {
          setState(() {
            isFav = false;
            _isCheckingFavorite = false;
          });
        }
        return;
      }

      final userRole = await _storageService.getUserRole();
      if (userRole != 'tenant') {
        if (mounted) {
          setState(() {
            isFav = false;
            _isCheckingFavorite = false;
          });
        }
        return;
      }

      await _favoriteStore.checkFavoriteStatus(widget.apartment.id);

      if (mounted) {
        setState(() {
          isFav = _favoriteStore.isFavorite(widget.apartment.id);
          _isCheckingFavorite = false;
        });
      }
    } catch (e) {
      print('⚠️ خطأ في التحقق من المفضلة: $e');
      if (mounted) {
        setState(() {
          isFav = false;
          _isCheckingFavorite = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isCheckingFavorite || !mounted) return;

    try {
      if (mounted) {
        setState(() => _isCheckingFavorite = true);
      }

      if (!_logged) {
        Get.snackbar(
          'يرجى تسجيل حساب أولاً',
          'لا يمكن إضافة إلى المفضلة بدون تسجيل حساب',
          backgroundColor: Configuration.primaryColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.toNamed('/login');
        if (mounted) {
          setState(() => _isCheckingFavorite = false);
        }
        return;
      }

      final userRole = await _storageService.getUserRole();
      if (userRole != 'tenant') {
        Get.snackbar(
          'غير مسموح',
          'فقط المستأجرون يمكنهم إضافة مفضلة',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        if (mounted) {
          setState(() => _isCheckingFavorite = false);
        }
        return;
      }

      await _favoriteStore.toggleFavorite(widget.apartment.id);
      final newState = _favoriteStore.isFavorite(widget.apartment.id);

      if (mounted) {
        setState(() {
          isFav = newState;
          _isCheckingFavorite = false;
        });
      }

      if (widget.onFavoriteChanged != null) {
        widget.onFavoriteChanged!();
      }
    } catch (e) {
      print('💥 خطأ في تعديل المفضلة: $e');

      final actualState = _favoriteStore.isFavorite(widget.apartment.id);

      if (mounted) {
        setState(() {
          isFav = actualState;
          _isCheckingFavorite = false;
        });
      }

      Get.snackbar(
        'خطأ',
        'فشل في تحديث المفضلة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  void dispose() {
    _isInitialized = false;
    _cancelToken?.cancel('Widget disposed');

    if (_imageFuture != null) {
      _imageFuture = null;
    }

    _dio.close();

    super.dispose();
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: _toggleFavorite,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: (_isCheckingFavorite || _isLoading)
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isFav ? Colors.red : Colors.grey,
                ),
              )
            : Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : Colors.grey,
                size: 20,
              ),
      ),
    );
  }

  String _buildImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    if (imagePath.startsWith('storage/')) {
      return 'http://${Configuration.baseUrl}:8000/$imagePath';
    } else if (imagePath.startsWith('apartments/')) {
      return 'http://${Configuration.baseUrl}:8000/storage/$imagePath';
    } else if (imagePath.contains('.jpg') ||
        imagePath.contains('.png') ||
        imagePath.contains('.jpeg')) {
      return 'http://${Configuration.baseUrl}:8000/storage/apartments/$imagePath';
    } else {
      return 'http://${Configuration.baseUrl}:8000/storage/apartments/$imagePath';
    }
  }

  String _getMainImage() {
    try {
      if (widget.apartment.images.isEmpty) return '';

      final mainImage = widget.apartment.images.firstWhere(
        (img) => img.isMain,
        orElse: () => widget.apartment.images.first,
      );

      return _buildImageUrl(mainImage.url);
    } catch (e) {
      return '';
    }
  }

  String _formatPrice(double price) {
    try {
      return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ل.س';
    } catch (e) {
      return '0 ل.س';
    }
  }

  String _getFullAddress() {
    try {
      final city = widget.apartment.city.isNotEmpty
          ? widget.apartment.city
          : '';
      final province = widget.apartment.province.isNotEmpty
          ? widget.apartment.province
          : '';
      final address = widget.apartment.address.isNotEmpty
          ? widget.apartment.address
          : '';

      final parts = [
        city,
        province,
        address,
      ].where((part) => part.isNotEmpty).toList();
      return parts.join('، ');
    } catch (e) {
      return 'العنوان غير متوفر';
    }
  }

  String _getArea() {
    try {
      return '${widget.apartment.rooms * 50} م²';
    } catch (e) {
      return '100 م²';
    }
  }

  Future<Uint8List> _loadImageWithAuth(String imageUrl) async {
    try {
      final options = Options(
        responseType: ResponseType.bytes,
        // cancelToken: _cancelToken,
        headers: _authToken != null && _authToken!.isNotEmpty
            ? {'Authorization': 'Bearer $_authToken'}
            : {},
      );

      final response = await _dio.get<Uint8List>(imageUrl, options: options);

      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      } else {
        throw Exception('فشل تحميل الصورة');
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        throw FlutterError('تم إلغاء تحميل الصورة');
      }
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = _formatPrice(widget.apartment.price);
    final address = _getFullAddress();
    final nameApartment = widget.apartment.title.isNotEmpty
        ? widget.apartment.title
        : 'شقة فاخرة';
    final room = widget.apartment.rooms > 0
        ? widget.apartment.rooms.toString()
        : '3';
    final guests = widget.apartment.guests > 0
        ? widget.apartment.guests.toString()
        : '2';
    final area = _getArea();
    final mainImageUrl = _getMainImage();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Material(
          // ✅ إضافة Material هنا
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () {
              _apartmentStore.selectApartment(widget.apartment);
              Get.toNamed(
                '/apartmentDetails',
                arguments: {
                  'apartmentId': widget.apartment.id,
                  'apartment': widget.apartment,
                },
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildImageAndOverlays(mainImageUrl),
                  _buildDetailsSection(
                    price: price,
                    address: address,
                    nameApartment: nameApartment,
                    room: room,
                    guests: guests,
                    area: area,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageAndOverlays(String imageUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Stack(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: imageUrl.isNotEmpty
                ? _buildNetworkImage(imageUrl)
                : _buildDefaultImage(),
          ),
          Positioned(top: 15, left: 15, child: _buildFavoriteButton()),
          if (widget.apartment.isActive && widget.apartment.price > 1000000)
            Positioned(
              top: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: Configuration.spacialGradientColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'مميز',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    _imageFuture = _loadImageWithAuth(imageUrl);

    return FutureBuilder<Uint8List>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (!mounted) {
          return _buildDefaultImage();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Lottie.asset(
              'assets/icons/Sandy Loading.json',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildDefaultImage();
        }

        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultImage();
            },
          );
        }

        return _buildDefaultImage();
      },
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      color: Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apartment, size: 50, color: Colors.grey.shade500),
          const SizedBox(height: 8),
          Text(
            widget.apartment.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection({
    required String price,
    required String address,
    required String nameApartment,
    required String room,
    required String guests,
    required String area,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nameApartment,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Tajawal',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: 'Tajawal',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _specItem(Icons.king_bed_outlined, '$room غرف'),
              const SizedBox(width: 15),
              _specItem(Icons.groups_sharp, '$guests أشخاص'),
              const SizedBox(width: 15),
              _specItem(Icons.aspect_ratio, area),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(height: 1),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Configuration.primaryColor,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  Text(
                    'لليلة الواحدة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
              Material(
                // ✅ إضافة Material حول IconButton
                color: Configuration.primaryColor,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    if (_logged) {
                      Get.to(
                        () => BookingPage(
                          apartmentId: widget.apartment.id,
                          apartment: widget.apartment,
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
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!widget.apartment.isActive)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'غير متاحة حالياً',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _specItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Configuration.primaryColor, size: 18),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }
}
