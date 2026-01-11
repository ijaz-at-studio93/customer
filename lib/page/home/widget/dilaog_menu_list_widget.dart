import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import '../../../model/home_category_list_model.dart';

class DialogMenuListWidget extends StatelessWidget {
  final CategoryListData categoryListData;
  final VoidCallback onPress;
  const DialogMenuListWidget(
      {super.key, required this.onPress, required this.categoryListData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  height: 70,
                  width: 70,
                  // Horoscope image
                  fit: BoxFit.cover,
                  imageUrl:  SharedPrefs.readStringValue(PrefConstants.gender) ==
                          "0"
                      ? "${APIConstants.image}${categoryListData.imageMale}"
                      : "${APIConstants.image}${categoryListData.imageFemale}",
                  placeholder: (context, url) => const Image(
                    image: AssetImage(AssetsConstant.placeHolder),
                    height: 70,
                    width: 70,
                    // Horoscope image
                    fit: BoxFit.cover,
                  ),
                  errorWidget: (context, url, error) => const Image(
                    image: AssetImage(AssetsConstant.placeHolder),
                    height: 70,
                    width: 70,
                    // Horoscope image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Space between image and text
              SizedBox(
                width: Get.width * 0.2,
                child: Text(
                  categoryListData.name ?? "", // Horoscope name
                  maxLines: 2,
                  softWrap: true,
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.medium
                      .copyWith(color: ColorConstant.blackColor, fontSize: 13),
                  // Text style
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          Positioned(
            right: -3,
            top: 10,
            child: categoryListData.isSelectCategory ?? false
                ? Container(
                    height: 21,
                    width: 21,
                    decoration: BoxDecoration(
                        color: changeTheme(
                            SharedPrefs.readStringValue(PrefConstants.gender)),
                        shape: BoxShape.circle),
                    child: Center(
                      child: Image.asset(
                        AssetsConstant.xMark,
                        color: ColorConstant.whiteColor,
                        width: 10,
                        height: 10,
                      ),
                    ),
                  )
                : const SizedBox(),
          )
        ],
      ),
    );
  }
}
