import 'dart:async';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import 'package:salon_customer/page/bottom_navigation_bar.dart';
import 'package:salon_customer/page/onboarding/pay_after_service_onboarding_page.dart';
import 'package:salon_customer/project_specific/ProgressContainerView.dart';
import 'package:salon_customer/project_specific/button_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

import '../../main.dart';
import 'create_profile_page.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io';

class OtpScreenPage extends StatefulWidget {
  final bool isLogin;
  final String mobileNumber;
  const OtpScreenPage(
      {super.key, required this.mobileNumber, required this.isLogin});

  @override
  State<OtpScreenPage> createState() => _OtpScreenPageState();
}

class _OtpScreenPageState extends State<OtpScreenPage> {
  /*---------------- Controller Define -------------*/
  final _otpTextEditingController = TextEditingController();
  int _start = 60;
  bool isResendOTp = false;
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      body: Obx(
        () => ProgressContainerView(
          isProgressRunning: _authController.showProgress,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// 🖼️ GIF
                    SizedBox(
                      height: 250,
                      width: 250,
                      child: Image.asset("assets/gifs/login_gif.gif",
                          fit: BoxFit.cover),
                    ),

                    /// 🎯 TITLE
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 20, // ✅ same size for both lines
                                fontWeight: FontWeight.w700, // ✅ Bold
                                height: 1.2, // ✅ tight line spacing
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(text: "Enter the OTP\n"),
                                const TextSpan(text: "Sent to +91 "),
                                TextSpan(
                                  text: widget.mobileNumber,
                                  style: const TextStyle(
                                    color:
                                        Color(0xFF8B5CF6), // ✅ purple highlight
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Transform.translate(
                            offset: const Offset(0, 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .maybePop(); // 🔥 go to login page
                              },
                              child: const Icon(
                                Icons.edit, // ✅ edit icon
                                size: 20, // 🔥 small & clean
                                color: Color(0xFF8B5CF6), // match your theme
                              ),
                            ),
                          )
                        ]),

                    const SizedBox(height: 30),

                    /// 🔢 OTP FIELD (UNCHANGED LOGIC)
                    Center(
                        child: SizedBox(
                      width: 44 * 6 + 15 * 5,
                      child: PinCodeTextField(
                        autoDisposeControllers: false,
                        appContext: context,
                        length: 6,
                        controller: _otpTextEditingController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        //spacing: 12,
                        textStyle: const TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),

                        onChanged: (value) {},

                        /// ✅ SAME LOGIC
                        onCompleted: (val) {
                          _otpTextEditingController.text = val;
                          doOtp();
                        },

                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,

                          /// 🎯 SIZE MATCH
                          fieldHeight: 44, // ✅ exact
                          fieldWidth: 44, // ✅ exact

                          /// 🎯 BORDER
                          borderWidth: 1,
                          borderRadius: BorderRadius.circular(5), // ✅ exact

                          /// 🎯 COLORS
                          inactiveColor: Colors.black,
                          activeColor: Colors.black,
                          selectedColor: const Color(0xFF8B5CF6),

                          inactiveFillColor: Colors.transparent,
                          activeFillColor: const Color(0xFFEDE9FE),
                          selectedFillColor: Colors.transparent,
                        ),

                        enableActiveFill: true,
                      ),
                    )),

                    const SizedBox(height: 15),

                    /// 🔁 RESEND SECTION (UNCHANGED LOGIC)
                    Center(
                        child: SizedBox(
                            width: 44 * 6 + 15 * 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Didn’t Receive the OTP?",
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 18, // ✅ Figma
                                    fontWeight: FontWeight.w600, // ✅ SemiBold
                                    color: Colors.black,
                                  ),
                                ),
                                isResendOTp
                                    ? GestureDetector(
                                        onTap: () {
                                          _authController.doResendOTP(
                                              mobileNo: widget.mobileNumber,
                                              cc: "91");
                                          setState(() {
                                            _start = 60;
                                            isResendOTp = false;
                                            startTimer();
                                          });
                                        },
                                        child: const Text(
                                          "Resend",
                                          style: TextStyle(
                                            fontFamily: "Outfit",
                                            fontSize: 18, // ✅ Figma
                                            fontWeight:
                                                FontWeight.w800, // ✅ ExtraBold
                                            color: Color(0xFF8B5CF6),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        "00:${_start.toString().padLeft(2, '0')}",
                                        style: const TextStyle(
                                          fontFamily: "Outfit",
                                          fontSize: 18, // ✅ match
                                          fontWeight:
                                              FontWeight.w800, // ✅ ExtraBold
                                          color: Color(0xFF8B5CF6),
                                        ),
                                      ),
                              ],
                            ))),

                    const SizedBox(height: 20),

                    /// 🚀 BUTTON (UNCHANGED FUNCTION)
                    ButtonWidget(
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
                      color: changeTheme(SharedPrefs.readStringValue(
                              PrefConstants.gender)) ??
                          ColorConstant.primaryColor,
                      onPress: () {
                        doOtp(); // ✅ SAME FUNCTION
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String hashPhone(String phone) {
    return sha256.convert(utf8.encode(phone)).toString();
  }

  /*---------- header widget ---------*/
  Container _headerWidget() {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.only(top: 50, left: 21, right: 21, bottom: 35),
      decoration: BoxDecoration(
        color: changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)) ??
            ColorConstant.primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).maybePop();
                },
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorConstant.whiteColor,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: ColorConstant.whiteColor,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),
          Text(
            "Enter the OTP \nSent to +91 ${widget.mobileNumber}",
            style: AppTextTheme.bold
                .copyWith(color: ColorConstant.whiteColor, fontSize: 23),
          ),
        ],
      ),
    );
  }

  /*-------------  OTP  Code  -------*/
  Padding _otpCodeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Code",
            style: AppTextTheme.regular
                .copyWith(fontSize: 13, color: ColorConstant.blackColor),
          ),
          const SizedBox(height: 15),
          PinCodeTextField(
            autoDisposeControllers: false,
            appContext: context,
            length: 6,
            controller: _otpTextEditingController,
            keyboardType: TextInputType.number,
            cursorColor: ColorConstant.whiteColor,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            obscureText: false,
            useHapticFeedback: true,
            enableActiveFill: true,
            enabled: true,
            animationType: AnimationType.fade,
            textStyle: AppTextTheme.bold.copyWith(
                color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)) ??
                    ColorConstant.primaryColor,
                fontSize: 16),
            animationDuration: const Duration(milliseconds: 300),
            onChanged: (value) {},
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderWidth: 1,
              inactiveFillColor: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              selectedColor: changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender)) ??
                  ColorConstant.primaryColor,
              activeFillColor: const Color(0xffE0D3FF),
              selectedFillColor: Colors.transparent,
              inactiveColor: ColorConstant.grayColor,
              activeColor: changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender)) ??
                  ColorConstant.primaryColor,
            ),
            //onCompleted: (val) {},
            onCompleted: (val) {
              _otpTextEditingController.text = val;
              doOtp(); // auto submit
            },
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Didn’t receive the OTP?",
                style: AppTextTheme.medium
                    .copyWith(fontSize: 16, color: const Color(0xff022326)),
              ),
              isResendOTp
                  ? TextButton(
                      onPressed: () {
                        _authController.doResendOTP(
                            mobileNo: widget.mobileNumber, cc: "91");
                        setState(() {
                          _start = 60;
                          isResendOTp = false;
                          startTimer();
                        });
                      },
                      child: Text(
                        "Resend",
                        style: AppTextTheme.bold.copyWith(
                          fontSize: 16,
                          color: changeTheme(SharedPrefs.readStringValue(
                                  PrefConstants.gender)) ??
                              ColorConstant.primaryColor,
                        ),
                      ))
                  : Text(
                      "Retry in 00:${_start.toString()}",
                      style: AppTextTheme.bold.copyWith(
                        fontSize: 16,
                        color: changeTheme(SharedPrefs.readStringValue(
                                PrefConstants.gender)) ??
                            ColorConstant.primaryColor,
                      ),
                    ),
            ],
          )
        ],
      ),
    );
  }

  /*--------------  Start Timer --------------*/
  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
        setState(() {
          isResendOTp = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  /*------------- doOtp --------*/
  void doOtp() {
    if (_otpTextEditingController.text.isEmpty) {
      showMessage("Please enter OTP");
    } else if (_otpTextEditingController.text.length != 6) {
      showMessage("Please enter 6 digit OTP");
    } else {
      _authController.doLogin(
          mobile: widget.mobileNumber,
          cc: "91",
          verificationCode: _otpTextEditingController.text,
          callback: () async {

            // READ DATA HERE ↓ after login completes
            final data = _authController.userResponseModel.data;

            print("🔥 LOGIN EVENT TRIGGERED");
            try {
              await facebookAppEvents.logEvent(
                name: 'fb_mobile_login',
                parameters: {
                  'ph': hashPhone("91${widget.mobileNumber}"),
                  'method': 'phone_otp',
                  //'is_new_user': data?.isNewUser == true ? 1 : 0,
                  'login_source': 'app_open',
                  'platform': Platform.isIOS ? 'ios' : 'android',
                },
              );
              await facebookAppEvents.flush();
              print("✅ FB Login Event Sent");
            } catch (e) {
              print("❌ FB Error: $e");
            }

            // CompleteRegistration for new users
            if (data?.isNewUser == true) {
              try {
                await facebookAppEvents.logEvent(
                  name: 'fb_mobile_complete_registration',
                  parameters: {
                    'ph': hashPhone("91${widget.mobileNumber}"),
                    'registration_method': 'phone_otp',
                    'platform': Platform.isIOS ? 'ios' : 'android',
                  },
                );
                await facebookAppEvents.flush();
                print("✅ FB CompleteRegistration Event Sent");
              } catch (e) {
                print("❌ FB CompleteRegistration Error: $e");
              }

              Get.to(() => CreateProfilePage(
                mobileNo: widget.mobileNumber,
              ));
            } else {
              Get.to(() => PayAfterServiceOnboardingPage.gate(
                    const BottomNavBarPage(),
                  ));
            }
          }
      );
    }
  }
}
