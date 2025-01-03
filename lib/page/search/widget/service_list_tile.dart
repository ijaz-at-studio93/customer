import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/project_specific/text_theme.dart';

import '../../../constant/variable_constant.dart';
import '../../../util/SharedPrefs.dart';

class ServiceListTile extends StatelessWidget {
  final String price;
  final String name;
  final String salonName;
  final String description;
  final String image;
  final String rating;
  final String duration;
  final VoidCallback onPress;
  const ServiceListTile(
      {super.key,
      required this.price,
      required this.name,
      required this.description,
      required this.image,
      required this.duration,
      required this.rating,
      required this.onPress,
      required this.salonName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: Get.width * 0.5,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: const TextScaler.linear(0.85),
                    style: AppTextTheme.bold
                        .copyWith(color: ColorConstant.blackColor, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 15,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      "$rating (Reviews)",
                      textScaler: const TextScaler.linear(0.85),
                      style: AppTextTheme.medium
                          .copyWith(color: ColorConstant.grayColor, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      "₹ $price • ",
                      textScaler: const TextScaler.linear(0.85),
                      style: AppTextTheme.bold.copyWith(
                          color: ColorConstant.blackColor, fontSize: 16),
                    ),
                    Text(
                      "$duration min",
                      textScaler: const TextScaler.linear(0.85),
                      style: AppTextTheme.medium
                          .copyWith(color: ColorConstant.grayColor, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  "By : $salonName",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.bold
                      .copyWith(color: ColorConstant.blackColor, fontSize: 18),
                ),
                const SizedBox(height: 5),
                Dash(
                  direction: Axis.horizontal,
                  length: Get.width * 0.5,
                  dashLength: 2,
                  dashColor: ColorConstant.grayTextColor,
                ),
                const SizedBox(height: 13),
                SizedBox(
                  width: Get.width * 0.5,
                  child: ReadMoreText(
                    description,
                    trimMode: TrimMode.Line,
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.grayTextColor, fontSize: 14),
                    trimLines: 2,
                    colorClickableText: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)),
                    trimCollapsedText: 'more',
                    trimExpandedText: 'Show less',
                    moreStyle: AppTextTheme.medium.copyWith(
                      fontSize: 15,
                      color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)),
                    ),
                  ),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                width: 123,
                height: 123,
                fit: BoxFit.cover,
                imageUrl: "${APIConstants.image}$image",
                placeholder: (context, url) => const Image(
                    width: 123,
                    height: 123,
                    fit: BoxFit.cover,
                    image: AssetImage(AssetsConstant.placeHolder)),
                errorWidget: (context, url, error) => const Image(
                    width: 123,
                    height: 123,
                    fit: BoxFit.cover,
                    image: AssetImage(AssetsConstant.placeHolder)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
