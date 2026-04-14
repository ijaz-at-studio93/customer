import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';

import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/model/cart/service_add_cart_model.dart';
import 'package:salon_customer/project_specific/edit_product_button_widget.dart';
import 'package:salon_customer/project_specific/remove_button_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import '../../../controller/home_controller.dart'; // 🔥 ADD THIS

class KnowWhatYouWidget extends StatelessWidget {
  final ServicesWithProduct items;
  final String serviceId;
  final VoidCallback removeBtn;
  final VoidCallback addBtn;
  final VoidCallback editProduct;

  const KnowWhatYouWidget({
    super.key,
    required this.items,
    required this.removeBtn,
    required this.editProduct,
    required this.addBtn, // 👈 ADD
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final qty = controller.getQuantity(serviceId);

      /// 🔥 SAFE UNIT PRICE CALCULATION
      final double unitPrice = qty > 0
          ? (items.totalCost ?? 0) / qty
          : (items.totalCost ?? 0).toDouble();

      final double totalPrice = unitPrice * qty;

      /// 🔥 SERVICE COST FIX
      final double unitServiceCost = qty > 0
          ? (items.totalServiceCost ?? 0) / qty
          : (items.totalServiceCost ?? 0).toDouble();

      final double totalServiceCost = unitServiceCost * qty;

      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ROW 1: Title + Duration
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${items.name}",
                                style: AppTextTheme.bold.copyWith(
                                  fontFamily: "Outfit",          // ✅ Figma font
                                  fontWeight: FontWeight.w600,   // ✅ Bold
                                  fontSize: 18,                  // ✅ exact size from Figma
                                  color: const Color(0xFF000000),
                                  height: 1,                     // ✅ tight like design
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            Text(
                              "${items.duration} min",
                              style: AppTextTheme.medium.copyWith(
                                fontFamily: "Outfit",           // ✅ Figma font
                                fontWeight: FontWeight.w800,    // ✅ Medium (not bold)
                                fontSize: 14,                   // ✅ smaller like Figma
                                color: Colors.black.withOpacity(0.4), // ✅ soft grey
                                height: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4), // 🔥 reduced gap

                        /// ROW 2: Price + Remove
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "₹${unitPrice.toStringAsFixed(0)}",
                              style: AppTextTheme.bold.copyWith(
                                fontFamily: "Outfit",          // ✅ Figma font
                                fontWeight: FontWeight.w700,   // ✅ Bold
                                fontSize: 14,                  // ✅ correct size
                                color: const Color(0xFF000000),
                                height: 1,
                              ),
                            ),

                            SizedBox(
                              width: 80,
                              height: 30, // 🔥 control button height
                              //child: RemoveButtonWidget(onPress: removeBtn),
                                child: Container(
                                  //height: 30,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: removeBtn, // 👈 decrease
                                        child: const Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Icon(Icons.remove, size: 16, color: Colors.red),
                                        ),
                                      ),
                                      const SizedBox(width: 13),

                                      Text(
                                        "$qty",
                                        style: const TextStyle(
                                          fontFamily: "Outfit",
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 13),

                                      GestureDetector(
                                        onTap: addBtn, // 👈 increase
                                        child: const Padding(
                                          padding: EdgeInsets.only(right: 5),
                                          child: Icon(Icons.add, size: 16, color: Colors.green),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Dash(
              //   direction: Axis.horizontal,
              //   length: Get.width * 0.85,
              //   dashLength: 3,
              //   dashColor: ColorConstant.grayBorderColor,
              // ),
              //
              // const SizedBox(height: 6),
              //
              // /// 🔥 UPDATED SERVICE COST
              // Text(
              //   "Service Cost: ₹${totalServiceCost.toStringAsFixed(0)}",
              //   style: AppTextTheme.medium.copyWith(
              //     color: ColorConstant.grayTextColor,
              //     fontSize: 13,
              //   ),
              // ),
            ],
          ),
          Positioned(
            bottom: 90, // 👈 adjust based on bottom bar
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Get.back(); // stylist
                  Get.back(); // salon
                },
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF01AB4D), // green from figma
                      width: 1.5,
                    ),
                    color: const Color(0x1401AB4D), // light green bg
                  ),
                  child: const Center(
                    child: Text(
                      "Add More",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF01AB4D),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]
      );
    });
  }
}