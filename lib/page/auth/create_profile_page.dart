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
import '../bottom_navigation_bar.dart';
import '../onboarding/pay_after_service_onboarding_page.dart';
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

  /// Null until the user picks one — gender is mandatory, so nothing is
  /// pre-selected and [_doCreateProfile] blocks until a choice is made.
  int? selectGender;
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
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    /// 🔙 BACK BUTTON
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).maybePop();
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// 🧠 TITLE
                    const Text(
                      "Let’s Create Your Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 👤 NAME
                    _inputField(
                      label: "Your Name",
                      controller: _nameTextEditingController,
                      hint: "Enter Your Name",
                    ),

                    const SizedBox(height: 15),

                    /// 📱 MOBILE (UNCHANGED)
                    _inputField(
                      label: "Mobile Number",
                      controller: _mobileTextEditingController,
                      hint: "Enter Mobile Number",
                      isReadOnly: true,
                      prefix: "+91 | ",
                    ),

                    const SizedBox(height: 15),

                    /// 🚻 GENDER
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Gender",
                          style: TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _genderOption("Male", 1),
                            const SizedBox(width: 20),
                            _genderOption("Female", 2),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    /// 📧 EMAIL
                    _inputField(
                      label: "Email",
                      controller: _emailTextEditingController,
                      hint: "Enter Your Email (Optional)",
                    ),

                    const SizedBox(height: 30),

                    /// 🚀 BUTTON (UNCHANGED FUNCTION)
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
                          _doCreateProfile();
                        },
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isReadOnly = false,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: "Outfit",
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            children: [
              if (prefix != null)
                Text(prefix,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: isReadOnly,
                  keyboardType: TextInputType.text,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 14,
                    fontWeight: FontWeight.w600, // SemiBold
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 14,
                      fontWeight: FontWeight.w600, // SemiBold
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _genderOption(String title, int value) {
    final isSelected = selectGender == value;

    final selectedColor =
        value == 1 ? ColorConstant.primaryColor : ColorConstant.primary2;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectGender = value;
        });
      },
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: "Outfit",
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 18,
            width: 18,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? selectedColor : Colors.grey,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? selectedColor : Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*--------------   Phone Number TextField -----------*/
  Padding _columPhoneWithTextField() {
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
  Padding _columWithNameTextField() {
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
                        color: ColorConstant.grayColor,
                        fontFamily: 'Outfit',
                        fontSize: 13)),
              )),
        ],
      ),
    );
  }

  String? validateName(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return "Please enter your name";
    }

    if (trimmed.length < 3) {
      return "Name must be at least 3 characters";
    }

    // Only alphabets + space
    final regex = RegExp(r'^[a-zA-Z ]+$');

    if (!regex.hasMatch(trimmed)) {
      return "Only letters allowed";
    }

    // Avoid multiple spaces
    if (trimmed.contains(RegExp(r'\s{2,}'))) {
      return "Invalid name format";
    }

    return null;
  }

  /*--------------  Email TextField -------------*/
  Padding _columWithEmailTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter Your Email",
            style: AppTextTheme.regular.copyWith(
                fontSize: 12,
                fontFamily: 'Outfit',
                color: ColorConstant.blackColor),
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
  void _doCreateProfile() {
    // Dismiss the keyboard so bottom snackbars/toasts aren't hidden behind it.
    FocusManager.instance.primaryFocus?.unfocus();

    final name = _nameTextEditingController.text.trim();
    final mobile = _mobileTextEditingController.text.trim();

    // 🔹 NAME VALIDATION
    if (name.isEmpty) {
      showMessage("Please enter your name");
      return;
    }

    if (name.length < 3) {
      showMessage("Name must be at least 3 characters");
      return;
    }

    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(name)) {
      showMessage("Only letters allowed in name");
      return;
    }

    if (name.contains(RegExp(r'\s{2,}'))) {
      showMessage("Invalid name format");
      return;
    }

    // 🔹 MOBILE VALIDATION
    if (mobile.isEmpty) {
      showMessage("Please enter mobile number");
      return;
    }

    if (mobile.length != 10) {
      showMessage("Please enter 10 digit mobile number");
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      showMessage("Invalid mobile number");
      return;
    }

    // 🔹 GENDER VALIDATION
    if (selectGender == null) {
      showMessage("Please select your gender");
      return;
    }

    SharedPrefs.remove(PrefConstants.hasVisitedSalon);
    SharedPrefs.remove(PrefConstants.hasShownSalonDialog);

    // ✅ ALL GOOD → API CALL
    _authController.doSignUp(
      gender: selectGender == 1 ? "MALE" : "FEMALE",
      mobileNO: mobile,
      name: name,
      cc: "91",
      email: _emailTextEditingController.text.trim(),
      // callback: () {
      //   Get.to(() => OtpScreenPage(
      //         mobileNumber: mobile,
      //         isLogin: false,
      //       ));
      // },
      callback: () {
        Get.offAll(() => PayAfterServiceOnboardingPage.gate(
              const BottomNavBarPage(),
            ));
      },
    );
  }
}
