import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/appointment/qr_page.dart';
import 'package:salon_customer/page/booking/complate_booking_details_view.dart';
import 'package:salon_customer/page/booking/widget/complete_reject_widget.dart';
import 'package:salon_customer/page/booking/widget/pending_card_widget.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import '../../constant/variable_constant.dart';
import '../../util/NoItemsWidget.dart';
import '../../util/SharedPrefs.dart';

class BookingHomePage extends StatefulWidget {
  const BookingHomePage({super.key});

  @override
  State<BookingHomePage> createState() => _BookingHomePageState();
}

class _BookingHomePageState extends State<BookingHomePage> {
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetCurrentBookingListData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: const SizedBox(),
        centerTitle: true,
        title: Text(
          "Bookings",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: Column(
        children: [
          _bookingOverView(),
          Obx(
            () => Expanded(
                child: _homeController.showProgress
                    ? const ProgressBarView()
                    : bookingOverView == "0"
                        ? _homeController
                                    .getCurrentBookingListModel.data?.isEmpty ??
                                false
                            ? const NoItemsWidget(
                                text: "There are no current bookings on record",
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _homeController
                                        .getCurrentBookingListModel
                                        .data
                                        ?.length ??
                                    0,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    child: PendingCardWidget(
                                      onPress: () {
                                        Get.to(() => QRCodePage(
                                            appointmentId: _homeController
                                                    .getCurrentBookingListModel
                                                    .data?[index]
                                                    .appointmentId ??
                                                ""));
                                      },
                                      bookingData: _homeController
                                          .getCurrentBookingListModel
                                          .data![index],
                                    ),
                                  );
                                })
                        : _homeController
                                    .getBookingHistoryListModel.data?.isEmpty ??
                                false
                            ? const NoItemsWidget(
                                text: "There are no completed bookings available.",
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _homeController
                                        .getBookingHistoryListModel
                                        .data
                                        ?.length ??
                                    0,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    child: CompleteAndRejectWidget(
                                      historyList: _homeController
                                          .getBookingHistoryListModel
                                          .data![index],
                                      onPress: () {
                                        Get.to(() => CompleteBookingDetailsView(
                                              appointmentId: _homeController
                                                      .getBookingHistoryListModel
                                                      .data?[index]
                                                      .appointmentId ??
                                                  "",
                                            ));
                                      },
                                    ),
                                  );
                                })),
          )
        ],
      ),
    );
  }

  /*----------- Tab Bar variable  ----------- */
  String? bookingOverView = "0";

  /*------------------- Switch Tab Stylist & Salon -------------------*/
  _bookingOverView() {
    return Container(
      height: 81,
      color: ColorConstant.whiteColor,
      width: Get.width,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CupertinoSlidingSegmentedControl(
          backgroundColor: changeTheme(
              SharedPrefs.readStringValue(PrefConstants.gender)) ?? Colors.transparent,
          padding: const EdgeInsets.all(6),
          groupValue: bookingOverView,
          thumbColor: ColorConstant.whiteColor,
          children: {
            "0": SizedBox(
              width: Get.width,
              height: Get.height * 0.05,
              child: Center(
                child: Text(
                  "Pending",
                  style: bookingOverView == "0"
                      ? AppTextTheme.bold.copyWith(
                          fontSize: 14, color: ColorConstant.blackColor)
                      : AppTextTheme.medium.copyWith(
                          fontSize: 13, color: ColorConstant.whiteColor),
                ),
              ),
            ),
            "1": Text(
              "Completed",
              style: bookingOverView == "1"
                  ? AppTextTheme.bold
                      .copyWith(fontSize: 14, color: ColorConstant.blackColor)
                  : AppTextTheme.medium
                      .copyWith(fontSize: 13, color: ColorConstant.whiteColor),
            ),
          },
          onValueChanged: (dynamic value) {
            bookingOverView = value;
            if (bookingOverView == "0") {
              setState(() {
                _homeController.doGetCurrentBookingListData();
              });
            } else {
              setState(() {
                _homeController.doGetBookingHistory();
              });
            }
          }),
    );
  }
}
