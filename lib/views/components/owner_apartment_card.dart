import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/models/apartment_model.dart';
import 'package:marsa_app/stores/apartment_store.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/views/owner_apartment_details_screen.dart';

class OwnerApartmentCardWidget extends StatefulWidget {
  final Apartment apartment;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;
  final int? index;

  const OwnerApartmentCardWidget({
    super.key,
    required this.apartment,
    this.onUpdate,
    this.onDelete,
    this.index,
  });

  @override
  State<OwnerApartmentCardWidget> createState() =>
      _OwnerApartmentCardWidgetState();
}

class _OwnerApartmentCardWidgetState extends State<OwnerApartmentCardWidget> {
  bool _isLoading = false;
  final ApartmentStore _apartmentStore = ApartmentStore.instance;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
  }

  // دالة لتنسيق السعر
  String _formatPrice(double price) {
    try {
      return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ل.س';
    } catch (e) {
      return '0 ل.س';
    }
  }

  // دالة للحصول على العنوان الكامل
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

  // دالة للحصول على المساحة
  String _getArea() {
    try {
      return '${widget.apartment.rooms * 50} م²';
    } catch (e) {
      return '100 م²';
    }
  }

  // دالة للحصول على الصورة الرئيسية
  String _getMainImage() {
    try {
      if (widget.apartment.images.isEmpty) {
        return '';
      }

      final mainImage = widget.apartment.images.firstWhere(
        (img) => img.isMain,
        orElse: () => widget.apartment.images.first,
      );

      // بناء URL الصورة
      if (mainImage.url.startsWith('http://') ||
          mainImage.url.startsWith('https://')) {
        return mainImage.url;
      } else {
        return 'http://${Configuration.baseUrl}:8000/storage/${mainImage.url}';
      }
    } catch (e) {
      return '';
    }
  }

  // دالة حذف الشقة
  Future<void> _deleteApartment() async {
    final BuildContext context = this.context;

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'تأكيد الحذف',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Configuration.mainFont,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('هل أنت متأكد من حذف هذه الشقة؟'),
              const SizedBox(height: 10),
              Text(
                widget.apartment.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              const Text('لا يمكن التراجع عن هذا الإجراء'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: Configuration.mainFont,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'حذف',
                style: TextStyle(
                  fontFamily: Configuration.mainFont,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );

      if (result == true) {
        setState(() => _isLoading = true);

        final deleteResult = await _apartmentStore.deleteApartment(
          widget.apartment.id,
        );

        if (deleteResult['success'] == true) {
          // استخدام التحديث الذكي بدلاً من إعادة التحميل الكامل
          _apartmentStore.refreshAfterDelete(widget.apartment.id);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الشقة بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // استدعاء callback إذا كان موجوداً
          if (widget.onDelete != null) {
            widget.onDelete!();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(deleteResult['message'] ?? 'فشل حذف الشقة'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الحذف: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = _formatPrice(widget.apartment.price);
    final address = _getFullAddress();
    final nameApartment = widget.apartment.title.isNotEmpty
        ? widget.apartment.title
        : 'شقة';
    final room = widget.apartment.rooms > 0
        ? widget.apartment.rooms.toString()
        : '0';
    final guests = widget.apartment.guests > 0
        ? widget.apartment.guests.toString()
        : '0';
    final area = _getArea();
    final mainImageUrl = _getMainImage();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
              // صورة الشقة مع الأزرار العلوية
              _buildImageSection(mainImageUrl),

              // تفاصيل الشقة
              _buildDetailsSection(
                price: price,
                address: address,
                nameApartment: nameApartment,
                room: room,
                guests: guests,
                area: area,
              ),

              // أزرار التحكم (التعديل والحذف)
              _buildControlButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(String imageUrl) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      // عرض Lottie بدلاً من CircularProgressIndicator
                      return Center(
                        child: Lottie.asset(
                          'assets/icons/Sandy Loading.json', // تأكد من صحة المسار
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultImage();
                    },
                  )
                : _buildDefaultImage(),
          ),
        ),

        // فهرس الشقة
        if (widget.index != null)
          Positioned(
            top: 15,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Configuration.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#${widget.index! + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
      ],
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
          // العنوان والموقع
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
                  ],
                ),
              ),

              // السعر
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          // المواصفات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _specItem(Icons.king_bed_outlined, '$room غرف'),
              _specItem(Icons.groups_sharp, '$guests أشخاص'),
              _specItem(Icons.aspect_ratio, area),
            ],
          ),

          const SizedBox(height: 15),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _specItem(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: Configuration.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // زر تعديل
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                      // تحديد الشقة للتحرير
                      _apartmentStore.selectApartment(widget.apartment);
                      Get.toNamed(
                        '/editApartment',
                        arguments: {'apartment': widget.apartment},
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                foregroundColor: Colors.blue.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.edit, size: 20),
              label: const Text(
                'تعديل',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // زر حذف
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _deleteApartment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.delete, size: 20),
              label: const Text('حذف', style: TextStyle(fontFamily: 'Tajawal')),
            ),
          ),

          const SizedBox(width: 10),

          // زر التفاصيل
          Container(
            decoration: BoxDecoration(
              color: Configuration.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () {
                _apartmentStore.selectApartment(widget.apartment);
                Get.toNamed(
                  '/ownerApartmentDetails',
                  arguments: {
                    'apartmentId': widget.apartment.id,
                    'apartment': widget.apartment,
                  },
                );
              },
              icon: const Icon(
                Icons.remove_red_eye_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
