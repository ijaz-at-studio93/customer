import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sallon_customer/api/dio_client.dart';
import 'package:sallon_customer/constant/api_constant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/controller/home_controller.dart';
import 'package:sallon_customer/page/appointment/widget/know_what_you_widget.dart';
import 'package:sallon_customer/page/appointment/widget/popular_service_widget.dart';
import 'package:sallon_customer/page/appointment/your_approval_bottom_sheet.dart';
import 'package:sallon_customer/project_specific/ProgressContainerView.dart';
import 'package:sallon_customer/project_specific/progressbar_view.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';
import '../../constant/assetsconstant.dart';
import '../profile/add_address_page.dart';

class AppointmentBookingPage extends StatefulWidget {
  final String artiestId;
  const AppointmentBookingPage({super.key, required this.artiestId});

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      userServiceAddressIdSelect = "";
      DateTime date = DateTime.now();
      String formatDate = DateFormat("yyyy-MM-dd").format(date);
      selectDate = formatDate;
      _homeController.doGetUnAvailableDatesListData(
          artiestId: widget.artiestId,
          date: formatDate,
          callback: () {
            _homeController.doGetCart();
            _homeController.doGetAvailabilitiesTimeSlot(
              artiestId: widget.artiestId,
              date: formatDate,
            );
          });
    });
  }

  int selectedIndex = 0;
  String selectTime = '';

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
      body: Obx(
        () => ProgressContainerView(
          isProgressRunning: _homeController.showBookingProgress,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                    height: 200,
                    width: Get.width,
                    child: _customBackgroundExample()),
                /*----------- Popular Service By Your Artist ---------------*/
                _homeController.showProgress
                    ? Column(
                        children: [
                          SizedBox(height: Get.height * 0.23),
                          const ProgressBarView(),
                        ],
                      )
                    : Column(
                        children: [
                          Container(
                            width: Get.width,
                            color: ColorConstant.whiteColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Popular Service By Your Artist",
                                  style: AppTextTheme.bold.copyWith(
                                      fontSize: 16,
                                      color: ColorConstant.blackColor),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Select Time Slot",
                                  style: AppTextTheme.bold.copyWith(
                                      fontSize: 16,
                                      color: ColorConstant.blackColor),
                                ),
                                const SizedBox(height: 15),
                                Dash(
                                  direction: Axis.horizontal,
                                  length: Get.width * 0.88,
                                  dashLength: 2,
                                  dashColor: const Color(0xffCFCFCF),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 50,
                                  width: Get.width,
                                  child: ListView.builder(
                                      itemCount: _homeController
                                              .getAvailabilitiesTimeSlotModelData
                                              .data
                                              ?.length ??
                                          0,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, i) {
                                        return _timeSlotContainerWidget(
                                            isSelected: selectedIndex == i,
                                            onPress: () {
                                              setState(() {
                                                selectedIndex = i;
                                                selectTime = _homeController
                                                        .getAvailabilitiesTimeSlotModelData
                                                        .data?[i]
                                                        .time ??
                                                    "";
                                              });
                                            },
                                            timeSlot: convertTimesToAmPmString(
                                                _homeController
                                                        .getAvailabilitiesTimeSlotModelData
                                                        .data?[i]
                                                        .time ??
                                                    ""));
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Know What You are paying For",
                                  style: AppTextTheme.bold.copyWith(
                                      fontSize: 16,
                                      color: ColorConstant.blackColor),
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
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _homeController
                                            .getServiceAddCartModel
                                            .data
                                            ?.items
                                            ?.length ??
                                        0,
                                    itemBuilder: (context, index) {
                                      return KnowWhatYouWidget(
                                        removeProduct: () {
                                          _homeController.doRemoveProductCart(
                                              productId: _homeController
                                                      .getServiceAddCartModel
                                                      .data
                                                      ?.items?[index]
                                                      .product
                                                      ?.id ??
                                                  "",
                                              callback: () {
                                                _homeController.doGetCart();
                                              });
                                        },
                                        removeBtn: () {
                                          _homeController.doRemoveCart(
                                              salonServiceId: _homeController
                                                      .getServiceAddCartModel
                                                      .data
                                                      ?.items?[index]
                                                      .service
                                                      ?.id ??
                                                  "",
                                              callback: () {
                                                _homeController.doGetCart();
                                              });
                                        },
                                        items: _homeController
                                            .getServiceAddCartModel
                                            .data!
                                            .items![index],
                                      );
                                    }),
                                const SizedBox(height: 100),
                              ],
                            ),
                          )
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _homeController.showProgress
          ? const SizedBox()
          : _homeController.getServiceAddCartModel.data?.items?.isEmpty ?? false
              ? const SizedBox()
              : Container(
                  width: Get.width,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: ColorConstant.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1E000000),
                        blurRadius: 8,
                        offset: Offset(-2, -2),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _homeController.getServiceAddCartModel.data?.previewImages
                                  ?.isEmpty ??
                              false
                          ? const SizedBox()
                          : Row(
                              children: [
                                _homeController.getServiceAddCartModel.data
                                            ?.previewImages?.length ==
                                        1
                                    ? Row(
                                        children: [
                                          for (int i = 0; i < 1; i++)
                                            Align(
                                              widthFactor: 0.8,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  width: 30,
                                                  height: 30,
                                                  imageUrl:
                                                      "${APIConstants.image}${_homeController.getServiceAddCartModel.data?.previewImages?[i] ?? ""}",
                                                  placeholder: (context, url) =>
                                                      const Image(
                                                    image: AssetImage(
                                                        AssetsConstant
                                                            .placeHolder),
                                                    fit: BoxFit.cover,
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Image(
                                                    image: AssetImage(
                                                        AssetsConstant
                                                            .placeHolder),
                                                    fit: BoxFit.cover,
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                ),
                                              ),
                                            )
                                        ],
                                      )
                                    : _homeController.getServiceAddCartModel
                                                .data?.previewImages?.length ==
                                            2
                                        ? Row(
                                            children: [
                                              for (int i = 0; i < 2; i++)
                                                Align(
                                                  widthFactor: 0.8,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      width: 30,
                                                      height: 30,
                                                      imageUrl:
                                                          "${APIConstants.image}${_homeController.getServiceAddCartModel.data?.previewImages?[i] ?? ""}",
                                                      placeholder:
                                                          (context, url) =>
                                                              const Image(
                                                        image: AssetImage(
                                                            AssetsConstant
                                                                .placeHolder),
                                                        fit: BoxFit.cover,
                                                        width: 30,
                                                        height: 30,
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Image(
                                                        image: AssetImage(
                                                            AssetsConstant
                                                                .placeHolder),
                                                        fit: BoxFit.cover,
                                                        width: 30,
                                                        height: 30,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              for (int i = 0; i < 2; i++)
                                                Align(
                                                  widthFactor: 0.7,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: CachedNetworkImage(
                                                      fit: BoxFit.cover,
                                                      width: 35,
                                                      height: 35,
                                                      imageUrl:
                                                          "${APIConstants.image}${_homeController.getServiceAddCartModel.data?.previewImages?[i] ?? ""}",
                                                      placeholder:
                                                          (context, url) =>
                                                              const Image(
                                                        image: AssetImage(
                                                            AssetsConstant
                                                                .placeHolder),
                                                        fit: BoxFit.cover,
                                                        width: 35,
                                                        height: 35,
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Image(
                                                        image: AssetImage(
                                                            AssetsConstant
                                                                .placeHolder),
                                                        fit: BoxFit.cover,
                                                        width: 35,
                                                        height: 35,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(width: 10),
                                              Container(
                                                width: 33,
                                                height: 33,
                                                decoration: const BoxDecoration(
                                                    color: ColorConstant
                                                        .primaryColor,
                                                    shape: BoxShape.circle),
                                                child: Center(
                                                  child: Text(
                                                    _homeController
                                                            .getServiceAddCartModel
                                                            .data
                                                            ?.previewImages
                                                            ?.length
                                                            .toString() ??
                                                        "",
                                                    style: AppTextTheme.medium
                                                        .copyWith(
                                                      color: ColorConstant
                                                          .whiteColor,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                              ],
                            ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_homeController.getServiceAddCartModel.data?.items?.length} Add On",
                            style: AppTextTheme.bold.copyWith(
                                fontSize: 13,
                                color: ColorConstant.grayTextColor),
                          ),
                          Text(
                            "₹${_homeController.getServiceAddCartModel.data?.price ?? ""}",
                            style: AppTextTheme.bold.copyWith(
                                fontSize: 19, color: ColorConstant.blackColor),
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_homeController.getServiceAddCartModel.data?.items
                                  ?.isEmpty ??
                              false) {
                            showMessage("Cart Service Not Found");
                          } else {
                            if (_homeController
                                    .getAvailabilitiesTimeSlotModelData
                                    .data
                                    ?.isEmpty ??
                                false) {
                              showMessage(
                                  "This Date No Available Any Slot Please Select Next Date");
                            } else {
                              if (selectTime == "") {
                                selectTime = _homeController
                                        .getAvailabilitiesTimeSlotModelData
                                        .data?[0]
                                        .time ??
                                    "";
                                String inputDateTime = "$selectDate$selectTime";
                                String correctedDateTime =
                                    '${inputDateTime.substring(0, 10)}T${inputDateTime.substring(10)}';
                                DateTime dateTime =
                                    DateTime.parse(correctedDateTime);
                                String isoDateTime = dateTime.toIso8601String();

                                if (_homeController.getServiceAddCartModel.data
                                        ?.isHomeService ??
                                    false) {
                                  if (userServiceAddressIdSelect == "") {
                                    Get.to(() => const AddAddressPage(
                                          isSelect: true,
                                        ));
                                  } else {
                                    _homeController.doCreateBooking(
                                        userAddressId:
                                            userServiceAddressIdSelect,
                                        isHomeService: _homeController
                                                .getServiceAddCartModel
                                                .data
                                                ?.isHomeService ??
                                            false,
                                        salonArtistId: widget.artiestId,
                                        startAt: isoDateTime,
                                        callback: () {
                                          showModalBottomSheet(
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                topLeft: Radius.circular(32),
                                                topRight: Radius.circular(32),
                                              )),
                                              context: context,
                                              builder: (context) {
                                                return YourApprovalBottomSheet(
                                                  salonAppointmentId: _homeController
                                                          .getCreateBookingAppointmentModel
                                                          .data
                                                          ?.salonAppointmentId ??
                                                      "",
                                                );
                                              });
                                        });
                                  }
                                } else {
                                  _homeController.doCreateBooking(
                                      userAddressId: "",
                                      isHomeService: _homeController
                                              .getServiceAddCartModel
                                              .data
                                              ?.isHomeService ??
                                          false,
                                      salonArtistId: widget.artiestId,
                                      startAt: isoDateTime,
                                      callback: () {
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(32),
                                              topRight: Radius.circular(32),
                                            )),
                                            context: context,
                                            builder: (context) {
                                              return YourApprovalBottomSheet(
                                                salonAppointmentId: _homeController
                                                        .getCreateBookingAppointmentModel
                                                        .data
                                                        ?.salonAppointmentId ??
                                                    "",
                                              );
                                            });
                                      });
                                }
                              } else {
                                String inputDateTime = "$selectDate$selectTime";
                                String correctedDateTime =
                                    '${inputDateTime.substring(0, 10)}T${inputDateTime.substring(10)}';
                                DateTime dateTime =
                                    DateTime.parse(correctedDateTime);
                                String isoDateTime = dateTime.toIso8601String();

                                if (_homeController.getServiceAddCartModel.data
                                        ?.isHomeService ??
                                    false) {
                                  if (userServiceAddressIdSelect == "") {
                                    Get.to(() => const AddAddressPage(
                                          isSelect: true,
                                        ));
                                  } else {
                                    _homeController.doCreateBooking(
                                        userAddressId:
                                            userServiceAddressIdSelect,
                                        isHomeService: _homeController
                                                .getServiceAddCartModel
                                                .data
                                                ?.isHomeService ??
                                            false,
                                        salonArtistId: widget.artiestId,
                                        startAt: isoDateTime,
                                        callback: () {
                                          showModalBottomSheet(
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                topLeft: Radius.circular(32),
                                                topRight: Radius.circular(32),
                                              )),
                                              context: context,
                                              builder: (context) {
                                                return YourApprovalBottomSheet(
                                                  salonAppointmentId: _homeController
                                                          .getCreateBookingAppointmentModel
                                                          .data
                                                          ?.salonAppointmentId ??
                                                      "",
                                                );
                                              });
                                        });
                                  }
                                } else {
                                  _homeController.doCreateBooking(
                                      userAddressId: "",
                                      isHomeService: _homeController
                                              .getServiceAddCartModel
                                              .data
                                              ?.isHomeService ??
                                          false,
                                      salonArtistId: widget.artiestId,
                                      startAt: isoDateTime,
                                      callback: () {
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(32),
                                              topRight: Radius.circular(32),
                                            )),
                                            context: context,
                                            builder: (context) {
                                              return YourApprovalBottomSheet(
                                                salonAppointmentId: _homeController
                                                        .getCreateBookingAppointmentModel
                                                        .data
                                                        ?.salonAppointmentId ??
                                                    "",
                                              );
                                            });
                                      });
                                }
                              }
                            }
                          }
                        },
                        child: Container(
                          height: 45,
                          width: Get.width * 0.35,
                          decoration: BoxDecoration(
                            color: changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender)) ??
                                ColorConstant.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Pay & Book",
                                textScaler: const TextScaler.linear(0.85),
                                style: AppTextTheme.medium.copyWith(
                                    fontSize: 16,
                                    color: ColorConstant.whiteColor),
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

  String selectDate = "";

  /*------------  Time Slot ------*/
  _timeSlotContainerWidget(
      {required String timeSlot,
      required bool isSelected,
      required VoidCallback onPress}) {
    return InkWell(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstant.primaryColor
              : ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ColorConstant.grayBorderColor, width: 1),
        ),
        child: Center(
          child: Text(
            timeSlot,
            style: AppTextTheme.bold.copyWith(
                color: isSelected
                    ? ColorConstant.whiteColor
                    : ColorConstant.blackColor,
                fontSize: 13),
          ),
        ),
      ),
    );
  }

  /*---------------  Date Calender Time ------------*/
  EasyDateTimeLine _customBackgroundExample() {
    final List<Map<String, String>> unavailableDates = [];

    for (int i = 0;
        i <
            (_homeController.getUnAvailableDatesListData.data?.unavailableDates
                    ?.length ??
                0);
        i++) {
      unavailableDates.add({
        "date": _homeController
                .getUnAvailableDatesListData.data?.unavailableDates?[i].date ??
            ""
      });
    }

    List<DateTime> dateTimeList = unavailableDates.map((dateMap) {
      return DateTime.parse(dateMap["date"]!);
    }).toList();

    return EasyDateTimeLine(
      onMonthChange: (val) {
        String inputString = val.toString();
        RegExp regExp = RegExp(r'\d+');
        Iterable<RegExpMatch> matches = regExp.allMatches(inputString);
        String result = matches.map((match) => match.group(0)).join('');
        String year = DateFormat("yyyy").format(DateTime.now());
        String finalDate =
            "$year-${result.length == 1 ? '0$result' : result}-01";

        selectDate = finalDate;
        _homeController.doGetUnAvailableDatesListData(
            artiestId: widget.artiestId,
            date: finalDate,
            callback: () {
              _homeController.doGetAvailabilitiesTimeSlot(
                artiestId: widget.artiestId,
                date: finalDate,
              );
            });
      },
      initialDate:
          selectDate == "" ? DateTime.now() : DateTime.parse(selectDate),
      onDateChange: (selectedDate) {
        //`selectedDate` the new date selected.
        String formatDate = DateFormat("yyyy-MM-dd").format(selectedDate);
        selectDate = formatDate;
        _homeController.doGetAvailabilitiesTimeSlot(
          artiestId: widget.artiestId,
          date: formatDate,
        );
      },
      headerProps: const EasyHeaderProps(
          showSelectedDate: true,
          monthPickerType: MonthPickerType.switcher,
          dateFormatter: DateFormatter.dayOnly()),
      disabledDates: dateTimeList,
      dayProps: EasyDayProps(
        dayStructure: DayStructure.dayStrDayNum,
        activeDayStyle: DayStyle(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender)) ??
                ColorConstant.primaryColor,
          ),
        ),
      ),
    );
  }

  /*-------------- convert AM PM Date Time --------------------*/
  String convertTimesToAmPmString(String timeSlot) {
    DateTime time = DateFormat("HH:mm").parse(timeSlot);
    String convertTimeSlot = DateFormat("hh:mm a").format(time);
    return convertTimeSlot;
  }
}
