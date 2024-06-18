import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';

import 'package:sallon_customer/project_specific/text_theme.dart';


class ServiceOfferListTileWidget extends StatelessWidget {
  final String name;
  final String image;
  final String price;
  final String duration;
  final double rate;
  final String reviewCount;
  const ServiceOfferListTileWidget(
      {super.key,
      required this.name,
      required this.image,
      required this.price,
      required this.rate,
      required this.reviewCount,
      required this.duration});

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
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              width: 108,
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
        ],
      ),
    );
  }
}
