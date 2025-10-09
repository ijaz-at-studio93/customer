import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/page/home/widget/add_product_sheet_widget.dart';
import 'package:salon_customer/page/home/widget/selected_service_list_tile_widget.dart';
import 'package:salon_customer/page/stylist/selecting_artist_bottom_sheet.dart';
import 'package:salon_customer/project_specific/ProgressContainerView.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';

import '../../../constant/api_constant.dart';
import '../../../constant/variable_constant.dart';
import '../../../controller/home_controller.dart';
import '../../../project_specific/text_theme.dart';
import '../../../util/SharedPrefs.dart';
import '../../appointment/appointment_booking_page.dart';

class SelectedServiceSheetPage extends StatefulWidget {
  final String artiestId;
  final String serviceId;
  final String salonId;
  const SelectedServiceSheetPage(
      {super.key,
      required this.artiestId,
      required this.serviceId,
      required this.salonId});

  @override
  State<SelectedServiceSheetPage> createState() =>
      _SelectedServiceSheetPageState();
}

class _SelectedServiceSheetPageState extends State<SelectedServiceSheetPage> {
  final _homeController = Get.find<HomeController>();
  final box = GetStorage();

  String artiestId = "";

  @override
  void initState() {
    super.initState();
    artiestId = widget.artiestId;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: Get.height * 0.7,
          width: Get.width,
          decoration: const BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
            ),
          ),
          child: Obx(
            () => ProgressContainerView(
              isProgressRunning: _homeController.showProgress,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(19),
                    child: Text(
                      "Selected Services",
                      style: AppTextTheme.bold.copyWith(
                          fontSize: 19, color: ColorConstant.blackColor),
                    ),
                  ),
                  Center(
                    child: Dash(
                      dashLength: 1,
                      dashGap: 5,
                      dashColor: ColorConstant.dividerColor,
                      dashThickness: 2,
                      length: Get.width * 0.9,
                    ),
                  ),
                  Expanded(
                    child: _homeController.getServiceAddCartModel.data
                                ?.servicesWithProduct?.isEmpty ??
                            false || _homeController.getServiceAddCartModel.data
                                ?.servicesWithProduct ==  null
                        ? const NoItemsWidget(text: "No Any Selected Service")
                        : ListView.builder(
                            shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      itemCount: _homeController.getServiceAddCartModel.data
                              ?.servicesWithProduct?.length ??
                          0,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: SelectedServiceListTileWidget(
                            editProduct: () {
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(32),
                                    topRight: Radius.circular(32),
                                  )),
                                  context: context,
                                  builder: (context) {
                                    return AddProductSheetWidget(
                                        price: _homeController
                                                .getServiceAddCartModel
                                                .data
                                                ?.servicesWithProduct?[index]
                                                .totalProductCost ??
                                            0,
                                        rating: _homeController
                                                .getServiceAddCartModel
                                                .data
                                                ?.servicesWithProduct?[index]
                                                .rating ??
                                            0.0,
                                        review: _homeController
                                                .getServiceAddCartModel
                                                .data
                                                ?.servicesWithProduct?[index]
                                                .reviewCount ??
                                            0,
                                        nameOfService: _homeController
                                                .getServiceAddCartModel
                                                .data
                                                ?.servicesWithProduct?[index]
                                                .name ??
                                            "",
                                        serviceId: _homeController
                                                .getServiceAddCartModel
                                                .data
                                                ?.servicesWithProduct?[index]
                                                .serviceId ??
                                            "");
                                  });
                            },
                            isRemove: () {
                              _homeController.doRemoveCart(
                                  salonServiceId: _homeController
                                          .getServiceAddCartModel
                                          .data
                                          ?.servicesWithProduct?[index]
                                          .serviceId ??
                                      "",
                                  callback: () {
                                    _homeController.doGetCart();
                                    _homeController.doGetSalonDetailsService(
                                        serviceGender:
                                        SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                                            ? "male"
                                            : "female",
                                        salonId: widget.salonId);
                                  });
                            },
                            serviceImage: _homeController.getServiceAddCartModel
                                    .data?.servicesWithProduct?[index].image ??
                                "",
                            serviceName: _homeController.getServiceAddCartModel
                                    .data?.servicesWithProduct?[index].name ??
                                "",
                            servicePrice: _homeController.getServiceAddCartModel
                                    .data?.servicesWithProduct?[index].totalCost
                                    .toString() ??
                                "",
                            serviceRating: _homeController
                                    .getServiceAddCartModel
                                    .data
                                    ?.servicesWithProduct?[index]
                                    .rating
                                    .toString() ??
                                "",
                            serviceReview: _homeController
                                    .getServiceAddCartModel
                                    .data
                                    ?.servicesWithProduct?[index]
                                    .reviewCount
                                    .toString() ??
                                "",
                          ),
                        );
                      },
                    ),
                  ),
                  _homeController.getServiceAddCartModel.data?.items?.isEmpty ??
                          false ||
                              _homeController
                                      .getServiceAddCartModel.data?.items ==
                                  null
                      ? const SizedBox()
                      : Container(
                          width: Get.width,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: ColorConstant.whiteColor,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x1E000000),
                                blurRadius: 8,
                                offset: Offset(-2, -2),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          clipBehavior: Clip.none,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _homeController.getServiceAddCartModel.data
                                              ?.previewImages?.isEmpty ??
                                          false
                                      ? const SizedBox()
                                      : Row(
                                          children: [
                                            _homeController
                                                        .getServiceAddCartModel
                                                        .data
                                                        ?.previewImages
                                                        ?.length ==
                                                    1
                                                ? Row(
                                                    children: [
                                                      for (int i = 0;
                                                          i < 1;
                                                          i++)
                                                        Align(
                                                          widthFactor: 0.8,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                            child:
                                                                CachedNetworkImage(
                                                              fit: BoxFit.cover,
                                                              width: 30,
                                                              height: 30,
                                                              imageUrl:
                                                                  "${APIConstants.image}${_homeController.getServiceAddCartModel.data?.previewImages?[i] ?? ""}",
                                                              placeholder:
                                                                  (context,
                                                                          url) =>
                                                                      const Image(
                                                                image: AssetImage(
                                                                    AssetsConstant
                                                                        .placeHolder),
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: 30,
                                                                height: 30,
                                                              ),
                                                              errorWidget: (context,
                                                                      url,
                                                                      error) =>
                                                                  const Image(
                                                                image: AssetImage(
                                                                    AssetsConstant
                                                                        .placeHolder),
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: 30,
                                                                height: 30,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    ],
                                                  )
                                                : _homeController
                                                            .getServiceAddCartModel
                                                            .data
                                                            ?.previewImages
                                                            ?.length ==
                                                        2
                                                    ? Row(
                                                        children: [
                                                          for (int i = 0;
                                                              i < 2;
                                                              i++)
                                                            Align(
                                                              widthFactor: 0.8,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: 30,
                                                                  height: 30,
                                                                  imageUrl:
                                                                      "${APIConstants.image}${_homeController.getServiceAddCartModel.data?.previewImages?[i] ?? ""}",
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      const Image(
                                                                    image: AssetImage(
                                                                        AssetsConstant
                                                                            .placeHolder),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    width: 30,
                                                                    height: 30,
                                                                  ),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      const Image(
                                                                    image: AssetImage(
                                                                        AssetsConstant
                                                                            .placeHolder),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    width: 30,
                                                                    height: 30,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                        ],
                                                      )
                                                    : Row(
                                                        children: [
                                                          for (int i = 0;
                                                              i < 2;
                                                              i++)
                                                            Align(
                                                              widthFactor: 0.7,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: 35,
                                                                  height: 35,
                                                                  imageUrl:
                                                                      "${APIConstants.image}${_homeController.getServiceAddCartModel.data?.previewImages?[i] ?? ""}",
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      const Image(
                                                                    image: AssetImage(
                                                                        AssetsConstant
                                                                            .placeHolder),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    width: 35,
                                                                    height: 35,
                                                                  ),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      const Image(
                                                                    image: AssetImage(
                                                                        AssetsConstant
                                                                            .placeHolder),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    width: 35,
                                                                    height: 35,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          const SizedBox(
                                                              width: 2),
                                                          Container(
                                                            width: 33,
                                                            height: 33,
                                                            decoration: const BoxDecoration(
                                                                color: ColorConstant
                                                                    .primaryColor,
                                                                shape: BoxShape
                                                                    .circle),
                                                            child: Center(
                                                              child: Text(
                                                                _homeController
                                                                        .getServiceAddCartModel
                                                                        .data
                                                                        ?.previewImages
                                                                        ?.length
                                                                        .toString() ??
                                                                    "",
                                                                style:
                                                                    AppTextTheme
                                                                        .medium
                                                                        .copyWith(
                                                                  color: ColorConstant
                                                                      .whiteColor,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                          ],
                                        ),
                                  const SizedBox(width: 15),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${_homeController.getServiceAddCartModel.data?.items?.length} Added",
                                        style: AppTextTheme.bold.copyWith(
                                            fontSize: 13,
                                            color: ColorConstant.grayTextColor),
                                      ),
                                      Text(
                                        "₹${(_homeController.getServiceAddCartModel.data?.price ?? 0).toDouble().toStringAsFixed(2)}",
                                        style: AppTextTheme.bold.copyWith(
                                            fontSize: 19,
                                            color: ColorConstant.blackColor,
                                        ),
                                      )

                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (artiestId != "") {
                                    Get.to(() => AppointmentBookingPage(
                                          artiestId: artiestId,
                                        ));
                                  } else {
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        isDismissible: false,
                                        enableDrag: false,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(32),
                                          topRight: Radius.circular(32),
                                        )),
                                        context: context,
                                        builder: (context) {
                                          return SelectingArtistBottomSheetWidget(
                                            salonId: widget.salonId,
                                            serviceId: widget.serviceId,
                                            callback: () {
                                              setState(() {
                                                artiestId =
                                                    box.read('artiestId');
                                              });
                                            },
                                          );
                                        });
                                  }
                                },
                                child: Container(
                                  height: 45,
                                  width: Get.width * 0.4,
                                  decoration: BoxDecoration(
                                    color: changeTheme(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.gender)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        artiestId.isNotEmpty
                                            ? "Book Slot"
                                            : "Select Stylist",
                                        textScaler:
                                            const TextScaler.linear(0.70),
                                        style: AppTextTheme.medium.copyWith(
                                            fontSize: 16,
                                            color: ColorConstant.whiteColor),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.arrow_forward,
                                        color: ColorConstant.whiteColor,
                                        size: 20,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: -50,
          left: 0,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                  color: ColorConstant.whiteColor, shape: BoxShape.circle),
              child: Center(
                child: Image.asset(
                  AssetsConstant.xMark,
                  width: 15,
                  height: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
