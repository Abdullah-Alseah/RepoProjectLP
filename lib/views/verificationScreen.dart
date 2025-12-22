import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:marsa_app/controllers/services/auth_service.dart';
import 'package:marsa_app/controllers/config.dart';

class OTPForm extends StatefulWidget {
  final String phoneNumber;

  const OTPForm({super.key, required this.phoneNumber});

  @override
  State<OTPForm> createState() => _OTPFormState();
}

class _OTPFormState extends State<OTPForm> {
  final List<TextEditingController> _otpControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResendEnabled = false;
  int _resendTimer = 60; // 60 ثانية
  late String _phoneNumber;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _phoneNumber = widget.phoneNumber;
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _isResendEnabled = false;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendTimer--;
        });
        if (_resendTimer > 0) {
          _startResendTimer();
        } else {
          setState(() {
            _isResendEnabled = true;
          });
        }
      }
    });
  }

  String _getMaskedPhoneNumber() {
    if (_phoneNumber.length >= 10) {
      return '${_phoneNumber.substring(_phoneNumber.length - 2)}×××××${_phoneNumber.substring(0, 3)}';
    }
    return _phoneNumber;
  }

  String _getFullOTP() {
    String otp = '';
    for (var controller in _otpControllers) {
      otp += controller.text;
    }
    return otp;
  }

  Future<void> _verifyOTP() async {
    final otp = _getFullOTP();

    if (otp.length != 5) {
      Get.snackbar(
        'خطأ',
        'الرجاء إدخال رمز التحقق المكون من 5 أرقام',
        backgroundColor: Colors.red.withAlpha(70),
        colorText: Colors.black,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.verifyOtp(
        phone: _phoneNumber,
        otp: otp,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        Get.snackbar(
          'نجاح',
          result['message'] ?? 'تم التحقق بنجاح',
          backgroundColor: Colors.green.withAlpha(70),
          colorText: Colors.black,
        );

        // الانتقال للصفحة الرئيسية أو التالية
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAllNamed('/'); // غير هذا إلى المسار المناسب
        });
      } else {
        Get.snackbar(
          'خطأ',
          result['message'] ?? 'رمز التحقق غير صحيح',
          backgroundColor: Colors.red.withAlpha(70),
          colorText: Colors.black,
        );

        // مسح الحقول
        for (var controller in _otpControllers) {
          controller.clear();
        }
        if (_focusNodes[0].canRequestFocus) {
          _focusNodes[0].requestFocus();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء التحقق: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _resendOTP() async {
    if (!_isResendEnabled) return;

    setState(() {
      _isResendEnabled = false;
      _resendTimer = 60;
    });

    Get.snackbar(
      'إعادة الإرسال',
      'تم إرسال رمز تحقق جديد',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );

    await _authService.resendOtp(phone: _phoneNumber);

    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Body
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Config.spaceBig,
    
              // Back Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back),
                  color: Config.primaryColor,
                ),
              ),
    
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "رمز التحقق",
                  style: TextStyle(
                    color: Config.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: Config.mainFont,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Text(
                  "أدخل رمز التحقق المُرسَل إلى رقم هاتفك",
                  style: TextStyle(
                    color: Config.primaryColor,
                    fontSize: 16,
                    fontFamily: Config.mainFont,
                  ),
                ),
              ),
    
              Padding(
                padding: const EdgeInsets.only(right: 20.0, top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        "تغيير رقم الهاتف؟",
                        style: TextStyle(
                          color: Config.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: Config.mainFont,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _getMaskedPhoneNumber(),
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Config.primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: Config.mainFont,
                      ),
                    ),
                  ],
                ),
              ),
    
              SizedBox(height: 25),
    
              // OTP Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    return SizedBox(
                      height: 60,
                      width: 55,
                      child: TextFormField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        textInputAction: index == 4
                            ? TextInputAction.done
                            : TextInputAction.next,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: Config.mainFont,
                          color: Config.primaryColor,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Config.primaryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Config.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 4) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
    
                          // إذا تم ملء جميع الحقول، تحقق تلقائياً
                          if (index == 4 && value.length == 1) {
                            final otp = _getFullOTP();
                            if (otp.length == 5) {
                              // إزالة التركيز من آخر حقل
                              _focusNodes[index].unfocus();
                              _verifyOTP();
                            }
                          }
                        },
                        onEditingComplete: () {
                          if (index == 4) {
                            _verifyOTP();
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
    
              Config.spaceSmall,
    
              // Resend Timer
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: _isResendEnabled
                      ? TextButton(
                          onPressed: _resendOTP,
                          child: Text(
                            "إعادة إرسال رمز التحقق",
                            style: TextStyle(
                              color: Config.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: Config.mainFont,
                            ),
                          ),
                        )
                      : Text(
                          "إعادة إرسال رمز التحقق بعد $_resendTimer ثانية",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontFamily: Config.mainFont,
                          ),
                        ),
                ),
              ),
            ],
          ),
    
          // Bottom Buttons
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Config.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            "تأكيد",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: Config.mainFont,
                            ),
                          ),
                  ),
                ),
    
                SizedBox(height: 15),
    
                // SizedBox(
                //   width: double.infinity,
                //   height: 55,
                //   child: ElevatedButton(
                //     onPressed: _isResendEnabled ? _resendOTP : null,
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.white,
                //       foregroundColor: Config.primaryColor,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(15),
                //         side: BorderSide(
                //           color: Config.primaryColor,
                //           width: 2,
                //         ),
                //       ),
                //     ),
                //     child: Text(
                //       "إعادة إرسال",
                //       style: TextStyle(
                //         fontSize: 18,
                //         fontWeight: FontWeight.bold,
                //         fontFamily: Config.mainFont,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
