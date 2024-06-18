import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/api_constant.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';
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
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  height: 80,
                  width: 80,
                  // Horoscope image
                  fit: BoxFit.cover,
                  imageUrl: categoryListData.serviceableGender == "male"
                      ? "${APIConstants.image}${categoryListData.imageMale}"
                      : "${APIConstants.image}${categoryListData.imageFemale}",
                  placeholder: (context, url) => const Image(
                    image: AssetImage(AssetsConstant.placeHolder),
                    height: 80,
                    width: 80,
                    // Horoscope image
                    fit: BoxFit.cover,
                  ),
                  errorWidget: (context, url, error) => const Image(
                    image: AssetImage(AssetsConstant.placeHolder),
                    height: 80,
                    width: 80,
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
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.medium
                      .copyWith(color: ColorConstant.blackColor, fontSize: 13),
                  // Text style
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Positioned(
            right: -5,
            top: 2,
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
