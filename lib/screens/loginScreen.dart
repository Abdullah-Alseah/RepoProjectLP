import 'package:flutter/material.dart';
import 'package:marsa_app/screens/homeScreen.dart';
import 'package:marsa_app/utils/config.dart';
import 'package:marsa_app/utils/main_layout.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final _passConroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Image.asset(
              'assets/background/1.jpg',
              fit: BoxFit.cover,
              // Adding a dark overlay to make white text pop
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // 2. Welcome Text (Over the image)
          const Positioned(
            top: 100,
            right: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "مرحباً بعودتك",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial', // Replace with Cairo or Tajawal
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "سجل الدخول للوصول إلى حسابك",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          // 3. The White Card Container
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                top: 200,
                left: 50,
                right: 50,
                bottom: 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email Field
                    Text(
                      "رقم الهاتف",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Config.secandryColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "09 9999 9999",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        // In RTL, suffix is on the left
                        suffixIcon: Icon(
                          Icons.phone_iphone_outlined,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    const Text(
                      "كلمة المرور",
                      style: TextStyle(
                        color: Config.secandryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passConroller,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Config.primaryColor,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        labelText: 'Password',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.lock_outline),
                        prefixIconColor: Config.primaryColor,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: _isPasswordVisible
                              ? const Icon(
                                  Icons.visibility_off_outlined,
                                  color: Colors.black38,
                                )
                              : const Icon(
                                  Icons.visibility_outlined,
                                  color: Config.primaryColor,
                                ),
                        ),
                      ),
                    ),
                    TextFormField(
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: "أدخل كلمة المرور",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: Config.outlinedBorder,
                        // Lock on the left (Suffix in RTL)
                        suffixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey[500],
                        ),
                        // Eye on the right (Prefix in RTL)
                        prefixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey[500],
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "نسيت كلمة المرور؟",
                            style: TextStyle(
                              color: Config.secandryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: GestureDetector(
                        onTap: () {
                          // Handle Login Action
                          print("Login Pressed");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: Config.gradientColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "تسجيل الدخول",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Create Account Footer
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "إنشاء حساب جديد ",
                                style: TextStyle(
                                  color: Config.secandryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "ليس لديك حساب؟     ",
                              style: TextStyle(color: Colors.grey[600]),
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
        ],
      ),
    );
  }
}
