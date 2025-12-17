import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:marsa_app/utils/config.dart';

class OTPForm extends StatefulWidget {
  const OTPForm({super.key});

  @override
  State<OTPForm> createState() => _OTPFormState();
}

class _OTPFormState extends State<OTPForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            // decoration: BoxDecoration(gradient: Config.spacialGradientColor),
          ),
          // Body
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Verification code",
                  style: TextStyle(
                    color: Config.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: Config.mainFont,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "We have sent the code verification to",
                  style: TextStyle(
                    color: Config.primaryColor,
                    fontSize: 16,
                    fontFamily: Config.mainFont,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "096",
                      style: TextStyle(
                        color: Config.primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: Config.mainFont,
                      ),
                    ),
                    Text(
                      "×××××",
                      style: TextStyle(
                        color: Config.primaryColor,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        fontFamily: Config.mainFont,
                      ),
                    ),
                    Text(
                      "56",
                      style: TextStyle(
                        color: Config.primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: Config.mainFont,
                      ),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        "Change phone number?",
                        style: TextStyle(
                          color: Config.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: Config.mainFont,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 50),
                  SizedBox(
                    height: 68,
                    width: 64,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onSaved: (pin1) {},
                      onChanged: (Value) {
                        if (Value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      style: TextStyle(fontFamily: Config.mainFont),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 68,
                    width: 64,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onSaved: (pin2) {},
                      onChanged: (Value) {
                        if (Value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (Value.length == 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      style: TextStyle(fontFamily: Config.mainFont),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 68,
                    width: 64,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onSaved: (pin3) {},
                      onChanged: (Value) {
                        if (Value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (Value.length == 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      style: TextStyle(fontFamily: Config.mainFont),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 68,
                    width: 64,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onSaved: (pin4) {},
                      onChanged: (Value) {
                        if (Value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (Value.length == 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      style: TextStyle(fontFamily: Config.mainFont),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 68,
                    width: 64,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onSaved: (pin5) {},
                      onChanged: (Value) {
                        if (Value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (Value.length == 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      style: TextStyle(fontFamily: Config.mainFont),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Resend code after",
                    style: TextStyle(
                      color: Config.primaryColor,
                      // fontSize: 20,
                      // fontWeight: FontWeight.bold,
                      fontFamily: Config.mainFont,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    "1:06",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 186, 228),
                      fontFamily: Config.mainFont,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Bottom Buttons
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 200,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Config.secandryColor,
                        shadowColor: Colors.black,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Resend",
                          style: TextStyle(
                            fontSize: 18,
                            color: Config.secandryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: Config.mainFont,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Config.secandryColor,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.cyanAccent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Confirm",
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
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
