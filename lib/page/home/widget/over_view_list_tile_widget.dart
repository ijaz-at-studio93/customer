import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:sallon_customer/constant/api_constant.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/model/category_service_list_model.dart';
import 'package:sallon_customer/project_specific/add_button_widget.dart';
import 'package:sallon_customer/project_specific/remove_button_widget.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

class OverviewListTileWidget extends StatefulWidget {
  final Services servicesList ;

  final VoidCallback onTap;
  final VoidCallback addButtonTap;
  final bool isSelect;
  const OverviewListTileWidget(
      {super.key,
      required this.onTap,
      required this.addButtonTap,
      required this.isSelect,
      required this.servicesList});

  @override
  State<OverviewListTileWidget> createState() => _OverviewListTileWidgetState();
}

class _OverviewListTileWidgetState extends State<OverviewListTileWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: InkWell(
        onTap: widget.onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: Get.width * 0.5,
                  child: Text(
                    widget.servicesList.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: const TextScaler.linear(0.85),
                    style: AppTextTheme.bold.copyWith(
                        color: ColorConstant.blackColor, fontSize: 17),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      "Gender • ",
                      textScaler: const TextScaler.linear(0.85),
                      style: AppTextTheme.bold.copyWith(
                          color: ColorConstant.blackColor, fontSize: 16),
                    ),
                    Text(
                      widget.servicesList.gender ?? "",
                      textScaler: const TextScaler.linear(0.85),
                      style: AppTextTheme.medium.copyWith(
                          color: ColorConstant.grayColor, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      "₹${widget.servicesList.price} • ",
                      textScaler: const TextScaler.linear(0.85),
                      style: AppTextTheme.bold.copyWith(
                          color: ColorConstant.blackColor, fontSize: 16),
                    ),
                    Text(
                      "${widget.servicesList.duration} min",
                      textScaler: const TextScaler.linear(0.85),
                      style: AppTextTheme.medium.copyWith(
                          color: ColorConstant.grayColor, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                widget.servicesList.homeService ?? false
                    ? Row(
                        children: [
                          const Icon(Icons.home, size: 15),
                          const SizedBox(width: 5),
                          Text(
                            "Is service available",
                            textScaler: const TextScaler.linear(0.85),
                            style: AppTextTheme.medium.copyWith(
                                color: ColorConstant.grayColor, fontSize: 16),
                          ),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(height: 5),
                Dash(
                  direction: Axis.horizontal,
                  length: Get.width * 0.5,
                  dashLength: 2,
                  dashColor: ColorConstant.grayTextColor,
                ),
                const SizedBox(height: 13),
                SizedBox(
                  width: Get.width * 0.5,
                  child: ReadMoreText(
                    widget.servicesList.description ?? "",
                    trimMode: TrimMode.Line,
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.grayTextColor, fontSize: 14),
                    trimLines: 2,
                    colorClickableText: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)),
                    trimCollapsedText: 'more',
                    trimExpandedText: 'Show less',
                    moreStyle: AppTextTheme.medium.copyWith(
                      fontSize: 15,
                      color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)),
                    ),
                  ),
                ),
              ],
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: widget.addButtonTap,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      width: 123,
                      height: 123,
                      fit: BoxFit.cover,
                      imageUrl: "${APIConstants.image}${widget.servicesList.image ?? " "}",
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
                  left: 8,
                  right: 8,
                  child: widget.isSelect
                      ? RemoveButtonWidget(onPress: widget.addButtonTap)
                      : AddButtonWidget(
                          onPress: widget.addButtonTap,
                          color: changeTheme(SharedPrefs.readStringValue(
                                  PrefConstants.gender)) ??
                              ColorConstant.primaryColor,
                        ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
