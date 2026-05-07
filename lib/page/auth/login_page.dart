import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import 'package:salon_customer/page/auth/otp_screen_page.dart';
import 'package:salon_customer/project_specific/ProgressContainerView.dart';
import 'package:salon_customer/project_specific/button_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class LoginPage extends StatefulWidget {
  final bool splashPage;

  const LoginPage({super.key, required this.splashPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _mobileTextEditingController = TextEditingController();
  final _authController = Get.find<AuthController>();

  bool getWhatsappUpdate = false;
  bool iAgree = false;
  bool readEula = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      resizeToAvoidBottomInset: true,
      body: Obx(
            () => ProgressContainerView(
          isProgressRunning: _authController.showProgress,
          child: SafeArea(
            child: Column(
              children: [

                /// 🔽 SCROLLABLE CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          const SizedBox(height: 20),

                          /// 🎬 FIXED GIF (no empty space)
                          ClipRect(
                            child: Align(
                              alignment: Alignment.topCenter,
                              heightFactor: 0.75,
                              child: Image.asset(
                                "assets/gifs/login_gif.gif",
                                width: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// 🎨 TITLE
                          // ShaderMask(
                          //   shaderCallback: (bounds) => const LinearGradient(
                          //     colors: [Color(0xFFCD73B4), Color(0xFF8454E5)],
                          //   ).createShader(bounds),
                          //   child: const Text(
                          //     "Welcome To Scuts",
                          //     textAlign: TextAlign.center,
                          //     style: TextStyle(
                          //       fontFamily: "Outfit",
                          //       fontSize: 35,
                          //       fontWeight: FontWeight.w900,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                          Text(
                            "Welcome To Scuts",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 40,
                              fontWeight: FontWeight.w800, // 🔥 important
                              letterSpacing: 0.2,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [Color(0xFFCD73B4), Color(0xFF8454E5)],
                                ).createShader(Rect.fromLTWH(0, 0, 350, 80)),
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// SUBTITLE
                          const Text(
                            "Log in Using Your Phone Number",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// 📱 INPUT
                          Container(
                            height: 50,
                            width: 350,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF8565D0).withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "+91 |",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 10),

                                Expanded(
                                  child: TextField(
                                      controller: _mobileTextEditingController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 14,
                                      autofillHints: const [
                                        AutofillHints.telephoneNumber
                                      ],
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) => _doLogin(),
                                      style: const TextStyle(fontSize: 16),
                                      decoration: const InputDecoration(
                                        hintText: "Enter phone number",
                                        border: InputBorder.none,
                                        counterText: "",
                                        hintStyle: TextStyle(
                                          color: Colors.black26, // 👈 reduced opacity
                                          fontSize: 16,
                                        ),
                                      ),

                                      /// ✅ CLEANING LOGIC
                                      onChanged: (value) {
                                        print(value);
                                        String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

                                        if (digits.length > 10) {
                                          digits = digits.substring(digits.length - 10);
                                        }

                                        if (digits != value) {
                                          _mobileTextEditingController.value = TextEditingValue(
                                            text: digits,
                                            selection: TextSelection.collapsed(offset: digits.length),
                                          );
                                        }
                                      }
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// 📜 TERMS
                          _termsCondition(),
                          const SizedBox(height: 20),
                          /// ✅ MOVE BUTTON HERE
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ButtonWidget(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8454E5),
                                    Color(0xFFCD73B4),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              buttonTitleText: "Continue",
                              onPress: () {
                                _doLogin();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _termsCondition() {
    // Common text style for the gray text
    const TextStyle grayStyle = TextStyle(
      fontFamily: "Outfit",
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: ColorConstant.grayTextColor,
    );

    // Common text style for the clickable black text
    const TextStyle linkStyle = TextStyle(
      fontFamily: "Outfit",
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: ColorConstant.blackColor,
      decoration: TextDecoration.underline,
    );

    return Column(
      children: [
        // --- FIRST ROW ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _customCheckbox(
              iAgree,
                  () {
                setState(() {
                  iAgree = !iAgree;
                });
              },
            ),
            const SizedBox(width: 6),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "By clicking, I accept the ",
                    style: grayStyle,
                  ),
                  TextSpan(
                    text: "Terms & Condition",
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => openUrl("https://scuts.in/terms-conditions/"),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8), // Precise control over the gap between lines

        if(Platform.isIOS)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _customCheckbox(
                readEula,
                    () {
                  setState(() {
                    readEula = !readEula;
                  });
                },
              ),
              const SizedBox(width: 6),

              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "I agree to ",
                      style: grayStyle,
                    ),
                    TextSpan(
                      text: "Privacy Policy",
                      style: linkStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => openUrl("https://scuts.in/privacy-policy/"),
                    ),
                    const TextSpan(
                      text: " ",
                      style: grayStyle,
                    ),
                    TextSpan(
                      text: "Read EULA",
                      style: linkStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showDialog(
                            context: context,
                            builder: (_) => _buildEulaDialog(),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEulaDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "End User License Agreement (EULA)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "This End User License Agreement (\"Agreement\") is a legal agreement between you and Scuts Technologies Pvt. Ltd.\n\n"
                  "1. You will not upload, share, or publish abusive content.\n"
                  "2. Zero tolerance for objectionable behavior.\n"
                  "3. We may terminate access if policies are violated.\n"
                  "4. You are responsible for your content.\n"
                  "5. Content is protected under copyright laws.\n\n"
                  "If you do not agree, do not use the app.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Reusable Checkbox Widget to keep code DRY
  Widget _customCheckbox(bool value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: value
              ? ColorConstant.primaryColor
              : Colors.transparent,
          border: Border.all(color: ColorConstant.primary2, width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(
          child: Icon(
            CupertinoIcons.checkmark_alt,
            color: value
                ? ColorConstant.whiteColor
                : Colors.transparent,
            size: 14,
          ),
        ),
      ),
    );
  }

  Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  /// 🚀 LOGIN LOGIC (UNCHANGED)
  void _doLogin() {
    if (_mobileTextEditingController.text.isEmpty) {
      showMessage("Please enter mobile Number");
    } else if (_mobileTextEditingController.text.length != 10) {
      showMessage("Please enter 10 digit mobile Number");
    } else if (!iAgree) {
      showMessage("Please accept Terms & Conditions");
    } else if (Platform.isIOS && !readEula) {
      showMessage("Please accept EULA");
    }else {
      _authController.sendOtpAndGoToOtp(
        mobileNo: _mobileTextEditingController.text,
        countryCode: "91",
      );
      // _authController.doCheckMobileNumberRegistration(
      //   mobileNo: _mobileTextEditingController.text,
      //   countryCode: "91",
      //   callback: () {
      //     Get.to(() => OtpScreenPage(
      //       mobileNumber: _mobileTextEditingController.text,
      //       isLogin: false,
      //     ));
      //   },
      // );
    }
  }
}