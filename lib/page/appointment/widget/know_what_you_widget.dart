import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';


import 'package:salon_customer/constant/color_constant.dart';

import 'package:salon_customer/model/cart/service_add_cart_model.dart';
import 'package:salon_customer/project_specific/edit_product_button_widget.dart';

import 'package:salon_customer/project_specific/remove_button_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';



class KnowWhatYouWidget extends StatelessWidget {
  final ServicesWithProduct items;
  final VoidCallback removeBtn;
  final VoidCallback editProduct;

  const KnowWhatYouWidget({
    super.key,
    required this.items,
    required this.removeBtn,
    required this.editProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items.name ?? "",
                  style: AppTextTheme.bold
                      .copyWith(fontSize: 16, color: ColorConstant.blackColor),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0, // gap between adjacent chips
                  runSpacing: 4.0, // gap between lines
                  children: List.generate(
                      items.products?.length ?? 0,
                      (index) => Text(
                            index == 0
                                ? "${items.products?[index].name ?? ""}"
                                : "${items.products?[index].name ?? ""} +",
                            style: AppTextTheme.medium.copyWith(
                                fontSize: 13,
                                color: ColorConstant.grayTextColor),
                          )),
                ),
                const SizedBox(height: 15),
                Text(
                  '₹${items.totalCost}',
                  style: AppTextTheme.bold
                      .copyWith(fontSize: 16, color: ColorConstant.blackColor),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${items.duration} Min',
                  style: AppTextTheme.medium.copyWith(
                      fontSize: 13, color: ColorConstant.grayTextColor),
                ),
                const SizedBox(height: 15),
                EditProductButtonWidget(onTap: editProduct),
                const SizedBox(height: 15),
                RemoveButtonWidget(onPress: removeBtn)
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Dash(
            direction: Axis.horizontal,
            length: Get.width * 0.85,
            dashLength: 3,
            dashColor: ColorConstant.grayBorderColor),
        const SizedBox(height: 15),
        Text(
          "Service Cost: ₹${items.totalServiceCost}", //• Product Cost: ₹${items.totalProductCost}",
          style: AppTextTheme.medium
              .copyWith(color: ColorConstant.grayTextColor, fontSize: 13),
        )
      ],
    );
  }
}
