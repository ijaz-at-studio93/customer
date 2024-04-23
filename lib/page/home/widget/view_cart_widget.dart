import 'package:flutter/material.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/page/home/widget/view_cart_list_tile_widget.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

import '../../../constant/assetsconstant.dart';
import '../../appointment/appointment_booking_page.dart';

class ViewCartWidget extends StatefulWidget {
  const ViewCartWidget({super.key});

  @override
  State<ViewCartWidget> createState() => _ViewCartWidgetState();
}

class _ViewCartWidgetState extends State<ViewCartWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: Get.height * 0.55,
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
                child: Text(
                  "Selected Services",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.bold.copyWith(
                    fontSize: 19,
                    color: ColorConstant.blackColor,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 23),
                      child: ViewCartListTileWidget(),
                    );
                  },
                ),
              ),
              Container(
                width: Get.width,
                height: 100,
                decoration: const BoxDecoration(
                  color: ColorConstant.whiteColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    topLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1E000000),
                      blurRadius: 8,
                      offset: Offset(-2, -2),
                      spreadRadius: 0,
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        FlutterImageStack(
                          imageList: _images,
                          showTotalCount: false,
                          totalCount: 4,
                          imageSource: ImageSource.network,
                          itemRadius: 35,
                          itemCount: 2,
                          itemBorderWidth: 3, // Border width around the images
                        ),
                        const SizedBox(width: 10),
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
                                  fontSize: 19,
                                  color: ColorConstant.blackColor),
                            )
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(()=> const AppointmentBookingPage());
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
                              "Select Stylist",
                              textScaler: const TextScaler.linear(0.85),
                              style: AppTextTheme.medium.copyWith(
                                  fontSize: 16,
                                  color: ColorConstant.whiteColor),
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

  /*---------  Dummy Image ------*/
  List<String> _images = [
    'https://images.unsplash.com/photo-1593642532842-98d0fd5ebc1a?ixid=MXwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=2250&q=80',
    'https://images.unsplash.com/photo-1612594305265-86300a9a5b5b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
  ];
}
