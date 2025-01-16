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

class LoginPage extends StatefulWidget {
  final bool splashPage;

  const LoginPage({super.key, required this.splashPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /*-----------  Define Controller ------------*/
  final _mobileTextEditingController = TextEditingController();

  final _authController = Get.find<AuthController>();

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
                      _columWithTextField(),
                      const SizedBox(height: 12),
                      _termsCondition(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 30),
                        child: ButtonWidget(
                            color: changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender)) ??
                                ColorConstant.primaryColor,
                            buttonTitleText: "Continue",
                            onPress: () {
                              _doLogin();
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [SizedBox(width: 34, height: 34)],
          ),
          const SizedBox(height: 35),
          Text(
            "Login to \nyour Scuts Account",
            style: AppTextTheme.bold
                .copyWith(color: ColorConstant.whiteColor, fontSize: 23),
          ),
        ],
      ),
    );
  }

  /*--------------  Enter Your Phone Number -----------*/
  _columWithTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter Your Phone Number",
            style: AppTextTheme.regular
                .copyWith(fontSize: 13, color: ColorConstant.blackColor),
          ),
          const SizedBox(height: 12),
          Container(
            height: 50,
            width: Get.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorConstant.borderColor,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      Text(
                        "+91",
                        style: AppTextTheme.bold.copyWith(
                            fontSize: 13, color: ColorConstant.blackColor),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "|",
                        style: AppTextTheme.bold.copyWith(
                            fontSize: 13, color: ColorConstant.grayColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: Get.width * 0.7,
                  child: TextField(
                    controller: _mobileTextEditingController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.blackColor, fontSize: 13),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(bottom: 2),
                        border: InputBorder.none,
                        hintText: "10 digit mobile number",
                        counterText: "",
                        hintStyle: AppTextTheme.medium.copyWith(
                            color: ColorConstant.grayColor, fontSize: 13)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /*------------ terms & Condition  ------------------*/
  bool getWhatsappUpdate = false;
  bool iAgree = false;

  _termsCondition() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  iAgree = !iAgree;
                });
              },
              child: Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: iAgree
                            ? ColorConstant.primaryColor
                            : Colors.transparent,
                        border: Border.all(color: CupertinoColors.black)),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.checkmark_alt,
                        color: iAgree
                            ? ColorConstant.whiteColor
                            : Colors.transparent,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "By clicking , I accept the",
                    style: AppTextTheme.medium.copyWith(
                        fontSize: 14, color: ColorConstant.grayTextColor),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                openUrl("https://scuts.in/terms-conditions/");
              },
              child: Text(
                "Terms & Condition",
                style: AppTextTheme.medium.copyWith(
                  color: ColorConstant.blackColor,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              getWhatsappUpdate = !getWhatsappUpdate;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 17,
                width: 17,
                decoration: BoxDecoration(
                  color: getWhatsappUpdate
                      ? changeTheme(SharedPrefs.readStringValue(
                              PrefConstants.gender)) ??
                          ColorConstant.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: changeTheme(SharedPrefs.readStringValue(
                            PrefConstants.gender)) ??
                        ColorConstant.primaryColor,
                  ),
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.check_mark,
                    size: 10,
                    color: getWhatsappUpdate
                        ? ColorConstant.whiteColor
                        : Colors.transparent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Get Update on whatsapp",
                style: AppTextTheme.medium.copyWith(
                    color: changeTheme(SharedPrefs.readStringValue(
                            PrefConstants.gender)) ??
                        ColorConstant.primaryColor,
                    fontSize: 14),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  /*----------- do Login ------------*/
  _doLogin() {
    if (_mobileTextEditingController.text.isEmpty) {
      showMessage("Please enter mobile Number");
    } else if (_mobileTextEditingController.text.length != 10) {
      showMessage("Please enter 10 digit mobile Number");
    }else if(!iAgree){
      showMessage("Please select Terms and Conditions to proceed further");
    } else {
      _authController.doCheckMobileNumberRegistration(
          mobileNo: _mobileTextEditingController.text,
          countryCode: "91",
          callback: () {
            Get.to(() => OtpScreenPage(
                  mobileNumber: _mobileTextEditingController.text,
                  isLogin: false,
                ));
          });
      /* Get.to(() => const CreateProfilePage());*/
    }
  }
}
