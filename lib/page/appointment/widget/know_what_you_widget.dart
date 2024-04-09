import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/project_specific/edit_product_button_widget.dart';
import 'package:sallon_customer/project_specific/remove_button_widget.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

class KnowWhatYouWidget extends StatelessWidget {
  const KnowWhatYouWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Facial Spa',
                  style: AppTextTheme.bold
                      .copyWith(fontSize: 16, color: ColorConstant.blackColor),
                ),
                const SizedBox(height: 10),
                Text(
                  'Lakme Cream + Head Facial..',
                  style: AppTextTheme.medium.copyWith(
                      fontSize: 13, color: ColorConstant.grayTextColor),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '₹399',
                      style: AppTextTheme.bold.copyWith(
                          fontSize: 16, color: ColorConstant.blackColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹3199',
                      style: AppTextTheme.bold.copyWith(
                          fontSize: 16,
                          color: ColorConstant.grayTextColor,
                          decoration: TextDecoration.lineThrough),
                    ),
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        Image.asset(
                          AssetsConstant.offerIcon,
                          height: 14,
                          width: 14,
                        ),
                        Text(
                          "50% Off",
                          style: AppTextTheme.medium.copyWith(
                              color: ColorConstant.primaryColor, fontSize: 13),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
            Column(
              children: [
                Text(
                  '38 Min',
                  style: AppTextTheme.medium.copyWith(
                      fontSize: 13, color: ColorConstant.grayTextColor),
                ),
                const SizedBox(height: 10),
                EditProductButtonWidget(onTap: () {}),
                const SizedBox(height: 10),
                RemoveButtonWidget(onPress: () {})
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Dash(
            direction: Axis.horizontal,
            length: 351,
            dashLength: 3,
            dashColor: Colors.grey),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Service Cost : 300',
              style: AppTextTheme.medium
                  .copyWith(fontSize: 13, color: ColorConstant.grayTextColor),
            ),
            const SizedBox(width: 9),
            Container(
              height: 4,
              width: 4,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.grey),
            ),
            const SizedBox(width: 9),
            Text(
              'Product Cost : 400',
              style: AppTextTheme.medium
                  .copyWith(fontSize: 13, color: ColorConstant.grayTextColor),
            ),
          ],
        ),
      ],
    );
  }
}
