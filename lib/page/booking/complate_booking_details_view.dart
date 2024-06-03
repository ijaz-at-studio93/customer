import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/controller/home_controller.dart';
import 'package:sallon_customer/page/booking/widget/product_rating_list_tile.dart';
import 'package:sallon_customer/page/booking/widget/service_rating_list_tile.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/NoItemsWidget.dart';
import '../../project_specific/progressbar_view.dart';
import 'widget/artist_rating_list_tile.dart';

class CompleteBookingDetailsView extends StatefulWidget {
  final String appointmentId;
  const CompleteBookingDetailsView({
    super.key,
    required this.appointmentId,
  });

  @override
  State<CompleteBookingDetailsView> createState() =>
      _CompleteBookingDetailsViewState();
}

class _CompleteBookingDetailsViewState
    extends State<CompleteBookingDetailsView> {
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetReviewDataList(appointmentId: widget.appointmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstant.whiteColor,
        appBar: AppBar(
          backgroundColor: ColorConstant.whiteColor,
          elevation: 1.0,
          centerTitle: true,
          title: Text(
            "Rating Review",
            style: AppTextTheme.bold
                .copyWith(color: ColorConstant.blackColor, fontSize: 19),
          ),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: ColorConstant.blackColor,
              )),
        ),
        body: Column(
          children: [
            _stylistAndSalon(),
            Obx(
              () => Expanded(
                  child: _homeController.showProgress
                      ? const ProgressBarView()
                      : overall == "0"
                          ? _homeController.getReviewDataListModel.data
                                      ?.services?.isEmpty ??
                                  false
                              ? const NoItemsWidget(
                                  text: "No Any Service Data Found")
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: _homeController
                                          .getReviewDataListModel
                                          .data
                                          ?.services
                                          ?.length ??
                                      0,
                                  itemBuilder: (context, i) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: ServiceRatingListTile(
                                        appointmentId: widget.appointmentId,
                                        servicesModel: _homeController
                                            .getReviewDataListModel
                                            .data!
                                            .services![i],
                                      ),
                                    );
                                  })
                          : overall == "1"
                              ? _homeController.getReviewDataListModel.data
                                          ?.products?.isEmpty ??
                                      false
                                  ? const NoItemsWidget(
                                      text: "No Any Product Data Found")
                                  : ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: _homeController
                                              .getReviewDataListModel
                                              .data
                                              ?.products
                                              ?.length ??
                                          0,
                                      itemBuilder: (context, i) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: ProductRatingListTile(
                                            appointmentId: widget.appointmentId,
                                            products: _homeController
                                                .getReviewDataListModel
                                                .data!
                                                .products![i],
                                          ),
                                        );
                                      })
                              : _homeController.getReviewDataListModel.data
                                          ?.artists?.isEmpty ??
                                      false
                                  ? const NoItemsWidget(
                                      text: "No Any Artists Found")
                                  : ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: _homeController
                                              .getReviewDataListModel
                                              .data
                                              ?.artists
                                              ?.length ??
                                          0,
                                      itemBuilder: (context, i) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: ArtistRatingListTile(
                                            artists: _homeController
                                                .getReviewDataListModel
                                                .data!
                                                .artists![i],
                                            appointmentId: widget.appointmentId,
                                          ),
                                        );
                                      })),
            )
          ],
        ));
  }

  /*----------- Tab Bar variable  ----------- */
  String? overall = "0";

  /*------------------- Switch Tab Stylist & Salon -------------------*/
  _stylistAndSalon() {
    return Container(
      color: ColorConstant.whiteColor,
      width: Get.width,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      child: CupertinoSlidingSegmentedControl(
          backgroundColor: ColorConstant.grayBorderColor,
          padding: const EdgeInsets.all(6),
          groupValue: overall,
          thumbColor: ColorConstant.whiteColor,
          children: {
            "0": SizedBox(
              width: Get.width,
              height: Get.height * 0.06,
              child: Center(
                child: Text(
                  "Service",
                  style: AppTextTheme.medium.copyWith(
                      fontSize: 16,
                      color: overall == "0"
                          ? ColorConstant.blackColor
                          : ColorConstant.grayTextColor),
                ),
              ),
            ),
            "1": Text(
              "Product",
              style: AppTextTheme.medium.copyWith(
                  fontSize: 16,
                  color: overall == "1"
                      ? ColorConstant.blackColor
                      : ColorConstant.grayTextColor),
            ),
            "2": Text(
              "Artist",
              style: AppTextTheme.medium.copyWith(
                  fontSize: 16,
                  color: overall == "2"
                      ? ColorConstant.blackColor
                      : ColorConstant.grayTextColor),
            ),
          },
          onValueChanged: (dynamic value) {
            setState(() {
              overall = value;
            });
          }),
    );
  }
}
