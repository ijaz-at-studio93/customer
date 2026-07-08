import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/project_specific/remove_button_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import '../../../constant/api_constant.dart';
import '../../../controller/home_controller.dart';
import '../../../project_specific/action_button.dart';

class SelectedServiceListTileWidget extends StatelessWidget {
  final String serviceName;
  final String serviceCategory;
  final String servicePrice;
  final String serviceRating;
  final String serviceReview;
  final String serviceImage;

  final String serviceId; // 🔥 NEW
  final String gender;

  final VoidCallback onAdd; // 🔥 NEW
  final VoidCallback onRemove; // 🔥 UPDATED (rename)
  final VoidCallback editProduct;
  final String serviceTime;

  const SelectedServiceListTileWidget({
    super.key,
    required this.onRemove,
    required this.onAdd,
    required this.editProduct,
    required this.serviceName,
    required this.serviceCategory,
    required this.gender,
    required this.servicePrice,
    required this.serviceTime,
    required this.serviceRating,
    required this.serviceReview,
    required this.serviceImage,
    required this.serviceId, // 🔥 NEW
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    // Prefer the category from the cart response; otherwise resolve it from
    // the loaded salon categories using the service id.
    final String categoryLabel = serviceCategory.trim().isNotEmpty
        ? serviceCategory.trim()
        : controller.categoryNameForService(serviceId);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT SIDE
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: Get.width * 0.6,
              child: Text(
                serviceName,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.bold.copyWith(
                  fontSize: 16.5,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                  color: (gender ?? "").toLowerCase() == "male"
                      ? ColorConstant.primaryColor
                      : ColorConstant.primary2, // female
                ),
              ),
            ),

            /// CATEGORY (shown under the service name)
            if (categoryLabel.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: Get.width * 0.6,
                child: Text(
                  categoryLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.medium.copyWith(
                    fontSize: 13,
                    fontFamily: 'Outfit',
                    color: ColorConstant.grayTextColor,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),

            const SizedBox(height: 10),

            Row(
              children: [
                Text(
                  "₹ $servicePrice •",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.bold.copyWith(
                    color: ColorConstant.blackColor, fontSize: 17, fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,),
                ),
                const SizedBox(width: 10),
                Text(
                  "($serviceTime min)",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.medium.copyWith(
                    color: ColorConstant.grayTextColor, fontSize: 13, fontFamily: 'Inter',),
                ),
                const SizedBox(width: 13),

                // InkWell(
                //   onTap: editProduct,
                //   child: Row(
                //     children: [
                //       Image.asset(
                //         AssetsConstant.editIcon,
                //         height: 15,
                //         width: 15,
                //         color: changeTheme(
                //           SharedPrefs.readStringValue(PrefConstants.gender),
                //         ) ??
                //             ColorConstant.primaryColor,
                //       ),
                //       const SizedBox(width: 8),
                //       Text(
                //         "Edit Product",
                //         style: AppTextTheme.regular.copyWith(
                //           fontSize: 13,
                //           color: changeTheme(
                //               SharedPrefs.readStringValue(PrefConstants.gender)),
                //         ),
                //       ),
                //     ],
                //   ),
                // )
              ],
            ),

            const SizedBox(height: 10),

            // Dash(
            //   direction: Axis.horizontal,
            //   length: Get.width * 0.55,
            //   dashLength: 2,
            //   dashColor: ColorConstant.grayTextColor,
            // ),
            SizedBox(
              width: Get.width * 0.6, // or any fixed width
              child: Dash(
                dashLength: 2,
                dashColor: ColorConstant.grayTextColor,
              ),
            )
          ],
        ),

        /// RIGHT SIDE (IMAGE + BUTTON)
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                width: 123,
                height: 123,
                fit: BoxFit.cover,
                imageUrl: "${APIConstants.image}$serviceImage",
                placeholder: (context, url) => const Image(
                  image: AssetImage(AssetsConstant.placeHolder),
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) => const Image(
                  image: AssetImage(AssetsConstant.placeHolder),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// 🔥 QUANTITY BUTTON
            Positioned(
              bottom: -18,
              left: 8,
              right: 8,
              child: Obx(() {
                final qty = controller.getQuantity(serviceId);

                if (qty > 0) {
                  return Container(
                      height: 40,
                      width: 120,
                    // padding: const EdgeInsets.symmetric(
                    //     horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (gender ?? "").toLowerCase() == "male"
                        ? ColorConstant.primaryColor
                            : ColorConstant.primary2,
                        )
                    ),
                    // child: Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     GestureDetector(
                    //       onTap: onRemove,
                    //       child: const Icon(Icons.remove, size: 18),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     Text(
                    //       qty.toString(),
                    //       style: AppTextTheme.bold.copyWith(
                    //         color: ColorConstant.blackColor,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 16),
                    //     GestureDetector(
                    //       onTap: onAdd,
                    //       child: const Icon(Icons.add, size: 18),
                    //     ),
                    //   ],
                    // ),
                      child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              /// 🔥 MINUS
                              ActionIconButton(
                                icon: Icons.remove,
                                onTap: onRemove,
                              ),

                              const SizedBox(width: 13),

                              Text(
                                qty.toString(),
                                style: AppTextTheme.bold.copyWith(
                                  color: ColorConstant.blackColor,
                                ),
                              ),

                              const SizedBox(width: 13),

                              /// 🔥 PLUS
                              ActionIconButton(
                                icon: Icons.add,
                                onTap: onAdd,
                              ),
                            ],
                          )
                      )
                  );
                } else {
                  return RemoveButtonWidget(onPress: onRemove);
                }
              }),
            ),
          ],
        ),
      ],
    );
  }
}