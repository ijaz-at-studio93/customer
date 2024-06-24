import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';

import 'package:salon_customer/model/blog_data_model.dart';
import 'package:salon_customer/project_specific/text_theme.dart';

class InsightsCardWidget extends StatefulWidget {
  final VoidCallback onPress;
  final BlogData blogData;
  const InsightsCardWidget(
      {super.key, required this.onPress, required this.blogData});

  @override
  State<InsightsCardWidget> createState() => _InsightsCardWidgetState();
}

class _InsightsCardWidgetState extends State<InsightsCardWidget> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: ColorConstant.grayColor.withOpacity(0.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: ColorConstant.grayTextColor)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        width: Get.width,
                        height: Get.height * 0.25,
                        fit: BoxFit.fitWidth,
                        imageUrl:
                            "${APIConstants.image}${widget.blogData.image}",
                        placeholder: (context, url) => Image(
                          image: const AssetImage(AssetsConstant.placeHolder),
                          width: Get.width,
                          height: Get.height * 0.25,
                          fit: BoxFit.fitWidth,
                        ),
                        errorWidget: (context, url, error) => Image(
                          image: const AssetImage(AssetsConstant.placeHolder),
                          width: Get.width,
                          height: Get.height * 0.25,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                widget.blogData.title ?? "",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  /*Row(
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
                  ),*/
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                          imageUrl:
                              "${APIConstants.image}${widget.blogData.artist?.profileImage ?? ""}",
                          placeholder: (context, url) => const Image(
                            image: AssetImage(AssetsConstant.placeHolder),
                            height: 30,
                            width: 30,
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => const Image(
                            image: AssetImage(AssetsConstant.placeHolder),
                            height: 30,
                            width: 30,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.blogData.artist?.name ?? "",
                        style: AppTextTheme.medium.copyWith(
                            color: ColorConstant.grayTextColor, fontSize: 11),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
