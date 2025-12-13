import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:marsa_app/utils/config.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Teal color from the design
  final Color _primaryColor = Config.primaryColor;
  final Color _fillColor = const Color(0xFFF5F5F5);

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  DateTime? _selectedDate;
  String? _profileImage = "assets/icons/profile.png";

  // Helper method to pick a date
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
              primary: _primaryColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
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
                  setState(() {
                    Get.toNamed("/login");
                  });
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
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
                    color: Config.secandryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: Config.mainFont,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  "أنضم ألينا واكتشف أفضل الشقق",
                  style: TextStyle(
                    color: Config.secandryColor,
                    fontSize: 17,
                    fontFamily: Config.mainFont,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // 3. The White Card Container
          Container(
            height: Config.screenHeight! * 0.8,
            margin: const EdgeInsets.only(
              top: 170,
              left: 50,
              right: 50,
              bottom: 0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 25,
                  offset: const Offset(0, 5),
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
                                      fontFamily: Config.mainFont,
                                    ),
                                  ),
                                  Text(
                                    "(JPG, PNG الحد الأقصى 5MB)",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                      fontFamily: Config.mainFont,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 25),
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: _fillColor,
                                    backgroundImage: AssetImage(_profileImage!),
                                    child: Text(""),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor: _primaryColor,
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _profileImage =
                                                "assets/icons/profile.png";
                                          });
                                        },
                                        icon: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 2. Full Name Field
                        _buildLabel("الاسم الكامل"),
                        _buildTextField(
                          hint: "أدخل اسمك الكامل",
                          suffixIcon: Icons.person_outline,
                          keyboardType: TextInputType.text,
                        ),

                        // 3. Email Field
                        _buildLabel("البريد الإلكتروني"),
                        _buildTextField(
                          hint: "example@email.com",
                          suffixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        // 4. Phone Number Field
                        _buildLabel("رقم الهاتف"),
                        _buildTextField(
                          hint: "+963 9X XXX XXXX",
                          suffixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        // 5. Date of Birth Field (Custom InkWell)
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
                                      fontFamily: Config.mainFont,
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

                        // 6. ID Photo Upload Field (Custom InkWell)
                        _buildLabel("صورة الهوية"),
                        InkWell(
                          onTap: () {
                            // Handle file upload tap
                          },
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
                                  Icons.badge_outlined,
                                  color: Colors.grey[600],
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "قم برفع صورة الهوية",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontFamily: Config.mainFont,
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
                              fontFamily: Config.mainFont,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 7. Password Field
                        _buildLabel("كلمة المرور"),
                        _buildPasswordField(
                          hint: "أدخل كلمة المرور",
                          obscureText: _obscurePassword,
                          onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 5),
                          child: Text(
                            "يجب أن تحتوي على 8 أحرف على الأقل",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontFamily: Config.mainFont,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 8. Confirm Password Field
                        _buildLabel("تأكيد كلمة المرور"),
                        _buildPasswordField(
                          hint: "أعد إدخال كلمة المرور",
                          obscureText: _obscureConfirmPassword,
                          onToggle: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
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
                              style: TextStyle(fontFamily: Config.mainFont),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  "الشروط واﻷحكام",
                                  style: TextStyle(
                                    color: Config.secandryColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Config.mainFont,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              " و ",
                              style: TextStyle(fontFamily: Config.mainFont),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  "سياسية الخصوصية",
                                  style: TextStyle(
                                    color: Config.secandryColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Config.mainFont,
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
                            onPressed: () {
                              // Handle form submission
                              Get.toNamed("/");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "إنشاء الحساب",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: Config.mainFont,
                              ),
                            ),
                          ),
                        ),
                        Config.spaceBig,

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
                                    fontFamily: Config.mainFont,
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
                                        color: Config.secandryColor,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Config.mainFont,
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
          fontFamily: Config.mainFont,
        ),
      ),
    );
  }

  // Helper for Standard Text Fields
  Widget _buildTextField({
    required String hint,
    IconData? suffixIcon,
    required TextInputType keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        style: TextStyle(fontFamily: Config.mainFont),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontFamily: Config.mainFont,
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
          // In RTL, suffixIcon appears on the left
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: Colors.grey[600], size: 22)
              : null,
        ),
      ),
    );
  }

  // Helper for Password Fields
  Widget _buildPasswordField({
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      style: TextStyle(fontFamily: Config.mainFont),
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontFamily: Config.mainFont,
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
        // Lock icon on the left (suffix in RTL)
        suffixIcon: Icon(Icons.lock_outline, color: Colors.grey[600], size: 22),
        // Eye icon on the right (prefix in RTL)
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
