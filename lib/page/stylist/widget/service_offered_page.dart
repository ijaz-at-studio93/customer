import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/model/artiest_portfolio_model.dart';
import 'package:salon_customer/page/stylist/widget/service_offered_list_tile_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import '../../../controller/home_controller.dart';

class ServiceAndOfferedPage extends StatefulWidget {
  final ArtiestPortfolio artiestPortfolio;

  const ServiceAndOfferedPage({
    super.key,
    required this.artiestPortfolio,
  });

  @override
  State<ServiceAndOfferedPage> createState() => _ServiceAndOfferedPageState();
}

class _ServiceAndOfferedPageState extends State<ServiceAndOfferedPage> {
  final _homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstant.whiteColor,
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: Get.height * 0.16),
          itemCount:
              widget.artiestPortfolio.data?.categorizedServiceList?.length ?? 0,
          itemBuilder: (context, index) {
            return ExpansionTile(
              initiallyExpanded: index == 0 ? true : false,
              title: Text(
                widget.artiestPortfolio.data?.categorizedServiceList?[index]
                        .name ??
                    "",
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.blackColor, fontSize: 19),
              ),
              children: [
                ListView.separated(
                    separatorBuilder: (context, i) {
                      return Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        height: 1,
                        width: Get.width,
                        color: ColorConstant.dividerColor,
                      );
                    },
                    shrinkWrap: true,
                    itemCount: widget.artiestPortfolio.data
                            ?.categorizedServiceList?[index].services?.length ??
                        0,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, i) {
                      return ServiceOfferListTileWidget(
                        rate: widget
                                .artiestPortfolio
                                .data
                                ?.categorizedServiceList?[index]
                                .services?[i]
                                .rating ??
                            0.0,
                        image:
                            "${APIConstants.image}${widget.artiestPortfolio.data?.categorizedServiceList?[index].services?[i].image ?? 0.0}",
                        name: widget
                                .artiestPortfolio
                                .data
                                ?.categorizedServiceList?[index]
                                .services?[i]
                                .name ??
                            "",
                        description: widget
                                .artiestPortfolio
                                .data
                                ?.categorizedServiceList?[index]
                                .services?[i]
                                .description ??
                            "",
                        price: widget
                                .artiestPortfolio
                                .data
                                ?.categorizedServiceList?[index]
                                .services?[i]
                                .price
                                .toString() ??
                            "",
                        duration: widget
                                .artiestPortfolio
                                .data
                                ?.categorizedServiceList?[index]
                                .services?[i]
                                .duration
                                .toString() ??
                            "",
                        reviewCount: widget
                                .artiestPortfolio
                                .data
                                ?.categorizedServiceList?[index]
                                .services?[i]
                                .reviewCount
                                .toString() ??
                            "",
                        isSelect: widget
                                .artiestPortfolio
                                .data
                                ?.categorizedServiceList?[index]
                                .services?[i]
                                .isAddedToCart ??
                            false,
                        addButtonTap: () {
                          widget
                              .artiestPortfolio
                              .data
                              ?.categorizedServiceList?[index]
                              .services?[i]
                              .isAddedToCart = !(widget
                                  .artiestPortfolio
                                  .data
                                  ?.categorizedServiceList?[index]
                                  .services?[i]
                                  .isAddedToCart ??
                              false);

                          if (widget
                                  .artiestPortfolio
                                  .data
                                  ?.categorizedServiceList?[index]
                                  .services?[i]
                                  .isAddedToCart ??
                              false) {
                            _homeController.doAddCart(
                                salonServiceId: widget
                                        .artiestPortfolio
                                        .data
                                        ?.categorizedServiceList?[index]
                                        .services?[i]
                                        .id ??
                                    "",
                                isHomeService: _homeController
                                        .homeSalonDetailsData
                                        .data
                                        ?.homeService ??
                                    false,
                                callback: () {
                                  _homeController.doGetCart();
                                });
                          } else {
                            _homeController.doRemoveCart(
                                salonServiceId: widget
                                        .artiestPortfolio
                                        .data
                                        ?.categorizedServiceList?[index]
                                        .services?[i]
                                        .id ??
                                    "",
                                callback: () {
                                  _homeController.doGetCart();
                                });
                          }
                        },
                      );
                    }),
                const SizedBox(height: 22),
              ],
            );
          }),
    );
  }
}
