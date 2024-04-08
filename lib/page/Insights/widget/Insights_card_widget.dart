import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/controller/auth_controller.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

class InsightsCardWidget extends StatefulWidget {
  final VoidCallback onPress;
  const InsightsCardWidget({super.key, required this.onPress});

  @override
  State<InsightsCardWidget> createState() => _InsightsCardWidgetState();
}

class _InsightsCardWidgetState extends State<InsightsCardWidget> {
  final _authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    width: Get.width,
                    height: Get.height * 0.25,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      if (_authController.isInsightsFav) {
                        _authController.isInsightsFavSelect = false;
                      } else {
                        _authController.isInsightsFavSelect = true;
                      }
                    },
                    child: Obx(
                      () => Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorConstant.blackColor),
                        child: Center(
                          child: _authController.isInsightsFav
                              ? const Icon(
                                  CupertinoIcons.heart_fill,
                                  color: Colors.red,
                                )
                              : Image.asset(
                                  AssetsConstant.likeBlank,
                                  height: 20,
                                  width: 20,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    height: 30,
                    width: Get.width * 0.25,
                    decoration: BoxDecoration(
                        color: ColorConstant.topRatedColor,
                        borderRadius: BorderRadius.circular(6)),
                    child: Center(
                      child: Text(
                        "By Nykaa Saloon",
                        style: AppTextTheme.medium.copyWith(
                            color: ColorConstant.whiteColor, fontSize: 11),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 80,
                  child: Image.asset(
                    AssetsConstant.playIcon,
                    height: 60,
                    width: 60,
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'SML Isuzu Ltd. (SMLI) is a trusted and reliable',
              style: AppTextTheme.medium
                  .copyWith(color: ColorConstant.blackColor, fontSize: 16),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.remove_red_eye,
                      color: ColorConstant.grayTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "708 Views",
                      style: AppTextTheme.medium.copyWith(
                          color: ColorConstant.grayTextColor, fontSize: 13),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        "https://images.unsplash.com/photo-1546961329-78bef0414d7c?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                        height: 17,
                        width: 17,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "By Harshit Mehta",
                      style: AppTextTheme.medium.copyWith(
                          color: ColorConstant.grayTextColor, fontSize: 11),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
