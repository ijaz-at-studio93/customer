import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/model/current_booking_list_model.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constant/color_constant.dart';

class PendingCardWidget extends StatefulWidget {
  final BookingData bookingData;
  final VoidCallback onPress;
  final VoidCallback onReSchedule;

  const PendingCardWidget(
      {super.key, required this.onPress, required this.onReSchedule, required this.bookingData});

  @override
  State<PendingCardWidget> createState() => _PendingCardWidgetState();
}

class _PendingCardWidgetState extends State<PendingCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, top: 20, left: 13, right: 13),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: const Color(0xffF7F7F7)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "ID : ",
                    style: AppTextTheme.regular
                        .copyWith(color: ColorConstant.idColor, fontSize: 16),
                  ),
                  Text(
                    widget.bookingData.idx ?? "",
                    textScaler: const TextScaler.linear(0.85),
                    style: AppTextTheme.bold.copyWith(
                        color: ColorConstant.blackColor, fontSize: 16),
                  ),
                ],
              ),
              Text(
                "${convertDate(date: widget.bookingData.startsAt ?? "")} - ${convertDate(date: widget.bookingData.endsAt ?? "")}",
                style: AppTextTheme.regular
                    .copyWith(fontSize: 13, color: ColorConstant.grayTextColor),
              )
            ],
          ),
          const SizedBox(height: 15),
          Dash(
            direction: Axis.horizontal,
            length: Get.width * 0.8,
            dashLength: 2,
            dashColor: const Color(0xffCFCFCF),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(
                "Booking Date : ",
                style: AppTextTheme.medium
                    .copyWith(fontSize: 14, color: ColorConstant.grayTextColor),
              ),
              const SizedBox(height: 5),
              Text(
                convertFinalDate(date: widget.bookingData.finalizedAt ?? ""),
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.bold
                    .copyWith(fontSize: 16, color: ColorConstant.blackColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Total : ",
                style: AppTextTheme.medium
                    .copyWith(fontSize: 14, color: ColorConstant.grayTextColor),
              ),
              const SizedBox(height: 5),
              Text(
                "₹${widget.bookingData.orderAmount}/-",
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.bold
                    .copyWith(fontSize: 16, color: ColorConstant.blackColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Salon Name : ",
                style: AppTextTheme.medium
                    .copyWith(fontSize: 14, color: ColorConstant.grayTextColor),
              ),
              const SizedBox(height: 5),
              Text(
                widget.bookingData.salon?.name ?? "",
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.bold
                    .copyWith(fontSize: 16, color: ColorConstant.blackColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Stylist Name : ",
                style: AppTextTheme.medium
                    .copyWith(fontSize: 14, color: ColorConstant.grayTextColor),
              ),
              const SizedBox(height: 5),
              Text(
                widget.bookingData.appointment?.artist?.name ?? "",
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.bold
                    .copyWith(fontSize: 16, color: ColorConstant.blackColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Order Status : ",
                style: AppTextTheme.medium
                    .copyWith(fontSize: 14, color: ColorConstant.grayTextColor),
              ),
              const SizedBox(height: 5),
              Text(
                widget.bookingData.orderStatus == "salon_artist_rejected" || widget.bookingData.orderStatus == "salon_rejected"
                    ? "Rejected"
                    : widget.bookingData.orderStatus == "user_cancelled"
                    ? "Cancelled"
                    : widget.bookingData.orderStatus ?? "",
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.bold.copyWith(
                    fontSize: 16,
                    color: widget.bookingData.orderStatus == "salon_artist_rejected" ||
                        widget.bookingData.orderStatus == "salon_rejected" ||
                        widget.bookingData.orderStatus == "user_cancelled"
                        ? ColorConstant.redBgColor
                        : changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Service",
            style: AppTextTheme.medium
                .copyWith(fontSize: 14, color: ColorConstant.grayTextColor),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: List.generate(
              widget.bookingData.items?.length ?? 0,
              (index) => widget.bookingData.items?[index].isService ?? false
                  ? Text(
                      index == 0
                          ? "${widget.bookingData.items?[index].service?.name ?? ""}"
                          : " •  ${widget.bookingData.items?[index].service?.name ?? ""}",
                      style: AppTextTheme.medium.copyWith(
                          color: ColorConstant.grayTextColor, fontSize: 13),
                    )
                  : const SizedBox(),
            ),
          ),
          const SizedBox(height: 10),
          widget.bookingData.orderStatus != "completed"
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bookingData.orderStatus == "pending"
                          ? "Your anticipation matters. Awaiting salon's happy news."
                          : widget.bookingData.orderStatus == "confirmed"
                          ? "So thrilled! Your appointment is now a reality."
                          : widget.bookingData.orderStatus == "salon_rejected" ||
                          widget.bookingData.orderStatus == "salon_artist_rejected"
                          ? "Heartfelt apologies. Salon couldn't confirm this time."
                          : widget.bookingData.orderStatus == "user_cancelled"
                          ? "We understand. You've successfully changed your plans."
                          : "Awaiting acceptance from stylist", // Default if status is unknown or needs a generic phrase
                      style: AppTextTheme.bold.copyWith(
                          fontSize: 18,
                          color: widget.bookingData.orderStatus == "salon_rejected" ||
                              widget.bookingData.orderStatus == "salon_artist_rejected" ||
                              widget.bookingData.orderStatus == "user_cancelled"
                              ? ColorConstant.redBgColor // Apply red for rejected/cancelled
                              : changeTheme(
                              SharedPrefs.readStringValue(PrefConstants.gender))),
                    ),
                    // SizedBox(height: 10),
                    // Column(
                    //   children: [
                    //     Text(
                    //       "To cancel appointment, please drop whatsapp message on ",
                    //       style: AppTextTheme.regular.copyWith(
                    //           fontSize: 14,
                    //           height: 1.2,
                    //           color: changeTheme(SharedPrefs.readStringValue(
                    //               PrefConstants.gender))),
                    //     ),
                    //     const SizedBox(height: 2),
                    //     Row(
                    //       children: [
                    //         GestureDetector(
                    //           onTap: () {
                    //             launchWhatsApp("9347882037");
                    //           },
                    //           child: Text(
                    //             "+91 9347882037 / ",
                    //             style: AppTextTheme.bold.copyWith(
                    //                 fontSize: 14,
                    //                 height: 1.2,
                    //                 color: changeTheme(
                    //                     SharedPrefs.readStringValue(
                    //                         PrefConstants.gender))),
                    //           ),
                    //         ),
                    //         GestureDetector(
                    //           onTap: () {
                    //             launchWhatsApp("8897090838");
                    //           },
                    //           child: Text(
                    //             "+91 8897090838",
                    //             style: AppTextTheme.bold.copyWith(
                    //                 fontSize: 14,
                    //                 height: 1.2,
                    //                 color: changeTheme(
                    //                     SharedPrefs.readStringValue(
                    //                         PrefConstants.gender))),
                    //           ),
                    //         ),
                    //       ],
                    //     )
                    //   ],
                    // ),
                  ],
                )
              : const SizedBox(),

          // old flow of showing view on confirmed only.
          // widget.bookingData.orderStatus == "confirmed"
          //     ? GestureDetector(
          //         onTap: widget.
          //         ,
          //         child: Container(
          //           height: 50,
          //           width: Get.width,
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(8),
          //             color: const Color(0xffEAEAEA),
          //           ),
          //           child: Center(
          //             child: Text(
          //               "VIEW",
          //               style: AppTextTheme.bold.copyWith(
          //                   color: ColorConstant.blackColor, fontSize: 16),
          //             ),
          //           ),
          //         ),
          //       )
          //     : const SizedBox()

          const SizedBox(height: 15),
          if (!(widget.bookingData.orderStatus == "user_cancelled" ||
              widget.bookingData.orderStatus == "salon_rejected" ||
              widget.bookingData.orderStatus == "salon_artist_rejected")) ...[
            GestureDetector(
              onTap: widget.onPress,
              child: Container(
                height: 40,
                width: Get.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xffEAEAEA),
                ),
                child: Center(
                  child: Text(
                    "VIEW",
                    style: AppTextTheme.bold.copyWith(
                        color: ColorConstant.blackColor, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: widget.onReSchedule,
              child: Container(
                height: 40,
                width: Get.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xffEAEAEA),
                ),
                child: Center(
                  child: Text(
                    "Re Schedule",
                    style: AppTextTheme.bold.copyWith(
                        color: ColorConstant.blackColor, fontSize: 16),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
  Future<void> launchWhatsApp(String phone) async {
    final whatsappUrl = Uri.parse("https://wa.me/$phone");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch WhatsApp";
    }
  }
  /*---------------- convertTime ------------*/
  String convertDate({required String date}) {
    String dateTimeString = date;
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return formattedTime;
  }

  /*---------------- Date Convert Fun  -------------*/
  String convertFinalDate({required String date}) {
    if (date.isEmpty) {
      return "";
    } else {
      String dateTimeString = date;
      DateTime dateTime = DateTime.parse(dateTimeString);
      String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);

      return formattedDate;
    }
  }
}
