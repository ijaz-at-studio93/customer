import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';
import 'package:ticket_widget/ticket_widget.dart';

import '../bottom_navigation_bar.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: changeTheme(
          SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 67),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Icon(
                Icons.arrow_back_ios,
                color: ColorConstant.whiteColor,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.network(
                      "https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                      height: Get.height * 0.26,
                      width: Get.height,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: Get.height * 0.18,
                      right: 0,
                      left: 0,
                      child: TicketWidget(
                        isCornerRounded: true,
                        padding: const EdgeInsets.all(23),
                        width: Get.width,
                        height: Get.height * 0.64,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Amrit Saloon And Spa",
                              style: AppTextTheme.bold.copyWith(
                                  fontSize: 16, color: ColorConstant.blackColor),
                            ),
                            const SizedBox(height: 15),
                            Container(
                              width: Get.width * 0.8,
                              height: 1,
                              decoration: const BoxDecoration(
                                  color: ColorConstant.divider2Color),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Date",
                                      style: AppTextTheme.medium.copyWith(
                                          color: ColorConstant.grayTextColor,
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Fri, 15 May 2023",
                                      style: AppTextTheme.medium.copyWith(
                                          color: ColorConstant.blackColor,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Time Slot",
                                      style: AppTextTheme.medium.copyWith(
                                          color: ColorConstant.grayTextColor,
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "10:00-10:00 AM",
                                      style: AppTextTheme.medium.copyWith(
                                          color: ColorConstant.blackColor,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                              width: Get.width * 0.8,
                              height: 1,
                              decoration: const BoxDecoration(
                                  color: ColorConstant.divider2Color),
                            ),
                            const SizedBox(height: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Address",
                                  style: AppTextTheme.medium.copyWith(
                                      color: ColorConstant.grayTextColor,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Ring Road No. 1, near RAIPURA, C.G, Changurabhata, Raipur, Chhattisgarh 492007",
                                  style: AppTextTheme.medium.copyWith(
                                      color: ColorConstant.blackColor,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                              width: Get.width * 0.8,
                              height: 1,
                              decoration: const BoxDecoration(
                                  color: ColorConstant.divider2Color),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Stylist Name",
                                  style: AppTextTheme.medium.copyWith(
                                      color: ColorConstant.grayTextColor,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Ajay Chandrakar",
                                  style: AppTextTheme.medium.copyWith(
                                      color: ColorConstant.blackColor,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                            Center(
                              child: QrImageView(
                                data: 'Test Developer',
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Center(
                              child: Text(
                                "AU86286HH",
                                style: AppTextTheme.medium.copyWith(
                                    fontSize: 13,
                                    color: ColorConstant.blackColor),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.offAll(() => const BottomNavBarPage());
        },
        backgroundColor: ColorConstant.removeStroke,
        child: Image.asset(
          AssetsConstant.sosIcon,
          width: 42,
          height: 19,
        ),
      ),
    );
  }
}
