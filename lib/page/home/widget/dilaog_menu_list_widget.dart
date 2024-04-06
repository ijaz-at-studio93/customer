import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

import '../../../controller/auth_controller.dart';

class DialogMenuListWidget extends StatelessWidget {
  final AuthController authController;
  final VoidCallback onPress;
  const DialogMenuListWidget(
      {super.key, required this.onPress, required this.authController});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  "https://static.toiimg.com/thumb/msid-108614769/108614769.jpg?width=500&resizemode=4",
                  height: 80, width: 80, // Horoscope image
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              // Space between image and text
              SizedBox(
                width: Get.width * 0.2,
                child: Text(
                  "Make Your Package", // Horoscope name
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.medium
                      .copyWith(color: ColorConstant.blackColor, fontSize: 13),
                  // Text style
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Obx(
            () => Positioned(
              right: -5,
              top: -6,
              child: authController.isSelectMenu
                  ? Container(
                      height: 21,
                      width: 21,
                      decoration: const BoxDecoration(
                          color: ColorConstant.crossMarkColor,
                          shape: BoxShape.circle),
                      child: Center(
                        child: Image.asset(
                          AssetsConstant.xMark,
                          width: 10,
                          height: 10,
                        ),
                      ),
                    )
                  : SizedBox(),
            ),
          )
        ],
      ),
    );
  }
}
