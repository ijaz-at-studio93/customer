import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

import '../../stylist/stylist_saloon_details_page.dart';

class StylistListGridWidget extends StatelessWidget {
  final VoidCallback onPress;
  final String image;
  final String name;
  const StylistListGridWidget(
      {super.key,
      required this.onPress,
      required this.image,
      required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFF1F1F1)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    width: Get.width,
                    height: 135,
                    fit: BoxFit.cover,
                    imageUrl: image,
                    placeholder: (context, url) => Image(
                      image: const AssetImage(AssetsConstant.placeHolder),
                      width: Get.width,
                      height: 135,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => Image(
                      image: const AssetImage(AssetsConstant.placeHolder),
                      width: Get.width,
                      height: 135,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    height: 25,
                    width: Get.width * 0.22,
                    decoration: BoxDecoration(
                        color: ColorConstant.topRatedColor,
                        borderRadius: BorderRadius.circular(6)),
                    child: Center(
                      child: Text(
                        "TOP RATED",
                        style: AppTextTheme.medium.copyWith(
                            color: ColorConstant.whiteColor, fontSize: 11),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    textScaler: const TextScaler.linear(0.85),
                    style: AppTextTheme.bold.copyWith(
                        color: ColorConstant.blackColor, fontSize: 15),
                  ),
                  Row(
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
                    ],
                  )
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Get.to(() => const StylistSaloonDetailsPage());
              },
              child: Text(
                "View Profile",
                style: AppTextTheme.medium.copyWith(
                    fontSize: 13,
                    color: ColorConstant.grayTextColor,
                    decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
