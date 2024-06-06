import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/api_constant.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/model/artiest_list_model.dart';

import 'package:sallon_customer/project_specific/remove_button_widget.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

import '../../../project_specific/text_theme.dart';
import '../stylist_saloon_details_page.dart';

class SelectedFavArtistCardWidget extends StatelessWidget {
  final VoidCallback onPress;
  final Artiest artiest;
  const SelectedFavArtistCardWidget(
      {super.key, required this.onPress, required this.artiest});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  imageUrl: '${APIConstants.image}${artiest.profileImage}',
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
                  artiest.name ?? "",
                  textScaler: const TextScaler.linear(0.70),
                  style: AppTextTheme.bold
                      .copyWith(color: ColorConstant.blackColor, fontSize: 15),
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
                      "${artiest.rating}",
                      style: AppTextTheme.medium.copyWith(
                          fontSize: 11, color: ColorConstant.yellowColor),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onPress,
            child: artiest.isSelectArtist ?? false
                ? RemoveButtonWidget(onPress: onPress)
                : Container(
                    height: 39,
                    width: 158,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(56),
                        border: Border.all(
                          color: changeTheme(SharedPrefs.readStringValue(
                                  PrefConstants.gender)) ??
                              ColorConstant.primaryColor,
                        )),
                    child: Center(
                      child: Text(
                        "Select Artist",
                        style: AppTextTheme.medium.copyWith(
                            color: changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender)) ??
                                ColorConstant.primaryColor,
                            fontSize: 13),
                      ),
                    ),
                  ),
          ),
          TextButton(
            onPressed: () {
              Get.to(() => StylistSaloonDetailsPage(
                    artiestId: artiest.id ?? "",
                  ));
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
    );
  }
}
