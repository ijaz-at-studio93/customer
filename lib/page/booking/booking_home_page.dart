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
import '../../util/call_wrapper.dart';
import '../../util/snackbar_util.dart';
import '../appointment/widget/pending_payment_bar.dart';

class BookingHomePage extends StatefulWidget {
  const BookingHomePage({super.key});

  @override
  State<BookingHomePage> createState() => _BookingHomePageState();
}

class _BookingHomePageState extends State<BookingHomePage>
    with AutomaticKeepAliveClientMixin<BookingHomePage> {

  final _homeController = Get.find<HomeController>();

  static const pendingListKey =
  PageStorageKey<String>('booking_pending_list');

  static const completedListKey =
  PageStorageKey<String>('booking_completed_list');

  @override
  bool get wantKeepAlive => true;

  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeController.doGetCurrentBookingListData();
    });
  }

  String? bookingOverView = "0";

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CallWrapper(
      child: Scaffold(
        backgroundColor: ColorConstant.whiteColor,

        appBar: AppBar(
          elevation: 0,
          backgroundColor: ColorConstant.whiteColor,
          centerTitle: true,
          title: Text(
            "Bookings",
            style: AppTextTheme.bold.copyWith(
              color: ColorConstant.blackColor,
              fontSize: 19,
            ),
          ),
        ),

        body: Stack(
          children: [

            /// MAIN PAGE CONTENT
            Column(
              children: [

                _bookingOverView(),

                /// BOOKING LIST
                Obx(() => Expanded(
                  child: _homeController.showProgress
                      ? const ProgressBarView()

                  /// UPCOMING BOOKINGS
                      : bookingOverView == "0"
                      ? _homeController
                      .getCurrentBookingListModel.data?.isEmpty ?? false
                      ? const NoItemsWidget(
                    text: "There are no current bookings on record",
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 150),
                    key: pendingListKey,
                    itemCount: _homeController
                        .getCurrentBookingListModel.data?.length ?? 0,

                    itemBuilder: (context, index) {

                      final booking = _homeController
                          .getCurrentBookingListModel.data![index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5
                        ),
                        child: PendingCardWidget(

                          bookingData: booking,

                          onPress: () async {

                            await Get.to(() => QRCodePage(
                              isBooking: false,
                              appointmentId: booking.appointmentId ?? "",
                            ));

                            _homeController.doGetCurrentBookingListData();
                          },

                          onReSchedule: () async {

                            final result = await _showRescheduleDialog(
                              context,
                              booking.appointmentId ?? "",
                            );

                            if (result == true) {
                              _homeController
                                  .doGetCurrentBookingListData();
                            }
                          },
                        ),
                      );
                    },
                  )

                  /// COMPLETED BOOKINGS
                      : _homeController
                      .getBookingHistoryListModel.data?.isEmpty ?? false
                      ? const NoItemsWidget(
                    text:
                    "There are no completed bookings available.",
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 150),
                    key: completedListKey,

                    itemCount: _homeController
                        .getBookingHistoryListModel.data?.length ?? 0,

                    itemBuilder: (context, index) {

                      final history = _homeController
                          .getBookingHistoryListModel.data![index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5
                        ),
                        child: CompleteAndRejectWidget(
                          historyList: history,
                          onPress: () {
                            Get.to(() => CompleteBookingDetailsView(
                              appointmentId:
                              history.appointmentId ?? "",
                            ));
                          },
                        ),
                      );
                    },
                  ),
                ))
              ],
            ),

            /// FLOATING PAY BAR ABOVE CALL BUTTON
            // Obx(() {
            //
            //   if (bookingOverView != "0") {
            //     return const SizedBox();
            //   }
            //
            //   final bookings =
            //       _homeController.getCurrentBookingListModel.data ?? [];
            //
            //   final pending = bookings.firstWhereOrNull(
            //         (b) =>
            //     b.paymentStatus == "pending" &&
            //         b.orderStatus == "pending",
            //   );
            //
            //   if (pending == null) {
            //     return const SizedBox();
            //   }
            //
            //   return Positioned(
            //     bottom: 70,
            //     left: 20,
            //     right: 20,
            //     child: PendingPaymentBar(
            //       bookingId: pending.appointmentId ?? "",
            //       salonName: pending.salon?.displayName ?? "",
            //       startsAt: pending.startsAt ?? "",
            //     ),
            //   );
            // }),

          ],
        ),
      ),
    );
  }

  /// TAB SWITCH
  _bookingOverView() {
    return Container(
      height: 81,
      color: ColorConstant.whiteColor,
      width: Get.width,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CupertinoSlidingSegmentedControl(
        backgroundColor:
        changeTheme(SharedPrefs.readStringValue(PrefConstants.gender))
            ?? Colors.transparent,
        padding: const EdgeInsets.all(6),
        groupValue: bookingOverView,
        thumbColor: ColorConstant.whiteColor,

        children: {

          "0": SizedBox(
            width: Get.width,
            height: Get.height * 0.05,
            child: Center(
              child: Text(
                "Upcoming",
                style: bookingOverView == "0"
                    ? AppTextTheme.bold.copyWith(
                  fontSize: 14,
                  color: ColorConstant.blackColor,
                )
                    : AppTextTheme.medium.copyWith(
                  fontSize: 13,
                  color: ColorConstant.whiteColor,
                ),
              ),
            ),
          ),

          "1": Text(
            "Completed",
            style: bookingOverView == "1"
                ? AppTextTheme.bold.copyWith(
              fontSize: 14,
              color: ColorConstant.blackColor,
            )
                : AppTextTheme.medium.copyWith(
              fontSize: 13,
              color: ColorConstant.whiteColor,
            ),
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
        },
      ),
    );
  }

  /// RESCHEDULE
  Future<bool?> _showRescheduleDialog(
      BuildContext context,
      String appointmentId,
      ) async {

    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (newDate != null) {

      TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (newTime != null) {

        DateTime finalDateTime = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
          newTime.hour,
          newTime.minute,
        );

        await _homeController.reScheduledBooking(
          appointmentId: appointmentId,
          newTime: finalDateTime.toIso8601String(),

          callback: () {

            Get.back(result: true);

            SnackbarUtil.show(
              "Re scheduled",
              "Your booking was re scheduled successfully.",
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );
      }
    }
  }
}