import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'custom_list_tile_widget.dart';

class AddProductSheetWidget extends StatefulWidget {
  final String serviceId;
  final String nameOfService;
  final double rating;
  final int review;
  final int price;
  const AddProductSheetWidget(
      {super.key,
      required this.serviceId,
      required this.nameOfService,
      required this.rating,
      required this.review,
      required this.price});

  @override
  State<AddProductSheetWidget> createState() => _AddProductSheetWidgetState();
}

class _AddProductSheetWidgetState extends State<AddProductSheetWidget> {
  final _homeController = Get.find<HomeController>();

  bool isAddForProduct = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetProductData(serviceId: widget.serviceId);
    });
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
            () => _homeController.showProgress
                ? const ProgressBarView()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.nameOfService,
                              textScaler: const TextScaler.linear(0.85),
                              style: AppTextTheme.bold.copyWith(
                                  fontSize: 19,
                                  color: ColorConstant.blackColor),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Image.asset(
                                  AssetsConstant.starIcon,
                                  height: 13,
                                  width: 13,
                                ),
                                Text(
                                  "${widget.rating} (${widget.review} Reviews)",
                                  textScaler: const TextScaler.linear(0.85),
                                  style: AppTextTheme.medium.copyWith(
                                      fontSize: 19,
                                      color: ColorConstant.grayTextColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "₹${widget.price}",
                              textScaler: const TextScaler.linear(0.85),
                              style: AppTextTheme.bold.copyWith(
                                  fontSize: 19,
                                  color: ColorConstant.blackColor),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: ColorConstant.dividerRedLightColor,
                        thickness: 1,
                      ),
                      Container(
                        width: Get.width * 0.3,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 21, vertical: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ColorConstant.greenColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            "RECOMMENDED",
                            style: AppTextTheme.medium.copyWith(
                                fontSize: 10, color: ColorConstant.whiteColor),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _homeController
                                    .getServiceProductModel.data?.isEmpty ??
                                false
                            ? const NoItemsWidget(
                                text: "No products were found.")
                            : ListView.separated(
                                separatorBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 15, top: 15),
                                    height: 1,
                                    width: Get.width,
                                    color: ColorConstant.dividerColor,
                                  );
                                },
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 15),
                                itemCount: _homeController
                                        .getServiceProductModel.data?.length ??
                                    0,
                                itemBuilder: (context, index) {
                                  isAddForProduct = _homeController
                                      .getServiceProductModel
                                      .data?[index]
                                      .isAddedToCart ??
                                      false;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    child: CustomListTileWidget(
                                      rate:
                                          "${_homeController.getServiceProductModel.data?[index].rating}",
                                      nameProduct: _homeController
                                              .getServiceProductModel
                                              .data?[index]
                                              .name ??
                                          "",
                                      productDescription: _homeController
                                              .getServiceProductModel
                                              .data?[index]
                                              .description ??
                                          "",
                                      productImage: _homeController
                                              .getServiceProductModel
                                              .data?[index]
                                              .image ??
                                          "",
                                      price: _homeController
                                              .getServiceProductModel
                                              .data?[index]
                                              .price
                                              .toString() ??
                                          "",
                                      isAdd: () {
                                        _homeController.doAddProductCart(
                                            productSelectedServiceId:
                                                widget.serviceId,
                                            productId: _homeController
                                                    .getServiceProductModel
                                                    .data?[index]
                                                    .id ??
                                                "",
                                            callback: () {
                                              setState(() {
                                                _homeController
                                                    .getServiceProductModel
                                                    .data?[index]
                                                    .isAddedToCart = true;
                                              });
                                              _homeController.doGetCart();
                                              isAddForProduct = _homeController
                                                      .getServiceProductModel
                                                      .data?[index]
                                                      .isAddedToCart ??
                                                  false;
                                            });
                                      },
                                      isRemove: () {
                                        _homeController.doRemoveProductCart(
                                            productSelectedServiceId:
                                                widget.serviceId,
                                            productId: _homeController
                                                    .getServiceProductModel
                                                    .data?[index]
                                                    .id ??
                                                "",
                                            callback: () {
                                              setState(() {
                                                _homeController
                                                    .getServiceProductModel
                                                    .data?[index]
                                                    .isAddedToCart = false;
                                              });
                                              _homeController.doGetCart();
                                              isAddForProduct = _homeController
                                                      .getServiceProductModel
                                                      .data?[index]
                                                      .isAddedToCart ??
                                                  false;
                                            });
                                      },
                                      isAdded: _homeController
                                              .getServiceProductModel
                                              .data?[index]
                                              .isAddedToCart ??
                                          false,
                                    ),
                                  );
                                },
                              ),
                      ),
                      Container(
                        width: Get.width,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFF8F8F8)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            isAddForProduct
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total Price",
                                        style: AppTextTheme.bold.copyWith(
                                            fontSize: 13,
                                            color: ColorConstant.grayTextColor),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "₹${_homeController.getServiceAddCartModel.data?.price ?? ""}",
                                        style: AppTextTheme.bold.copyWith(
                                            fontSize: 19,
                                            color: ColorConstant.blackColor),
                                      )
                                    ],
                                  )
                                : const SizedBox(),
                            GestureDetector(
                              onTap: () {
                                Get.back();
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
                                      isAddForProduct
                                          ? "Continue"
                                          : "Skip & Continue",
                                      textScaler: const TextScaler.linear(0.70),
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
                      )
                    ],
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
