import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/project_specific/add_button_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import '../../../constant/variable_constant.dart';
import '../../../project_specific/remove_button_widget.dart';
import '../../../util/SharedPrefs.dart';

class ServiceOfferListTileWidget extends StatelessWidget {
  final String name;
  final String image;
  final String price;
  final String duration;
  final double rate;
  final String reviewCount;
  final String description;
  final bool isSelect;
  final VoidCallback addButtonTap;

  const ServiceOfferListTileWidget(
      {super.key,
      required this.name,
      required this.image,
      required this.price,
      required this.rate,
      required this.reviewCount,
      required this.duration,
      required this.isSelect,
      required this.addButtonTap,
      required this.description});

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
                  name,
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
                    "$rate ($reviewCount Reviews)",
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
                    "₹$price • ",
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
          GestureDetector(
            onTap: addButtonTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    width: 123,
                    height: 123,
                    fit: BoxFit.cover,
                    imageUrl: image,
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
                  bottom: -18,
                  left: 8,
                  right: 8,
                  child: isSelect
                      ? RemoveButtonWidget(onPress: addButtonTap)
                      : AddButtonWidget(
                          onPress: addButtonTap,
                          color: changeTheme(SharedPrefs.readStringValue(
                                  PrefConstants.gender)) ??
                              ColorConstant.primaryColor,
                        ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
