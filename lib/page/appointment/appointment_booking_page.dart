import 'dart:developer';

import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/appointment/person_of_the_year_page.dart';
import 'package:salon_customer/page/appointment/secret_santa_scratch_page.dart';
import 'package:salon_customer/page/appointment/widget/know_what_you_widget.dart';
import 'package:salon_customer/page/appointment/widget/popular_service_widget.dart';
import 'package:salon_customer/page/appointment/widget/promocode_sheet_widget.dart';
import 'package:salon_customer/page/appointment/your_approval_page.dart';
import 'package:salon_customer/project_specific/ProgressContainerView.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

import '../../api/dio_client.dart';
import '../../util/call_wrapper.dart';
import '../home/widget/add_product_sheet_widget.dart';
import '../profile/add_address_page.dart';

class AppointmentBookingPage extends StatefulWidget {
  final String artiestId;

  const AppointmentBookingPage({super.key, required this.artiestId});

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final _homeController = Get.find<HomeController>();
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      userServiceAddressIdSelect = "";
      DateTime date = DateTime.now();
      String formatDate = DateFormat("yyyy-MM-dd").format(date);
      int _visibleYear = DateTime.now().year;
      selectDate = formatDate;
      _homeController.doGetPopularServiceByYourStylist(
          stylistId: widget.artiestId);
      _homeController.doGetBlogData(
        lat: double.parse(SharedPrefs.readStringValue(PrefConstants.latitude)),
        lng: double.parse(SharedPrefs.readStringValue(PrefConstants.longitude)),
      );
      _homeController.doGetUnAvailableDatesListData(
          artiestId: widget.artiestId, date: formatDate, callback: () {});

      _homeController.doGetCart().whenComplete(() {
        _homeController.doGetOrderId();
      });
      _homeController.doGetAvailabilitiesTimeSlot(
        artiestId: widget.artiestId,
        date: formatDate,
      );
    });
  }

  int selectedIndex = 0;
  String selectTime = '';
  Razorpay razorpay = Razorpay();

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CallWrapper(
        child: SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
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
                  _customBackgroundExample(),
                  const SizedBox(height: 15),
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
                            _homeController.getArtistPopularServicesModel.data
                                        ?.isEmpty ??
                                    false
                                ? const SizedBox()
                                : Container(
                                    width: Get.width,
                                    color: ColorConstant.whiteColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Popular Service By Your Artist",
                                          style: AppTextTheme.bold.copyWith(
                                              fontSize: 16,
                                              color: ColorConstant.blackColor),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 140,
                                          child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: _homeController
                                                      .getArtistPopularServicesModel
                                                      .data
                                                      ?.length ??
                                                  0,
                                              itemBuilder: (context, index) {
                                                return PopularServiceWidget(
                                                  addButtonTap: () {
                                                    _homeController
                                                        .getArtistPopularServicesModel
                                                        .data?[index]
                                                        .isAddCart = !(_homeController
                                                            .getArtistPopularServicesModel
                                                            .data?[index]
                                                            .isAddCart ??
                                                        false);

                                                    if (_homeController
                                                            .getArtistPopularServicesModel
                                                            .data?[index]
                                                            .isAddCart ??
                                                        false) {
                                                      _homeController.doAddCart(
                                                          salonServiceId:
                                                              _homeController
                                                                      .getArtistPopularServicesModel
                                                                      .data?[
                                                                          index]
                                                                      .id ??
                                                                  "",
                                                          isHomeService: SharedPrefs
                                                              .readBoolValue(
                                                                  PrefConstants
                                                                      .isHomeService),
                                                          callback: () {
                                                            _homeController
                                                                .doGetCart()
                                                                .whenComplete(
                                                                    () {
                                                                  _homeController
                                                                      .doGetOrderId();
                                                                });
                                                            if (_homeController
                                                                    .getServiceAddCartModel
                                                                    .data
                                                                    ?.items ==
                                                                null) {
                                                              stylistId.value =
                                                                  "";
                                                              stylistId
                                                                  .notifyListeners();
                                                            }
                                                          });
                                                    } else {
                                                      _homeController
                                                          .doRemoveCart(
                                                              salonServiceId:
                                                                  _homeController
                                                                          .getArtistPopularServicesModel
                                                                          .data?[
                                                                              index]
                                                                          .id ??
                                                                      "",
                                                              callback: () {
                                                                _homeController
                                                                    .doGetCart()
                                                                    .whenComplete(
                                                                        () {
                                                                      _homeController
                                                                          .doGetOrderId();
                                                                    });

                                                                if (_homeController
                                                                        .getServiceAddCartModel
                                                                        .data
                                                                        ?.items ==
                                                                    null) {
                                                                  stylistId
                                                                      .value = "";
                                                                  stylistId
                                                                      .notifyListeners();
                                                                }
                                                              });
                                                    }
                                                  },
                                                  review: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .reviewCount
                                                          .toString() ??
                                                      "",
                                                  rating: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .rating ??
                                                      0.0,
                                                  name: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .name ??
                                                      "",
                                                  image: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .image ??
                                                      "",
                                                  duration: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .duration
                                                          .toString() ??
                                                      "",
                                                  isAdd: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .isAddCart ??
                                                      false,
                                                  price: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .price
                                                          .toString() ??
                                                      "",
                                                );
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
                                  horizontal: 20, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select Time Slot",
                                    style: AppTextTheme.bold.copyWith(
                                        fontSize: 16,
                                        color: ColorConstant.blackColor),
                                  ),
                                  const SizedBox(height: 7),
                                  Dash(
                                    direction: Axis.horizontal,
                                    length: Get.width * 0.88,
                                    dashLength: 2,
                                    dashColor: const Color(0xffCFCFCF),
                                  ),
                                  const SizedBox(height: 7),
                                  _homeController
                                              .getAvailabilitiesTimeSlotModelData
                                              .data
                                              ?.isEmpty ??
                                          false
                                      ? Center(
                                          child: Text(
                                          "No Time Slot Available",
                                          style: AppTextTheme.bold.copyWith(
                                              fontSize: 16,
                                              color: ColorConstant.blackColor),
                                        ))
                                      : Column(
                                          children: [
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
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder: (context, i) {
                                                    return _timeSlotContainerWidget(
                                                        isSelected:
                                                            selectedIndex == i,
                                                        onPress: () {
                                                          setState(() {
                                                            selectedIndex = i;
                                                            selectTime =
                                                                _homeController
                                                                        .getAvailabilitiesTimeSlotModelData
                                                                        .data?[
                                                                            i]
                                                                        .time ??
                                                                    "";
                                                          });
                                                        },
                                                        timeSlot:
                                                            convertTimesToAmPmString(
                                                                _homeController
                                                                        .getAvailabilitiesTimeSlotModelData
                                                                        .data?[
                                                                            i]
                                                                        .time ??
                                                                    ""));
                                                  }),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),

                            /*------------- Apply PromoCode ---------------*/
                            Dash(
                              direction: Axis.horizontal,
                              length: Get.width * 0.88,
                              dashLength: 2,
                              dashColor: const Color(0xffCFCFCF),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Text(
                                    "Exclusive ScutS Offers",
                                    textScaler: const TextScaler.linear(0.90),
                                    style: AppTextTheme.bold.copyWith(
                                        fontSize: 18,
                                        color: ColorConstant.blackColor),
                                  ),
                                ),
                                if (_homeController.getServiceAddCartModel.data
                                        ?.isDiscountApplied ??
                                    false)
                                  GestureDetector(
                                    onTap: () async {
                                      _homeController.doRemovePromoCode(
                                          callback: () {
                                            _homeController
                                                .doGetCart()
                                                .whenComplete(() {
                                              _homeController.doGetOrderId();
                                            });
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      width: Get.width,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: ColorConstant.whiteColor,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: ColorConstant.primaryColor,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                AssetsConstant.offerIcon,
                                                color: changeTheme(SharedPrefs
                                                        .readStringValue(
                                                            PrefConstants
                                                                .gender)) ??
                                                    ColorConstant.primaryColor,
                                                width: 25,
                                                height: 25,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                "Remove PromoCode",
                                                style: AppTextTheme.bold
                                                    .copyWith(
                                                        fontSize: 14,
                                                        color: ColorConstant
                                                            .blackColor),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _homeController.doRemovePromoCode(
                                                  callback: () {
                                                _homeController
                                                    .doGetCart()
                                                    .whenComplete(() {
                                                  _homeController
                                                      .doGetOrderId();
                                                });
                                              });
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                color: ColorConstant.redBgColor,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Remove",
                                                  style: AppTextTheme.medium
                                                      .copyWith(fontSize: 13),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () async {
                                      String id = await showModalBottomSheet(
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(32),
                                            topRight: Radius.circular(32),
                                          )),
                                          context: context,
                                          builder: (context) {
                                            return const PromoCodeSheetWidget();
                                          });

                                      _homeController.doApplyPromoCode(
                                          data: {
                                            "discountId": id,
                                          },
                                          callback: () {
                                            _homeController
                                                .doGetCart()
                                                .whenComplete(() {
                                              _homeController.doGetOrderId();
                                            });
                                          });
                                    },
                                    child: Container(
                                      height: 50,
                                      width: Get.width,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: ColorConstant.whiteColor,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: ColorConstant.primaryColor,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                AssetsConstant.offerIcon,
                                                width: 25,
                                                color: changeTheme(SharedPrefs
                                                        .readStringValue(
                                                            PrefConstants
                                                                .gender)) ??
                                                    ColorConstant.primaryColor,
                                                height: 25,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                "Tap to Save More",
                                                style: AppTextTheme.bold
                                                    .copyWith(
                                                        fontSize: 14,
                                                        color: ColorConstant
                                                            .blackColor),
                                              ),
                                            ],
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 20,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Dash(
                              direction: Axis.horizontal,
                              length: Get.width * 0.88,
                              dashLength: 2,
                              dashColor: const Color(0xffCFCFCF),
                            ),
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
                                    "Know What You Are Paying For",
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
                                              ?.servicesWithProduct
                                              ?.length ??
                                          0,
                                      itemBuilder: (context, index) {
                                        return KnowWhatYouWidget(
                                          editProduct: () {
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
                                                  return AddProductSheetWidget(
                                                    price: _homeController
                                                            .getServiceAddCartModel
                                                            .data
                                                            ?.servicesWithProduct?[
                                                                index]
                                                            .totalCost ??
                                                        0,
                                                    rating: _homeController
                                                            .getServiceAddCartModel
                                                            .data
                                                            ?.servicesWithProduct?[
                                                                index]
                                                            .rating ??
                                                        0.0,
                                                    review: 0,
                                                    nameOfService: _homeController
                                                            .getServiceAddCartModel
                                                            .data
                                                            ?.servicesWithProduct?[
                                                                index]
                                                            .name ??
                                                        "",
                                                    serviceId: _homeController
                                                            .getServiceAddCartModel
                                                            .data
                                                            ?.servicesWithProduct?[
                                                                index]
                                                            .serviceId ??
                                                        "",
                                                  );
                                                });
                                          },
                                          removeBtn: () {
                                            _homeController.doRemoveCart(
                                                salonServiceId: _homeController
                                                        .getServiceAddCartModel
                                                        .data
                                                        ?.servicesWithProduct?[
                                                            index]
                                                        .serviceId ??
                                                    "",
                                                callback: () {
                                                  _homeController
                                                      .doGetPopularServiceByYourStylist(
                                                          stylistId:
                                                              widget.artiestId);
                                                  _homeController.doGetSalonDetailsService(
                                                      serviceGender: SharedPrefs
                                                                  .readStringValue(
                                                                      PrefConstants
                                                                          .gender) ==
                                                              "0"
                                                          ? "male"
                                                          : "female",
                                                      salonId: _homeController
                                                              .getServiceAddCartModel
                                                              .data
                                                              ?.salonId ??
                                                          "");
                                                  _homeController
                                                      .doGetCart()
                                                      .whenComplete(() {
                                                    _homeController
                                                        .doGetOrderId();
                                                  });
                                                  if (_homeController
                                                          .getServiceAddCartModel
                                                          .data
                                                          ?.items ==
                                                      null) {
                                                    stylistId.value = "";
                                                    stylistId.notifyListeners();
                                                  }
                                                });
                                          },
                                          items: _homeController
                                              .getServiceAddCartModel
                                              .data!
                                              .servicesWithProduct![index],
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
        floatingActionButton: Obx(
          () => _homeController.showProgress
              ? const SizedBox()
              : _homeController.getServiceAddCartModel.data?.servicesWithProduct
                          ?.isEmpty ??
                      false ||
                          _homeController.getServiceAddCartModel.data
                                  ?.servicesWithProduct ==
                              null
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
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Text(
                          //       "Total Price",
                          //       style: AppTextTheme.bold.copyWith(
                          //           fontSize: 13,
                          //           color: ColorConstant.grayTextColor),
                          //     ),
                          //     const SizedBox(height: 2),
                          //     Text(
                          //       "₹${(_homeController.getServiceAddCartModel.data?.price ?? 0).toStringAsFixed(2)}",
                          //       style: AppTextTheme.bold.copyWith(
                          //           fontSize: 19,
                          //           color: ColorConstant.blackColor),
                          //     ),
                          //     const SizedBox(height: 2),
                          //     Text(
                          //       "GST is included",
                          //       style: AppTextTheme.regular.copyWith(
                          //           color: ColorConstant.blackColor,
                          //           fontSize: 12),
                          //     )
                          //   ],
                          // ),
                          GestureDetector(
                            onTap: _showPriceBreakdownSheet,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Total Payable",
                                      style: AppTextTheme.bold.copyWith(
                                        fontSize: 13,
                                        color: ColorConstant.grayTextColor,
                                      ),
                                    ),

                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      "₹${(_homeController.getServiceAddCartModel.data?.price ?? 0).toStringAsFixed(2)}",
                                      style: AppTextTheme.bold.copyWith(
                                        fontSize: 19,
                                        color: ColorConstant.blackColor,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Transform.rotate(
                                      angle: 3.1416, // 180° in radians
                                      child: Icon(
                                        Icons.expand_circle_down,
                                        size: 24,
                                        color: Colors.black,
                                      ),
                                    )
                                  ]
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "View Breakdown",
                                  style: AppTextTheme.regular.copyWith(
                                    color: ColorConstant.blackColor,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _payAndBook();
                              //_showBookingOptionsBottomSheet(context);
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
                                    //"Book",
                                    textScaler: const TextScaler.linear(0.85),
                                    style: AppTextTheme.medium.copyWith(
                                        fontSize: 20,
                                        color: ColorConstant.whiteColor),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.arrow_forward,
                                      color: ColorConstant.whiteColor, size: 20)
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
          ),
        ),
      ),
    ));
  }

  void _showPriceBreakdownSheet() {
    final data = _homeController.getServiceAddCartModel.data;

    /// ORIGINAL service total
    final double original =
    (data?.totalPrice ?? 0).toDouble();

    /// DISCOUNT applied
    final double discount =
    (data?.discountAmount ?? 0).toDouble();

    /// AFTER DISCOUNT (before GST)
    final double subtotal =
    (data?.taxAbleTotal ?? 0).toDouble();

    /// GST
    final double gst =
    (data?.cartTaxDetails?.totalTaxAmount ?? 0).toDouble();

    /// FINAL PAYABLE
    final double total =
    (data?.price ?? 0).toDouble();

    final double platformFee =
    (data?.platformFee ?? 0).toDouble();


    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// HANDLE BAR
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              /// TITLE
              Text(
                "Price Breakdown",
                style: AppTextTheme.bold.copyWith(fontSize: 16,color: ColorConstant.blackColor),
              ),

              const SizedBox(height: 16),

              /// ORIGINAL PRICE
              _priceRow("Original Price", original),

              /// GST
              //_priceRow("GST", gst),
              GestureDetector(
                onTap: _showChargesPopup,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _priceRow("GST & Other Charges", gst+platformFee),

                    /// dotted underline
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 150,
                      child: Row(
                        children: List.generate(
                          30,
                              (_) => Expanded(
                            child: Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// DISCOUNT
              if (discount > 0)
                _priceRow("Discount", discount, isDiscount: true),

              const Divider(height: 24),

              /// FINAL TOTAL
              _priceRow("Total Payable", total, isBold: true),
            ],
          ),
        );
      },
    );
  }

  void _showChargesPopup() {
    final data = _homeController.getServiceAddCartModel.data;

    final double gst =
    (data?.cartTaxDetails?.totalTaxAmount ?? 0).toDouble();

    final double platformFee = data?.platformFee ?? 0; // replace when backend sends

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              bottom: 120, // adjust based on your layout
              left: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _priceRow("GST", gst),
                      const SizedBox(height: 6),
                      _priceRow("Platform Fee", platformFee),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _priceRow(
      String label,
      double value, {
        bool isBold = false,
        bool isDiscount = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextTheme.medium.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount
                  ? Colors.green
                  : (isBold ? Colors.black : ColorConstant.grayTextColor),
            ),
          ),
          Text(
            isDiscount
                ? "- ₹${value.toStringAsFixed(2)}"
                : "₹${value.toStringAsFixed(2)}",
            style: AppTextTheme.medium.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount
                  ? Colors.green
                  : (isBold ? Colors.black : ColorConstant.blackColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // 🔹 Title
              Text(
                "Choose Payment Option",
                style: AppTextTheme.bold.copyWith(fontSize: 18, color: Colors.black),
              ),

              const SizedBox(height: 20),

              // ✅ PAY & BOOK (existing flow)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _payAndBook(); // 👈 existing Razorpay flow
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: changeTheme(SharedPrefs.readStringValue(
                        PrefConstants.gender)) ??
                        ColorConstant.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Pay Online",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🕒 PAY AFTER SERVICE
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _bookPayAfterService();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: changeTheme(SharedPrefs.readStringValue(
                        PrefConstants.gender)) ??
                        ColorConstant.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Pay After Service ",
                            style: TextStyle(
                              fontSize: 16,
                              color: changeTheme(
                                SharedPrefs.readStringValue(PrefConstants.gender),
                              ) ??
                                  ColorConstant.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          TextSpan(
                            text: "   (+2.36%)",
                            style: TextStyle(
                              fontSize: 11, // 👈 small text
                              color: Colors.grey[600], // 👈 subtle
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Future<void> _payAndBook() async {
  //   if (selectTime == ""){
  //     selectTime =
  //         _homeController.getAvailabilitiesTimeSlotModelData.data?[0].time ??
  //             "";
  //   }
  //   else {
  //     selectTime = selectTime;
  //   }
  //   String inputDateTime = "$selectDate$selectTime";
  //   String correctedDateTime =
  //       '${inputDateTime.substring(0, 10)}T${inputDateTime.substring(10)}';
  //   DateTime dateTime = DateTime.parse(correctedDateTime);
  //   String isoDateTime = dateTime.toIso8601String();
  //   _homeController.doCreateBookingIntent(
  //       userAddressId: userServiceAddressIdSelect,
  //       isHomeService:
  //       _homeController.getServiceAddCartModel.data?.isHomeService ??
  //           false,
  //       salonArtistId: widget.artiestId,
  //       startAt: isoDateTime);
  //   var options = {
  //     'key': _homeController
  //         .getOrderIdModel.data?.razorpayKey ??
  //         "",
  //     'amount': _homeController
  //         .getServiceAddCartModel.data?.price ??
  //         0 * 100,
  //     'name': 'ScutS',
  //     'timeout': 120,
  //     "order_id": _homeController
  //         .getOrderIdModel.data?.orderId ??
  //         "",
  //     'description': 'Booking Appointment',
  //     'retry': {'enabled': true, 'max_count': 1},
  //     'send_sms_hash': true,
  //     'prefill': {
  //       'contact': _authController.userResponseModel
  //           .data?.userData?.mobile ??
  //           "",
  //       'email': _authController.userResponseModel
  //           .data?.userData?.mobile ??
  //           ""
  //     },
  //     'external': {}
  //   };
  //   razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
  //       handlePaymentErrorResponse);
  //   razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
  //       handlePaymentSuccessResponse);
  //   razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
  //       handleExternalWalletSelected);
  //
  //   if (_homeController.getServiceAddCartModel.data
  //       ?.items?.isEmpty ??
  //       false) {
  //     showMessage("Cart Service Not Found");
  //   } else {
  //     if (_homeController
  //         .getAvailabilitiesTimeSlotModelData
  //         .data
  //         ?.isEmpty ??
  //         false) {
  //       showMessage(
  //           "This Date No Available Any Slot Please Select Next Date");
  //     } else {
  //       if (SharedPrefs.readBoolValue(
  //           PrefConstants.isHomeService)) {
  //         if (userServiceAddressIdSelect == "") {
  //           Get.to(() =>
  //           const AddAddressPage(isSelect: true));
  //         } else {
  //           log("isHomeService  ${_homeController.getServiceAddCartModel.data?.price ?? 0 * 100}");
  //           razorpay.open(options);
  //         }
  //       } else {
  //         log("Booking Appointment without HomeService  ${_homeController.getServiceAddCartModel.data?.price ?? 0 * 100}");
  //         razorpay.open(options);
  //       }
  //     }
  //   }
  // }

  Future<void> _payAndBook() async {

    // ✅ 1. Cart validation
    if (_homeController.getServiceAddCartModel.data?.items?.isEmpty ?? true) {
      showMessage("Cart Service Not Found");
      return;
    }

    // ✅ 2. Slot validation — MUST be before selectTime logic
    final slots = _homeController
        .getAvailabilitiesTimeSlotModelData
        .data;

    if (slots == null || slots.isEmpty) {
      showMessage(
        "No slots available for today.\nPlease select a future date.",
      );
      return; // 👈 VERY IMPORTANT
    }

    // ✅ 3. Safe selectTime assignment
    if (selectTime.isEmpty) {
      selectTime = slots.first.time ?? "";
    }

    // ✅ 4. Date-time construction
    String inputDateTime = "$selectDate$selectTime";
    String correctedDateTime =
        '${inputDateTime.substring(0, 10)}T${inputDateTime.substring(10)}';

    DateTime dateTime = DateTime.parse(correctedDateTime);
    String isoDateTime = dateTime.toIso8601String();

    // ✅ 5. Create booking intent
    _homeController.doCreateBookingIntent(
      userAddressId: userServiceAddressIdSelect,
      isHomeService:
      _homeController.getServiceAddCartModel.data?.isHomeService ?? false,
      salonArtistId: widget.artiestId,
      startAt: isoDateTime,
    );

    // ✅ 6. Razorpay options
    var options = {
      'key': _homeController.getOrderIdModel.data?.razorpayKey ?? "",
      'amount':
      (_homeController.getServiceAddCartModel.data?.price ?? 0) * 100,
      'name': 'ScutS',
      'timeout': 120,
      'order_id': _homeController.getOrderIdModel.data?.orderId ?? "",
      'description': 'Booking Appointment',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact':
        _authController.userResponseModel.data?.userData?.mobile ?? "",
        'email':
        _authController.userResponseModel.data?.userData?.email ?? "",
      },
      'external': {}
    };

    // ✅ 7. Razorpay listeners
    razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(
        Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);

    // ✅ 8. Home service validation
    if (SharedPrefs.readBoolValue(PrefConstants.isHomeService)) {
      if (userServiceAddressIdSelect.isEmpty) {
        Get.to(() => const AddAddressPage(isSelect: true));
        return;
      }
    }

    // ✅ 9. Open Razorpay
    log("Opening Razorpay for booking");
    razorpay.open(options);
  }

  Future<void> _bookPayAfterService() async {
    if (selectTime == ""){
      selectTime =
          _homeController.getAvailabilitiesTimeSlotModelData.data?[0].time ??
              "";
    }
    else {
      selectTime = selectTime;
    }
    String inputDateTime = "$selectDate$selectTime";
    String correctedDateTime =
        '${inputDateTime.substring(0, 10)}T${inputDateTime.substring(10)}';
    DateTime dateTime = DateTime.parse(correctedDateTime);
    String isoDateTime = dateTime.toIso8601String();

    _homeController.doCreateBooking(
        userAddressId: "",
        isHomeService:
            _homeController.getServiceAddCartModel.data?.isHomeService ??
                false,
        salonArtistId: widget.artiestId,
        startAt: isoDateTime,
        callback: ()
        {
          stylistId.value = "";
          stylistId.notifyListeners();
          _navigateAfterBooking();
        }
    );
  }
  /*================  Razor Pay ==============*/
  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  /*-------------  On Payment Fail Method ------------- */
  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    final user = _authController.userResponseModel.data?.userData;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return CallWrapper( // ✅ adds your Help 24×7 call button
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              "Payment Failed",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView( // ✅ ensures content never overflows
              child: ListBody(
                children: [
                  const Text(
                    "You may have cancelled the payment or there was a delay in response from the UPI app.",
                  ),
                  const SizedBox(height: 12),
                  Text("Mobile: +91 ${user?.mobile ?? ''}"),
                  Text("Email: ${user?.email ?? ''}"),
                  Text("Name: ${user?.name ?? ''}"),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();       // ✅ close dialog
                  //Navigator.of(context).maybePop(); // ✅ go back if possible
                },
                child: const Text(
                  "OK",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /*---------------  On Payment Success Method ------------ */
  Future<void> handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    print("🎯 Razorpay Success Response: $response");
    print("PaymentId: ${response.paymentId}");
    print("OrderId: ${response.orderId}");
    print("Signature: ${response.signature}");
    showMessage("Payment Successful");
    showMessage("Payment Successful");

    final booking = await _homeController.fetchBookingByRazorpayOrderId(
      razorpayOrderId: response.orderId!,
    );

    if (booking == null) {
      showMessage("Booking is being processed. Please wait.");
      return;
    }

    _navigateAfterBooking(); // ✅ runs ONLY after data is ready

    // Commenting because booking happening using razorpay webhooks and home service is disabled.
    // if (selectTime == "") {
    //   selectTime =
    //       _homeController.getAvailabilitiesTimeSlotModelData.data?[0].time ??
    //           "";
    //   String inputDateTime = "$selectDate$selectTime";
    //   String correctedDateTime =
    //       '${inputDateTime.substring(0, 10)}T${inputDateTime.substring(10)}';
    //   DateTime dateTime = DateTime.parse(correctedDateTime);
    //   String isoDateTime = dateTime.toIso8601String();
    //
    //   if (_homeController.getServiceAddCartModel.data?.isHomeService ?? false) {
    //     if (userServiceAddressIdSelect == "") {
    //       Get.to(() => const AddAddressPage(
    //             isSelect: true,
    //           ));
    //     } else {
    //       _homeController.doCreateBooking(
    //           userAddressId: userServiceAddressIdSelect,
    //           isHomeService:
    //               _homeController.getServiceAddCartModel.data?.isHomeService ??
    //                   false,
    //           salonArtistId: widget.artiestId,
    //           startAt: isoDateTime,
    //           callback: () {
    //             stylistId.value = "";
    //             stylistId.notifyListeners();
    //
    //             // Get.to(() => YourApprovalPage(
    //             //       salonAppointmentId: _homeController
    //             //               .getCreateBookingAppointmentModel
    //             //               .data
    //             //               ?.salonAppointmentId ??
    //             //           "",
    //             //     ));
    //             _navigateAfterBooking();
    //           });
    //     }
    //   } else {
    //     _homeController.doCreateBooking(
    //         userAddressId: "",
    //         isHomeService:
    //             _homeController.getServiceAddCartModel.data?.isHomeService ??
    //                 false,
    //         salonArtistId: widget.artiestId,
    //         startAt: isoDateTime,
    //         callback: () {
    //           stylistId.value = "";
    //           stylistId.notifyListeners();
    //
    //           // Get.to(() => YourApprovalPage(
    //           //       salonAppointmentId: _homeController
    //           //               .getCreateBookingAppointmentModel
    //           //               .data
    //           //               ?.salonAppointmentId ??
    //           //           "",
    //           //     ));
    //           _navigateAfterBooking();
    //         });
    //   }
    // } else {
    //   String inputDateTime = "$selectDate$selectTime";
    //   String correctedDateTime =
    //       '${inputDateTime.substring(0, 10)}T${inputDateTime.substring(10)}';
    //   DateTime dateTime = DateTime.parse(correctedDateTime);
    //   String isoDateTime = dateTime.toIso8601String();
    //
    //   if (SharedPrefs.readBoolValue(PrefConstants.isHomeService)) {
    //     _homeController.doCreateBooking(
    //         userAddressId: userServiceAddressIdSelect,
    //         isHomeService:
    //             _homeController.getServiceAddCartModel.data?.isHomeService ??
    //                 false,
    //         salonArtistId: widget.artiestId,
    //         startAt: isoDateTime,
    //         callback: () {
    //           stylistId.value = "";
    //           stylistId.notifyListeners();
    //
    //           // Get.to(() => YourApprovalPage(
    //           //       salonAppointmentId: _homeController
    //           //               .getCreateBookingAppointmentModel
    //           //               .data
    //           //               ?.salonAppointmentId ??
    //           //           "",
    //           //     ));
    //           _navigateAfterBooking();
    //         });
    //   } else {
    //     stylistId.value = "";
    //     _homeController.doCreateBooking(
    //         userAddressId: "",
    //         isHomeService:
    //             _homeController.getServiceAddCartModel.data?.isHomeService ??
    //                 false,
    //         salonArtistId: widget.artiestId,
    //         startAt: isoDateTime,
    //         callback: () {
    //           // Get.to(() => YourApprovalPage(
    //           //       salonAppointmentId: _homeController
    //           //               .getCreateBookingAppointmentModel
    //           //               .data
    //           //               ?.salonAppointmentId ??
    //           //           "",
    //           //     ));
    //           _navigateAfterBooking();
    //         });
    //   }
    // }
  }

  /*---------------  On  External Success Method ------------ */
  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
        context, "External Wallet Selected", "${response.walletName}");
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
              ? changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender)) ??
                  ColorConstant.primaryColor
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

  final Rx<bool> _isMonthChange = false.obs;

  bool get isDialogShow => _isMonthChange.value;

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
      key: ValueKey(selectDate),
      // Force rebuild when selectDate changes
      onMonthChange: (val) {
        selectDate = "";
        String inputString = val.toString();
        RegExp regExp = RegExp(r'\d+');
        Iterable<RegExpMatch> matches = regExp.allMatches(inputString);
        String result = matches.map((match) => match.group(0)).join('');
        String year = DateFormat("yyyy").format(DateTime.now());
        String finalDate =
            "$year-${result.length == 1 ? '0$result' : result}-01";

        // Update selectDate to the first day of the new month
        setState(() {
          selectDate = finalDate;
        });

        _homeController.doGetUnAvailableDatesListData(
          artiestId: widget.artiestId,
          date: finalDate,
          callback: () {
            _homeController.doGetAvailabilitiesTimeSlot(
              artiestId: widget.artiestId,
              date: finalDate,
            );
          },
        );
      },
      initialDate:
          selectDate == "" ? DateTime.now() : DateTime.parse(selectDate),
      onDateChange: (selectedDate) {
        //`selectedDate` the new date selected.
        selectDate = "";
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
        height: 72,
        width: 58,
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

  /*-------------- Convert AM PM Date Time --------------------*/
  String convertTimesToAmPmString(String timeSlot) {
    DateTime time = DateFormat("HH:mm").parse(timeSlot);
    String convertTimeSlot = DateFormat("hh:mm a").format(time);
    return convertTimeSlot;
  }

  Future<void> _navigateAfterBooking() async {
    final booking = _homeController.getCreateBookingAppointmentModel.data;

    final isPersonOfTheYearEnabled =
        _authController.getAppUpdateModel.data
            ?.personOfTheYear
            ?.enabled ??
            false;

    String? name;
    String? phone;

    // 👉 Person of the Year (INTERMEDIATE STEP)
    if (isPersonOfTheYearEnabled) {
      final result = await Get.to<Map<String, String>>(
            () => PersonOfTheYearPage(
          salonAppointmentId: booking?.salonAppointmentId ?? "",
        ),
      );

      if (result != null) {
        name = result['name'];
        phone = result['phone'];
      }

      Get.to(() => YourApprovalPage(
        salonAppointmentId: booking?.salonAppointmentId ?? "",
        name: name,
        phone: phone,
      ));
    }
    else {
      Get.to(() => YourApprovalPage(
        salonAppointmentId: booking?.salonAppointmentId ?? "",
      ));
    }

  }

// Secret santa commented
  // Future<void> _navigateAfterBooking() async {
  //   final booking = _homeController.getCreateBookingAppointmentModel.data;
  //
  //   if (booking?.complimentaryServiceId != null &&
  //       (booking?.complimentaryServiceName?.isNotEmpty ?? false)) {
  //     final bool? isClaimed = await showDialog<bool>(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (_) => SecretSantaScratchDialog(
  //         rewardName: booking!.complimentaryServiceName! +
  //             ' ' +
  //             booking!.complimentaryServiceCategoryName!,
  //       ),
  //     );
  //
  //     Get.to(() => YourApprovalPage(
  //       salonAppointmentId: booking?.salonAppointmentId ?? "",
  //       isClaimed: isClaimed, // 👈 NOW IT EXISTS
  //     ));
  //
  //   } else {
  //     Get.to(() => YourApprovalPage(
  //       salonAppointmentId: booking?.salonAppointmentId ?? "",
  //     ));
  //   }
  // }
}
