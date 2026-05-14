import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/model/category_service_list_model.dart';
import 'package:salon_customer/project_specific/add_button_widget.dart';
import 'package:salon_customer/project_specific/remove_button_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

import '../../../controller/home_controller.dart';
import '../../../project_specific/action_button.dart';

class OverviewListTileWidget extends StatefulWidget {
  final Services servicesList;
  final VoidCallback onTap;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const OverviewListTileWidget(
      {super.key,
      required this.onTap,
      required this.quantity,
      required this.onAdd,
      required this.onRemove,
      required this.servicesList});

  @override
  State<OverviewListTileWidget> createState() => _OverviewListTileWidgetState();
}

class _OverviewListTileWidgetState extends State<OverviewListTileWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 6),
      child: InkWell(
        onTap: widget.onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.servicesList.name ?? "",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textScaler: const TextScaler.linear(0.85),
                    style: AppTextTheme.bold.copyWith(
                      color: ColorConstant.blackColor,
                      fontSize: 16.5,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        "₹${widget.servicesList.price}  ",
                        textScaler: const TextScaler.linear(0.85),
                        style: AppTextTheme.bold.copyWith(
                          color: ColorConstant.blackColor,
                          fontSize: 17,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, 1),
                        child: Text(
                          "(${widget.servicesList.duration} min)",
                          textScaler: const TextScaler.linear(0.85),
                          style: AppTextTheme.medium.copyWith(
                            color: ColorConstant.grayTextColor,
                            fontSize: 13,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ReadMoreText(
                    widget.servicesList.description ?? "",
                    trimMode: TrimMode.Line,
                    style: AppTextTheme.medium.copyWith(
                      color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)),
                      fontSize: 12,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                    ),
                    trimLines: 4,
                    colorClickableText: ColorConstant.blackColor,
                    trimCollapsedText: 'more',
                    trimExpandedText: 'Show less',
                    moreStyle: AppTextTheme.medium.copyWith(
                      fontSize: 12,
                      color: ColorConstant.blackColor,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      width: 140,
                      height: 142,
                      fit: BoxFit.cover,
                      imageUrl:
                          "${APIConstants.image}${widget.servicesList.image ?? " "}",
                      placeholder: (context, url) => const Image(
                        image: AssetImage(AssetsConstant.placeHolder),
                        width: 108,
                        height: 123,
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (context, url, error) => const Image(
                        image: AssetImage(AssetsConstant.placeHolder),
                        width: 108,
                        height: 123,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -18,
                  left: 12,
                  right: 6,
                  child: Align(
                    alignment: Alignment.center,
                    child: Obx(() {
                      final controller = Get.find<HomeController>();
                      final serviceId = widget.servicesList.id ?? "";
                      final qty = controller.getQuantity(serviceId);

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: qty > 0
                            ? Container(
                                key: const ValueKey("qty"),
                                height: 40,
                                width: 115,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: changeTheme(
                                          SharedPrefs.readStringValue(
                                              PrefConstants.gender),
                                        ) ??
                                        ColorConstant.primaryColor,
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ActionIconButton(
                                        icon: Icons.remove,
                                        onTap: widget.onRemove,
                                      ),
                                      const SizedBox(width: 15),
                                      _buildQtyText(qty),
                                      const SizedBox(width: 15),
                                      ActionIconButton(
                                        icon: Icons.add,
                                        onTap: widget.onAdd,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : AddButtonWidget(
                                key: const ValueKey("add"),
                                onPress: widget.onAdd,
                                color: changeTheme(
                                      SharedPrefs.readStringValue(
                                          PrefConstants.gender),
                                    ) ??
                                    ColorConstant.primaryColor,
                              ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyText(int qty) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: Text(
        qty.toString(),
        key: ValueKey(qty),
        style: AppTextTheme.bold.copyWith(
          color: ColorConstant.blackColor,
        ),
      ),
    );
  }
}
