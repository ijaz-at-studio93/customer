import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/model/home_salon_list_model.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

class SaloonCardWidget extends StatefulWidget {
  final VoidCallback onPress;
  final HomeSalonDataList homeSalonModel;
  final bool isFav;
  const SaloonCardWidget({
    super.key,
    required this.onPress,
    required this.homeSalonModel,
    required this.isFav,
  });

  @override
  State<SaloonCardWidget> createState() => _SaloonCardWidgetState();
}

class _SaloonCardWidgetState extends State<SaloonCardWidget> {
  final _homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: GestureDetector(
        onTap: widget.onPress,
        child: Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: ColorConstant.crossMarkColor,
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
                      height: Get.height * 0.20,
                      fit: BoxFit.fitWidth,
                      imageUrl:
                          "${APIConstants.image}${widget.homeSalonModel.image}",
                      placeholder: (context, url) => Image(
                        image: const AssetImage(AssetsConstant.placeHolder),
                        width: Get.width,
                        height: Get.height * 0.20,
                        fit: BoxFit.fitWidth,
                      ),
                      errorWidget: (context, url, error) => Image(
                        image: const AssetImage(AssetsConstant.placeHolder),
                        width: Get.width,
                        height: Get.height * 0.20,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          ColorConstant.blackColor,
                          Colors.black.withOpacity(0),
                          Colors.black.withOpacity(0),
                        ],
                      ),
                    ),
                    width: Get.width,
                    height: Get.height * 0.25,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.homeSalonModel.isFavourite =
                              !(widget.homeSalonModel.isFavourite ?? false);
                          if (widget.homeSalonModel.isFavourite ?? false) {
                            _homeController.doAddFavouriteSalon(
                                salonId: widget.homeSalonModel.id ?? "");
                          } else {
                            _homeController.doRemoveFavouriteSalon(
                                callback: () {},
                                salonId: widget.homeSalonModel.id ?? "");
                          }
                        });
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorConstant.blackColor),
                        child: Center(
                          child: widget.homeSalonModel.isFavourite ?? false
                              ? const Icon(
                                  CupertinoIcons.heart_fill,
                                  color: Colors.red,
                                )
                              : Image.asset(
                                  AssetsConstant.likeBlank,
                                  height: 20,
                                  width: 20,
                                  color: ColorConstant.whiteColor,
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
                          (widget.homeSalonModel.averageArtistRatings ?? 0).toStringAsFixed(2),
                          style: AppTextTheme.medium.copyWith(
                              fontSize: 11, color: ColorConstant.yellowColor),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Average Stylist Rating',
                          style: AppTextTheme.medium.copyWith(
                              fontSize: 13, color: ColorConstant.whiteColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
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
                        Text(
                          "${widget.homeSalonModel.distanceTime} Min • ${widget.homeSalonModel.homeService == true ? "Available for Home" : "Available for Shop"}",
                          style: AppTextTheme.medium.copyWith(
                              color: ColorConstant.grayTextColor, fontSize: 13),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              "Starting From",
                              style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.grayTextColor,
                                  fontSize: 13),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "₹${widget.homeSalonModel.serviceStartingPrice} Onwards",
                              style: AppTextTheme.bold.copyWith(
                                  color: changeTheme(
                                      SharedPrefs.readStringValue(
                                          PrefConstants.gender)),
                                  fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height:
                                5), /* Row(
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
                        ),*/
                      ],
                    ),
                    Container(
                      height: 28,
                      width: 52,
                      decoration: BoxDecoration(
                          color: ColorConstant.greenColor,
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star,
                              color: ColorConstant.whiteColor, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            widget.homeSalonModel.rating.toString(),
                            style: AppTextTheme.medium.copyWith(
                                color: ColorConstant.whiteColor, fontSize: 11),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Dash(
                direction: Axis.horizontal,
                length: Get.width * 0.8,
                dashLength: 2,
                dashColor: ColorConstant.grayTextColor,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    Image.asset(
                      AssetsConstant.newOfferIcon,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Upto 20% Off ",
                      style: AppTextTheme.bold.copyWith(
                          color: ColorConstant.offerTextColor, fontSize: 13),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
