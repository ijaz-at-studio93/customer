import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

class ButtonWidget extends StatelessWidget {
  final String buttonTitleText;
  final VoidCallback onPress;
  final Color? color;
  final BoxDecoration? decoration;

  const ButtonWidget(
      {super.key,
      required this.buttonTitleText,
        this.decoration,
      required this.onPress,
      this.color = ColorConstant.primaryColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      // child: Container(
      //   height: 45,
      //   width: Get.width,
      //   decoration: BoxDecoration(
      //     color: changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)) ?? color,
      //     borderRadius: BorderRadius.circular(12),
      //   ),
      //   child: Center(
      //     child: Text(
      //       buttonTitleText,
      //       style: AppTextTheme.bold.copyWith(
      //         fontSize: 16,
      //         color: ColorConstant.whiteColor,
      //       ),
      //     ),
      //   ),
      // ),
        child: Container(
          height: 48,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: decoration ??
              BoxDecoration(
                color: color ?? Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
          child: Text(
            buttonTitleText,
            style: const TextStyle(
              fontFamily: "Outfit",
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        )
    );
  }
}
