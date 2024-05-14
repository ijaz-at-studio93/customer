import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

import '../../../constant/variable_constant.dart';

class PopularServiceWidget extends StatelessWidget {
  const PopularServiceWidget({super.key});

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
                imageUrl:
                    'https://images.unsplash.com/photo-1488376739361-ed24c9beb6d0?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fHBsYXklMjBpY29ufGVufDB8fDB8fHww',
                placeholder: (context, url) => const Image(
                    image: AssetImage(AssetsConstant.placeHolder),
                    fit: BoxFit.cover),
                errorWidget: (context, url, error) => const Image(
                    image: AssetImage(AssetsConstant.placeHolder),
                    fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Low Fade Hair',
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 12,
                    color: ColorConstant.grayTextColor,
                  ),
                  Text(
                    '4.8 (76 Reviews)',
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
                    '₹399',
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
                    '35 min',
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.grayTextColor, fontSize: 16),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Container(
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
            ],
          ),
        ],
      ),
    );
  }
}
