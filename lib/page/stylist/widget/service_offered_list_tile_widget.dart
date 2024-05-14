import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/project_specific/add_button_widget.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

class ServiceOfferListTileWidget extends StatelessWidget {
  const ServiceOfferListTileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: Get.width * 0.6,
                child: Text(
                  "Manicure & pedicure",
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
                  const Icon(
                    Icons.star,
                    color: ColorConstant.grayColor,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "4.8 (76 Reviews)",
                    textScaler: const TextScaler.linear(0.85),
                    style: AppTextTheme.medium
                        .copyWith(color: ColorConstant.grayColor, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    "₹399 • ",
                    textScaler: const TextScaler.linear(0.85),
                    style: AppTextTheme.bold.copyWith(
                        color: ColorConstant.blackColor, fontSize: 16),
                  ),
                  Text(
                    "35 min",
                    textScaler: const TextScaler.linear(0.85),
                    style: AppTextTheme.medium
                        .copyWith(color: ColorConstant.grayColor, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Dash(
                direction: Axis.horizontal,
                length: Get.width * 0.6,
                dashLength: 2,
                dashColor: ColorConstant.grayTextColor,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: Get.width * 0.5,
                child: ReadMoreText(
                  'Short Description of the Hair cut ideas of something cut ideas of something.',
                  trimMode: TrimMode.Line,
                  style: AppTextTheme.medium.copyWith(
                      color: ColorConstant.grayTextColor, fontSize: 14),
                  trimLines: 2,
                  colorClickableText:  changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor,
                  trimCollapsedText: 'more',
                  trimExpandedText: 'Show less',
                  moreStyle: AppTextTheme.medium.copyWith(
                      fontSize: 15, color:  changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor),
                ),
              ),
            ],
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
               child: CachedNetworkImage(
                  width: 108,
                  height: 123,
                  fit: BoxFit.cover,
                  imageUrl:
                      'https://cdn.shopify.com/s/files/1/0403/4661/5957/files/5f7b77c13666f8fb7f0dc454c34bde9f_1_480x480.jpg?v=1655612815',
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
              Positioned(
                bottom: -15,
                left: 10,
                right: 10,
                child: AddButtonWidget(onPress: (){},
                color: changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
