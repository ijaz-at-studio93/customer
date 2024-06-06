import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/controller/home_controller.dart';
import 'package:sallon_customer/model/cart/service_add_cart_model.dart';
import 'package:sallon_customer/project_specific/ProgressContainerView.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/NoItemsWidget.dart';
import 'package:sallon_customer/util/logger.dart';
import 'custom_list_tile_widget.dart';

class CustomizedSheetWidget extends StatefulWidget {
  final ServiceAddCartModel serviceAddCartModel;
  const CustomizedSheetWidget({super.key, required this.serviceAddCartModel});

  @override
  State<CustomizedSheetWidget> createState() => _CustomizedSheetWidgetState();
}

class _CustomizedSheetWidgetState extends State<CustomizedSheetWidget> {
  final _homeController = Get.find<HomeController>();

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
                    child: widget.serviceAddCartModel.data
                                ?.servicesAvailableProductList?.isEmpty ??
                            false
                        ? const NoItemsWidget(text: "No Any Product Found")
                        : ListView.separated(
                            separatorBuilder: (context, index) {
                              return Container(
                                margin:
                                    const EdgeInsets.only(bottom: 15, top: 15),
                                height: 1,
                                width: Get.width,
                                color: ColorConstant.dividerColor,
                              );
                            },
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 15),
                            itemCount: widget.serviceAddCartModel.data
                                    ?.servicesAvailableProductList?.length ??
                                0,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: CustomListTileWidget(
                                  rate:
                                      "${widget.serviceAddCartModel.data?.servicesAvailableProductList?[index].rating}",
                                  nameProduct: widget
                                          .serviceAddCartModel
                                          .data
                                          ?.servicesAvailableProductList?[index]
                                          .name ??
                                      "",
                                  productDescription: widget
                                          .serviceAddCartModel
                                          .data
                                          ?.servicesAvailableProductList?[index]
                                          .description ??
                                      "",
                                  productImage: widget
                                          .serviceAddCartModel
                                          .data
                                          ?.servicesAvailableProductList?[index]
                                          .image ??
                                      "",
                                  price: widget
                                          .serviceAddCartModel
                                          .data
                                          ?.servicesAvailableProductList?[index]
                                          .price
                                          .toString() ??
                                      "",
                                  isAdd: () {
                                    /* logger.d("Is Add");
                                    setState(() {
                                      widget
                                          .serviceAddCartModel
                                          .data
                                          ?.servicesAvailableProductList?[index]
                                          .isAdded = !(widget
                                              .serviceAddCartModel
                                              .data
                                              ?.servicesAvailableProductList?[
                                                  index]
                                              .isAdded ??
                                          false);
                                    });*/
                                    _homeController.doAddProductCart(
                                        productId: widget
                                                .serviceAddCartModel
                                                .data
                                                ?.servicesAvailableProductList?[
                                                    index]
                                                .id ??
                                            "",
                                        callback: () {
                                          setState(() {
                                            widget
                                                .serviceAddCartModel
                                                .data
                                                ?.servicesAvailableProductList?[
                                                    index]
                                                .isAdded = true;
                                          });
                                          _homeController.doGetCart();
                                        });
                                  },
                                  isRemove: () {
                                    logger.d("Is Remove");
                                    _homeController.doRemoveProductCart(
                                        productId: widget
                                                .serviceAddCartModel
                                                .data
                                                ?.servicesAvailableProductList?[
                                                    index]
                                                .id ??
                                            "",
                                        callback: () {
                                          setState(() {
                                            widget
                                                .serviceAddCartModel
                                                .data
                                                ?.servicesAvailableProductList?[
                                                    index]
                                                .isAdded = false;
                                          });
                                          _homeController.doGetCart();
                                        });
                                  },
                                  isAdded: widget
                                          .serviceAddCartModel
                                          .data
                                          ?.servicesAvailableProductList?[index]
                                          .isAdded ??
                                      false,
                                ),
                              );
                            },
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
                  color: ColorConstant.crossMarkColor, shape: BoxShape.circle),
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
