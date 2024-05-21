import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sallon_customer/constant/api_constant.dart';

import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/model/home_salon_list_model.dart';

import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

class SaloonCardWidget extends StatefulWidget {
  final VoidCallback onPress;
  final HomeSalonModel homeSalonModel;
  const SaloonCardWidget({
    super.key,
    required this.onPress,
    required this.homeSalonModel,
  });

  @override
  State<SaloonCardWidget> createState() => _SaloonCardWidgetState();
}

class _SaloonCardWidgetState extends State<SaloonCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: GestureDetector(
        onTap: widget.onPress,
        child: Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorConstant.strokeColor, width: 1.5),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: CachedNetworkImage(
                      width: Get.width,
                      height: Get.height * 0.25,
                      fit: BoxFit.fitWidth,
                      imageUrl:
                          "${APIConstants.image}${widget.homeSalonModel.image}",
                      placeholder: (context, url) => Image(
                        image: const AssetImage(AssetsConstant.placeHolder),
                        width: Get.width,
                        height: Get.height * 0.25,
                        fit: BoxFit.fitWidth,
                      ),
                      errorWidget: (context, url, error) => Image(
                        image: const AssetImage(AssetsConstant.placeHolder),
                        width: Get.width,
                        height: Get.height * 0.25,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.homeSalonModel.isFav = !(widget.homeSalonModel.isFav ??false);
                        });
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorConstant.blackColor),
                        child: Center(
                          child: widget.homeSalonModel.isFav ?? false
                              ? const Icon(
                            CupertinoIcons.heart_fill,
                            color: Colors.red,
                          )
                              : Image.asset(
                            AssetsConstant.likeBlank,
                            height: 20,
                            width: 20,
                            color: changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                      bottom: 10,
                      left: 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          const SizedBox(width: 5),
                          Text(
                            'Average Stylist rating',
                            style: AppTextTheme.medium.copyWith(
                                fontSize: 13, color: ColorConstant.whiteColor),
                          ),
                        ],
                      )),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: Get.width * 0.5,
                          child: Text(
                            '${widget.homeSalonModel.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textScaler: const TextScaler.linear(0.85),
                            style: AppTextTheme.bold.copyWith(
                                fontSize: 19, color: ColorConstant.blackColor),
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (widget.homeSalonModel.homeService ?? false) Row(
                          children: [
                            Text(
                              "25 Min",
                              style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.grayTextColor,
                                  fontSize: 13),
                            ),
                            Text(
                              " • Available for Home",
                              style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.grayTextColor,
                                  fontSize: 13),
                            ),
                          ],
                        ) else  const SizedBox(),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              AssetsConstant.locationNewIcon,
                              height: 15,
                              width: 15,
                              color: changeTheme(SharedPrefs.readStringValue(
                                  PrefConstants.gender)),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: Get.width * 0.75,
                              child: Text(
                                '${widget.homeSalonModel.address}',
                                style: AppTextTheme.medium.copyWith(
                                    fontSize: 13,
                                    color: ColorConstant.grayTextColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
