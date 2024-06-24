import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/model/current_booking_list_model.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import '../../../constant/color_constant.dart';

class PendingCardWidget extends StatefulWidget {
  final BookingData bookingData;
  final VoidCallback onPress;
  const PendingCardWidget(
      {super.key, required this.onPress, required this.bookingData});

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
                    style: AppTextTheme.bold.copyWith(
                        color: ColorConstant.blackColor, fontSize: 16),
                  ),
                ],
              ),
              Text(
                "${convertDate(date: widget.bookingData.startsAt ?? "")}- ${convertDate(date: widget.bookingData.endsAt ?? "")}",
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
              widget.bookingData.items?.length ?? 0,
              (index) => widget.bookingData.items?[index].isService ?? false
                  ? FilterChip(
                      labelStyle: AppTextTheme.medium.copyWith(
                          color: ColorConstant.whiteColor, fontSize: 13),
                      label: Text(
                          widget.bookingData.items?[index].service?.name ?? ""),
                backgroundColor: changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender)),
                      onSelected: (bool value) {},
                    )
                  : const SizedBox(),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
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
                  style: AppTextTheme.bold
                      .copyWith(color: ColorConstant.blackColor, fontSize: 16),
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
}
