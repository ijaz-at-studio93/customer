import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import 'package:salon_customer/project_specific/ProgressContainerView.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

import '../../constant/color_constant.dart';
import '../../project_specific/button_widget.dart';
import '../../project_specific/text_theme.dart';
import 'otp_screen_page.dart';

class CreateProfilePage extends StatefulWidget {
  final String mobileNo;
  const CreateProfilePage({super.key, required this.mobileNo});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  /*---------------- Controller Define -------------*/
  final _mobileTextEditingController = TextEditingController();
  final _nameTextEditingController = TextEditingController();
  final _emailTextEditingController = TextEditingController();
  final _authController = Get.find<AuthController>();

  int selectGender = 1;
  @override
  void initState() {
    super.initState();
    _mobileTextEditingController.text = widget.mobileNo;
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
                      _columWithNameTextField(),
                      const SizedBox(height: 30),
                      _columPhoneWithTextField(),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Gender",
                              style: AppTextTheme.regular.copyWith(
                                  fontSize: 13,
                                  color: ColorConstant.blackColor),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectGender = 1;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        "male",
                                        style: AppTextTheme.medium.copyWith(
                                            color: ColorConstant.blackColor,
                                            fontSize: 14),
                                      ),
                                      const SizedBox(width: 15),
                                      Container(
                                        height: 16,
                                        width: 16,
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: selectGender == 1
                                                ? ColorConstant.primaryColor
                                                : ColorConstant.blackColor,
                                          ),
                                        ),
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selectGender == 1
                                                ? ColorConstant.primaryColor
                                                : Colors.transparent,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 15),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectGender = 2;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        "female",
                                        style: AppTextTheme.medium.copyWith(
                                            color: ColorConstant.blackColor,
                                            fontSize: 14),
                                      ),
                                      const SizedBox(width: 15),
                                      Container(
                                        height: 16,
                                        width: 16,
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: selectGender == 2
                                                ? ColorConstant.primaryColor
                                                : ColorConstant.blackColor,
                                          ),
                                        ),
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selectGender == 2
                                                ? ColorConstant.primaryColor
                                                : Colors.transparent,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _columWithEmailTextField(),
                      const SizedBox(height: 35),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 35),
                        child: ButtonWidget(
                            color: changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender)) ??
                                ColorConstant.primaryColor,
                            buttonTitleText: "Continue",
                            onPress: () {
                              _doCreateProfile();
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
          color:
              changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)) ??
                  ColorConstant.primaryColor),
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
            "Let’s \nCreate your profile",
            style: AppTextTheme.bold
                .copyWith(color: ColorConstant.whiteColor, fontSize: 23),
          ),
        ],
      ),
    );
  }

  /*--------------   Phone Number TextField -----------*/
  _columPhoneWithTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Mobile Number",
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
                  child: Text(
                    "+91",
                    style: AppTextTheme.bold.copyWith(
                        fontSize: 13, color: ColorConstant.blackColor),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: Get.width * 0.72,
                  child: TextField(
                    readOnly: true,
                    canRequestFocus: false,
                    controller: _mobileTextEditingController,
                    keyboardType: TextInputType.phone,
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.blackColor, fontSize: 13),
                    maxLength: 10,
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

  /*--------------  Name TextField -------------*/
  _columWithNameTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Name",
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
              child: TextField(
                controller: _nameTextEditingController,
                keyboardType: TextInputType.text,
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 13),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 12),
                    border: InputBorder.none,
                    hintText: "Enter Your Name",
                    hintStyle: AppTextTheme.medium.copyWith(
                        color: ColorConstant.grayColor, fontSize: 13)),
              )),
        ],
      ),
    );
  }

/*--------------  Email TextField -------------*/
  _columWithEmailTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter Your Email",
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
              child: TextField(
                controller: _emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 13),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 12),
                    border: InputBorder.none,
                    hintText: "Enter your mail ID (Optional)",
                    hintStyle: AppTextTheme.medium.copyWith(
                        color: ColorConstant.grayColor, fontSize: 13)),
              )),
        ],
      ),
    );
  }

  /*------------  Do  Create Profile ----*/
  _doCreateProfile() {
    if (_nameTextEditingController.text.isEmpty) {
      showMessage("Please enter your name");
    } else if (_mobileTextEditingController.text.isEmpty) {
      showMessage("Please enter mobile number");
    } else if (_mobileTextEditingController.text.length != 10) {
      showMessage("Please enter 10 digit mobile number");
    } else {
      _authController.doSignUp(
          gender: selectGender == 1 ? "MALE" : "FEMALE",
          mobileNO: _mobileTextEditingController.text,
          name: _nameTextEditingController.text,
          cc: "91",
          email: _emailTextEditingController.text,
          callback: () {
            Get.to(() => OtpScreenPage(
                  mobileNumber: _mobileTextEditingController.text,
                  isLogin: false,
                ));
          });
    }
  }
}
