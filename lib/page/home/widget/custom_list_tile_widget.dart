import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/project_specific/remove_button_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

import '../../../constant/api_constant.dart';
import '../../../constant/color_constant.dart';
import '../../../project_specific/add_button_widget.dart';

class CustomListTileWidget extends StatelessWidget {
  final String nameProduct;
  final String productDescription;
  final String productImage;
  final String price;
  final String rate;
  final VoidCallback isAdd;
  final VoidCallback isRemove;
  final bool isAdded;
  const CustomListTileWidget(
      {super.key,
      required this.nameProduct,
      required this.productDescription,
      required this.productImage,
      required this.price,
      required this.isAdd,
      required this.isRemove,
      required this.isAdded,
      required this.rate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: Get.width * 0.6,
              child: Text(
                nameProduct,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.blackColor, fontSize: 17),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                  Icon(
                  Icons.star,
                  color: changeTheme(SharedPrefs.readStringValue(
                      PrefConstants.gender)) ??
                      ColorConstant.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  rate,
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.medium
                      .copyWith(color: ColorConstant.grayColor, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              "₹$price",
              textScaler: const TextScaler.linear(0.85),
              style: AppTextTheme.bold
                  .copyWith(color: ColorConstant.blackColor, fontSize: 16),
            ),
            const SizedBox(height: 13),
            Dash(
              direction: Axis.horizontal,
              length: Get.width * 0.6,
              dashLength: 2,
              dashColor: ColorConstant.grayTextColor,
            ),
            const SizedBox(height: 13),
            SizedBox(
              width: Get.width * 0.5,
              child: ReadMoreText(
                productDescription,
                trimMode: TrimMode.Line,
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.grayTextColor, fontSize: 14),
                trimLines: 2,
                colorClickableText: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)) ??
                    ColorConstant.primaryColor,
                trimCollapsedText: 'more',
                trimExpandedText: 'Show less',
                moreStyle: AppTextTheme.medium.copyWith(
                  fontSize: 15,
                  color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)) ??
                      ColorConstant.primaryColor,
                ),
              ),
            ),
          ],
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: isAdded ? isRemove : isAdd,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  width: 123,
                  height: 123,
                  fit: BoxFit.cover,
                  imageUrl: "${APIConstants.image}$productImage",
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
              bottom: -12,
              left: 8,
              right: 8,
              child: isAdded
                  ? RemoveButtonWidget(onPress: isRemove)
                  : AddButtonWidget(
                      onPress: isAdd,
                      color: changeTheme(SharedPrefs.readStringValue(
                              PrefConstants.gender)) ??
                          ColorConstant.primaryColor,
                    ),
            )
          ],
        )
      ],
    );
  }
}
