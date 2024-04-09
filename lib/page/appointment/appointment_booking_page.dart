import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/page/appointment/qr_page.dart';
import 'package:sallon_customer/page/appointment/widget/know_what_you_widget.dart';
import 'package:sallon_customer/page/appointment/widget/popular_service_widget.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

class AppointmentBookingPage extends StatefulWidget {
  const AppointmentBookingPage({super.key});

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: ColorConstant.blackColor,
            )),
        centerTitle: true,
        title: Text(
          "Booking Appointment",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
                height: 200,
                width: Get.width,
                child: _customBackgroundExample()),
            /*----------- Popular Service By Your Artist ---------------*/
            Container(
              width: Get.width,
              color: ColorConstant.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Popular Service By Your Artist",
                    style: AppTextTheme.bold.copyWith(
                        fontSize: 16, color: ColorConstant.blackColor),
                  ),
                  const SizedBox(height: 15),
                  Dash(
                    direction: Axis.horizontal,
                    length: Get.width * 0.88,
                    dashLength: 2,
                    dashColor: const Color(0xffCFCFCF),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return const PopularServiceWidget();
                        }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            /*-------------- Select Time Slot  ---------------*/
            Container(
              color: ColorConstant.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Time Slot",
                    style: AppTextTheme.bold.copyWith(
                        fontSize: 16, color: ColorConstant.blackColor),
                  ),
                  const SizedBox(height: 15),
                  Dash(
                    direction: Axis.horizontal,
                    length: Get.width * 0.88,
                    dashLength: 2,
                    dashColor: const Color(0xffCFCFCF),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Image.asset(
                        AssetsConstant.daySlot,
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Day Slot",
                        style: AppTextTheme.medium
                            .copyWith(color: ColorConstant.grayTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    width: Get.width,
                    child: ListView.builder(
                        itemCount: 5,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          return _timeSlotContainerWidget(
                              timeSlot: "10:00 - 10:00 AM");
                        }),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Image.asset(
                        AssetsConstant.eveningSLot,
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Evening SLot",
                        style: AppTextTheme.medium
                            .copyWith(color: ColorConstant.grayTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    width: Get.width,
                    child: ListView.builder(
                        itemCount: 5,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          return _timeSlotContainerWidget(
                              timeSlot: "10:00 - 10:00 AM");
                        }),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            const SizedBox(height: 2),
            /*------------ Know What You are paying For ------------*/
            Container(
              width: Get.width,
              color: ColorConstant.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Know What You are paying For",
                    style: AppTextTheme.bold.copyWith(
                        fontSize: 16, color: ColorConstant.blackColor),
                  ),
                  const SizedBox(height: 15),
                  Dash(
                    direction: Axis.horizontal,
                    length: Get.width * 0.88,
                    dashLength: 2,
                    dashColor: const Color(0xffCFCFCF),
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                      separatorBuilder: (context, index) {
                        return const Divider(
                          height: 24,
                          color: Color(0xffE0E0E0),
                          thickness: 1.5,
                        );
                      },
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return const KnowWhatYouWidget();
                      }),
                  const SizedBox(height: 100),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: Get.width,
        color: ColorConstant.whiteColor,
        height: 100,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "1 Add On",
                  style: AppTextTheme.bold.copyWith(
                      fontSize: 13, color: ColorConstant.grayTextColor),
                ),
                Text(
                  "₹4,000",
                  style: AppTextTheme.bold
                      .copyWith(fontSize: 19, color: ColorConstant.blackColor),
                )
              ],
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => const QRCodePage());
              },
              child: Container(
                height: 45,
                width: Get.width * 0.4,
                decoration: BoxDecoration(
                  color: ColorConstant.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Pay & Book",
                      textScaler: const TextScaler.linear(0.85),
                      style: AppTextTheme.medium.copyWith(
                          fontSize: 16, color: ColorConstant.whiteColor),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.arrow_forward,
                      color: ColorConstant.whiteColor,
                      size: 20,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /*------------  Time Slot ------*/
  _timeSlotContainerWidget({required String timeSlot}) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ColorConstant.grayBorderColor, width: 1),
      ),
      child: Center(
        child: Text(
          timeSlot,
          style: AppTextTheme.medium
              .copyWith(color: ColorConstant.blackColor, fontSize: 12),
        ),
      ),
    );
  }

  /*---------------  Date Calender Time ------------*/
  EasyDateTimeLine _customBackgroundExample() {
    return EasyDateTimeLine(
      initialDate: DateTime.now(),
      onDateChange: (selectedDate) {
        //`selectedDate` the new date selected.
        print(selectedDate);
      },
      headerProps: const EasyHeaderProps(
          monthPickerType: MonthPickerType.switcher,
          dateFormatter: DateFormatter.dayOnly()
          // fullDateDMY(),
          ),
      dayProps: const EasyDayProps(
        dayStructure: DayStructure.dayStrDayNum,
        activeDayStyle: DayStyle(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Color(0xff8466CF),
          ),
        ),
      ),
    );
  }
}
