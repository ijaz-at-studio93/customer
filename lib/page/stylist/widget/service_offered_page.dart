import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';

import 'package:get/get.dart';
import 'package:sallon_customer/constant/api_constant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/model/artiest_portfolio_model.dart';
import 'package:sallon_customer/page/stylist/widget/service_offered_list_tile_widget.dart';

import '../../../project_specific/text_theme.dart';

class ServiceAndOfferedPage extends StatefulWidget {
  final ArtiestPortfolio artiestPortfolio;
  const ServiceAndOfferedPage({super.key, required this.artiestPortfolio});

  @override
  State<ServiceAndOfferedPage> createState() => _ServiceAndOfferedPageState();
}

class _ServiceAndOfferedPageState extends State<ServiceAndOfferedPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstant.whiteColor,
      child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) {
            return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  height: 1,
                  width: Get.width,
                  color: const Color(0xffADADAD),
                ));
          },
          shrinkWrap: true,
          itemCount: widget.artiestPortfolio.data?.services?.length ?? 0,
          itemBuilder: (context, index) {
            return ServiceOfferListTileWidget(
              rate:
                  widget.artiestPortfolio.data?.services?[index].rating ?? 0.0,
              image:
                  "${APIConstants.image}${widget.artiestPortfolio.data?.services?[index].image}",
              name: widget.artiestPortfolio.data?.services?[index].name ?? "",
              price: widget.artiestPortfolio.data?.services?[index].price
                      .toString() ??
                  "",
              duration: widget.artiestPortfolio.data?.services?[index].duration
                      .toString() ??
                  "",
              reviewCount: widget
                      .artiestPortfolio.data?.services?[index].reviewCount
                      .toString() ??
                  "",
            );
          }),
    );
  }
}
