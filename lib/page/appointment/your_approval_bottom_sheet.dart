import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/page/appointment/qr_page.dart';
import 'package:sallon_customer/project_specific/button_widget.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

import '../../constant/color_constant.dart';
import '../../constant/variable_constant.dart';
import '../../project_specific/text_theme.dart';

class YourApprovalBottomSheet extends StatefulWidget {
  final  VoidCallback tapDone;
  const YourApprovalBottomSheet({super.key, required this.tapDone});

  @override
  State<YourApprovalBottomSheet> createState() =>
      _YourApprovalBottomSheetState();
}

class _YourApprovalBottomSheetState extends State<YourApprovalBottomSheet> {
  int yourApproval = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.32,
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
          Container(
            height: 71,
            width: Get.width,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender)) ??
                  ColorConstant.primaryColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                topLeft: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Text(
                  "Your Approval",
                  style: AppTextTheme.bold
                      .copyWith(color: ColorConstant.whiteColor, fontSize: 19),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: ColorConstant.whiteColor,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 30),
            child: Text(
              "is stylist Allowed to upload your images to his/her portfolio?",
              style: AppTextTheme.medium
                  .copyWith(fontSize: 16, color: ColorConstant.blackColor),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      yourApproval = 1;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        "Yes",
                        style: AppTextTheme.medium.copyWith(
                            fontSize: 13, color:changeTheme(
                            SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor,),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ColorConstant.blackColor),
                        ),
                        child: Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: yourApproval == 1
                                    ? ColorConstant.blackColor
                                    : Colors.transparent),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      yourApproval = 2;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        "No",
                        style: AppTextTheme.medium.copyWith(
                            fontSize: 13, color: changeTheme(
                            SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor,),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ColorConstant.blackColor),
                        ),
                        child: Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: yourApproval == 2
                                    ? ColorConstant.blackColor
                                    : Colors.transparent),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ButtonWidget(
                buttonTitleText: "Done",
                color: changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor,
                onPress: widget.tapDone),
          ),
        ],
      ),
    );
  }
}
