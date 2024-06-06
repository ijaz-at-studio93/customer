import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/api_constant.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/controller/auth_controller.dart';
import 'package:sallon_customer/model/blog_data_model.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

class InsightsCardWidget extends StatefulWidget {
  final VoidCallback onPress;
  final BlogData blogData;
  const InsightsCardWidget(
      {super.key, required this.onPress, required this.blogData});

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
                  child: CachedNetworkImage(
                    width: Get.width,
                    height: Get.height * 0.25,
                    fit: BoxFit.fitWidth,
                    imageUrl: "${APIConstants.image}${widget.blogData.image}",
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
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {

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
                      child: CachedNetworkImage(
                        height: 17,
                        width: 17,
                        fit: BoxFit.cover,
                        imageUrl:
                            "${APIConstants.image}${widget.blogData.artist?.profileImage ?? ""}",
                        placeholder: (context, url) => const Image(
                          image: AssetImage(AssetsConstant.placeHolder),
                          height: 17,
                          width: 17,
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, error) => const Image(
                          image: AssetImage(AssetsConstant.placeHolder),
                          height: 17,
                          width: 17,
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
            )
          ],
        ),
      ),
    );
  }
}
