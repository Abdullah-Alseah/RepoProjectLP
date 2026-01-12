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

class AddApartmentPage extends StatefulWidget {
  const AddApartmentPage({super.key});

  @override
  State<AddApartmentPage> createState() => _AddApartmentPageState();
}

class _AddApartmentPageState extends State<AddApartmentPage> {
  String _formattedPrice = '0';
  int _bedrooms = 1;
  int _guests = 1;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<File> _selectedImages = [];
  File? _mainImage;
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
    _checkUserRole();
  }

  // التحقق من صلاحية المستخدم
  Future<void> _checkUserRole() async {
    try {
      _userData = await _storageService.getUserData();
      print('👤 بيانات المستخدم: $_userData');

      if (_userData != null) {
        final role = _userData!['role']?.toString() ?? 'user';
        // final isApproved = _userData!['is_approved'] ?? false;

        print('🎭 دور المستخدم: $role');
      } else {
        _showError('يجب تسجيل الدخول أولاً');
      }
    } catch (e) {
      print('❌ خطأ في التحقق من صلاحية المستخدم: $e');
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
      setState(() {
        // تحويل الصور المختارة إلى قائمة Files
        final newImages = pickedFiles.map((file) => File(file.path)).toList();

        // إذا كانت هناك صورة رئيسية حالياً، نضعها أولاً في القائمة الجديدة
        if (_mainImage != null && _selectedImages.contains(_mainImage)) {
          // إضافة الصورة الرئيسية أولاً
          _selectedImages.clear();
          _selectedImages.add(_mainImage!);

          // إضافة الصور الجديدة بعد الصورة الرئيسية
          _selectedImages.addAll(newImages);
        } else {
          // لا توجد صورة رئيسية حالياً، نضيف الصور الجديدة فقط
          _selectedImages.addAll(newImages);

          // تعيين أول صورة كصورة رئيسية
          if (_selectedImages.isNotEmpty && _mainImage == null) {
            _mainImage = _selectedImages.first;
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إضافة ${pickedFiles.length} ${pickedFiles.length == 1 ? 'صورة' : 'صور'} بنجاح',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickMainImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 90,
    );

    if (pickedFile != null) {
      final newMainImage = File(pickedFile.path);

      setState(() {
        // إزالة الصورة الجديدة إذا كانت موجودة مسبقاً
        _selectedImages.removeWhere((img) => img.path == newMainImage.path);

        // إضافة الصورة الجديدة في البداية
        _selectedImages.insert(0, newMainImage);

        // تعيينها كصورة رئيسية
        _mainImage = newMainImage;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تعيين الصورة الرئيسية بنجاح',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      final removedImage = _selectedImages[index];

      // إذا كنا نحذف الصورة الرئيسية
      if (removedImage == _mainImage) {
        _selectedImages.removeAt(index);

        // تعيين صورة رئيسية جديدة إذا كان هناك صور متبقية
        if (_selectedImages.isNotEmpty) {
          _mainImage = _selectedImages.first;
        } else {
          _mainImage = null;
        }
      } else {
        // إذا لم تكن الصورة الرئيسية، فقط احذفها
        _selectedImages.removeAt(index);
      }
    });
  }

  void _setAsMainImage(int index) {
    setState(() {
      final selectedImage = _selectedImages[index];

      // إذا كانت الصورة المختارة هي نفسها الصورة الرئيسية الحالية
      if (selectedImage == _mainImage) return;

      // حفظ الصورة المختارة
      _mainImage = selectedImage;

      // إعادة ترتيب القائمة: وضع الصورة الرئيسية في الموقع 0
      _selectedImages.removeAt(index); // إزالة الصورة من موقعها الحالي
      _selectedImages.insert(0, _mainImage!); // وضعها في البداية
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

  void _clearAllImages() {
    setState(() {
      _selectedImages.clear();
      _mainImage = null;
    });
  }

  // دالة إرسال البيانات إلى API
  Future<void> _submitApartment() async {
    // التحقق من صلاحية المستخدم أولاً
    if (_userData == null) {
      _showError('يجب تسجيل الدخول أولاً');
      return;
    }

    final role = _userData!['role']?.toString() ?? 'user';
    // final isApproved = _userData!['is_approved'] ?? false;

    if (role != 'owner') {
      _showError('يجب أن تكون مالكاً لإضافة شقة');
      return;
    }

    // if (!(isApproved == 1)) {
    //   _showError('حسابك قيد المراجعة. يرجى الانتظار حتى الموافقة');
    //   return;
    // }

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

    if (_selectedImages.isEmpty) {
      _showError('يرجى إضافة صورة على الأقل');
      return;
    }

    // تأكيد أن الصورة الرئيسية هي أول صورة في القائمة
    if (_mainImage != null &&
        _selectedImages.isNotEmpty &&
        _selectedImages.first != _mainImage) {
      // إعادة ترتيب القائمة لضمان أن الصورة الرئيسية أولاً
      setState(() {
        _selectedImages.removeWhere((img) => img == _mainImage);
        _selectedImages.insert(0, _mainImage!);
      });
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // تحويل السعر إلى رقم
      final priceString = _priceController.text.replaceAll(',', '');
      final price = double.tryParse(priceString) ?? 0.0;

      print('🚀 بدء إضافة الشقة...');
      print('👤 المستخدم: ${_userData!['id']} - ${_userData!['name']}');
      print('📝 العنوان: ${_titleController.text}');
      print(
        '📍 الموقع: ${_cityController.text}, ${_provinceController.text}, ${_streetController.text}',
      );
      print('💰 السعر: $price');
      print('🛏️ الغرف: $_bedrooms');
      print('👥 الضيوف: $_guests');
      print('📄 الوصف: ${_descriptionController.text}');
      print('🖼️ عدد الصور: ${_selectedImages.length}');
      print(
        '⭐ الصورة الرئيسية (الأولى في القائمة): ${_selectedImages.first.path}',
      );

      // إرسال البيانات إلى API
      final result = await _apartmentService.createApartment(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        city: _cityController.text.trim(),
        province: _provinceController.text.trim(),
        address: _streetController.text.trim(),
        price: price,
        rooms: _bedrooms,
        guests: _guests,
        images: _selectedImages,
        isActive: true,
      );

      print('📊 نتيجة إضافة الشقة:');
      print('   النجاح: ${result['success']}');
      print('   الرسالة: ${result['message']}');
      print('   كود الحالة: ${result['statusCode']}');

      if (result['success'] == true) {
        _showSuccess('تم إضافة العقار بنجاح');

        // تحديث قائمة الشقات في الـ store
        _apartmentStore.fetchApartments(refresh: true);

        // مسح الحقول بعد النجاح
        _clearForm();

        // الانتظار قليلاً ثم العودة
        await Future.delayed(const Duration(seconds: 2));

        // العودة للصفحة السابقة
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        String errorMessage = result['message'] ?? 'حدث خطأ أثناء إضافة العقار';

        // معالجة رسائل الخطأ الخاصة
        if (errorMessage.contains('Unauthorized') ||
            errorMessage.contains('غير مصرح')) {
          errorMessage =
              'غير مصرح لك بإضافة شقة. يجب أن تكون مالكاً ومفعل الحساب';
        } else if (errorMessage.contains('Only approved owners')) {
          errorMessage = 'حسابك قيد المراجعة. يرجى الانتظار حتى الموافقة';
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
        _showError('غير مصرح لك بإضافة شقة. يجب أن تكون مالكاً ومفعل الحساب');
      } else if (e.toString().contains('String') &&
          e.toString().contains('Map<String, dynamic>')) {
        _showError('خطأ في استجابة الخادم. يرجى المحاولة مرة أخرى');
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

  void _clearForm() {
    _titleController.clear();
    _priceController.clear();
    _areaController.clear();
    _cityController.clear();
    _provinceController.clear();
    _streetController.clear();
    _descriptionController.clear();

    setState(() {
      _bedrooms = 1;
      _guests = 1;
      _formattedPrice = '0';
      _selectedImages.clear();
      _mainImage = null;
    });
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

  // إضافة معلومات المستخدم في الواجهة
  Widget _buildUserInfo() {
    if (_userData == null) return const SizedBox();

    final role = _userData!['role']?.toString() ?? 'user';
    // final isApproved = _userData!['is_approved'] ?? false;
    final userName = _userData!['name'] ?? _userData!['first_name'] ?? 'مستخدم';

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: role == 'owner' ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: role == 'owner' ? Colors.green[200]! : Colors.orange[200]!,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            role == 'owner' ? Icons.verified : Icons.info_outline,
            color: role == 'owner' ? Colors.green[600] : Colors.orange[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً $userName',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role == 'owner'
                      ? 'حسابك مفعل كمالك. يمكنك إضافة شقق.'
                      : role == 'owner'
                      ? 'حسابك قيد المراجعة كمالك. يرجى الانتظار حتى الموافقة.'
                      : 'يجب أن تكون مالكاً لإضافة شقق.',
                  style: TextStyle(
                    fontSize: 12,
                    color: role == 'owner'
                        ? Colors.green[700]
                        : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
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
                'إضافة شقة جديدة',
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
                  // معلومات المستخدم
                  _buildUserInfo(),

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
                    'يجب إضافة صورة رئيسية واحدة على الأقل',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),

                  // عرض الصور المختارة
                  if (_selectedImages.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'الصور المضافة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const Spacer(),
                            if (_selectedImages.isNotEmpty)
                              InkWell(
                                onTap: _clearAllImages,
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
                                        'حذف الكل',
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
                              final image = _selectedImages[index];
                              final isMainImage =
                                  index ==
                                  0; // الصورة الأولى دائماً هي الرئيسية

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
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isMainImage
                                              ? Colors.green
                                              : Colors.grey[300]!,
                                          width: isMainImage ? 3 : 1.5,
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
                                        borderRadius: BorderRadius.circular(11),
                                        child: Image.file(
                                          image,
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
                                    if (isMainImage)
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
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
                                        onTap: () => _removeImage(index),
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
                                                offset: const Offset(0, 1),
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
                                    if (!isMainImage)
                                      Positioned(
                                        bottom: 6,
                                        left: 6,
                                        child: GestureDetector(
                                          onTap: () => _setAsMainImage(index),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[700],
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
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
                                color: Configuration.primaryColor.withAlpha(50),
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
                              'اسحب الصور أو اضغط للرفع',
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
                                      'اختيار الصور',
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
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green[200]!,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'تم إضافة ${_selectedImages.length} ${_selectedImages.length == 1 ? 'صورة' : 'صور'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (_mainImage != null)
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
                                    'الصورة الأولى هي الرئيسية',
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
                      maxLines: 6,
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

                  // زر إضافة العقار
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
                        onTap: () {
                          // التحقق من صلاحية المستخدم قبل الإرسال
                          if (_userData == null) {
                            _showError('يجب تسجيل الدخول أولاً');
                            return;
                          }

                          final role = _userData!['role']?.toString() ?? 'user';
                          // final isApproved = _userData!['is_approved'] ?? false;

                          if (role != 'owner') {
                            _showError('يجب أن تكون مالكاً لإضافة شقة');
                            return;
                          }

                          // if (!(isApproved == 1)) {
                          //   _showError(
                          //     'حسابك قيد المراجعة. يرجى الانتظار حتى الموافقة',
                          //   );
                          //   return;
                          // }

                          if (!_isSubmitting) {
                            _submitApartment();
                          }
                        },
                        child: Center(
                          child: _isSubmitting
                              ? Lottie.asset(
                                  'assets/icons/Sandy Loading.json', // تأكد من صحة المسار
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                )
                              : Text(
                                  'إضافة العقار',
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
          Container(
            padding: const EdgeInsets.all(16),
            height: 55,
            decoration: BoxDecoration(
              // color: Colors.grey,
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
