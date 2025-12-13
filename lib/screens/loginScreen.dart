import 'package:flutter/material.dart';
import 'package:marsa_app/screens/RegistrationScreen.dart';
import 'package:marsa_app/screens/homeScreen.dart';
import 'package:marsa_app/utils/config.dart';
import 'package:get/get.dart';
import 'package:marsa_app/utils/main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _passConroller = TextEditingController();
  final _numberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Config.init(context);
    return 
    Scaffold(
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

          // 2. Welcome Text (Over the image)
          const Positioned(
            top: 200,
            right: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "مرحباً بعودتك",
                  style: TextStyle(
                    color: Config.secandryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: Config.mainFont,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "سجل الدخول للوصول إلى حسابك",
                  style: TextStyle(
                    color: Config.secandryColor,
                    fontSize: 16,
                    fontFamily: Config.mainFont,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // 3. The White Card Container
          Container(
            height: Config.screenHeight! * 0.6,
            margin: const EdgeInsets.only(
              top: 300,
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // PhoneNumber Field
                  Text(
                    "رقم الهاتف",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Config.secandryColor,
                      fontSize: 16,
                      fontFamily: Config.mainFont,
                    ),
                  ),

                  Config.spaceSmall,

                  TextFormField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontFamily: Config.mainFont),
                    decoration: InputDecoration(
                      hintText: "09 9999 9999",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: Config.mainFont,
                      ),
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

                  Config.spaceMedium,

                  // Password Field
                  const Text(
                    "كلمة المرور",
                    style: TextStyle(
                      color: Config.secandryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: Config.mainFont,
                    ),
                  ),
                  Config.spaceSmall,

                  TextFormField(
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(fontFamily: Config.mainFont),
                    decoration: InputDecoration(
                      hintText: "أدخل كلمة المرور",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontFamily: Config.mainFont,
                      ),
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

                  Config.spaceBig,

                  // Forgot Password
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
                            fontFamily: Config.mainFont,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Config.spaceSmall,

                  // Login Button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: GestureDetector(
                        onTap: () {
                          Get.offNamed("/");
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
                              fontFamily: Config.mainFont,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Config.spaceBig,

                  // Create Account Footer
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(RegistrationPage());
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text(
                                "إنشاء حساب جديد ",
                                style: TextStyle(
                                  color: Config.secandryColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: Config.mainFont,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            "ليس لديك حساب؟     ",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: Config.mainFont,
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
        ],
      ),
    );
  }
}
