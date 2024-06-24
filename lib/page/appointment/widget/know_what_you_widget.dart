import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';

import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/model/cart/service_add_cart_model.dart';

import 'package:salon_customer/project_specific/remove_button_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';

import '../../../util/SharedPrefs.dart';

class KnowWhatYouWidget extends StatelessWidget {
  final Items items;
  final VoidCallback removeBtn;
  final VoidCallback removeProduct;
  const KnowWhatYouWidget(
      {super.key,
      required this.items,
      required this.removeBtn,
      required this.removeProduct});

  @override
  Widget build(BuildContext context) {
    if (items.isService ?? false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Service",
            style: AppTextTheme.bold
                .copyWith(fontSize: 16, color: ColorConstant.primaryColor),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items.service?.name ?? "",
                    style: AppTextTheme.bold.copyWith(
                        fontSize: 16, color: ColorConstant.blackColor),
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
                        '₹${items.service?.price}',
                        style: AppTextTheme.bold.copyWith(
                            fontSize: 16, color: ColorConstant.blackColor),
                      ),
                      const SizedBox(width: 8),
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    '${items.service?.duration} Min',
                    style: AppTextTheme.medium.copyWith(
                        fontSize: 13, color: ColorConstant.grayTextColor),
                  ),
                  const SizedBox(height: 10),
                  /* EditProductButtonWidget(onTap: () {}),
                const SizedBox(height: 10),*/
                  RemoveButtonWidget(onPress: removeBtn)
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Dash(
              direction: Axis.horizontal,
              length: Get.width * 0.85,
              dashLength: 3,
              dashColor: Colors.grey),
          const SizedBox(height: 10),
          SizedBox(
            width: Get.width,
            child: ReadMoreText(
              items.service?.description ?? "",
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
                      ColorConstant.primaryColor),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product",
            style: AppTextTheme.bold
                .copyWith(fontSize: 16, color: ColorConstant.primaryColor),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items.product?.name ?? "",
                    style: AppTextTheme.bold.copyWith(
                        fontSize: 16, color: ColorConstant.blackColor),
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
                        '₹${items.product?.price}',
                        style: AppTextTheme.bold.copyWith(
                            fontSize: 16, color: ColorConstant.blackColor),
                      ),
                      const SizedBox(width: 8),
                    ],
                  )
                ],
              ),
              RemoveButtonWidget(onPress: removeProduct)
            ],
          ),
          const SizedBox(height: 10),
        ],
      );
    }
  }
}
