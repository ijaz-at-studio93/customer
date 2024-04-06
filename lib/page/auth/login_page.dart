import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/api/dio_client.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/page/auth/create_profile_page.dart';
import 'package:sallon_customer/page/bottom_navigation_bar.dart';
import 'package:sallon_customer/project_specific/button_widget.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _mobileTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      body: Column(
        children: [
          _headerWidget(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 35),
                  _columWithTextField(),
                  const SizedBox(height: 35),
                  _termsCondition(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 35),
                    child: ButtonWidget(
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
    );
  }

  /*---------- header widget ---------*/
  _headerWidget() {
    return Container(
      width: Get.width,
      height: Get.height * 0.23,
      padding: const EdgeInsets.only(top: 50, left: 21, right: 21),
      decoration: const BoxDecoration(color: ColorConstant.primaryColor),
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
              InkWell(
                onTap: () {
                  Get.offAll(()=> BottomNavBarPage());
                },
                child: Container(
                  height: 40,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    border: Border.all(
                      color: ColorConstant.whiteColor.withOpacity(0.10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Skip",
                      style: AppTextTheme.regular.copyWith(
                          color: ColorConstant.whiteColor, fontSize: 13),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 35),
          Text(
            "Login to \nyour Scout Account",
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
                  width: Get.width * 0.72,
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
  _termsCondition() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "by clicking , i accept the",
              style: AppTextTheme.medium
                  .copyWith(fontSize: 14, color: ColorConstant.grayTextColor),
            ),
            TextButton(
              onPressed: () {},
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
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  getWhatsappUpdate = !getWhatsappUpdate;
                });
              },
              child: Container(
                height: 17,
                width: 17,
                decoration: BoxDecoration(
                  color: getWhatsappUpdate
                      ? ColorConstant.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: ColorConstant.primaryColor,
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
            ),
            const SizedBox(width: 12),
            Text(
              "Get Update on whatsapp",
              style: AppTextTheme.medium
                  .copyWith(color: ColorConstant.primaryColor, fontSize: 14),
            ),
          ],
        )
      ],
    );
  }

  /*----------- do Login ------------*/
  _doLogin() {
    if (_mobileTextEditingController.text.isEmpty) {
      showMessage("Please enter mobile Number");
    } else if (_mobileTextEditingController.text.length != 10) {
      showMessage("Please enter 10 digit mobile Number");
    } else {
      Get.to(() => const CreateProfilePage());
    }
  }
}
