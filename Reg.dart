import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:marsa_app/screens/terms.dart';
import 'package:marsa_app/utils/config.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final Color _primaryColor = Config.primaryColor;
  final Color _fillColor = const Color(0xFFF5F5F5);

  // --- المتحكمات (Controllers) للربط مع Laravel ---
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false; // لحالة التحميل
  DateTime? _selectedDate;

  File? _avatarFile; // الصورة الشخصية
  File? _idDocumentFile; // صورة الهوية

  final ImagePicker _picker = ImagePicker();

  // دالة اختيار الصور
  Future<void> _pickImage(bool isAvatar) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        if (isAvatar) {
          _avatarFile = File(pickedFile.path);
        } else {
          _idDocumentFile = File(pickedFile.path);
        }
      });
    }
  }

  // دالة الربط مع Laravel API
  Future<void> _register() async {
    if (!_agreedToTerms) {
      Get.snackbar(
        "تنبيه",
        "يجب الموافقة على الشروط والأحكام",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (_idDocumentFile == null) {
      Get.snackbar(
        "تنبيه",
        "يجب رفع صورة الهوية",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // تغيير الرابط ليتناسب مع جهازك
      var uri = Uri.parse("http://10.0.2.2:8000/api/register");
      var request = http.MultipartRequest('POST', uri);

      // إضافة النصوص (تطابق مسميات Laravel Controller)
      request.fields['first_name'] = _firstNameController.text;
      request.fields['last_name'] = _lastNameController.text;
      request.fields['phone'] = _phoneController.text;
      request.fields['password'] = _passwordController.text;
      request.fields['password_confirmation'] = _confirmPasswordController.text;
      request.fields['date_of_birth'] = _selectedDate != null
          ? "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}"
          : "";
      request.fields['role'] = 'tenant';

      // إضافة الملفات (Images)
      if (_avatarFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('avatar_url', _avatarFile!.path),
        );
      }
      request.files.add(
        await http.MultipartFile.fromPath(
          'id_document_url',
          _idDocumentFile!.path,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar(
          "نجاح",
          "تم إرسال رمز التحقق بنجاح",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.toNamed("/verification"); // توجه لصفحة الـ OTP
      } else {
        // عرض أول خطأ قادم من Laravel Validation
        String errorMsg =
            data['message'] ??
            "تأكد من البيانات (كلمة المرور يجب أن تكون قوية)";
        Get.snackbar(
          "فشل التسجيل",
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "تعذر الاتصال بالسيرفر: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية الصورة
          Container(
            height: 350,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 15,
            child: CircleAvatar(
              backgroundColor: Colors.white.withAlpha(50),
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),

          // محتوى البطاقة البيضاء
          Container(
            height: Config.screenHeight! * 0.8,
            margin: const EdgeInsets.only(top: 170, left: 30, right: 30),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)],
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // رفع الصورة الشخصية
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _pickImage(true),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: _fillColor,
                              backgroundImage: _avatarFile != null
                                  ? FileImage(_avatarFile!)
                                  : const AssetImage("assets/icons/profile.png")
                                        as ImageProvider,
                              child: _avatarFile == null
                                  ? const Icon(
                                      Icons.camera_alt,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),
                          const Text(
                            "الصورة الشخصية",
                            style: TextStyle(
                              fontFamily: Config.mainFont,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("الاسم الأول"),
                    _buildTextField(
                      hint: "الاسم الأول",
                      controller: _firstNameController,
                      keyboardType: TextInputType.name,
                    ),

                    _buildLabel("الاسم الأخير"),
                    _buildTextField(
                      hint: "الكنية",
                      controller: _lastNameController,
                      keyboardType: TextInputType.name,
                    ),

                    _buildLabel("رقم الهاتف"),
                    _buildTextField(
                      hint: "09xxxxxxxx",
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),

                    _buildLabel("تاريخ الميلاد"),
                    _buildInkField(
                      text: _selectedDate == null
                          ? "اختر التاريخ"
                          : "${_selectedDate!.toLocal()}".split(' ')[0],
                      icon: Icons.calendar_today,
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("صورة الهوية"),
                    _buildInkField(
                      text: _idDocumentFile == null
                          ? "ارفع صورة الهوية (مطلوب)"
                          : "تم اختيار الصورة",
                      icon: Icons.badge_outlined,
                      onTap: () => _pickImage(false),
                      color: _idDocumentFile != null ? Colors.green : null,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("كلمة المرور"),
                    _buildPasswordField(
                      hint: "********",
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),

                    const SizedBox(height: 15),
                    _buildLabel("تأكيد كلمة المرور"),
                    _buildPasswordField(
                      hint: "********",
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      onToggle: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          activeColor: _primaryColor,
                          onChanged: (v) => setState(() => _agreedToTerms = v!),
                        ),
                        const Text(
                          "أوافق على الشروط والأحكام",
                          style: TextStyle(
                            fontFamily: Config.mainFont,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "إنشاء الحساب",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // أدوات مساعدة لبناء الحقول (Helpers)
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: Config.mainFont,
      ),
    ),
  );

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildInkField({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _fillColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.grey),
            const SizedBox(width: 10),
            Text(text, style: TextStyle(color: color ?? Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _fillColor,
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
