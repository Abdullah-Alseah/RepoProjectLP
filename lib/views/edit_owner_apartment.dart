import 'package:dashed_border/dashed_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/services/apartment_service.dart';
import 'package:marsa_app/stores/apartment_store.dart';
import 'package:marsa_app/controllers/services/storage_service.dart';
import 'package:marsa_app/models/apartment_model.dart';

class EditApartmentPage extends StatefulWidget {
  final int apartmentId;
  final Apartment? apartment;

  const EditApartmentPage({
    super.key,
    required this.apartmentId,
    this.apartment,
  });

  @override
  State<EditApartmentPage> createState() => _EditApartmentPageState();
}

class _EditApartmentPageState extends State<EditApartmentPage> {
  bool _isMounted = false;
  bool _isPageLoading = true;
  bool _isLoadingAction = false;
  int _currentImageIndex = 0;
  Apartment? _apartment;
  String? _authToken;
  bool _isOwner = false;

  String _formattedPrice = '0';
  int _bedrooms = 1;
  int _guests = 1;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<File> _selectedImages = [];
  List<ApartmentImage> _existingImages = []; // تغيير النوع إلى ApartmentImage
  List<int> _imagesToDelete = [];
  int? _mainImageId;
  final ImagePicker _picker = ImagePicker();
  bool _isHovered = false;

  final ApartmentService _apartmentService = ApartmentService();
  final ApartmentStore _apartmentStore = Get.find<ApartmentStore>();
  final StorageService _storageService = StorageService();
  bool _isSubmitting = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadApartmentData();
  }

  @override
  void dispose() {
    _isMounted = false;
    _titleController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _streetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (_isMounted) {
      setState(fn);
    }
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

  Future<void> _loadApartmentData() async {
    try {
      _safeSetState(() => _isPageLoading = true);

      // جلب بيانات المستخدم أولاً
      _userData = await _storageService.getUserData();

      if (_userData == null) {
        _showError('يجب تسجيل الدخول أولاً');
        Get.back();
        return;
      }

      final role = _userData!['role']?.toString() ?? 'user';
      if (role != 'owner') {
        _showError('يجب أن تكون مالكاً لتعديل الشقة');
        Get.back();
        return;
      }

      // جلب بيانات الشقة
      if (widget.apartment != null) {
        _apartment = widget.apartment;
      } else {
        final result = await _apartmentStore.getApartmentDetails(
          widget.apartmentId,
        );
        if (result['success'] == true && result['data'] != null) {
          _apartment = Apartment.fromJson(
            result['data'] as Map<String, dynamic>,
          );
        } else {
          _showError('تعذر تحميل بيانات الشقة');
          Get.back();
          return;
        }
      }

      // تعبئة الحقول بالبيانات الحالية
      _titleController.text = _apartment?.title ?? '';
      _priceController.text = _apartment?.price != null
          ? _formatPrice(_apartment!.price!.toString())
          : '';
      _cityController.text = _apartment?.city ?? '';
      _provinceController.text = _apartment?.province ?? '';
      _streetController.text = _apartment?.address ?? '';
      _descriptionController.text = _apartment?.description ?? '';
      _bedrooms = _apartment?.rooms ?? 1;
      _guests = _apartment?.guests ?? 1;

      // تحميل الصور الحالية
      if (_apartment != null && _apartment!.images.isNotEmpty) {
        _existingImages = List.from(_apartment!.images); // نسخ الصور الحالية

        // البحث عن الصورة الرئيسية
        final mainImage = _apartment!.images.firstWhere(
          (img) => img.isMain == true,
          orElse: () => _apartment!.images.first,
        );
        _mainImageId = mainImage.id;
      }
    } catch (e) {
      print('💥 خطأ في تحميل بيانات الشقة: $e');
      _showError('تعذر تحميل بيانات الشقة');
      Get.back();
    } finally {
      if (_isMounted) {
        _safeSetState(() => _isPageLoading = false);
      }
    }
  }

  String _formatPrice(String input) {
    try {
      String cleanInput = input.replaceAll(',', '');
      double price = double.tryParse(cleanInput) ?? 0;
      String formatted = price.toStringAsFixed(0);
      formatted = formatted.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return formatted;
    } catch (_) {
      return '0';
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      _safeSetState(() {
        final newImages = pickedFiles.map((file) => File(file.path)).toList();
        _selectedImages.addAll(newImages);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إضافة ${pickedFiles.length} ${pickedFiles.length == 1 ? 'صورة' : 'صور'} جديدة',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeExistingImage(int index) {
    if (index < _existingImages.length) {
      final imageId = _existingImages[index].id;
      _safeSetState(() {
        _existingImages.removeAt(index);
        if (imageId != null) {
          _imagesToDelete.add(imageId);
        }
      });
    }
  }

  void _removeNewImage(int index) {
    if (index < _selectedImages.length) {
      _safeSetState(() {
        _selectedImages.removeAt(index);
      });
    }
  }

  void _setAsMainImage(int imageId) {
    _safeSetState(() {
      _mainImageId = imageId;
      // تحديث حالة الصور لتعكس التغيير
      for (var image in _existingImages) {
        image.isMain = (image.id == imageId);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم تعيين الصورة كرئيسية',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearAllNewImages() {
    _safeSetState(() {
      _selectedImages.clear();
    });
  }

  // دالة تحديث البيانات إلى API
  Future<void> _updateApartment() async {
    // التحقق من البيانات
    if (_titleController.text.isEmpty) {
      _showError('يرجى إدخال عنوان العقار');
      return;
    }

    if (_priceController.text.isEmpty) {
      _showError('يرجى إدخال سعر العقار');
      return;
    }

    if (_cityController.text.isEmpty) {
      _showError('يرجى إدخال المدينة');
      return;
    }

    if (_provinceController.text.isEmpty) {
      _showError('يرجى إدخال المنطقة');
      return;
    }

    if (_streetController.text.isEmpty) {
      _showError('يرجى إدخال الشارع');
      return;
    }

    if (_descriptionController.text.isEmpty) {
      _showError('يرجى إدخال وصف للشقة');
      return;
    }

    if (_existingImages.isEmpty && _selectedImages.isEmpty) {
      _showError('يجب أن تحتوي الشقة على صورة واحدة على الأقل');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // تحويل السعر إلى رقم
      final priceString = _priceController.text.replaceAll(',', '');
      final price = double.tryParse(priceString) ?? 0.0;

      print('🔄 بدء تحديث الشقة...');
      print('🏢 معرّف الشقة: ${_apartment!.id}');
      print('📝 العنوان: ${_titleController.text}');
      print(
        '📍 الموقع: ${_cityController.text}, ${_provinceController.text}, ${_streetController.text}',
      );
      print('💰 السعر: $price');
      print('🛏️ الغرف: $_bedrooms');
      print('👥 الضيوف: $_guests');
      print('📄 الوصف: ${_descriptionController.text}');
      print('🖼️ الصور الحالية: ${_existingImages.length}');
      print('🗑️ الصور المراد حذفها: ${_imagesToDelete.length}');
      print('➕ الصور الجديدة: ${_selectedImages.length}');
      print('⭐ الصورة الرئيسية: $_mainImageId');

      // إرسال البيانات إلى API للتحديث
      final result = await _apartmentService.updateApartment(
        apartmentId: _apartment!.id!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        city: _cityController.text.trim(),
        province: _provinceController.text.trim(),
        address: _streetController.text.trim(),
        price: price,
        rooms: _bedrooms,
        guests: _guests,
        newImages: _selectedImages,
        deleteImages: _imagesToDelete,
        mainImageId: _mainImageId,
        isActive: _apartment?.isActive ?? true,
      );

      print('📊 نتيجة تحديث الشقة:');
      print('   النجاح: ${result['success']}');
      print('   الرسالة: ${result['message']}');
      print('   كود الحالة: ${result['statusCode']}');

      if (result['success'] == true) {
        _showSuccess('تم تحديث الشقة بنجاح');

        // تحديث قائمة الشقات في الـ store
        _apartmentStore.fetchApartments(refresh: true);

        // الانتظار قليلاً ثم العودة
        await Future.delayed(const Duration(seconds: 2));

        // العودة للصفحة السابقة
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        String errorMessage = result['message'] ?? 'حدث خطأ أثناء تحديث الشقة';

        // معالجة رسائل الخطأ الخاصة
        if (errorMessage.contains('Forbidden') ||
            errorMessage.contains('do not own')) {
          errorMessage = 'غير مصرح لك بتعديل هذه الشقة';
        }

        // عرض تفاصيل الخطأ إن وجدت
        if (result['errors'] != null) {
          try {
            if (result['errors'] is Map<String, dynamic>) {
              final errors = result['errors'] as Map<String, dynamic>;
              if (errors.isNotEmpty) {
                final firstErrorKey = errors.keys.first;
                final firstError = errors[firstErrorKey];
                if (firstError is List && firstError.isNotEmpty) {
                  errorMessage = firstError.first.toString();
                } else if (firstError is String) {
                  errorMessage = firstError;
                }
              }
            }
          } catch (e) {
            print('⚠️ خطأ في تحويل errors: $e');
          }
        }

        _showError(errorMessage);
      }
    } catch (e) {
      print('💥 خطأ غير متوقع: $e');
      if (e.toString().contains('403')) {
        _showError('غير مصرح لك بتعديل هذه الشقة');
      } else {
        _showError('حدث خطأ غير متوقع: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildImageWidget(ApartmentImage image, bool isExisting, int index) {
    final imageUrl = image.url;
    final imageId = image.id;
    final isMain = image.isMain == true || imageId == _mainImageId;

    return Padding(
      padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isMain ? Colors.green : Colors.grey[300]!,
                width: isMain ? 3 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[300]!.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child:
                  _buildImageUrl(imageUrl).startsWith('http') ||
                      imageUrl.startsWith('storage/')
                  ? Image.network(
                      _buildImageUrl(imageUrl),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    )
                  : Image.file(
                      File(imageUrl),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          if (isMain)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  'رئيسية',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => isExisting
                  ? _removeExistingImage(index)
                  : _removeNewImage(index),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
          if (!isMain && imageId != null && isExisting)
            Positioned(
              bottom: 6,
              left: 6,
              child: GestureDetector(
                onTap: () => _setAsMainImage(imageId),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'رئيسية',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isPageLoading) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Lottie.asset(
              'assets/icons/Sandy Loading.json',
              width: 150,
              height: 150,
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Configuration.primaryColor,
              expandedHeight: 300,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Configuration.primaryColor,
                        Configuration.secandryColor,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 130,
                      height: 150,
                      decoration: const BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: const Icon(
                        Icons.apartment_outlined,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'تعديل الشقة',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: Configuration.mainFont,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان الشقة
                    _buildSectionTitle('عنوان الشقة'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'مثال: شقة فاخرة في وسط المدينة',
                      controller: _titleController,
                    ),
                    const SizedBox(height: 24),

                    // السعر
                    _buildSectionTitle('السعر'),
                    const SizedBox(height: 8),
                    _buildPriceTextField(),
                    const SizedBox(height: 24),

                    // غرف النوم والحمامات
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('غرف النوم'),
                              const SizedBox(height: 8),
                              _buildCounter(
                                value: _bedrooms,
                                onIncrement: () => setState(() => _bedrooms++),
                                onDecrement: () => setState(() {
                                  if (_bedrooms > 1) _bedrooms--;
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('عدد الأشخاص'),
                              const SizedBox(height: 8),
                              _buildCounter(
                                value: _guests,
                                onIncrement: () => setState(() => _guests++),
                                onDecrement: () => setState(() {
                                  if (_guests > 1) _guests--;
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // الموقع
                    _buildSectionTitle('الموقع'),
                    const SizedBox(height: 16),
                    _buildSectionSubtitle('المدينة'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'مثال: دمشق',
                      controller: _cityController,
                    ),
                    const SizedBox(height: 16),
                    _buildSectionSubtitle('المنطقة'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'مثال: حي المهاجرين',
                      controller: _provinceController,
                    ),
                    const SizedBox(height: 16),
                    _buildSectionSubtitle('الشارع'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: 'مثال: إبراهيم هنانو',
                      controller: _streetController,
                    ),
                    const SizedBox(height: 24),

                    // صور العقار
                    _buildSectionTitle('صور العقار'),
                    const SizedBox(height: 12),
                    Text(
                      'يمكنك حذف الصور الحالية أو إضافة صور جديدة',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),

                    // عرض الصور الحالية
                    if (_existingImages.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الصور الحالية',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _existingImages
                                  .length, // استخدام _existingImages
                              itemBuilder: (context, index) {
                                final image = _existingImages[index];
                                return _buildImageWidget(image, true, index);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // عرض الصور الجديدة المضافة
                    if (_selectedImages.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'الصور الجديدة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const Spacer(),
                              if (_selectedImages.isNotEmpty)
                                InkWell(
                                  onTap: _clearAllNewImages,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          color: Colors.red[600],
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'حذف الجديدة',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.red[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0 ? 0 : 12,
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey[300]!
                                                  .withOpacity(0.5),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            11,
                                          ),
                                          child: Image.file(
                                            _selectedImages[index],
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        size: 40,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: GestureDetector(
                                          onTap: () => _removeNewImage(index),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 2,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),

                    // منطقة إضافة الصور
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: GestureDetector(
                        onTap: _pickImages,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            border: DashedBorder(
                              color: Configuration.secandryColor,
                              width: 2.0,
                              dashLength: 8.0,
                              dashGap: 4.0,
                            ),
                            color: Configuration.primaryColor.withAlpha(50),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Configuration.primaryColor.withAlpha(
                                    50,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey[300]!.withOpacity(0.8),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 48,
                                  color: Configuration.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),

                              Text(
                                'اضغط لإضافة صور جديدة',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Text(
                                'JPG, PNG حتى 10MB لكل صورة',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 20),

                              Container(
                                height: 46,
                                width: 180,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Configuration.primaryColor,
                                      Configuration.secandryColor,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(23),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue[300]!.withOpacity(
                                        _isHovered ? 0.5 : 0.3,
                                      ),
                                      blurRadius: _isHovered ? 12 : 8,
                                      offset: Offset(0, _isHovered ? 6 : 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.photo_library_outlined,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'إضافة صور',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // إحصاءات الصور
                    if (_existingImages.isNotEmpty ||
                        _selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue[200]!,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      color: Colors.blue[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'إحصاءات الصور',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_mainImageId != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.green[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'الصورة الرئيسية محددة',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildStatItem(
                                  'الصور الحالية',
                                  '${_existingImages.length}',
                                  Colors.blue,
                                ),
                                const SizedBox(width: 16),
                                _buildStatItem(
                                  'سيتم حذفها',
                                  '${_imagesToDelete.length}',
                                  Colors.red,
                                ),
                                const SizedBox(width: 16),
                                _buildStatItem(
                                  'الصور الجديدة',
                                  '${_selectedImages.length}',
                                  Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // الوصف
                    _buildSectionTitle('الوصف'),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[100]!,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 60,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: Configuration.mainFont,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          hintText: '...اكتب وصفاً تفصيلياً للشقة',
                          hintTextDirection: TextDirection.rtl,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // زر تحديث العقار
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Configuration.primaryColor,
                            Configuration.secandryColor,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Configuration.secandryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _isSubmitting ? null : _updateApartment,
                          child: Center(
                            child: _isSubmitting
                                ? Lottie.asset(
                                    'assets/icons/Sandy Loading.json',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.contain,
                                  )
                                : Text(
                                    'تحديث العقار',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Configuration.mainFont,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildSectionSubtitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100]!,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        child: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          style: TextStyle(fontFamily: Configuration.mainFont, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            hintText: hintText,
            hintTextDirection: TextDirection.rtl,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontFamily: Configuration.mainFont,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTextField() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100]!,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: Configuration.mainFont,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  hintText: 'أدخل السعر',
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: Configuration.mainFont,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _formattedPrice = _formatPrice(value);
                    _priceController.value = _priceController.value.copyWith(
                      text: _formattedPrice,
                      selection: TextSelection.collapsed(
                        offset: _formattedPrice.length,
                      ),
                    );
                    if (_priceController.text == '0') {
                      _priceController.text = '';
                    }
                  });
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            height: 55,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Text(
              'ل.س',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: Configuration.mainFont,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter({
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100]!,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: IconButton(
              onPressed: onDecrement,
              icon: Icon(
                Icons.remove,
                size: 24,
                color: value > 1 ? Colors.grey[700] : Colors.grey[400],
              ),
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              fontFamily: Configuration.mainFont,
            ),
          ),
          Container(
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: IconButton(
              onPressed: onIncrement,
              icon: Icon(Icons.add, size: 24, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
