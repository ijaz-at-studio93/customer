import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/api/dio_client.dart';
import 'package:sallon_customer/constant/api_constant.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/controller/auth_controller.dart';
import 'package:sallon_customer/project_specific/ProgressContainerView.dart';
import 'package:sallon_customer/project_specific/button_widget.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/pick_image.dart';
import 'package:sallon_customer/util/simple_text_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  /*--------------  Define Controller -----------*/
  File imagePath = File("");
  final _mobileTextEditingController = TextEditingController();
  final _nameTextEditingController = TextEditingController();
  final _emailTextEditingController = TextEditingController();
  final _verificationCode = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _nameTextEditingController.text =
        _authController.userResponseModel.data?.userData?.name ?? "";
    _mobileTextEditingController.text =
        _authController.userResponseModel.data?.userData?.mobile ?? "";
    _emailTextEditingController.text =
        _authController.userResponseModel.data?.userData?.email ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: ColorConstant.blackColor,
          ),
        ),
        centerTitle: true,
        title: Text(
          "Edit Details",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: Obx(
        () => ProgressContainerView(
          isProgressRunning: _authController.showProgress,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                InkWell(
                  onTap: () async {
                    FileUtils.openPlatformImagePicker(onSelectImage: (file) {
                      setState(() {
                        imagePath = file;
                      });
                    });
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: imagePath.path == ""
                            ? CachedNetworkImage(
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                imageUrl:
                                    "${APIConstants.image}${_authController.userResponseModel.data?.userData?.profileImage ?? ""}",
                                placeholder: (context, url) => const Image(
                                  image: AssetImage(AssetsConstant.placeHolder),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (context, url, error) =>
                                    const Image(
                                  image: AssetImage(AssetsConstant.placeHolder),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.file(
                                imagePath,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const Positioned(
                          bottom: 10,
                          right: 2,
                          child: Icon(
                            CupertinoIcons.pencil_circle_fill,
                            color: ColorConstant.primaryColor,
                          ))
                    ],
                  ),
                ),
                _columWithNameTextField(),
                const SizedBox(height: 30),
                _columPhoneWithTextField(),
                isVerifyOtp
                    ? Column(
                        children: [
                          SimpleTextFieldWidget(
                              onChanged: (val) {
                                if (val.length == 6) {
                                  _authController.doVerifyOtp(
                                      mobileNO:
                                          _mobileTextEditingController.text,
                                      cc: "91",
                                      verificationCode: val);
                                }
                              },
                              textEditingController: _verificationCode,
                              hintText: "",
                              textInputType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              title: "Enter OTP"),
                          Padding(
                            padding: const EdgeInsets.only(right: 20, top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                isResendOTp
                                    ? TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _start = 60;
                                            isResendOTp = false;
                                            startTimer();
                                            _authController.doSendOTP(
                                                mobileNo:
                                                    _mobileTextEditingController
                                                        .text,
                                                cc: "91");
                                            _verificationCode.clear();
                                          });
                                        },
                                        child: Text(
                                          "Resend",
                                          style: AppTextTheme.bold.copyWith(
                                              fontSize: 16,
                                              color: ColorConstant.redBgColor),
                                        ))
                                    : Text(
                                        "Retry in 00:${_start.toString()}",
                                        style: AppTextTheme.bold.copyWith(
                                            fontSize: 16,
                                            color: ColorConstant.redBgColor),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(height: 30),
                _columWithEmailTextField(),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: ButtonWidget(
                      buttonTitleText: "Edit Details",
                      onPress: () {
                        _doEditProfile();
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*--------------   Phone Number TextField -----------*/
  bool isOtpEnable = false;
  bool isVerifyOtp = false;
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
                  width: Get.width * 0.56,
                  child: TextField(
                    controller: _mobileTextEditingController,
                    onChanged: (val) {
                      setState(() {
                        if (_authController
                                    .userResponseModel.data?.userData?.mobile !=
                                _mobileTextEditingController.text &&
                            _mobileTextEditingController.text.length == 10) {
                          isOtpEnable = true;
                        } else {
                          isOtpEnable = false;
                        }
                      });
                    },
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
                ),
                isOtpEnable
                    ? TextButton(
                        onPressed: () {
                          _authController.doSendOTP(
                              mobileNo: _mobileTextEditingController.text,
                              cc: "91");
                          isVerifyOtp = true;
                          _start = 60;
                          startTimer();
                        },
                        child: Text(
                          "GET OTP",
                          style: AppTextTheme.medium.copyWith(
                              fontSize: 14, color: ColorConstant.primaryColor),
                        ))
                    : const SizedBox(),
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

  /*-------------------  Do  Create Profile ----------------*/
  _doEditProfile() {
    if (_nameTextEditingController.text.isEmpty) {
      showMessage("Please enter your name");
      return;
    } else if (_mobileTextEditingController.text.isEmpty) {
      showMessage("Please enter mobile number");
      return;
    } else if (_mobileTextEditingController.text.length != 10) {
      showMessage("Please enter 10 digit mobile number");
      return;
    } else if (_authController.userResponseModel.data?.userData?.mobile !=
        _mobileTextEditingController.text) {
      if (_verificationCode.text.isEmpty) {
        showMessage("Please enter Otp");
        return;
      } else if (_verificationCode.text.length != 6) {
        showMessage("Please enter 6 Digit");
        return;
      } else {
        _authController.doEditProfile(
            name: _nameTextEditingController.text,
            email: _emailTextEditingController.text,
            mobile: _authController.userResponseModel.data?.userData?.mobile !=
                    _mobileTextEditingController.text
                ? _mobileTextEditingController.text
                : "",
            cc: "91",
            verificationCode: _verificationCode.text,
            image: imagePath,
            callback: () {
              setState(() {
                _authController.initUserData();
                Get.back();
                showMessage("Profile Update SuccessFully");
              });
            });
      }
    } else {
      _authController.doEditProfile(
          name: _nameTextEditingController.text,
          email: _emailTextEditingController.text,
          mobile: _authController.userResponseModel.data?.userData?.mobile !=
                  _mobileTextEditingController.text
              ? _mobileTextEditingController.text
              : "",
          cc: "91",
          verificationCode: _verificationCode.text,
          image: imagePath,
          callback: () {
            setState(() {
              _authController.initUserData();
              Get.back();
              showMessage("Profile Update SuccessFully");
            });
          });
    }
  }

  int _start = 60;

  bool isResendOTp = false;

  /*--------------  Start Timer --------------*/
  startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
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
}
