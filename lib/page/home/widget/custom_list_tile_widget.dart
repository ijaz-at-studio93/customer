import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

import '../../../constant/color_constant.dart';

class CustomListTileWidget extends StatelessWidget {
  const CustomListTileWidget({super.key});

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
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "₹399 • ",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.bold
                      .copyWith(color: ColorConstant.blackColor, fontSize: 16),
                ),
                Text(
                  "35 min",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.medium
                      .copyWith(color: ColorConstant.grayColor, fontSize: 16),
                ),
              ],
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
                'Short Description of the Hair cut ideas of something cut ideas of something.',
                trimMode: TrimMode.Line,
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.grayTextColor, fontSize: 14),
                trimLines: 2,
                colorClickableText: ColorConstant.primaryColor,
                trimCollapsedText: 'more',
                trimExpandedText: 'Show less',
                moreStyle: AppTextTheme.medium
                    .copyWith(fontSize: 15, color: ColorConstant.primaryColor),
              ),
            ),
          ],
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "https://www.rootandsoil.in/cdn/shop/products/CHB100back1_1_1100x.jpg?v=1712144340",
                width: 108,
                height: 123,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: -12,
              left: -8,
              right: -8,
              child: Container(
                height: 39,
                width: 110,
                decoration: BoxDecoration(
                  color: ColorConstant.removeBgStroke,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: ColorConstant.removeStroke),
                ),
                child: Center(
                  child: Text(
                    'Remove',
                    style: AppTextTheme.medium.copyWith(
                        fontSize: 13, color: ColorConstant.removeStroke),
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
