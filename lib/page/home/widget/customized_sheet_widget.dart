import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

import 'custom_list_tile_widget.dart';

class CustomizedSheetWidget extends StatefulWidget {
  const CustomizedSheetWidget({super.key});

  @override
  State<CustomizedSheetWidget> createState() => _CustomizedSheetWidgetState();
}

class _CustomizedSheetWidgetState extends State<CustomizedSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: Get.height * 0.7,
          width: Get.width,
          decoration: const BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Get.width * 0.6,
                      child: Text(
                        "Manicure & pedicure",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(0.85),
                        style: AppTextTheme.bold.copyWith(
                            color: ColorConstant.blackColor, fontSize: 17),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: ColorConstant.grayColor,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "4.8 (76 Reviews)",
                          textScaler: const TextScaler.linear(0.85),
                          style: AppTextTheme.medium.copyWith(
                              color: ColorConstant.grayColor, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          "₹399 • ",
                          textScaler: const TextScaler.linear(0.85),
                          style: AppTextTheme.bold.copyWith(
                              color: ColorConstant.blackColor, fontSize: 16),
                        ),
                        Text(
                          "35 min",
                          textScaler: const TextScaler.linear(0.85),
                          style: AppTextTheme.medium.copyWith(
                              color: ColorConstant.grayColor, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Container(
                height: 1,
                width: Get.width,
                color: ColorConstant.dividerRedLightColor,
              ),
              Container(
                width: Get.width * 0.3,
                margin:
                    const EdgeInsets.symmetric(horizontal: 21, vertical: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorConstant.greenColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    "RECOMMENDED",
                    style: AppTextTheme.medium.copyWith(
                        fontSize: 10, color: ColorConstant.whiteColor),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15,top: 15),
                      height: 1,
                      width: Get.width,
                      color: ColorConstant.dividerColor,
                    );
                  },
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: CustomListTileWidget(),
                    );
                  },
                ),
              ),
              Container(
                width: Get.width,
                color: ColorConstant.whiteColor,
                height: 100,
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "1 Added",
                              style: AppTextTheme.bold.copyWith(
                                  fontSize: 13,
                                  color: ColorConstant.grayTextColor),
                            ),
                            const SizedBox(width: 2),
                            Image.asset(
                              AssetsConstant.arrowUpIcon,
                              height: 8,
                              width: 11,
                              color: changeTheme(
                                  SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor,
                            )
                          ],
                        ),
                        Text(
                          "₹4,000",
                          style: AppTextTheme.bold.copyWith(
                              fontSize: 19, color: ColorConstant.blackColor),
                        )
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                         Get.back();
                      },
                      child: Container(
                        height: 45,
                        width: Get.width * 0.4,
                        decoration: BoxDecoration(
                          color: changeTheme(
                              SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Continue",
                              textScaler: const TextScaler.linear(0.85),
                              style: AppTextTheme.medium.copyWith(
                                  fontSize: 16, color: ColorConstant.whiteColor),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward,
                              color: ColorConstant.whiteColor,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

            ],
          ),
        ),
        Positioned(
          right: 0,
          top: -50,
          left: 0,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                  color: ColorConstant.crossMarkColor, shape: BoxShape.circle),
              child: Center(
                child: Image.asset(
                  AssetsConstant.xMark,
                  width: 15,
                  height: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
