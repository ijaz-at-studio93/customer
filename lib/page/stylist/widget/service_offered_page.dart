import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';

import 'package:get/get.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/page/stylist/widget/service_offered_list_tile_widget.dart';

import '../../../project_specific/text_theme.dart';

class ServiceAndOfferedPage extends StatefulWidget {
  const ServiceAndOfferedPage({super.key});

  @override
  State<ServiceAndOfferedPage> createState() => _ServiceAndOfferedPageState();
}

class _ServiceAndOfferedPageState extends State<ServiceAndOfferedPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstant.whiteColor,
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return ExpansionTile(
              initiallyExpanded: index == 0 ? true : false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Beard",
                    style: AppTextTheme.bold.copyWith(
                        color: ColorConstant.blackColor, fontSize: 19),
                  ),
                  const SizedBox(height: 10),
                  Dash(
                    direction: Axis.horizontal,
                    length: Get.width * 0.8,
                    dashLength: 2,
                    dashColor: ColorConstant.grayTextColor,
                  ),
                ],
              ),
              children: [
                ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            height: 1,
                            width: Get.width,
                            color: const Color(0xffADADAD),
                          ));
                    },
                    shrinkWrap: true,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return const ServiceOfferListTileWidget();
                    }),

              ],
            );
          }),
    );
  }
}
