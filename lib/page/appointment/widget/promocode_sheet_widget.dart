import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/appointment/widget/promocode_list_tile.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

import '../../../util/call_wrapper.dart';
import '../../../util/snackbar_util.dart';

class PromoCodeSheetWidget extends StatefulWidget {
  final DateTime selectedDate;

  const PromoCodeSheetWidget({super.key, required this.selectedDate});

  @override
  State<PromoCodeSheetWidget> createState() => _PromoCodeSheetWidgetState();
}

class _PromoCodeSheetWidgetState extends State<PromoCodeSheetWidget> {
  final _homeController = Get.find<HomeController>();

  // 👇 Added controller for new input tile
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetListPromoCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CallWrapper(   // ✅ Wrap everything in CallWrapper
      initialPosition: const Offset(250, 350),
      child: Container(
        height: Get.height * 0.7,
        width: Get.width,
        decoration: const BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            topLeft: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              width: Get.width,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF8454E5), // 🔥 left
                    Color(0xFFCD73B4), // 🔥 right
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  topLeft: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  "Apply PromoCode",
                  style: AppTextTheme.bold.copyWith(
                    fontFamily: "Outfit",
                  ),
                ),
              ),
            ),
            // 🔷 Custom coupon input field with Apply button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender),
                    ) ??
                        Colors.grey, // fallback
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF8454E5),
                          Color(0xFFCD73B4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.confirmation_number,
                        size: 40,
                        color: Colors.white, // 👈 IMPORTANT
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        style: const TextStyle(
                          fontFamily: "Outfit",   // 👈 input text
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Enter Coupon Code",
                          hintStyle: TextStyle(
                            fontFamily: "Outfit", // 👈 hint text
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                // Align(
                //   alignment: Alignment.centerRight, // 👈 THIS
                //     child: SizedBox(
                //       width: 100,
                //     height: 40,
                //     child: ElevatedButton(
                //       onPressed: () {
                //         final code = _couponController.text.trim().toLowerCase();
                //         final matchingPromo = _homeController
                //             .getPromoCodeModelList.data
                //             ?.firstWhereOrNull((promo) =>
                //         (promo.code?.toLowerCase() ?? '') == code);
                //
                //         if (matchingPromo != null) {
                //
                //           /// PRE-GST cart amount
                //           final int cartAmount =
                //           (((_homeController.getServiceAddCartModel.data?.price ?? 0).toInt()/1.05).toInt());
                //
                //           final int minOrder =
                //               int.tryParse(matchingPromo.minOrder?.toString() ?? '0') ?? 0;
                //
                //           if (cartAmount < minOrder) {
                //             final int remaining = minOrder - cartAmount;
                //
                //             SnackbarUtil.show(
                //               "Coupon Locked",
                //               "Add ₹$remaining more to use this coupon",
                //               backgroundColor: Colors.orange,
                //               colorText: Colors.white,
                //             );
                //
                //             return; // ❌ STOP — don't call API
                //           }
                //
                //           /// eligible → proceed
                //           Get.back(result: matchingPromo.id);
                //         }
                //
                //         // if (matchingPromo != null) {
                //         //   Get.back(result: matchingPromo.id);
                //         // }
                //         else {
                //           SnackbarUtil.show(
                //               "Invalid Code", "No promo found with that code.");
                //         }
                //       },
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: changeTheme(
                //             SharedPrefs.readStringValue(PrefConstants.gender)),
                //         padding: const EdgeInsets.symmetric(
                //             horizontal: 16, vertical: 10),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(10),
                //         ),
                //       ),
                //       child: const Text("Apply"),
                //     )),
                // )
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 100,
                        height: 40,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF8454E5),
                                Color(0xFFCD73B4),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              final code = _couponController.text.trim().toLowerCase();

                              final matchingPromo = _homeController
                                  .getAllPromoCodes
                                  .firstWhereOrNull((promo) =>
                              (promo.code?.toLowerCase() ?? '') == code);

                              if (matchingPromo != null) {
                                final int cartAmount =
                                (((_homeController.getServiceAddCartModel.data?.price ?? 0)
                                    .toInt() /
                                    1.05)
                                    .toInt());

                                final int minOrder =
                                    int.tryParse(matchingPromo.minOrder?.toString() ?? '0') ?? 0;

                                if (cartAmount < minOrder) {
                                  final int remaining = minOrder - cartAmount;

                                  SnackbarUtil.show(
                                    "Coupon Locked",
                                    "Add ₹$remaining more to use this coupon",
                                    backgroundColor: Colors.orange,
                                    colorText: Colors.white,
                                  );

                                  return;
                                }

                                Get.back(result: matchingPromo.id);
                              } else {
                                SnackbarUtil.show(
                                  "Invalid Code",
                                  "No promo found with that code.",
                                );
                              }
                            },

                            /// 🔥 MAKE BUTTON TRANSPARENT
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            child: const Text(
                              "Apply",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.white, // 👈 important
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(
                      () => _homeController.showProgress
                      ? const ProgressBarView()
                      : _homeController.getAllPromoCodes.isEmpty
                      ? const NoItemsWidget(
                    text: "Promo code not available there",
                  )
                      : ListView.builder(
                      itemCount: _homeController.getAllPromoCodes.length,
                      shrinkWrap: true,
                      // itemBuilder: (context, i) {
                      //   return PromoCodeListTile(
                      //     id: _homeController
                      //         .getPromoCodeModelList.data?[i].id ??
                      //         "",
                      //     image: _homeController
                      //         .getPromoCodeModelList.data?[i].image ??
                      //         "",
                      //     title: _homeController
                      //         .getPromoCodeModelList.data?[i].title ??
                      //         "",
                      //     description: _homeController
                      //         .getPromoCodeModelList
                      //         .data?[i]
                      //         .description ??
                      //         "",
                      //     type: _homeController
                      //         .getPromoCodeModelList.data?[i].type ??
                      //         "",
                      //     amount: _homeController
                      //         .getPromoCodeModelList.data?[i].amount ??
                      //         0,
                      //     code: _homeController
                      //         .getPromoCodeModelList.data?[i].code ??
                      //         "",
                      //     endsAt: _homeController
                      //         .getPromoCodeModelList.data?[i].endsAt ??
                      //         "",
                      //     maxDiscount: _homeController
                      //         .getPromoCodeModelList
                      //         .data?[i]
                      //         .maxDiscount ??
                      //         "",
                      //     minOrder: _homeController
                      //         .getPromoCodeModelList
                      //         .data?[i]
                      //         .minOrder ??
                      //         "",
                      //     startsAt: _homeController
                      //         .getPromoCodeModelList
                      //         .data?[i]
                      //         .startsAt ??
                      //         "",
                      //     onTapApplyBtn: () {
                      //       Get.back(
                      //           result: _homeController
                      //               .getPromoCodeModelList
                      //               .data?[i]
                      //               .id ??
                      //               "");
                      //     },
                      //   );
                      // }),
                      itemBuilder: (context, i) {
                        final promo = _homeController.getAllPromoCodes[i];

                        /// PRE-GST cart total
                        final int cartAmount =
                        (((_homeController.getServiceAddCartModel.data?.price ?? 0).toInt()/1.05).toInt());

                        print('***************');
                        print(cartAmount);

                        final int minOrder =
                            int.tryParse(promo?.minOrder?.toString() ?? '0') ?? 0;

                        //final bool isDisabled = cartAmount < minOrder;
                        final today = widget.selectedDate.weekday % 7;

                        final applicableDays = promo?.applicableDays;

                        final bool isDayValid = applicableDays == null ||
                            applicableDays.isEmpty ||
                            applicableDays.contains(today);

                        final bool isMinOrderFail = cartAmount < minOrder;

                        // Row 39: a category-scoped coupon is only valid when
                        // the cart contains a service from one of its
                        // categories (mirrors the applicableDays rule).
                        final applicableCategories = promo?.applicableCategories;
                        final bool isCategoryValid = applicableCategories ==
                                null ||
                            applicableCategories.isEmpty ||
                            applicableCategories
                                .any(_homeController.cartCategoryIds().contains);

                        final bool isDisabled =
                            isMinOrderFail || !isDayValid || !isCategoryValid;
                        final bool isDayFail = !isDayValid;

                        final int remainingAmount =
                        isMinOrderFail ? (minOrder - cartAmount) : 0;

                        return PromoCodeListTile(
                          id: promo?.id ?? "",
                          image: promo?.image ?? "",
                          title: promo?.title ?? "",
                          description: promo?.description ?? "",
                          type: promo?.type ?? "",
                          amount: promo?.amount ?? 0,
                          code: promo?.code ?? "",
                          endsAt: promo?.endsAt ?? "",
                          maxDiscount: promo?.maxDiscount ?? "",
                          minOrder: minOrder,
                          startsAt: promo?.startsAt ?? "",

                          isDisabled: isDisabled,
                          unlockAmount: remainingAmount,
                          isDayValid: isDayValid,
                          isMinOrderFail: isMinOrderFail,
                          applicableDays: applicableDays,

                          // Row 39: category-scoped coupon info.
                          isCategoryValid: isCategoryValid,
                          applicableCategoryNames: applicableCategories
                              ?.map((id) =>
                                  _homeController.categoryNameById(id))
                              .where((n) => n.isNotEmpty)
                              .toList(),

                          onTapApplyBtn: isDisabled
                              ? null
                              : () {
                            Get.back(result: promo?.id ?? "");
                          },
                        );
                      })

              ),
            ),
          ],
        ),
      ),
    );
  }
}