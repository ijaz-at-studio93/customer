import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

import '../../../constant/variable_constant.dart';

class PopularServiceWidget extends StatelessWidget {
  final String image;
  final String name;
  final String price;
  final double rating;
  final String review;
  final String duration;
  final bool isAdd;
  final VoidCallback addButtonTap;
  const PopularServiceWidget(
      {super.key,
      required this.image,
      required this.name,
      required this.price,
      required this.rating,
      required this.review,
      required this.duration,
      required this.addButtonTap,
      required this.isAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border:
              Border.all(color: ColorConstant.selectTimeSlotBorder, width: 1)),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: '${APIConstants.image}$image',
                placeholder: (context, url) => const Image(
                  image: AssetImage(AssetsConstant.placeHolder),
                  fit: BoxFit.cover,
                  width: 110,
                  height: 110,
                ),
                errorWidget: (context, url, error) => const Image(
                  image: AssetImage(AssetsConstant.placeHolder),
                  fit: BoxFit.cover,
                  width: 110,
                  height: 110,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Image.asset(
                    AssetsConstant.starIcon,
                    height: 13,
                    width: 13,
                    color: ColorConstant.grayTextColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$rating ($review Reviews)',
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.grayTextColor, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Dash(
                  direction: Axis.horizontal,
                  length: 130,
                  dashLength: 2,
                  dashColor: Colors.grey),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '₹$price',
                    style: AppTextTheme.bold.copyWith(
                        fontSize: 16, color: ColorConstant.blackColor),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    height: 4,
                    width: 4,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$duration min',
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.grayTextColor, fontSize: 16),
                  )
                ],
              ),
              const SizedBox(height: 10),
              isAdd
                  ? GestureDetector(
                      onTap: addButtonTap,
                      child: Container(
                        width: 100,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: ColorConstant.removeBgButton,
                          border: Border.all(color: ColorConstant.redBgColor),
                        ),
                        child: Center(
                          child: Text(
                            "Remove",
                            style: AppTextTheme.medium.copyWith(
                              fontSize: 13,
                              color: ColorConstant.redBgColor,
                            ),
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: addButtonTap,
                      child: Container(
                        width: 100,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: ColorConstant.pinkBgColor,
                          border: Border.all(
                            color: changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender)) ??
                                ColorConstant.primaryColor,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Add",
                            style: AppTextTheme.medium.copyWith(
                              fontSize: 13,
                              color: changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  ColorConstant.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
