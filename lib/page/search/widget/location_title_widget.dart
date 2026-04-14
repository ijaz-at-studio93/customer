import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/model/search_model/search_model.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

class LocationTileWidget extends StatelessWidget {
  final VoidCallback onPress;
  final SalonData salonListData;
  const LocationTileWidget(
      {super.key, required this.onPress, required this.salonListData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: Get.width,
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: ColorConstant.strokeColor, width: 1.5),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: CachedNetworkImage(
                    width: Get.width,
                    height: Get.height * 0.25,
                    fit: BoxFit.fitWidth,
                    imageUrl:
                        "${APIConstants.image}${salonListData.salon?.image ?? ""}",
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
                          salonListData.salon?.rating.toString() ?? "",
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
                      SizedBox(
                        width: Get.width * 0.5,
                        child: Text(
                          '${salonListData.salon?.displayName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: const TextScaler.linear(0.85),
                          style: AppTextTheme.bold.copyWith(
                              fontFamily: 'Outfit',
                              fontSize: 19, color: ColorConstant.blackColor),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(AssetsConstant.locationNewIcon,
                              height: 15,
                              width: 15,
                              color: changeTheme(SharedPrefs.readStringValue(
                                  PrefConstants.gender))),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: Get.width * 0.75,
                            child: Text(
                              '${salonListData.salon?.address}',
                              style: AppTextTheme.medium.copyWith(
                                fontFamily: 'Outfit',
                                  fontSize: 13,
                                  color: ColorConstant.grayTextColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
