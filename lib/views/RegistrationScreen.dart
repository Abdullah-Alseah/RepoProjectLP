import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marsa_app/views/privacy.dart';
import 'package:marsa_app/views/terms.dart';
import 'package:marsa_app/views/verificationScreen.dart';
import 'package:marsa_app/controllers/services/auth_service.dart';
import 'package:marsa_app/controllers/config.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Teal color from the design
  final Color _primaryColor = Configuration.primaryColor;
  final Color _fillColor = const Color(0xFFF5F5F5);

  // Controllers for text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  DateTime? _selectedDate;
  String _profileImagePath = "assets/icons/profile.png";
  File? _selectedAvatarFile;
  File? _selectedIdDocumentFile;

  String? _selectedUserType;

  final Map<String, String> _userTypes = {
    '': 'اختر نوع المستخدم',
    'tenant': 'مستأجر',
    'owner': 'مالك',
  };

  // Auth Service
  final AuthService _authService = AuthService();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(bool isAvatar) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (image != null) {
      setState(() {
        if (isAvatar) {
          _selectedAvatarFile = File(image.path);
          _profileImagePath = image.path;
        } else {
          _selectedIdDocumentFile = File(image.path);
        }
      });
    }
  }

  // Validate form
  bool _validateForm() {
    if (_firstNameController.text.isEmpty) {
      _showError('الرجاء إدخال الاسم الأول');
      return false;
    }
    if (_lastNameController.text.isEmpty) {
      _showError('الرجاء إدخال الاسم الأخير');
      return false;
    }
    if (_phoneController.text.isEmpty) {
      _showError('الرجاء إدخال رقم الهاتف');
      return false;
    }
    if (_selectedDate == null) {
      _showError('الرجاء اختيار تاريخ الميلاد');
      return false;
    }
    if (_selectedIdDocumentFile == null) {
      _showError('الرجاء رفع صورة الهوية');
      return false;
    }
    if (_selectedUserType == "") {
      _showError('الرجاء اختيار نوع المستخدم');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showError('الرجاء إدخال كلمة المرور');
      return false;
    }
    if (_passwordController.text.length < 8) {
      _showError('كلمة المرور يجب أن تكون 8 أحرف على الأقل');
      return false;
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      _showError('كلمات المرور غير متطابقة');
      return false;
    }
    if (!_agreedToTerms) {
      _showError('يجب الموافقة على الشروط والأحكام');
      return false;
    }
    return true;
  }

  // Show error message
  void _showError(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  // Show success message
  void _showSuccess(String message) {
    Get.snackbar(
      'نجاح',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  // Handle registration
  Future<void> _handleRegistration() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    print('🔄 بدء عملية التسجيل في الواجهة...');
    print('📝 البيانات المدخلة:');
    print('   الاسم الأول: ${_firstNameController.text}');
    print('   الاسم الأخير: ${_lastNameController.text}');
    print('   الهاتف: ${_phoneController.text}');
    print('   تاريخ الميلاد: $_selectedDate');
    print('   صورة الهوية: ${_selectedIdDocumentFile?.path}');
    print('   صورة الملف الشخصي: ${_selectedAvatarFile?.path}');
    print('     الدور: ${_selectedUserType.toString().trim()}');

    try {
      final result = await _authService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        dateOfBirth: _selectedDate!,
        avatarImage: _selectedAvatarFile,
        idDocumentImage: _selectedIdDocumentFile!,
        role: _selectedUserType.toString().trim(),
      );

      setState(() {
        _isLoading = false;
      });

      print('🎯 نتيجة التسجيل: $result');

      if (result['success'] == true) {
        _showSuccess(result['message'] ?? 'تم إرسال رمز التحقق');

        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.to(
            () => OTPForm(phoneNumber: _phoneController.text.trim()),
            transition: Transition.rightToLeft,
          );
        });
      } else {
        print('❌ فشل التسجيل بالتفاصيل: $result');

        // عرض الأخطاء التفصيلية
        if (result.containsKey('errors')) {
          final errors = result['errors'];
          if (errors is Map && errors.isNotEmpty) {
            errors.forEach((key, value) {
              print('   🔑 $key: $value');
            });
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              _showError(firstError.first);
            }
          }
        } else if (result.containsKey('message')) {
          _showError(result['message']);
        } else {
          _showError('حدث خطأ غير معروف');
        }
      }
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });

      print('💥 خطأ catch في الواجهة:');
      print('   🔴 الرسالة: ${e.toString()}');
      print('   🔴 Stack Trace: $stackTrace');

      _showError('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image
          Container(
            height: 350,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/background/3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 15,
            left: 15,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withAlpha(50),
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),

          // 2. Welcome Text (Over the image)
          const Positioned(
            top: 90,
            right: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "إنشاء حساب جديد",
                  style: TextStyle(
                    color: Configuration.secandryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: Configuration.mainFont,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  "أنضم ألينا واكتشف أفضل الشقق",
                  style: TextStyle(
                    color: Configuration.secandryColor,
                    fontSize: 17,
                    fontFamily: Configuration.mainFont,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // 3. The White Card Container
          Container(
            height: Configuration.screenHeight! * 0.8,
            margin: const EdgeInsets.only(
              top: 170,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 25,
                  offset: Offset(0, 5),
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Profile Picture Section
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "قم برفع صورتك الشخصية",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Configuration.mainFont,
                                    ),
                                  ),
                                  Text(
                                    "(JPG, PNG الحد الأقصى 5MB)",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                      fontFamily: Configuration.mainFont,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 25),
                              GestureDetector(
                                onTap: () => _pickImage(true),
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: _fillColor,
                                      backgroundImage:
                                          _selectedAvatarFile != null
                                          ? FileImage(_selectedAvatarFile!)
                                          : const AssetImage(
                                                  "assets/icons/profile.png",
                                                )
                                                as ImageProvider,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: CircleAvatar(
                                        radius: 15,
                                        backgroundColor: _primaryColor,
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 2. Full Name Fields
                        _buildLabel("الاسم اﻷول"),
                        _buildTextField(
                          controller: _firstNameController,
                          hint: "أدخل اسمك اﻷول",
                          suffixIcon: Icons.person,
                          keyboardType: TextInputType.text,
                        ),
                        _buildLabel("الاسم اﻷخير"),
                        _buildTextField(
                          controller: _lastNameController,
                          hint: "أدخل اسمك اﻷخير",
                          suffixIcon: Icons.person_outline,
                          keyboardType: TextInputType.text,
                        ),

                        // 4. Phone Number Field
                        _buildLabel("رقم الهاتف"),
                        _buildTextField(
                          controller: _phoneController,
                          hint: "9999 999 09",
                          suffixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        // 5. Date of Birth Field
                        _buildLabel("تاريخ الميلاد"),
                        InkWell(
                          onTap: () => _selectDate(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: _fillColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _selectedDate == null
                                        ? "يوم / شهر / سنة"
                                        : "${_selectedDate!.day} / ${_selectedDate!.month} / ${_selectedDate!.year}",
                                    style: TextStyle(
                                      color: _selectedDate == null
                                          ? Colors.grey[500]
                                          : Colors.black,
                                      fontFamily: Configuration.mainFont,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_month,
                                  color: Colors.grey[600],
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 6. ID Photo Upload Field
                        _buildLabel("صورة الهوية"),
                        InkWell(
                          onTap: () => _pickImage(false),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: _fillColor,
                              borderRadius: BorderRadius.circular(12),
                              border: _selectedIdDocumentFile != null
                                  ? Border.all(color: _primaryColor, width: 2)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  color: Colors.grey[600],
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _selectedIdDocumentFile != null
                                        ? _selectedIdDocumentFile!.path
                                              .split('/')
                                              .last
                                        : "قم برفع صورة الهوية",
                                    style: TextStyle(
                                      color: _selectedIdDocumentFile != null
                                          ? Colors.black
                                          : Colors.grey[500],
                                      fontFamily: Configuration.mainFont,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  color: _primaryColor,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 5),
                          child: Text(
                            "(JPG, PNG الحد الأقصى 5MB)",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontFamily: Configuration.mainFont,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 7. Password Field
                        _buildLabel("كلمة المرور"),
                        _buildPasswordField(
                          controller: _passwordController,
                          hint: "أدخل كلمة المرور",
                          obscureText: _obscurePassword,
                          onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 5),
                          child: Text(
                            "يجب أن تحتوي على 8 أحرف ورقم ورمز على الأقل",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontFamily: Configuration.mainFont,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 8. Confirm Password Field
                        _buildLabel("تأكيد كلمة المرور"),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hint: "أعد إدخال كلمة المرور",
                          obscureText: _obscureConfirmPassword,
                          onToggle: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // داخل الـ Column
                        SizedBox(height: 20),
                        _buildLabel('نوع المستخدم'),
                        DropdownButtonFormField<String>(
                          value: _selectedUserType,
                          decoration: InputDecoration(
                            // labelText: 'نوع المستخدم',
                            labelStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          items: _userTypes.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: entry.key.isEmpty
                                      ? Colors.grey[500]
                                      : Colors.grey[800],
                                ),
                              ),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء اختيار نوع المستخدم';
                            }
                            return null;
                          },
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedUserType = newValue;
                              print(newValue);
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // 9. Terms and Conditions Checkbox
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                activeColor: _primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _agreedToTerms = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "أوافق على ",
                              style: TextStyle(
                                fontFamily: Configuration.mainFont,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(const TermsPage());
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  "الشروط واﻷحكام",
                                  style: TextStyle(
                                    color: Configuration.secandryColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Configuration.mainFont,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              " و ",
                              style: TextStyle(
                                fontFamily: Configuration.mainFont,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(const PrivacyPage());
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  "سياسية الخصوصية",
                                  style: TextStyle(
                                    color: Configuration.secandryColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Configuration.mainFont,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // 10. Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegistration,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "إنشاء الحساب",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: Configuration.mainFont,
                                    ),
                                  ),
                          ),
                        ),
                        Configuration.spaceBig,

                        // Create Account Footer
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "لديك حساب بالفعل؟  ",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontFamily: Configuration.mainFont,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed("/login");
                                  },
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Text(
                                      "تسجيل الدخول",
                                      style: TextStyle(
                                        color: Configuration.secandryColor,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Configuration.mainFont,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Labels
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          fontFamily: Configuration.mainFont,
        ),
      ),
    );
  }

  // Helper for Standard Text Fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? suffixIcon,
    required TextInputType keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        style: TextStyle(fontFamily: Configuration.mainFont),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontFamily: Configuration.mainFont,
          ),
          filled: true,
          fillColor: _fillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: Colors.grey[600], size: 22)
              : null,
        ),
      ),
    );
  }

  // Helper for Password Fields
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(fontFamily: Configuration.mainFont),
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontFamily: Configuration.mainFont,
        ),
        filled: true,
        fillColor: _fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Icon(Icons.lock_outline, color: Colors.grey[600], size: 22),
        prefixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey[600],
            size: 22,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
