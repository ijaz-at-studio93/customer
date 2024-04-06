import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ButtonWidget extends StatelessWidget {
  final String buttonTitleText;
  final VoidCallback onPress;
  final Color? color;

  const ButtonWidget(
      {super.key,
      required this.buttonTitleText,
      required this.onPress,
      this.color = ColorConstant.primaryColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: 45,
        width: Get.width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            buttonTitleText,
            style: AppTextTheme.bold.copyWith(
              fontSize: 16,
              color: ColorConstant.whiteColor,
            ),
          ),
        ),
      ),
    );
  }
}
