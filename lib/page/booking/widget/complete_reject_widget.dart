import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

import '../../../model/booking_history_list_model.dart';

class CompleteAndRejectWidget extends StatefulWidget {
  final HistoryList historyList;
  final VoidCallback onPress;
  const CompleteAndRejectWidget(
      {super.key, required this.historyList, required this.onPress});

  @override
  State<CompleteAndRejectWidget> createState() =>
      _CompleteAndRejectWidgetState();
}

class _CompleteAndRejectWidgetState extends State<CompleteAndRejectWidget> {
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
                  SizedBox(
                    width: Get.width * 0.4,
                    child: Text(
                      widget.historyList.idx ?? "",
                      maxLines: 1,
                      style: AppTextTheme.bold.copyWith(
                          color: ColorConstant.blackColor, fontSize: 16),
                    ),
                  ),
                ],
              ),
              Text(
                "${convertDate(date: widget.historyList.startsAt ?? "")}- ${convertDate(date: widget.historyList.endsAt ?? "")}",
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
                convertFinalDate(date: widget.historyList.finalizedAt ?? ""),
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
                "₹${widget.historyList.orderAmount}/-",
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
                widget.historyList.orderStatus == "salon_artist_rejected"
                    ? "Rejected"
                    : widget.historyList.orderStatus ?? "",
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.bold.copyWith(
                    fontSize: 16,
                    color: widget.historyList.orderStatus ==
                            "salon_artist_rejected"
                        ? ColorConstant.redBgColor
                        : ColorConstant.primaryColor),
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
                widget.historyList.salon?.name ?? "",
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
                widget.historyList.appointment?.artist?.name ?? "",
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.bold
                    .copyWith(fontSize: 16, color: ColorConstant.blackColor),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Service",
            style: AppTextTheme.medium
                .copyWith(fontSize: 14, color: ColorConstant.grayTextColor),
          ),
          Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: List.generate(
              widget.historyList.items?.length ?? 0,
              (index) => widget.historyList.items?[index].isService ?? false
                  ? FilterChip(
                      labelStyle: AppTextTheme.medium.copyWith(
                          color: ColorConstant.whiteColor, fontSize: 13),
                      label: Text(
                          widget.historyList.items?[index].service?.name ?? ""),
                      backgroundColor: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)),
                      onSelected: (bool value) {},
                    )
                  : const SizedBox(),
            ),
          ),
          const SizedBox(height: 10),
          widget.historyList.orderStatus == "salon_artist_rejected"
              ? const SizedBox()
              : GestureDetector(
                  onTap: widget.onPress,
                  child: Container(
                    height: 50,
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
                )
        ],
      ),
    );
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
