import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';

import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/controller/auth_controller.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

class SaloonCardWidget extends StatefulWidget {
  final VoidCallback onPress;
  const SaloonCardWidget({super.key, required this.onPress});

  @override
  State<SaloonCardWidget> createState() => _SaloonCardWidgetState();
}

class _SaloonCardWidgetState extends State<SaloonCardWidget> {
  final _authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: GestureDetector(
        onTap: widget.onPress,
        child: Container(
          width: Get.width,
          decoration: BoxDecoration(
              color: ColorConstant.whiteColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorConstant.strokeColor, width: 1.5)),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1485686531765-ba63b07845a7?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8bGFrbWUlMjBzYWxvb258ZW58MHx8MHx8fDA%3D',
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
                        if (_authController.isFavService) {
                          _authController.isFavServiceSelect = false;
                        } else {
                          _authController.isFavServiceSelect = true;
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
                            child: _authController.isFavService
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
                      width: Get.width * 0.39,
                      decoration: BoxDecoration(
                          color: ColorConstant.topRatedColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Center(
                        child: Text(
                          "Hair Style •₹200 Onwards",
                          style: AppTextTheme.medium.copyWith(
                              color: ColorConstant.whiteColor, fontSize: 12),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                      bottom: 10,
                      left: 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star,
                            color: ColorConstant.yellowColor,
                            size: 20,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '4.8',
                            style: AppTextTheme.medium.copyWith(
                                fontSize: 11, color: ColorConstant.yellowColor),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Average Stylist rating',
                            style: AppTextTheme.medium.copyWith(
                                fontSize: 13, color: ColorConstant.whiteColor),
                          ),
                        ],
                      )),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lakme Saloon & Spa',
                          textScaler: TextScaler.linear(0.85),
                          style: AppTextTheme.bold.copyWith(
                              fontSize: 19, color: ColorConstant.blackColor),
                        ),
                        Row(
                          children: [
                            Text(
                              "25 Min",
                              style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.grayTextColor,
                                  fontSize: 13),
                            ),
                            Text(
                              " • Available for Home",
                              style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.grayTextColor,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset(
                              AssetsConstant.locationNewIcon,
                              height: 15,
                              width: 15,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'First Floor, Bindal Tower, near..',
                              style: AppTextTheme.medium.copyWith(
                                  fontSize: 13,
                                  color: ColorConstant.grayTextColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: ColorConstant.greenColor,
                          borderRadius: BorderRadius.circular(5)),
                      width: 60,
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '4.8',
                            style: AppTextTheme.medium.copyWith(
                                fontSize: 11, color: ColorConstant.whiteColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Dash(
                direction: Axis.horizontal,
                length: Get.width * 0.85,
                dashLength: 2,
                dashColor: const Color(0xffCFCFCF),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '₹200/-',
                      style: AppTextTheme.bold.copyWith(
                          fontSize: 16, color: ColorConstant.blackColor),
                    ),
                    Text(
                      '₹400',
                      style: AppTextTheme.bold.copyWith(
                          fontSize: 12,
                          color: ColorConstant.grayTextColor,
                          decoration: TextDecoration.lineThrough),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '50% off',
                      style: AppTextTheme.bold.copyWith(
                          color: ColorConstant.primaryColor, fontSize: 14),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
