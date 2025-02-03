import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/appointment/widget/promocode_list_tile.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

class PromoCodeSheetWidget extends StatefulWidget {
  const PromoCodeSheetWidget({super.key});

  @override
  State<PromoCodeSheetWidget> createState() => _PromoCodeSheetWidgetState();
}

class _PromoCodeSheetWidgetState extends State<PromoCodeSheetWidget> {
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetListPromoCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.7,
      width: Get.width,
      decoration: const BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            width: Get.width,
            decoration: BoxDecoration(
              color: changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender)) ??
                  ColorConstant.primaryColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                topLeft: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                "Apply PromoCode",
                style: AppTextTheme.bold,
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => _homeController.showProgress
                  ? const ProgressBarView()
                  : _homeController.getPromoCodeModelList.data?.isEmpty ?? false
                      ? const NoItemsWidget(
                          text: "Promo code not available there",
                        )
                      : ListView.builder(
                          itemCount: _homeController
                              .getPromoCodeModelList.data?.length,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            return PromoCodeListTile(
                              id: _homeController
                                      .getPromoCodeModelList.data?[i].id ??
                                  "",
                              image: _homeController
                                      .getPromoCodeModelList.data?[i].image ??
                                  "",
                              title: _homeController
                                      .getPromoCodeModelList.data?[i].title ??
                                  "",
                              description: _homeController.getPromoCodeModelList
                                      .data?[i].description ??
                                  "",
                              type: _homeController
                                      .getPromoCodeModelList.data?[i].type ??
                                  "",
                              amount: _homeController
                                      .getPromoCodeModelList.data?[i].amount ??
                                  0,
                              code: _homeController
                                      .getPromoCodeModelList.data?[i].code ??
                                  "",
                              endsAt: _homeController
                                      .getPromoCodeModelList.data?[i].endsAt ??
                                  "",
                              maxDiscount: _homeController.getPromoCodeModelList
                                      .data?[i].maxDiscount ??
                                  "",
                              minOrder: _homeController.getPromoCodeModelList
                                      .data?[i].minOrder ??
                                  "",
                              startsAt: _homeController.getPromoCodeModelList
                                      .data?[i].startsAt ??
                                  "",
                              onTapApplyBtn: () {
                                Get.back(
                                    result: _homeController
                                            .getPromoCodeModelList
                                            .data?[i]
                                            .id ??
                                        "");
                              },
                            );
                          }),
            ),
          ),
        ],
      ),
    );
  }
}
