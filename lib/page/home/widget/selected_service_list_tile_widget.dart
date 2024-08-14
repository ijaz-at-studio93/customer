import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/project_specific/remove_button_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import '../../../constant/api_constant.dart';

class SelectedServiceListTileWidget extends StatelessWidget {
  final String serviceName;
  final String servicePrice;
  final String serviceRating;
  final String serviceReview;
  final String serviceImage;
  final VoidCallback isRemove;
  final VoidCallback editProduct;

  const SelectedServiceListTileWidget({
    super.key,
    required this.isRemove,
    required this.editProduct,
    required this.serviceName,
    required this.servicePrice,
    required this.serviceRating,
    required this.serviceReview,
    required this.serviceImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: Get.width * 0.6,
              child: Text(
                serviceName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.blackColor, fontSize: 17),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Image.asset(
                  AssetsConstant.starIcon,
                  width: 13,
                  height: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  "$serviceRating ($serviceRating Reviews)",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.medium.copyWith(
                      color: ColorConstant.grayTextColor, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "₹ $servicePrice •",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.bold
                      .copyWith(color: ColorConstant.blackColor, fontSize: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  "35 min",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.bold.copyWith(
                      color: ColorConstant.grayTextColor, fontSize: 16),
                ),
                const SizedBox(width: 13),
                InkWell(
                  onTap: editProduct,
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          AssetsConstant.editIcon,
                          height: 15,
                          width: 15,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Edit Product",
                          style: AppTextTheme.regular.copyWith(
                              fontSize: 13,
                              color: changeTheme(SharedPrefs.readStringValue(
                                  PrefConstants.gender))),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Dash(
              direction: Axis.horizontal,
              length: Get.width * 0.55,
              dashLength: 2,
              dashColor: ColorConstant.grayTextColor,
            ),
          ],
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: isRemove,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  width: 123,
                  height: 123,
                  fit: BoxFit.cover,
                  imageUrl: "${APIConstants.image}$serviceImage",
                  placeholder: (context, url) => const Image(
                    image: AssetImage(AssetsConstant.placeHolder),
                    width: 108,
                    height: 123,
                    fit: BoxFit.cover,
                  ),
                  errorWidget: (context, url, error) => const Image(
                    image: AssetImage(AssetsConstant.placeHolder),
                    width: 108,
                    height: 123,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: -18,
                left: 8,
                right: 8,
                child: RemoveButtonWidget(onPress: isRemove))
          ],
        )
      ],
    );
  }
}
