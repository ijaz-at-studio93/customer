import 'dart:developer';

import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
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
import '../home/home_page.dart';
import '../home/saloon_after_selecting_page.dart';
import '../home/widget/add_product_sheet_widget.dart';
import '../profile/add_address_page.dart';
import '../stylist/selecting_artist_bottom_sheet.dart';
import 'package:salon_customer/service/analytics_service.dart';

class AppointmentBookingPage extends StatefulWidget {
  //final String artiestId;
  final List<String> artistIds;

  const AppointmentBookingPage({super.key, required this.artistIds});

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final _homeController = Get.find<HomeController>();
  final _authController = Get.find<AuthController>();
  final ScrollController _scrollController = ScrollController();
  List<String> selectedSlots = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      userServiceAddressIdSelect = "";
      DateTime date = DateTime.now();
      String formatDate = DateFormat("yyyy-MM-dd").format(date);
      int visibleYear = DateTime.now().year;
      selectDate = formatDate;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCenter(0); // today
      });
      _scrollController.addListener(_handleScrollMonthChange);
      // _homeController.doGetPopularServiceByYourStylist(
      //     stylistId: widget.artistIds.first);
      // No need of blogs in appointment page
      // _homeController.doGetBlogData(
      //   lat: double.parse(SharedPrefs.readStringValue(PrefConstants.latitude)),
      //   lng: double.parse(SharedPrefs.readStringValue(PrefConstants.longitude)),
      // );
      // _homeController.doGetUnAvailableDatesListData(
      //     artiestId: widget.artistIds.first, date: formatDate, callback: () {});

      _homeController.doGetCart();
      //Commenting because of Pay after service
      // No need to creating razorpay order
      //     .whenComplete(() {
      //   _homeController.doGetOrderId();
      // });
      // _homeController.doGetAvailabilitiesTimeSlot(
      //   artiestId: widget.artistIds.first,
      //   date: formatDate,
      // );
    });
  }

  Future<void> _markSalonVisited() async {
    await SharedPrefs.writeBoolValue(PrefConstants.hasVisitedSalon, true);
  }

  int selectedIndex = 0;
  String selectTime = '';
  Razorpay razorpay = Razorpay();

  void _handleScrollMonthChange() {
    if (!_scrollController.hasClients) return;

    final itemWidth = 64.0; // 56 + margin(8)

    final offset = _scrollController.offset;
    final screenWidth = MediaQuery.of(context).size.width;

    /// 👉 detect CENTER item
    final centerOffset = offset + screenWidth / 2;
    final index = (centerOffset / itemWidth).floor();

    final baseDate = DateTime.now();

    final visibleDate = baseDate.add(Duration(days: index));

    final newMonth = DateTime(visibleDate.year, visibleDate.month);

    if (newMonth.month != currentMonth.month ||
        newMonth.year != currentMonth.year) {
      setState(() {
        currentMonth = newMonth;
      });
    }
  }

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
        backgroundColor: ColorConstant.whiteColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: ColorConstant.whiteColor,
          leading: GestureDetector(
              onTap: () {
                //selectedArtistIdsGlobal.value = [];
                if (_homeController.getServiceAddCartModel.data?.items ==
                    null) {
                  Navigator.of(context).maybePop();
                } else {
                  _homeController.doGetArtiestListData();
                }
                Navigator.of(context).maybePop();
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: ColorConstant.blackColor,
              )),
          centerTitle: true,
          title: Text(
            "Booking Appointment",
            style: AppTextTheme.bold.copyWith(
              fontFamily: "Outfit", // ✅ important
              fontWeight: FontWeight.w700, // ✅ Bold
              fontSize: 25, // ✅ match Figma
              color: ColorConstant.blackColor,
            ),
          ),
        ),
        body: Obx(
          () => ProgressContainerView(
            isProgressRunning: _homeController.showBookingProgress,
            child: Stack(children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // _customBackgroundExample(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16), // ✅ match rest UI
                      //child: _customBackgroundExample(),

                      child: _customDateTimeline(),
                    ),
                    const SizedBox(height: 8),
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
                              // _homeController.getArtistPopularServicesModel.data
                              //             ?.isEmpty ??
                              //         false
                              //     ? const SizedBox()
                              //     : Container(
                              //         width: Get.width,
                              //         color: ColorConstant.whiteColor,
                              //         padding: const EdgeInsets.symmetric(
                              //             horizontal: 20, vertical: 10),
                              //         child: Column(
                              //           crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //           children: [
                              //             Text(
                              //               "Popular Service By Your Artist",
                              //               style: AppTextTheme.bold.copyWith(
                              //                   fontSize: 16,
                              //                   color: ColorConstant.blackColor),
                              //             ),
                              //             const SizedBox(height: 8),
                              //             SizedBox(
                              //               height: 140,
                              //               child: ListView.builder(
                              //                   padding: EdgeInsets.zero,
                              //                   shrinkWrap: true,
                              //                   scrollDirection: Axis.horizontal,
                              //                   itemCount: _homeController
                              //                           .getArtistPopularServicesModel
                              //                           .data
                              //                           ?.length ??
                              //                       0,
                              //                   itemBuilder: (context, index) {
                              //                     return PopularServiceWidget(
                              //                       addButtonTap: () {
                              //                         _homeController
                              //                             .getArtistPopularServicesModel
                              //                             .data?[index]
                              //                             .isAddCart = !(_homeController
                              //                                 .getArtistPopularServicesModel
                              //                                 .data?[index]
                              //                                 .isAddCart ??
                              //                             false);
                              //
                              //                         if (_homeController
                              //                                 .getArtistPopularServicesModel
                              //                                 .data?[index]
                              //                                 .isAddCart ??
                              //                             false) {
                              //                           _homeController.doAddCart(
                              //                               salonServiceId:
                              //                                   _homeController
                              //                                           .getArtistPopularServicesModel
                              //                                           .data?[
                              //                                               index]
                              //                                           .id ??
                              //                                       "",
                              //                               isHomeService: SharedPrefs
                              //                                   .readBoolValue(
                              //                                       PrefConstants
                              //                                           .isHomeService),
                              //                               callback: () {
                              //                                 _homeController
                              //                                     .doGetCart();
                              //                                 //Commenting because of Pay after service
                              //                                 // No need to creating razorpay order
                              //                                     // .whenComplete(
                              //                                     //     () {
                              //                                     //   _homeController
                              //                                     //       .doGetOrderId();
                              //                                     // });
                              //                                 if (_homeController
                              //                                         .getServiceAddCartModel
                              //                                         .data
                              //                                         ?.items ==
                              //                                     null) {
                              //                                   stylistId.value =
                              //                                       "";
                              //                                   stylistId
                              //                                       .notifyListeners();
                              //                                 }
                              //                               });
                              //                         } else {
                              //                           _homeController
                              //                               .doRemoveCart(
                              //                                   salonServiceId:
                              //                                       _homeController
                              //                                               .getArtistPopularServicesModel
                              //                                               .data?[
                              //                                                   index]
                              //                                               .id ??
                              //                                           "",
                              //                                   callback: () {
                              //                                     _homeController
                              //                                         .doGetCart();
                              //                                         //Commenting because of Pay after service
                              //                                         // No need to creating razorpay order
                              //                                         // .whenComplete(
                              //                                         //     () {
                              //                                         //   _homeController
                              //                                         //       .doGetOrderId();
                              //                                         // });
                              //
                              //                                     if (_homeController
                              //                                             .getServiceAddCartModel
                              //                                             .data
                              //                                             ?.items ==
                              //                                         null) {
                              //                                       stylistId
                              //                                           .value = "";
                              //                                       stylistId
                              //                                           .notifyListeners();
                              //                                     }
                              //                                   });
                              //                         }
                              //                       },
                              //                       review: _homeController
                              //                               .getArtistPopularServicesModel
                              //                               .data?[index]
                              //                               .reviewCount
                              //                               .toString() ??
                              //                           "",
                              //                       rating: _homeController
                              //                               .getArtistPopularServicesModel
                              //                               .data?[index]
                              //                               .rating ??
                              //                           0.0,
                              //                       name: _homeController
                              //                               .getArtistPopularServicesModel
                              //                               .data?[index]
                              //                               .name ??
                              //                           "",
                              //                       image: _homeController
                              //                               .getArtistPopularServicesModel
                              //                               .data?[index]
                              //                               .image ??
                              //                           "",
                              //                       duration: _homeController
                              //                               .getArtistPopularServicesModel
                              //                               .data?[index]
                              //                               .duration
                              //                               .toString() ??
                              //                           "",
                              //                       isAdd: _homeController
                              //                               .getArtistPopularServicesModel
                              //                               .data?[index]
                              //                               .isAddCart ??
                              //                           false,
                              //                       price: _homeController
                              //                               .getArtistPopularServicesModel
                              //                               .data?[index]
                              //                               .price
                              //                               .toString() ??
                              //                           "",
                              //                     );
                              //                   }),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
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
                                        fontFamily: "Outfit",
                                        fontWeight: FontWeight.w700, // ✅ Bold
                                        fontSize: 20, // ✅ 20 as required
                                        color: ColorConstant.blackColor,
                                      ),
                                    ),

                                    const SizedBox(height: 7),

                                    // (_homeController.getAvailabilitiesTimeSlotModelData.data?.isEmpty ?? true)
                                    //     ? Center(
                                    //   child: Text(
                                    //     "No Time Slot Available",
                                    //     style: AppTextTheme.bold.copyWith(
                                    //       fontSize: 16,
                                    //       color: ColorConstant.blackColor,
                                    //     ),
                                    //   ),
                                    // )
                                    //     : Builder(
                                    //   builder: (context) {
                                    //     /// ✅ LOGIC HERE (correct place)
                                    //     final originalList = _homeController
                                    //         .getAvailabilitiesTimeSlotModelData.data ??
                                    //         [];
                                    //
                                    //     final half = (originalList.length / 2).ceil();
                                    //
                                    //     final List reorderedList = [];
                                    //
                                    //     for (int i = 0; i < half; i++) {
                                    //       /// first row
                                    //       reorderedList.add(originalList[i]);
                                    //
                                    //       /// second row
                                    //       if (i + half < originalList.length) {
                                    //         reorderedList.add(originalList[i + half]);
                                    //       }
                                    //     }
                                    //
                                    //     /// ✅ UI (unchanged)
                                    //     return SizedBox(
                                    //       height: 90,
                                    //       child: GridView.builder(
                                    //         scrollDirection: Axis.horizontal,
                                    //         itemCount: reorderedList.length,
                                    //         gridDelegate:
                                    //         const SliverGridDelegateWithFixedCrossAxisCount(
                                    //           crossAxisCount: 2,
                                    //           mainAxisSpacing: 0,
                                    //           crossAxisSpacing: 6,
                                    //           mainAxisExtent: 100,
                                    //         ),
                                    //         itemBuilder: (context, i) {
                                    //           final slot = reorderedList[i];
                                    //
                                    //           return _timeSlotContainerWidget(
                                    //             isSelected: selectedIndex == i,
                                    //             onPress: () {
                                    //               setState(() {
                                    //                 selectedIndex = i;
                                    //                 selectTime = slot.time ?? "";
                                    //               });
                                    //             },
                                    //             timeSlot: convertTimesToAmPmString(
                                    //               slot.time ?? "",
                                    //             ),
                                    //           );
                                    //         },
                                    //       ),
                                    //     );
                                    //   },
                                    // ),

                                    Builder(
                                      builder: (context) {
                                        final slots = generateTimeSlots();

                                        return SizedBox(
                                          height: 90,
                                          child: GridView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: slots.length,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 0,
                                              crossAxisSpacing: 6,
                                              mainAxisExtent: 100,
                                            ),
                                            itemBuilder: (context, i) {
                                              final slot = slots[i];

                                              return _timeSlotContainerWidget(
                                                isSelected: selectedSlots
                                                    .contains(slot),
                                                onPress: () {
                                                  setState(() {
                                                    if (selectedSlots
                                                        .contains(slot)) {
                                                      selectedSlots
                                                          .remove(slot);
                                                    } else {
                                                      if (selectedSlots.length <
                                                          3) {
                                                        selectedSlots.add(slot);
                                                        // 📊 select_slot
                                                        AnalyticsService
                                                            .instance
                                                            .logSelectSlot(
                                                          slotTime: slot,
                                                          salonId: _homeController
                                                                  .getServiceAddCartModel
                                                                  .data
                                                                  ?.salonId ??
                                                              '',
                                                        );
                                                      } else {
                                                        showMessage(
                                                            "You can select up to 3 slots only");
                                                      }
                                                    }
                                                  });
                                                },
                                                timeSlot:
                                                    convertTimesToAmPmString(
                                                        slot),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                              //const SizedBox(height: 2),

                              /*------------- Apply PromoCode ---------------*/
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 5),
                                    child: Text(
                                      "Offer’s For You",
                                      textScaler: const TextScaler.linear(0.90),
                                      style: AppTextTheme.bold.copyWith(
                                        fontSize: 20,
                                        color: ColorConstant
                                            .blackColor, // Added missing comma
                                        fontFamily:
                                            'outfit', // Ensure this matches your pubspec.yaml name
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 1,
                                  ),
                                  if (_homeController.getServiceAddCartModel
                                          .data?.isDiscountApplied ??
                                      false)
                                    GestureDetector(
                                      onTap: () async {
                                        _homeController.doRemovePromoCode(
                                            callback: () {
                                          _homeController.doGetCart();
                                          //Commenting because of Pay after service
                                          // No need to creating razorpay order
                                          //     .whenComplete(() {
                                          //   _homeController.doGetOrderId();
                                          // });
                                        });
                                      },
                                      child: SizedBox(
                                          height: 44,
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.only(
                                                left: 10, right: 2),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF8454E5), // 🔥 left
                                                  Color(0xFFCD73B4), // 🔥 right
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              color: ColorConstant.whiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color:
                                                    ColorConstant.primaryColor,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                    child: Row(
                                                  children: [
                                                    Image.asset(
                                                      AssetsConstant.offerIcon,
                                                      // color: changeTheme(SharedPrefs
                                                      //     .readStringValue(
                                                      //     PrefConstants
                                                      //         .gender)) ??
                                                      //     ColorConstant.whiteColor,
                                                      color: Colors.white,
                                                      width: 25,
                                                      height: 25,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      "${_homeController.getServiceAddCartModel.data?.discountDetails?.code ?? ""} applied",
                                                      style: AppTextTheme.medium
                                                          .copyWith(
                                                        fontFamily:
                                                            "Outfit", // ✅ Figma font
                                                        fontWeight: FontWeight
                                                            .w600, // ✅ Medium (not bold)
                                                        fontSize: 16,
                                                        //color: const Color(0xFF000000),
                                                        color: Colors.white,
                                                        height: 1,
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        _homeController
                                                            .doRemovePromoCode(
                                                                callback: () {
                                                          _homeController
                                                              .doGetCart();
                                                          //Commenting because of Pay after service
                                                          // No need to creating razorpay order
                                                          //     .whenComplete(() {
                                                          //   _homeController
                                                          //       .doGetOrderId();
                                                          // });
                                                        });
                                                      },
                                                      child: Container(
                                                        height: 40,
                                                        width: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          //color: ColorConstant.redBgColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "Remove",
                                                            style: AppTextTheme
                                                                .medium
                                                                .copyWith(
                                                              fontFamily:
                                                                  "Outfit", // ✅ Figma font
                                                              fontWeight: FontWeight
                                                                  .w600, // ✅ Medium
                                                              fontSize:
                                                                  16, // ✅ correct size
                                                              color: ColorConstant
                                                                  .blackColor, // or theme if needed
                                                              height: 1,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                              ],
                                            ),
                                          )),
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
                                              _homeController.doGetCart();
                                              //Commenting because of Pay after service
                                              // No need to creating razorpay order
                                              //     .whenComplete(() {
                                              //   _homeController.doGetOrderId();
                                              // });
                                            });
                                      },
                                      child: Container(
                                        height: 45,
                                        width: 356, //Get.width,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF8454E5), // 🔥 left
                                              Color(0xFFCD73B4), // 🔥 right
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          //color: ColorConstant.whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          // border: Border.all(
                                          //   color: ColorConstant.primaryColor,
                                          // ),
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
                                                  color: Colors.white,
                                                  // color: changeTheme(SharedPrefs
                                                  //     .readStringValue(
                                                  //     PrefConstants
                                                  //         .gender)) ??
                                                  //     ColorConstant.primaryColor,
                                                  height: 25,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  "Tap to Save More",
                                                  style: AppTextTheme.bold
                                                      .copyWith(
                                                    fontFamily:
                                                        "Outfit", // ✅ Figma font
                                                    fontWeight: FontWeight
                                                        .w600, // ✅ SemiBold
                                                    fontSize:
                                                        16, // ✅ exact size
                                                    //color: const Color(0xFF000000), // ✅ pure black
                                                    color: Colors.white,
                                                    height:
                                                        1, // ✅ tight line height (since H = 11)
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                              size: 20,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              /*------------ Know What You are paying For ------------*/
                              Container(
                                width: Get.width,
                                color: ColorConstant.whiteColor,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        /// LEFT → TITLE
                                        Text(
                                          "Your Cart",
                                          style: AppTextTheme.bold.copyWith(
                                            fontSize: 20,
                                            color: ColorConstant.blackColor,
                                            fontFamily: 'Outfit',
                                          ),
                                        ),

                                        /// RIGHT → EDIT STYLIST BUTTON
                                        GestureDetector(
                                          // onTap: () {
                                          //   selectedArtistIdsGlobal.value = []; // 🔥 reset selection
                                          //   _homeController.doGetArtiestListData();
                                          //   Navigator.of(context).maybePop(); // 👈 go back to stylist selection
                                          // },
                                          onTap: () {
                                            //selectedArtistIdsGlobal.value = [];

                                            /// 🔥 CLOSE BOTH SCREENS
                                            Navigator.of(context)
                                                .maybePop(); // appointment
                                            Navigator.of(context)
                                                .maybePop(); // bottom sheet

                                            /// 🔥 REOPEN FRESH BOTTOM SHEET
                                            Get.bottomSheet(
                                              SelectingArtistBottomSheetWidget(
                                                serviceId: _homeController
                                                        .getServiceAddCartModel
                                                        .data
                                                        ?.salonId ??
                                                    "",
                                                salonId: _homeController
                                                        .getServiceAddCartModel
                                                        .data
                                                        ?.salonId ??
                                                    "",
                                                callback: () {},
                                              ),
                                              isScrollControlled: true,
                                            );
                                          },
                                          child: Container(
                                            height: 30,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: changeTheme(
                                                      SharedPrefs
                                                          .readStringValue(
                                                              PrefConstants
                                                                  .gender),
                                                    ) ??
                                                    const Color(0xFF8565D0),
                                                width: 1.5, // Figma color
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Edit Stylist",
                                                style: TextStyle(
                                                  fontFamily: "Outfit",
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: changeTheme(
                                                        SharedPrefs
                                                            .readStringValue(
                                                                PrefConstants
                                                                    .gender),
                                                      ) ??
                                                      const Color(0xFF8565D0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    // Dash(
                                    //   direction: Axis.horizontal,
                                    //   length: Get.width * 0.88,
                                    //   dashLength: 2,
                                    //   dashColor: const Color(0xffCFCFCF),
                                    // ),
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
                                            serviceId: _homeController
                                                    .getServiceAddCartModel
                                                    .data
                                                    ?.servicesWithProduct?[
                                                        index]
                                                    .serviceId ??
                                                "",
                                            editProduct: () {
                                              showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(32),
                                                    topRight:
                                                        Radius.circular(32),
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
                                                    // _homeController
                                                    //     .doGetPopularServiceByYourStylist(
                                                    //     stylistId:
                                                    //     widget.artistIds.first);
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
                                                    _homeController.doGetCart();
                                                    _homeController
                                                        .doGetSalonCart(
                                                      salonId: _homeController
                                                              .getServiceAddCartModel
                                                              .data
                                                              ?.salonId ??
                                                          "",
                                                      callback: () {
                                                        final items =
                                                            _homeController
                                                                .getServiceAddCartModel
                                                                .data
                                                                ?.items;

                                                        if (items == null ||
                                                            items.isEmpty) {
                                                          stylistId.value = "";
                                                          stylistId
                                                              .notifyListeners();

                                                          //print('going back to salon page');
                                                          Get.back();
                                                        }
                                                      },
                                                    );
                                                    //Commenting because of Pay after service
                                                    // No need to creating razorpay order
                                                    //     .whenComplete(() {
                                                    //   _homeController
                                                    //       .doGetOrderId();
                                                    // });
                                                    // if (_homeController
                                                    //     .getServiceAddCartModel
                                                    //     .data
                                                    //     ?.items ==
                                                    //     null) {
                                                    //   stylistId.value = "";
                                                    //   stylistId.notifyListeners();
                                                    //   print('!!!!!!!!!!!!!!!!!!!!!!!');
                                                    //   print('going back to salon page');
                                                    //   Navigator.of(context).maybePop();
                                                    //   Navigator.of(context).maybePop();
                                                    // }
                                                  });
                                            },
                                            addBtn: () {
                                              _homeController.doAddCart(
                                                salonServiceId: _homeController
                                                        .getServiceAddCartModel
                                                        .data
                                                        ?.servicesWithProduct?[
                                                            index]
                                                        .serviceId ??
                                                    "",
                                                isHomeService:
                                                    false, // 👈 as you said
                                                callback: () {
                                                  _homeController
                                                      .doGetSalonDetailsService(
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
                                                        "",
                                                  );

                                                  _homeController.doGetCart();
                                                  _homeController
                                                      .doGetSalonCart(
                                                    salonId: _homeController
                                                            .getServiceAddCartModel
                                                            .data
                                                            ?.salonId ??
                                                        "",
                                                  );
                                                },
                                              );
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
              Positioned(
                bottom: 80,
                left:
                    MediaQuery.of(context).size.width / 2 - 50, // 👈 CENTER FIX
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      selectedArtistIdsGlobal.value = [];
                      //Get.offAll(() => HomePage());
                      // Get.until((route) => Get.previousRoute == "");

                      // Future.delayed(const Duration(milliseconds: 100), () {
                      //   Get.to(() => SaloonAfterSelectingServicesPage(
                      //     id: _homeController.getServiceAddCartModel.data?.salonId ?? "",
                      //     callback: () {
                      //       _homeController.doGetCart();
                      //       Navigator.of(context).maybePop();
                      //       Navigator.of(context).maybePop();
                      //     },
                      //   ));
                      // });

                      Navigator.of(context).maybePop();
                      Navigator.of(context).maybePop();

                      // Mark that user has visited a salon
                      await _markSalonVisited();

                      Get.to(() => SaloonAfterSelectingServicesPage(
                            id: _homeController
                                    .getServiceAddCartModel.data?.salonId ??
                                "",
                            callback: () {
                              _homeController.doGetCart();
                            },
                          ));
                    },
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF01AB4D),
                          width: 1.5,
                        ),
                        color: const Color(0x1401AB4D),
                      ),
                      child: const Center(
                        child: Text(
                          "Add More",
                          style: TextStyle(
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF01AB4D),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ]),
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
                      height: 65,
                      decoration: const BoxDecoration(
                        color: ColorConstant.whiteColor,
                        borderRadius: BorderRadius.only(
                          topLeft:
                              Radius.circular(15), // 👈 adjust value if needed
                          topRight: Radius.circular(15),
                        ),
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
                          GestureDetector(
                            onTap: _showPriceBreakdownSheet,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Approx Payable",
                                      style: AppTextTheme.medium.copyWith(
                                        fontFamily: "Outfit", // ✅ Outfit font
                                        fontWeight: FontWeight
                                            .w600, // ✅ Medium (closest match)
                                        fontSize: 13,
                                        color: ColorConstant.grayTextColor,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(children: [
                                  Text(
                                    "₹${_homeController.getTotalPrice().toStringAsFixed(2)}",
                                    style: AppTextTheme.bold.copyWith(
                                      fontFamily: "Outfit", // ✅ Figma font
                                      fontWeight: FontWeight.w800, // ✅ Bold
                                      fontSize: 19, // ✅ correct size
                                      color: const Color(0xFF000000),
                                      height: 1,
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
                                ]),
                                const SizedBox(height: 2),
                                Text(
                                  "View Breakdown",
                                  style: AppTextTheme.medium.copyWith(
                                    fontFamily: "Outfit", // ✅ Figma font
                                    fontWeight: FontWeight
                                        .w500, // ✅ Medium (not regular)
                                    fontSize: 12,
                                    color: const Color(0xFF000000),
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // _payAndBook();
                              //_showBookingOptionsBottomSheet(context);
                              _showPaymentInfoDialog(context);
                            },
                            child: Container(
                                height: 50,
                                width: 140, //Get.width * 0.40,
                                //padding: Padding(padding: padding),
                                decoration: BoxDecoration(
                                  color: changeTheme(
                                          SharedPrefs.readStringValue(
                                              PrefConstants.gender)) ??
                                      ColorConstant.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Book &\n",
                                            style: AppTextTheme.bold.copyWith(
                                              // or directly TextStyle if needed
                                              fontFamily: "Outfit",
                                              fontWeight: FontWeight
                                                  .w800, // 🔥 ExtraBold
                                              fontSize: 15,
                                              color: ColorConstant.whiteColor,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "Pay After Service",
                                            style: AppTextTheme.bold.copyWith(
                                              fontFamily: "Outfit",
                                              fontWeight: FontWeight
                                                  .w800, // 🔥 ExtraBold
                                              fontSize: 15,
                                              color: ColorConstant.whiteColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // const SizedBox(width: 5),
                                    // const Icon(
                                    //   Icons.arrow_forward,
                                    //   color: ColorConstant.whiteColor,
                                    //   size: 20,
                                    // )
                                  ],
                                )),
                          )
                        ],
                      ),
                    ),
        ),
      ),
    ));
  }

  List<String> generateTimeSlots() {
    List<String> slots = [];

    DateTime now = DateTime.now();

    // 👉 Round to next 15-minute slot
    int minute = now.minute;
    int remainder = minute % 15;

    if (remainder != 0) {
      now = now.add(Duration(minutes: 15 - remainder));
    }

    // Optional: remove seconds
    now = DateTime(now.year, now.month, now.day, now.hour, now.minute);

    DateTime end = DateTime(now.year, now.month, now.day, 21, 0); // 9 PM

    while (now.isBefore(end)) {
      slots.add(DateFormat("HH:mm").format(now));
      now = now.add(const Duration(minutes: 15));
    }

    return slots;
  }

  void _showPriceBreakdownSheet() {
    final data = _homeController.getServiceAddCartModel.data;
    final double total = _homeController.getTotalPrice();

    /// ORIGINAL service total
    final double original = (data?.totalPrice ?? 0).toDouble();

    /// DISCOUNT applied
    final double discount = (data?.discountAmount ?? 0).toDouble();

    /// GST amount from cart (omitted from totals/UI when salon is not GST-registered).
    final double gst = (data?.cartTaxDetails?.totalTaxAmount ?? 0).toDouble();

    // /// FINAL PAYABLE
    // final double total =
    // (data?.price ?? 0).toDouble();

    final double platformFee = (data?.platformFee ?? 0).toDouble();
    final bool gstRegistered = _homeController.isCartSalonGstRegistered;

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
                style: AppTextTheme.bold.copyWith(
                  fontFamily: "Outfit", // ✅ Figma font
                  fontWeight: FontWeight.w600, // ✅ SemiBold (not full bold)
                  fontSize: 16,
                  color: const Color(0xFF000000),
                  height: 1,
                ),
              ),

              const SizedBox(height: 16),

              /// ORIGINAL PRICE
              _priceRow("If Original Price is", original),

              if (gstRegistered)
                GestureDetector(
                  onTap: _showChargesPopup,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _priceRow("GST & Other Charges", gst + platformFee),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 150,
                        child: Row(
                          children: List.generate(
                            30,
                            (_) => Expanded(
                              child: Container(
                                height: 1,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                _priceRow("Platform Fee", platformFee),

              /// DISCOUNT
              if (discount > 0)
                _priceRow("Discount", discount, isDiscount: true),

              const Divider(height: 24),

              /// FINAL TOTAL
              _priceRow("Approx Payable", total, isBold: true),
            ],
          ),
        );
      },
    );
  }

  void _showChargesPopup() {
    final data = _homeController.getServiceAddCartModel.data;

    final double gst = (data?.cartTaxDetails?.totalTaxAmount ?? 0).toDouble();

    final double platformFee =
        data?.platformFee ?? 0; // replace when backend sends
    final bool gstRegistered = _homeController.isCartSalonGstRegistered;

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
                      if (gstRegistered) ...[
                        _priceRow("GST (5%)", gst),
                        const SizedBox(height: 6),
                      ],
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
              fontFamily: "Outfit", // ✅ added
              fontWeight: isBold
                  ? FontWeight.w600 // ✅ SemiBold (total row)
                  : FontWeight.w500, // ✅ Medium (normal rows)
              fontSize: 13, // ✅ consistent
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
              fontFamily: "Outfit", // ✅ added
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
              color: isDiscount
                  ? Colors.green
                  : (isBold ? Colors.black : ColorConstant.blackColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentInfoDialog(BuildContext context) {
    final themeColor = changeTheme(
          SharedPrefs.readStringValue(PrefConstants.gender),
        ) ??
        ColorConstant.primaryColor;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // 🔥 IMPORTANT
                children: [
                  /// 🔥 TITLE (only this is centered)
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 26,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "How It Works",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 STEPS (LEFT ALIGNED)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "1. ",
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Book Your Appointment in the App",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            //height: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "2. ",
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Visit the Salon and Get Your Services Done",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            //height: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "3. ",
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Enter the Bill Amount in the App and Pay the Discounted Price in the App",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            //height: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 SECTION TITLE (LEFT — FIXED)
                  Center(
                      child: Text(
                    "Things To Keep In Mind",
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  )),

                  const SizedBox(height: 12),

                  /// 🔥 BULLETS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("• "),
                      Expanded(
                        child: Text(
                          "You can make changes (Add / Delete) to your services at the salon",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• "),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              color: Colors.black,
                            ),
                            children: [
                              const TextSpan(
                                text: "Discount can be availed only if you ",
                              ),
                              TextSpan(
                                text: "Pay in App",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: themeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("• "),
                      Expanded(
                        child: Text(
                          "Prices may vary based on the length, density or thickness of the hair in some services",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 BUTTON
                  Center(
                      child: SizedBox(
                    width: 227, //double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _bookPayAfterService();
                      },
                      child: const Text(
                        textAlign: TextAlign.center,
                        "Proceed To Book",
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),

            /// 🔥 CLOSE BUTTON
            Positioned(
              top: 90,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, size: 24),
                ),
              ),
            ),
          ],
        );
      },
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
                style: AppTextTheme.bold
                    .copyWith(fontSize: 18, color: Colors.black),
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
                    side: BorderSide(
                        color: changeTheme(SharedPrefs.readStringValue(
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
                                  SharedPrefs.readStringValue(
                                      PrefConstants.gender),
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
  //       salonArtistId: widget.artistIds.first,
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
    final slots = _homeController.getAvailabilitiesTimeSlotModelData.data;

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
      salonArtistId: widget.artistIds.first,
      startAt: isoDateTime,
    );

    // ✅ 6. Razorpay options
    var options = {
      'key': _homeController.getOrderIdModel.data?.razorpayKey ?? "",
      'amount': (_homeController.getServiceAddCartModel.data?.price ?? 0) * 100,
      'name': 'ScutS',
      'timeout': 120,
      'order_id': _homeController.getOrderIdModel.data?.orderId ?? "",
      'description': 'Booking Appointment',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact':
            _authController.userResponseModel.data?.userData?.mobile ?? "",
        'email': _authController.userResponseModel.data?.userData?.email ?? "",
      },
      'external': {}
    };

    // ✅ 7. Razorpay listeners
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);

    // ✅ 8. Home service validation
    if (SharedPrefs.readBoolValue(PrefConstants.isHomeService)) {
      if (userServiceAddressIdSelect.isEmpty) {
        Get.to(() => const AddAddressPage(isSelect: true));
        return;
      }
    }

    // ✅ 9. Open Razorpay
    log("Opening Razorpay for booking");

    // 📊 begin_checkout
    AnalyticsService.instance.logBeginCheckout(
      eventId: _homeController.getOrderIdModel.data?.orderId ?? '',
      value:
          (_homeController.getServiceAddCartModel.data?.price ?? 0).toDouble(),
      numberOfServices:
          _homeController.getServiceAddCartModel.data?.items?.length ?? 0,
      stylistSelected: selectedArtistIdsGlobal.value.isNotEmpty,
      slotSelected: selectedSlots.isNotEmpty,
      salonId: _homeController.getServiceAddCartModel.data?.salonId ?? '',
    );

    razorpay.open(options);
  }

  // Future<void> _bookPayAfterService() async {
  //   // ✅ 1. Cart validation
  //   if (_homeController.getServiceAddCartModel.data?.items?.isEmpty ?? true) {
  //     showMessage("Cart Service Not Found");
  //     return;
  //   }
  //
  //   // ✅ 2. Slot validation — MUST be before selectTime logic
  //   final slots = _homeController
  //       .getAvailabilitiesTimeSlotModelData
  //       .data;
  //
  //   if (slots == null || slots.isEmpty) {
  //     showMessage(
  //       "No slots available for today.\nPlease select a future date.",
  //     );
  //     return; // 👈 VERY IMPORTANT
  //   }
  //
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
  //
  //   final cartItems = _homeController.getServiceAddCartModel.data?.items ?? [];
  //
  //   Map<String, String> serviceArtistMap = {};
  //   print(cartItems);
  //   print('**********************');
  //
  //
  //   int artistIndex = 0;
  //
  //   for (var item in cartItems) {
  //     print(item.isService);
  //     print(item.service?.name ?? "");
  //
  //     if (item.isService == true) {
  //       final serviceId = item.service?.id ?? "";
  //
  //       if (widget.artistIds.isNotEmpty && serviceId.isNotEmpty) {
  //         serviceArtistMap[serviceId] =
  //         widget.artistIds[artistIndex % widget.artistIds.length];
  //
  //         artistIndex++; // move to next artist
  //       }
  //     }
  //   }
  //
  //   print(serviceArtistMap);
  //   _homeController.doCreateBooking(
  //       userAddressId: "",
  //       isHomeService:
  //       _homeController.getServiceAddCartModel.data?.isHomeService ??
  //           false,
  //       salonArtistId: widget.artistIds.first,
  //       serviceArtistMap: Map<String, String>.from(serviceArtistMap),
  //       startAt: isoDateTime,
  //       callback: ()
  //       {
  //         stylistId.value = "";
  //         stylistId.notifyListeners();
  //         _navigateAfterBooking();
  //       }
  //   );
  // }

  Future<void> _bookPayAfterService() async {
    // ✅ 1. Cart validation
    if (_homeController.getServiceAddCartModel.data?.items?.isEmpty ?? true) {
      showMessage("Cart Service Not Found");
      return;
    }

    // ✅ 2. Slot validation (NEW SYSTEM)
    if (selectedSlots.isEmpty) {
      showMessage("Please select at least one time slot");
      return;
    }

    // ✅ 3. Attach date to slots (IMPORTANT)
    List<String> finalSlots = selectedSlots.map((slot) {
      final dt = DateTime.parse("$selectDate $slot");
      return dt.toIso8601String();
    }).toList();

    // ✅ 4. Create booking (NEW PAYLOAD)
    _homeController.doCreateBooking(
      stylistIds: selectedArtistIdsGlobal.value, // 👈 ALL selected stylists
      selectedSlots: finalSlots, // 👈 date + time slots
      isHomeService:
          _homeController.getServiceAddCartModel.data?.isHomeService ?? false,
      userAddressId: "",
      callback: () {
        stylistId.value = "";
        stylistId.notifyListeners();
        _navigateAfterBooking();
      },
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
        return CallWrapper(
          // ✅ adds your Help 24×7 call button
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              "Payment Failed",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              // ✅ ensures content never overflows
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(); // ✅ close dialog
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
  Future<void> handlePaymentSuccessResponse(
      PaymentSuccessResponse response) async {
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

    // 📊 purchase — fires on confirmed booking
    try {
      final bookingData = _homeController.getCreateBookingAppointmentModel.data;
      final cartData = _homeController.getServiceAddCartModel.data;
      final serviceNames = cartData?.items
              ?.where((i) => i.isService == true)
              .map((i) => i.service?.name ?? '')
              .toList() ??
          [];
      AnalyticsService.instance.logPurchase(
        bookingId: bookingData?.idx ?? bookingData?.id ?? '',
        value: (bookingData?.orderAmount ?? 0).toDouble(),
        salonId: bookingData?.salonId ?? '',
        serviceNames: serviceNames,
        stylistId: selectedArtistIdsGlobal.value.isNotEmpty
            ? selectedArtistIdsGlobal.value.first
            : '',
        slotTime: selectedSlots.isNotEmpty ? selectedSlots.first : '',
      );
    } catch (_) {}

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
    //           salonArtistId: widget.artistIds.first,
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
    //         salonArtistId: widget.artistIds.first,
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
    //         salonArtistId: widget.artistIds.first,
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
    //         salonArtistId: widget.artistIds.first,
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
  InkWell _timeSlotContainerWidget({
    required String timeSlot,
    required bool isSelected,
    required VoidCallback onPress,
  }) {
    return InkWell(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? changeTheme(
                  SharedPrefs.readStringValue(PrefConstants.gender),
                )
              : Colors.black12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            timeSlot,
            style: AppTextTheme.bold.copyWith(
              fontFamily: "Outfit", // ✅ Figma font
              fontWeight: FontWeight.w600, // ✅ SemiBold
              fontSize: 14, // ✅ correct size
              color: isSelected ? Colors.white : const Color(0xFF000000),
              height: 1,
            ),
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
        // String finalDate =
        //     "$year-${result.length == 1 ? '0$result' : result}-01";
        final now = DateTime.now();

        final selectedMonth = int.parse(result);
        final selectedYear = now.year;

        DateTime newDate;

        if (selectedMonth == now.month && selectedYear == now.year) {
          /// ✅ CURRENT MONTH → go to TODAY
          newDate = now;
        } else {
          /// ✅ OTHER MONTH → go to 1st
          newDate = DateTime(selectedYear, selectedMonth, 1);
        }

        String finalDate = DateFormat("yyyy-MM-dd").format(newDate);

        // Update selectDate to the first day of the new month
        setState(() {
          selectDate = finalDate;
        });

        // _homeController.doGetUnAvailableDatesListData(
        //   artiestId: widget.artistIds.first,
        //   date: finalDate,
        //   callback: () {
        //     // _homeController.doGetAvailabilitiesTimeSlot(
        //     //   artiestId: widget.artistIds.first,
        //     //   date: finalDate,
        //     // );
        //   },
        // );
      },
      initialDate:
          selectDate == "" ? DateTime.now() : DateTime.parse(selectDate),
      // initialDate: selectDate.isEmpty
      //     ? DateTime.now()
      //     : DateTime.parse(selectDate).subtract(const Duration(days: 3)),
      onDateChange: (selectedDate) {
        //`selectedDate` the new date selected.
        selectDate = "";
        String formatDate = DateFormat("yyyy-MM-dd").format(selectedDate);
        selectDate = formatDate;
        // final formatDate = DateFormat("yyyy-MM-dd").format(selectedDate);
        //
        // setState(() {
        //   selectDate = formatDate;
        // });
        // _homeController.doGetAvailabilitiesTimeSlot(
        //   artiestId: widget.artistIds.first,
        //   date: formatDate,
        // );
        /// 🔥 ADD THIS (CENTER FIX)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final index = selectedDate.day - 1; // 🔥 key logic
          _scrollToCenter(index);
        });
      },
      // headerProps: const EasyHeaderProps(
      //     showSelectedDate: true,
      //     monthPickerType: MonthPickerType.switcher,
      //     dateFormatter: DateFormatter.dayOnly()),
      headerProps: EasyHeaderProps(
        showSelectedDate: true,
        monthPickerType: MonthPickerType.switcher,
        // ✅ THIS FIXES ALIGNMENT
        //padding: const EdgeInsets.symmetric(horizontal: 0),

        /// 🔥 Force proper layout
        //centerAlign: false, // 👈 IMPORTANT

        /// 🔥 STYLE FOR "Saturday"
        selectedDateStyle: TextStyle(
          fontFamily: "Outfit",
          fontSize: 20,
          fontWeight: FontWeight.w700, // bold
          color: Colors.black,
        ),

        /// 🔥 STYLE FOR "Mar"
        monthStyle: TextStyle(
          fontFamily: "Outfit",
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),

        dateFormatter: DateFormatter.dayOnly(),
      ),
      disabledDates: dateTimeList,
      dayProps: EasyDayProps(
        height: 58,
        width: 56,
        dayStructure: DayStructure.dayStrDayNum,

        /// ✅ SELECTED DAY (Purple box)
        activeDayStyle: DayStyle(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
                Radius.circular(5)), // 🔥 slightly bigger like Figma
            color: changeTheme(
                  SharedPrefs.readStringValue(PrefConstants.gender),
                ) ??
                ColorConstant.primaryColor,
          ),
          dayNumStyle: const TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w700, // ✅ Bold
            fontSize: 22,
            color: Colors.white,
          ),
          dayStrStyle: const TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w400, // ✅ Regular
            fontSize: 14,
            color: Colors.white,
          ),
        ),

        /// ❌ UNSELECTED DAY (Grey box)
        inactiveDayStyle: DayStyle(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            color:
                Colors.black.withOpacity(0.05), // 🔥 softer grey (Figma-like)
          ),
          dayNumStyle: const TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w700, // ✅ Bold
            fontSize: 20,
            color: Colors.black,
          ),
          dayStrStyle: TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w400, // ✅ Regular
            fontSize: 13,
            color: Colors.black.withOpacity(0.6), // ✅ subtle fade
          ),
        ),

        /// 🔒 DISABLED DAYS (optional but better UX)
        disabledDayStyle: DayStyle(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            color: Colors.grey.shade200,
          ),
          dayNumStyle: TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.grey.shade400,
          ),
          dayStrStyle: TextStyle(
            fontFamily: "Outfit",
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  DateTime currentMonth = DateTime.now();
  Widget _customDateTimeline() {
    final today = DateTime.now();
    // final today = DateTime(
    //   currentMonth.year,
    //   currentMonth.month,
    //   DateTime.now().day,
    // );

    final List<DateTime> dates = List.generate(
      30,
      (index) => today.add(Duration(days: index)),
    );

    /// 🔥 unavailable dates (same logic)
    final unavailableDates =
        (_homeController.getUnAvailableDatesListData.data?.unavailableDates ??
                [])
            .map((e) =>
                DateFormat("yyyy-MM-dd").format(DateTime.parse(e.date ?? "")))
            .toSet();

    final selected =
        selectDate.isEmpty ? DateTime.now() : DateTime.parse(selectDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// 🔥 LEFT → DAY
            Text(
              DateFormat("EEEE").format(selected),
              style: const TextStyle(
                fontFamily: "Outfit",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            /// 🔥 RIGHT → MONTH (AUTO)
            Padding(
              padding: const EdgeInsets.only(
                  right: 8.0), // adjust 8 → 12/16 if needed
              child: Text(
                DateFormat("MMM").format(currentMonth),
                style: const TextStyle(
                  fontFamily: "Outfit",
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 15),

        /// 🔥 TIMELINE (EXACT UI)
        SizedBox(
          height: 58,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final formatted = DateFormat("yyyy-MM-dd").format(date);

              final isSelected = formatted == selectDate;
              final isDisabled = unavailableDates.contains(formatted);

              return GestureDetector(
                onTap: isDisabled
                    ? null
                    : () {
                        setState(() {
                          selectDate = formatted;
                          currentMonth = date;
                        });

                        // _homeController.doGetAvailabilitiesTimeSlot(
                        //   artiestId: widget.artistIds.first,
                        //   date: formatted,
                        // );

                        _scrollToCenter(index);
                      },
                child: Container(
                  width: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      isSelected ? 5 : 12,
                    ),
                    color: isDisabled
                        ? Colors.grey.shade200
                        : isSelected
                            ? changeTheme(
                                  SharedPrefs.readStringValue(
                                      PrefConstants.gender),
                                ) ??
                                ColorConstant.primaryColor
                            : Colors.black.withOpacity(0.05),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// 🔥 DAY STRING (EXACT STYLE)
                      Text(
                        DateFormat("EEE").format(date),
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w400,
                          fontSize: isDisabled ? 12 : 13,
                          color: isDisabled
                              ? Colors.grey.shade400
                              : isSelected
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.6),
                        ),
                      ),

                      /// 🔥 DATE NUMBER (EXACT STYLE)
                      Text(
                        DateFormat("d").format(date),
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontWeight:
                              isDisabled ? FontWeight.w600 : FontWeight.w700,
                          fontSize: isSelected ? 22 : (isDisabled ? 18 : 20),
                          color: isDisabled
                              ? Colors.grey.shade400
                              : isSelected
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onMonthChange(DateTime val) {
    currentMonth = val;

    /// 🔥 EXACT SAME LOGIC AS YOUR OLD CODE
    String month = val.month.toString().padLeft(2, '0');
    String year = val.year.toString();

    String finalDate = "$year-$month-01";

    setState(() {
      selectDate = finalDate;
    });

    // _homeController.doGetUnAvailableDatesListData(
    //   artiestId: widget.artistIds.first,
    //   date: finalDate,
    //   callback: () {
    //     // _homeController.doGetAvailabilitiesTimeSlot(
    //     //   artiestId: widget.artistIds.first,
    //     //   date: finalDate,
    //     // );
    //   },
    // );

    /// 🔥 CENTER FIRST DAY
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCenter(0);
    });
  }

  void _scrollToCenter(int index) {
    final itemWidth = 72.0; // width + margin
    final screenWidth = MediaQuery.of(context).size.width;

    final offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    _scrollController.animateTo(
      offset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
        _authController.getAppUpdateModel.data?.personOfTheYear?.enabled ??
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
    } else {
      Get.to(() => YourApprovalPage(
            salonAppointmentId: booking?.salonAppointmentId ?? "",
          ));
    }
  }
}
