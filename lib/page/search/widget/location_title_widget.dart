import 'package:flutter/material.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

class LocationTileWidget extends StatelessWidget {
    final  VoidCallback onPress;
  const LocationTileWidget({super.key, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lakme Saloon & Spa",
            style: AppTextTheme.bold.copyWith(
              color: ColorConstant.blackColor,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "25 Min • Available for Home",
            style: AppTextTheme.medium
                .copyWith(fontSize: 13, color: ColorConstant.grayTextColor),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Image.asset(
                AssetsConstant.location,
                width: 12,
                height: 12,
              ),
              Text(
                "First Floor, Bindal Tower, near ...",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.grayTextColor, fontSize: 13),
              ),
            ],
          )
        ],
      ),
    );
  }
}
