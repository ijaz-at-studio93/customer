import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import 'package:salon_customer/page/bottom_navigation_bar.dart';
import 'package:salon_customer/project_specific/ProgressContainerView.dart';
import 'package:salon_customer/project_specific/button_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

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
          child: Column(
            children: [
              _headerWidget(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 35),
                      _otpCodeField(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 35),
                        child: ButtonWidget(
                            buttonTitleText: "Continue",
                            color: changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender)) ??
                                ColorConstant.primaryColor,
                            onPress: () {
                              doOtp();
                            }),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*---------- header widget ---------*/
  _headerWidget() {
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
                  Get.back();
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
  _otpCodeField() {
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
            onCompleted: (val) {},
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
  startTimer() {
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
  doOtp() {
    if (_otpTextEditingController.text.isEmpty) {
      showMessage("Please enter OTP");
    } else if (_otpTextEditingController.text.length != 6) {
      showMessage("Please enter 6 digit OTP");
    } else {
      _authController.doLogin(
          mobile: widget.mobileNumber,
          cc: "91",
          verificationCode: _otpTextEditingController.text,
          callback: () {
            Get.to(()=> const BottomNavBarPage());
          });

    }
  }
}
