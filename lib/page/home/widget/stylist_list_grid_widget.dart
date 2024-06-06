import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/model/salon_details_artiest.dart';
import 'package:sallon_customer/project_specific/remove_button_widget.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import '../../../constant/api_constant.dart';
import '../../../constant/variable_constant.dart';
import '../../../util/SharedPrefs.dart';
import '../../stylist/stylist_saloon_details_page.dart';

class StylistListGridWidget extends StatefulWidget {
  final VoidCallback onPress;
  final bool isView;
  final SalonArtiestListModel salonArtiestListModel;

  const StylistListGridWidget({
    super.key,
    required this.onPress,
    required this.salonArtiestListModel,
    required this.isView,
  });

  @override
  State<StylistListGridWidget> createState() => _StylistListGridWidgetState();
}

class _StylistListGridWidgetState extends State<StylistListGridWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPress,
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFF1F1F1)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    width: Get.width,
                    height: 135,
                    fit: BoxFit.cover,
                    imageUrl:
                        "${APIConstants.image}${widget.salonArtiestListModel.profileImage}",
                    placeholder: (context, url) => Image(
                      image: const AssetImage(AssetsConstant.placeHolder),
                      width: Get.width,
                      height: 135,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => Image(
                      image: const AssetImage(AssetsConstant.placeHolder),
                      width: Get.width,
                      height: 135,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    height: 25,
                    width: Get.width * 0.22,
                    decoration: BoxDecoration(
                        color: ColorConstant.topRatedColor,
                        borderRadius: BorderRadius.circular(6)),
                    child: Center(
                      child: Text(
                        "TOP RATED",
                        style: AppTextTheme.medium.copyWith(
                            color: ColorConstant.whiteColor, fontSize: 11),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.salonArtiestListModel.name ?? "",
                    textScaler: const TextScaler.linear(0.85),
                    style: AppTextTheme.bold.copyWith(
                        color: ColorConstant.blackColor, fontSize: 15),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: ColorConstant.yellowColor,
                        size: 20,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '4.8',
                        style: AppTextTheme.medium.copyWith(
                            fontSize: 11, color: ColorConstant.yellowColor),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            !widget.isView
                ? const SizedBox()
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.salonArtiestListModel.isSelected =
                            !(widget.salonArtiestListModel.isSelected ?? false);
                      });
                    },
                    child: widget.salonArtiestListModel.isSelected ?? false
                        ? RemoveButtonWidget(onPress: () {
                            setState(() {
                              widget.salonArtiestListModel.isSelected = false;
                            });
                          })
                        : Container(
                            height: 39,
                            width: 110,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(56),
                                border: Border.all(
                                  color: changeTheme(
                                          SharedPrefs.readStringValue(
                                              PrefConstants.gender)) ??
                                      ColorConstant.primaryColor,
                                )),
                            child: Center(
                              child: Text(
                                "Select Artist",
                                style: AppTextTheme.medium.copyWith(
                                    color: changeTheme(
                                            SharedPrefs.readStringValue(
                                                PrefConstants.gender)) ??
                                        ColorConstant.primaryColor,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                  ),
            !widget.isView ? const SizedBox(height: 39) : const SizedBox(),
            TextButton(
              onPressed: () {
                Get.to(() => StylistSaloonDetailsPage(
                      artiestId: widget.salonArtiestListModel.id ?? "",
                    ));
                /*Get.to(() => const AboutStylistPage());*/
              },
              child: Text(
                "View Profile",
                style: AppTextTheme.medium.copyWith(
                    fontSize: 13,
                    color: ColorConstant.grayTextColor,
                    decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
