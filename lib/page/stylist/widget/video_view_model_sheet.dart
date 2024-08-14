import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/page/stylist/widget/network_video_view_widget.dart';
import '../../../constant/assetsconstant.dart';
import '../../../project_specific/text_theme.dart';

class VideoViewModelSheet extends StatefulWidget {
  final String videoString;
  const VideoViewModelSheet({super.key, required this.videoString});

  @override
  State<VideoViewModelSheet> createState() => _VideoViewModelSheetState();
}

class _VideoViewModelSheetState extends State<VideoViewModelSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                        color: ColorConstant.crossMarkColor,
                        shape: BoxShape.circle),
                    child: Center(
                      child: Image.asset(
                        AssetsConstant.xMark,
                        width: 15,
                        height: 15,
                      ),
                    ),
                  ),
                ),
                Text(
                  "",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.bold.copyWith(
                    fontSize: 19,
                    color: ColorConstant.blackColor,
                  ),
                ),
                const SizedBox(),
                const SizedBox(),
              ],
            ),
          ),
          Expanded(
              child: NetworkVideoViewWidget(
            videoString: widget.videoString,
          )),
        ],
      ),
    );
  }
}
