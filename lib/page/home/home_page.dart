import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/home/review_screen.dart';
import 'package:salon_customer/page/home/saloon_after_selecting_page.dart';
import 'package:salon_customer/page/home/widget/menu_dialog_widget.dart';
import 'package:salon_customer/page/home/widget/saloon_card_widget.dart';
import 'package:salon_customer/page/location/google_map.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/status_bar_color_appbar.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:salon_customer/util/app_icon_helper.dart';
import '../../constant/variable_constant.dart';
import '../../util/call_wrapper.dart';
import '../../util/logger.dart';
import '../appointment/widget/pending_payment_bar.dart';
import '../profile/profile_page.dart';
import '../search/search_for_salon_or_service_page.dart';
import 'offer_animated_text_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  static const homeListKey = PageStorageKey<String>('home_main_list');
  /*-------------------  Controller ----------------------*/

  final _authController = Get.find<AuthController>();
  final _homeController = Get.find<HomeController>();
  final PageController _offerPageController =
      PageController(viewportFraction: 1.0);
  Timer? _offerAutoScrollTimer;
  int _currentOfferPage = 0;

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    Future.delayed(
      Duration.zero,
      () async {
        final bookingDate =
            await _homeController.fetchLatestCompletedBookingDate();
        await AppIconHelper.updateCustomerAppIcon(bookingDate);
      },
    );
    super.initState();
    print("🧠 CHECK DIALOG");
    print(
        "hasVisitedSalon: ${SharedPrefs.readBoolValue(PrefConstants.hasVisitedSalon)}");
    print(
        "hasShownSalonDialog: ${SharedPrefs.readBoolValue(PrefConstants.hasShownSalonDialog)}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startOfferAutoScroll();
    });

    // if (!kDebugMode) {
    //   getCurrentLatLng();
    // }
    getCurrentLatLng();
    ever(_homeController.hasPendingReview, (value) async {
      if (value == true) {
        /// 🔥 WAIT FOR BOOKING HISTORY
        await _homeController.doGetBookingHistory();

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withOpacity(0.6),
          builder: (context) {
            return ReviewScreen(
              appointmentId: _homeController.pendingReviewBookingId.value,
              salonId: _homeController.pendingReviewsalonId.value,
            );
          },
        );
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final genderPref = SharedPrefs.readStringValue(PrefConstants.gender);
        selectedGender.value = (genderPref == "1") ? 1 : 0;

        // Row 23: default the home gender to the customer's own gender,
        // unless they've already picked a gender manually.
        if (!SharedPrefs.readBoolValue(PrefConstants.isSelectedGender)) {
          final loaded = _authController.getUserProfile.data?.gender;
          if (loaded != null && loaded.isNotEmpty) {
            _applyProfileGenderDefault(loaded);
          } else {
            _authController.doGetProfile(callback: () {
              _applyProfileGenderDefault(
                  _authController.getUserProfile.data?.gender);
            });
          }
        }
      });
      //_homeController.getLastMakeYourOwnPackageModel.data = [];
    });
    //_homeController.getLastMakeYourOwnPackageModel.data = [];
  }

  void _startOfferAutoScroll() {
    _offerAutoScrollTimer?.cancel();

    _offerAutoScrollTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      final data = _homeController.getPromoCodeModel.data;

      if (data == null || data.isEmpty) return;
      if (!_offerPageController.hasClients) return;

      _currentOfferPage++;

      if (_currentOfferPage >= data.length) {
        _currentOfferPage = 0;
      }

      _offerPageController.animateToPage(
        _currentOfferPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _offerAutoScrollTimer?.cancel();
    _offerPageController.dispose();
    // _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CallWrapper(
        child: WillPopScope(
            onWillPop: () async {
              if (_shouldShowSalonDialog()) {
                _showExitDialog(context);
                return false;
              } else {
                SystemNavigator.pop();
                return false;
              }
            },
            child: Scaffold(
              appBar: statusBarTheme(context),
              backgroundColor: ColorConstant.whiteColor,
              // body: Obx(() {
              //   return Stack(
              //     children: [
              //       /// 🔹 NORMAL HOME UI
              //       _homeController.showProgress
              //           ? const ProgressBarView()
              //           // : ListView(
              //           //     key: _HomePageState.homeListKey,
              //           //     shrinkWrap: true,
              //           //     children: [
              //           //       _headerWidget(),
              //           //       //const SizedBox(height: 10),
              //           //       _searchWidget(),
              //           //
              //           //       //const SizedBox(height: 10),
              //           //       _ourService(),
              //           //       const SizedBox(height: 5),
              //           //       _offer(),
              //           //       const SizedBox(height: 15),
              //           //       _saloonsFoundNear(),
              //           //       _homeController.getHomeSalonList.data?.rows
              //           //                   ?.isEmpty ??
              //           //               false
              //           //           ? const NoItemsWidget(
              //           //               text: "No salons were found.")
              //           //           : ListView.builder(
              //           //               padding: EdgeInsets.zero,
              //           //               physics:
              //           //                   const NeverScrollableScrollPhysics(),
              //           //               itemCount: _homeController
              //           //                       .getHomeSalonList
              //           //                       .data
              //           //                       ?.rows
              //           //                       ?.length ??
              //           //                   0,
              //           //               shrinkWrap: true,
              //           //               itemBuilder: (context, index) {
              //           //                 return SaloonCardWidget(
              //           //                   homeSalonModel: _homeController
              //           //                       .getHomeSalonList
              //           //                       .data!
              //           //                       .rows![index],
              //           //                   onPress: () async {
              //           //                     // Mark that user has visited a salon
              //           //                     await _markSalonVisited();
              //           //
              //           //                     final changed = await Get.to(
              //           //                       () =>
              //           //                           SaloonAfterSelectingServicesPage(
              //           //                         id: _homeController
              //           //                                 .getHomeSalonList
              //           //                                 .data
              //           //                                 ?.rows?[index]
              //           //                                 .id ??
              //           //                             "",
              //           //                         callback: () {},
              //           //                       ),
              //           //                     );
              //           //                     /// 🔥 AFTER USER COMES BACK FROM SALON
              //           //                     print("🔙 Returned to Home from salon");
              //           //
              //           //                     if (!mounted) return;
              //           //
              //           //                     Future.microtask(() {
              //           //                       if (_shouldShowSalonDialog()) {
              //           //                         print("📢 Showing dialog after return");
              //           //                         _showExitDialog(Get.context!);
              //           //                       }
              //           //                     });
              //           //
              //           //                     if (changed == true) {
              //           //                       _homeController
              //           //                           .doGetHomeSalonList(
              //           //                         serviceGender:
              //           //                             selectedGender.value == 0
              //           //                                 ? "male"
              //           //                                 : "female",
              //           //                         homeService: atHome,
              //           //                         offset: 1,
              //           //                         size: 500,
              //           //                         lat: double.parse(
              //           //                             SharedPrefs.readStringValue(
              //           //                                 PrefConstants
              //           //                                     .latitude)),
              //           //                         lng: double.parse(
              //           //                             SharedPrefs.readStringValue(
              //           //                                 PrefConstants
              //           //                                     .longitude)),
              //           //                         orderBy: "",
              //           //                         nearest: false,
              //           //                         fourPlusRating: false,
              //           //                       );
              //           //                     }
              //           //                   },
              //           //                   isFav: false,
              //           //                 );
              //           //               },
              //           //             )
              //           //     ],
              //           //   ),
              //       : CustomScrollView(
              //         key: _HomePageState.homeListKey,
              //         cacheExtent: 500,
              //         slivers: [
              //           SliverToBoxAdapter(child: _headerWidget()),
              //           SliverToBoxAdapter(child: _searchWidget()),
              //           SliverToBoxAdapter(child: _ourService()),
              //           SliverToBoxAdapter(child: const SizedBox(height: 5)),
              //           SliverToBoxAdapter(child: _offer()),
              //           SliverToBoxAdapter(child: const SizedBox(height: 15)),
              //           SliverToBoxAdapter(child: _saloonsFoundNear()),
              //
              //           /// No salons found
              //           if (_homeController.getHomeSalonList.data?.rows?.isEmpty ?? false)
              //             const SliverToBoxAdapter(
              //               child: NoItemsWidget(text: "No salons were found."),
              //             )
              //           else
              //             SliverList(
              //               delegate: SliverChildBuilderDelegate(
              //                     (context, index) {
              //                   return SaloonCardWidget(
              //                     homeSalonModel:
              //                     _homeController.getHomeSalonList.data!.rows![index],
              //                     onPress: () async {
              //                       await _markSalonVisited();
              //
              //                       final changed = await Get.to(
              //                             () => SaloonAfterSelectingServicesPage(
              //                           id: _homeController
              //                               .getHomeSalonList.data?.rows?[index].id ??
              //                               "",
              //                           callback: () {},
              //                         ),
              //                       );
              //
              //                       print("🔙 Returned to Home from salon");
              //
              //                       if (!mounted) return;
              //
              //                       Future.microtask(() {
              //                         if (_shouldShowSalonDialog()) {
              //                           print("📢 Showing dialog after return");
              //                           _showExitDialog(Get.context!);
              //                         }
              //                       });
              //
              //                       if (changed == true) {
              //                         _homeController.doGetHomeSalonList(
              //                           serviceGender:
              //                           selectedGender.value == 0 ? "male" : "female",
              //                           homeService: atHome,
              //                           offset: 1,
              //                           size: 500,
              //                           lat: double.parse(
              //                               SharedPrefs.readStringValue(PrefConstants.latitude)),
              //                           lng: double.parse(
              //                               SharedPrefs.readStringValue(PrefConstants.longitude)),
              //                           orderBy: "",
              //                           nearest: false,
              //                           fourPlusRating: false,
              //                         );
              //                       }
              //                     },
              //                     isFav: false,
              //                   );
              //                 },
              //                 childCount:
              //                 _homeController.getHomeSalonList.data?.rows?.length ?? 0,
              //               ),
              //             ),
              //
              //           /// Bottom padding so last card clears the floating gender switch
              //           const SliverToBoxAdapter(child: SizedBox(height: 80)),
              //         ],
              //       )
              //     ],
              //   );
              // }),
              body: Stack(
                children: [
                  /// 🔥 Loader (unchanged)
                  Obx(() {
                    if (_homeController.showProgress) {
                      return const ProgressBarView();
                    }
                    return const SizedBox();
                  }),

                  /// 🔥 MAIN UI (still not fully reactive)
                  CustomScrollView(
                    key: _HomePageState.homeListKey,
                    cacheExtent: 500,
                    slivers: [
                      SliverToBoxAdapter(child: _headerWidget()),
                      SliverToBoxAdapter(child: _searchWidget()),
                      SliverToBoxAdapter(child: _ourService()),
                      SliverToBoxAdapter(child: const SizedBox(height: 5)),
                      SliverToBoxAdapter(child: _offer()),
                      SliverToBoxAdapter(child: const SizedBox(height: 15)),
                      SliverToBoxAdapter(child: _saloonsFoundNear()),

                      /// 🔥 ONLY THIS PART MADE REACTIVE
                      Obx(() {
                        final salons =
                            _homeController.getHomeSalonList.data?.rows ?? [];

                        /// Row 25 fix: while loading (or before the salon list
                        /// has loaded at all), don't show the "not here yet"
                        /// card — the loading indicator is on screen and we
                        /// don't yet know whether the area is operational.
                        final bool salonsLoaded =
                            _homeController.getHomeSalonList.data != null;
                        if (_homeController.showProgress || !salonsLoaded) {
                          return const SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        }

                        /// Row 25: non-operational area — no salon within 12 km.
                        if (!_hasSalonWithin12km()) {
                          return SliverToBoxAdapter(
                            child: _notHereYetWidget(),
                          );
                        }

                        /// Row 26 (updated) + Row 27: client-side ordering.
                        /// Nearest → by distance; Budget → starting price
                        /// low-to-high. Nearest takes precedence if both are on.
                        final orderedSalons = List.of(salons);
                        if (isNearestSelected) {
                          orderedSalons.sort((a, b) => (a.distance ?? (1 << 30))
                              .compareTo(b.distance ?? (1 << 30)));
                        } else if (_budgetLowToHigh) {
                          orderedSalons.sort((a, b) =>
                              (a.serviceStartingPrice ?? 0)
                                  .compareTo(b.serviceStartingPrice ?? 0));
                        }

                        /// Salon list
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final salon = orderedSalons[index];

                              return SaloonCardWidget(
                                homeSalonModel: salon,
                                onPress: () async {
                                  await _markSalonVisited();

                                  final changed = await Get.to(
                                    () => SaloonAfterSelectingServicesPage(
                                      isPayNowMode: true,
                                      id: salon.id ?? "",
                                      callback: () {},
                                    ),
                                  );

                                  if (!mounted) return;

                                  Future.microtask(() {
                                    if (_shouldShowSalonDialog()) {
                                      _showExitDialog(Get.context!);
                                    }
                                  });

                                  if (changed == true) {
                                    _homeController.doGetHomeSalonList(
                                      serviceGender: selectedGender.value == 0
                                          ? "male"
                                          : "female",
                                      homeService: atHome,
                                      offset: 1,
                                      size:
                                          500, // 👈 unchanged as you requested
                                      lat: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.latitude),
                                      ),
                                      lng: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.longitude),
                                      ),
                                      orderBy: "",
                                      nearest: false,
                                      fourPlusRating: false,
                                    );
                                  }
                                },
                                isFav: false,
                              );
                            },
                            childCount: orderedSalons.length,
                          ),
                        );
                      }),

                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ],
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Obx(() {
                final booking = _homeController.pendingBooking.value;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// PAY NOW BAR
                    if (booking != null &&
                        booking.paymentStatus == "pending" &&
                        booking.orderAmount > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 65),
                        child: PendingPaymentBar(
                            bookingId: booking.appointmentId,
                            salonName: booking.salon.displayName,
                            startsAt: booking.startsAt,
                            orderStatus: booking.orderStatus),
                      ),

                    /// YOUR EXISTING MEN / WOMEN SWITCH
                    Container(
                      width: Get.width * 0.58,
                      height: 50,
                      decoration: BoxDecoration(
                        color: ColorConstant.whiteColor,
                        borderRadius: BorderRadius.circular(12),
                        // Highlight border reflecting the active gender.
                        border: Border.all(
                          color: selectedGender.value == 0
                              ? ColorConstant.primaryColor
                              : ColorConstant.primary2,
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        // Inner radius = outer 12 − 1.5px border, so the filled
                        // halves round to match the border's inner edge with no
                        // corner clipping or gaps.
                        borderRadius: BorderRadius.circular(10.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// MEN BUTTON
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectGender(0),
                              child: Container(
                                height: 50,
                                // No corner radius here — the outer container's
                                // clipBehavior rounds the corners, so the fill
                                // reaches the border cleanly (no unfilled notch).
                                color: selectedGender.value == 0
                                    ? ColorConstant.primaryColor
                                    : ColorConstant.whiteColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AssetsConstant.man,
                                      height: 24,
                                      width: 24,
                                      color: selectedGender.value == 0
                                          ? ColorConstant.whiteColor
                                          : ColorConstant.grayTextColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Men",
                                      style: AppTextTheme.medium.copyWith(
                                        fontFamily: "Outfit", // ✅ added
                                        fontWeight: FontWeight
                                            .w500, // ✅ Medium (best for tabs/buttons)
                                        fontSize: 16, // ✅ consistent sizing
                                        color: selectedGender.value == 0
                                            ? ColorConstant.whiteColor
                                            : ColorConstant.grayTextColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /// WOMEN BUTTON
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectGender(1),
                              child: Container(
                                height: 50,
                                // No corner radius here — outer clipBehavior
                                // handles rounding so the fill reaches the
                                // border cleanly.
                                color: selectedGender.value == 1
                                    ? ColorConstant.primary2
                                    : ColorConstant.whiteColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AssetsConstant.woman,
                                      height: 24,
                                      width: 24,
                                      color: selectedGender.value == 1
                                          ? ColorConstant.whiteColor
                                          : ColorConstant.grayTextColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Women",
                                      style: AppTextTheme.medium.copyWith(
                                        fontFamily: "Outfit", // ✅ added
                                        fontWeight: selectedGender.value == 1
                                            ? FontWeight.w600 // 🔥 active
                                            : FontWeight.w500, // inactive
                                        fontSize: 16, // ✅ consistent
                                        color: selectedGender.value == 1
                                            ? ColorConstant.whiteColor
                                            : ColorConstant.grayTextColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),
                  ],
                );
              }),
            )));
  }

  /// Row 22: single, robust handler for the Home gender switch. Updates the
  /// selection, persists it, and refreshes ALL gender-dependent content
  /// (categories, packages, promos, salons). Lat/lng are parsed safely so a
  /// switch before location is ready can't crash the handler.
  void _selectGender(int gender) {
    setState(() {
      selectedGender.value = gender;
    });

    SharedPrefs.writeValue(PrefConstants.isSelectedGender, true);
    SharedPrefs.writeValue(PrefConstants.gender, gender == 0 ? "0" : "1");

    final serviceGender = gender == 0 ? "male" : "female";
    _homeController.doGetHomeCategory(gender: serviceGender);
    _homeController.doGetMakePackageData();

    final lat =
        double.tryParse(SharedPrefs.readStringValue(PrefConstants.latitude));
    final lng =
        double.tryParse(SharedPrefs.readStringValue(PrefConstants.longitude));
    if (lat != null && lng != null) {
      _homeController.doGetPromoCode(
        fourPlusRating: false,
        homeService: SharedPrefs.readBoolValue(PrefConstants.isHomeService),
        nearest: false,
        orderBy: "",
        serviceGender: serviceGender,
        lat: lat,
        lng: lng,
      );
      _homeController.doGetHomeSalonList(
        serviceGender: serviceGender,
        homeService: atHome,
        offset: 1,
        size: 500,
        lat: lat,
        lng: lng,
        orderBy: "",
        nearest: false,
        fourPlusRating: false,
      );
    }
  }

  /// Row 23: applies the customer's profile gender ("MALE"/"FEMALE") as the
  /// default home selection. Persists it for next launch and refreshes the
  /// gender-dependent content only when the selection actually changes.
  void _applyProfileGenderDefault(String? rawGender) {
    if (!mounted) return;

    final g = (rawGender ?? "").toUpperCase();
    final int target;
    if (g == "FEMALE") {
      target = 1;
    } else if (g == "MALE") {
      target = 0;
    } else {
      return; // Unknown gender → keep the existing default.
    }

    // Persist so subsequent launches start on the correct gender.
    SharedPrefs.writeValue(PrefConstants.gender, target == 1 ? "1" : "0");

    // Already showing the right gender → nothing else to do.
    if (selectedGender.value == target) return;

    setState(() {
      selectedGender.value = target;
    });
    final serviceGender = target == 0 ? "male" : "female";

    _homeController.doGetHomeCategory(gender: serviceGender);

    final lat =
        double.tryParse(SharedPrefs.readStringValue(PrefConstants.latitude));
    final lng =
        double.tryParse(SharedPrefs.readStringValue(PrefConstants.longitude));
    if (lat != null && lng != null) {
      _homeController.doGetPromoCode(
        fourPlusRating: false,
        homeService: SharedPrefs.readBoolValue(PrefConstants.isHomeService),
        nearest: false,
        orderBy: "",
        serviceGender: serviceGender,
        lat: lat,
        lng: lng,
      );
      _homeController.doGetHomeSalonList(
        serviceGender: serviceGender,
        homeService: atHome,
        offset: 1,
        size: 500,
        lat: lat,
        lng: lng,
        orderBy: "",
        nearest: false,
        fourPlusRating: false,
      );
    }
  }

  void sortSalonsByDiscount() {
    final promos = _homeController.getPromoCodeModel.data ?? [];
    final salons = _homeController.getHomeSalonList.data?.rows;

    if (salons == null) return;

    final salonIds = salons.map((e) => e.id).toSet();
    Map<String, double> discountMap = {};

    for (var promo in promos) {
      final salonId = promo.salon?.id ?? "";

      if (!salonIds.contains(salonId)) continue;

      double value;

      if (promo.type == "percentage") {
        value = promo.amount?.toDouble() ?? 0;
      } else {
        value = (promo.amount ?? 0) / 10; // normalize ₹
      }

      if (discountMap.containsKey(salonId)) {
        discountMap[salonId] =
            discountMap[salonId]! > value ? discountMap[salonId]! : value;
      } else {
        discountMap[salonId] = value;
      }
    }

    salons.sort((a, b) {
      final aVal = discountMap[a.id] ?? 0;
      final bVal = discountMap[b.id] ?? 0;

      if (bVal == aVal) {
        return (b.rating ?? 0).compareTo(a.rating ?? 0);
      }

      return bVal.compareTo(aVal);
    });

    _homeController.update();
  }

  Future<void> _markSalonVisited() async {
    await SharedPrefs.writeBoolValue(PrefConstants.hasVisitedSalon, true);
  }

  bool _shouldShowSalonDialog() {
    final hasVisitedSalon =
        SharedPrefs.readBoolValue(PrefConstants.hasVisitedSalon);

    final hasShownDialog =
        SharedPrefs.readBoolValue(PrefConstants.hasShownSalonDialog);

    print("🧠 CHECK DIALOG");
    print("hasVisitedSalon: $hasVisitedSalon");
    print("hasShownSalonDialog: $hasShownDialog");

    return hasVisitedSalon && !hasShownDialog;
  }

  Future<void> _markSalonDialogShown() async {
    await SharedPrefs.writeBoolValue(PrefConstants.hasShownSalonDialog, true);
  }

  void _showExitDialog(BuildContext context) {
    final controller = TextEditingController();
    final homeController = Get.find<HomeController>();

    // Mark that we've shown the dialog
    _markSalonDialogShown();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            height: 320,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF6A5AE0), Color(0xFFE85AA8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 281,
                  height: 18,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Help Us!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        height: 1, // 🔥 important (removes extra spacing)
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 281,
                  height: 43,
                  child: const Text(
                    "Didn’t find the salon you’re \nlooking for?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.white70,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1, // 🔥 controls line spacing
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 281,
                  child: const Text(
                    "Drop the Name, Location of the Salon below",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.white70,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      //height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  width: 261,
                  height: 132,
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, bottom: 5, top: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    //border: Border.all(color: Color(0xFF3B82F6), width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextField(
                        controller: controller,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Outfit',
                          color: Colors.black, // ❌ not exact 20%
                        ),
                        decoration: InputDecoration(
                          hintText: "ENTER HERE",
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.2),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      InkWell(
                          onTap: () async {
                            final text = controller.text.trim();

                            if (text.isNotEmpty) {
                              await homeController.doSendSalonRequest(text);
                            }

                            Navigator.pop(context);
                            SystemNavigator.pop();
                          },
                          child: Container(
                            height: 40,
                            width: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A5AE0), Color(0xFFE85AA8)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(
                                  1.5), // 👈 border thickness
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E5E5), // inner color
                                borderRadius: BorderRadius.circular(10.5),
                              ),
                              child: const Center(
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /*--------------  Header Widget ----------------*/
  Obx _headerWidget() {
    return Obx(
      () => Container(
        color: ColorConstant.whiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => GoogleMapGetLocation(
                      callback: () {
                        _homeController.doGetHomeSalonList(
                            serviceGender:
                                selectedGender.value == 0 ? "male" : "female",
                            homeService: atHome,
                            offset: 1,
                            size: 500,
                            lat: double.parse(SharedPrefs.readStringValue(
                                PrefConstants.latitude)),
                            lng: double.parse(SharedPrefs.readStringValue(
                                PrefConstants.longitude)),
                            orderBy: "",
                            nearest: false,
                            fourPlusRating: false);
                      },
                    ));
              },
              child: Container(
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      AssetsConstant.location,
                      width: 44,
                      height: 44,
                      color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _authController.userCity,
                          style: const TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 18,
                            fontWeight: FontWeight.w700, // 🔥 IMPORTANT
                            color: ColorConstant.blackColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        _homeController.showProgress
                            ? const SizedBox()
                            : SizedBox(
                                width: Get.width * 0.6,
                                child: Text(
                                  _authController.userCurrentLocation,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 14, // ✅ FIXED
                                    fontWeight: FontWeight.w600, // ✅ SemiBold
                                    color: Colors.black54, // ✅ 50% black
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => ProfilePage(
                      callback: () {
                        _homeController.doGetHomeCategory(
                          gender: selectedGender.value == 0 ? "male" : "female",
                        );
                        _homeController.doGetMakePackageData();
                        _homeController.doGetPromoCode(
                            fourPlusRating: false,
                            homeService: SharedPrefs.readBoolValue(
                                PrefConstants.isHomeService),
                            nearest: false,
                            orderBy: "",
                            serviceGender:
                                selectedGender.value == 0 ? "male" : "female",
                            lat: double.parse(SharedPrefs.readStringValue(
                                PrefConstants.latitude)),
                            lng: double.parse(SharedPrefs.readStringValue(
                                PrefConstants.longitude)));

                        _homeController.doGetHomeSalonList(
                            serviceGender:
                                selectedGender.value == 0 ? "male" : "female",
                            homeService: atHome,
                            offset: 1,
                            size: 500,
                            lat: double.parse(SharedPrefs.readStringValue(
                                PrefConstants.latitude)),
                            lng: double.parse(SharedPrefs.readStringValue(
                                PrefConstants.longitude)),
                            orderBy: "",
                            nearest: false,
                            fourPlusRating: false);
                      },
                    ));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender))),
                  child: Center(
                    child: Text(
                      (_authController.userResponseModel.data?.userData?.name ??
                                  "")
                              .isNotEmpty
                          ? _authController
                              .userResponseModel.data!.userData!.name![0]
                              .toUpperCase()
                          : "",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 14, // ✅ based on 38px container
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        //height: 1,                 // ✅ IMPORTANT (removes extra vertical space)
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /*--------------- Search Widget ------------*/
  GestureDetector _searchWidget() {
    return GestureDetector(
      onTap: () {
        Get.to(() => const SearchForSalonService());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        width: Get.width,
        height: 45,
        decoration: ShapeDecoration(
          color: ColorConstant.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender),
                  ) ??
                  ColorConstant.primaryColor,
              width: 1.2,
            ),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8.20,
              offset: Offset(1, 1),
              spreadRadius: 0,
            )
          ],
        ),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            alignment: Alignment.center, // ✅ centers text
            children: [
              /// 🔹 LEFT ICON (fixed position)
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  AssetsConstant.search,
                  width: 24,
                  height: 24,
                  color: changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender),
                  ),
                ),
              ),

              /// 🔹 CENTER TEXT (independent)
              Text(
                "Search for Salon",
                style: AppTextTheme.medium.copyWith(
                  color: ColorConstant.grayColor,
                  fontSize: 14,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*---------------- Our Service ------------*/
  Container _ourService() {
    return Container(
      color: ColorConstant.whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Our Services",
                    textScaler: const TextScaler.linear(0.90),
                    style: const TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 18,
                      fontWeight: FontWeight.w600, // ✅ FIXED (SemiBold)
                      color: Colors.black,
                      height: 1, // ✅ optional for better vertical match
                    )),
                TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return MenuDialogWidget(
                              categoryListData:
                                  _homeController.homeCategoryListResponseModel,
                              callback: () {
                                List<String> storeServiceId = [];
                                setState(() {
                                  for (int i = 0;
                                      i <
                                          _homeController
                                              .homeCategoryListResponseModel
                                              .data!
                                              .length;
                                      i++) {
                                    if (_homeController
                                            .homeCategoryListResponseModel
                                            .data?[i]
                                            .isSelectCategory ??
                                        false) {
                                      storeServiceId.add(_homeController
                                              .homeCategoryListResponseModel
                                              .data?[i]
                                              .id ??
                                          "");
                                    }
                                  }
                                });

                                if (storeServiceId.isNotEmpty) {
                                  _homeController.doAddPackageOneData(
                                      serviceCategoryIds: storeServiceId,
                                      callback: () {
                                        _homeController.doGetMakePackageData();
                                        _homeController.doGetHomeSalonList(
                                            serviceGender:
                                                selectedGender.value == 0
                                                    ? "male"
                                                    : "female",
                                            homeService: atHome,
                                            offset: 1,
                                            size: 500,
                                            lat: double.parse(
                                                SharedPrefs.readStringValue(
                                                    PrefConstants.latitude)),
                                            lng: double.parse(
                                                SharedPrefs.readStringValue(
                                                    PrefConstants.longitude)),
                                            orderBy: "",
                                            nearest: false,
                                            fourPlusRating: false);
                                      });
                                }
                              },
                            );
                          });
                    },
                    child: Text(
                      "View All",
                      style: const TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 14, // ✅ Figma
                        fontWeight: FontWeight.w600, // ✅ SemiBold
                        color: Color(0x66000000), // ✅ 40% black
                        height: 1, // ✅ better vertical alignment
                      ),
                    ))
              ],
            ),
          ),
          SizedBox(
              height: 118,
              child: Obx(() {
                final current =
                    _homeController.homeCategoryListResponseModel.data ?? [];
                final selected =
                    _homeController.getLastMakeYourOwnPackageModel.data ?? [];

                final displaySelected = selected.where((s) {
                  return current.any((c) => c.id == s.id);
                }).toList();

                return displaySelected.isEmpty
                    ? Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return MenuDialogWidget(
                                      categoryListData: _homeController
                                          .homeCategoryListResponseModel,
                                      callback: () {
                                        List<String> storeServiceId = [];
                                        setState(() {
                                          for (int i = 0;
                                              i <
                                                  _homeController
                                                      .homeCategoryListResponseModel
                                                      .data!
                                                      .length;
                                              i++) {
                                            if (_homeController
                                                    .homeCategoryListResponseModel
                                                    .data?[i]
                                                    .isSelectCategory ??
                                                false) {
                                              storeServiceId.add(_homeController
                                                      .homeCategoryListResponseModel
                                                      .data?[i]
                                                      .id ??
                                                  "");
                                            }
                                          }
                                        });

                                        if (storeServiceId.isNotEmpty) {
                                          _homeController.doAddPackageOneData(
                                              serviceCategoryIds:
                                                  storeServiceId,
                                              callback: () {
                                                _homeController
                                                    .doGetMakePackageData();
                                                _homeController.doGetHomeSalonList(
                                                    serviceGender:
                                                        selectedGender.value ==
                                                                0
                                                            ? "male"
                                                            : "female",
                                                    homeService: atHome,
                                                    offset: 1,
                                                    size: 500,
                                                    lat: double.parse(
                                                        SharedPrefs
                                                            .readStringValue(
                                                                PrefConstants
                                                                    .latitude)),
                                                    lng: double.parse(SharedPrefs
                                                        .readStringValue(
                                                            PrefConstants
                                                                .longitude)),
                                                    orderBy: "",
                                                    nearest: false,
                                                    fourPlusRating: false);
                                              });
                                        }
                                      },
                                    );
                                  });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                children: [
                                  Container(
                                      width: 60,
                                      height: 60,
                                      decoration: ShapeDecoration(
                                        gradient: RadialGradient(
                                          center: const Alignment(0.57, 0.07),
                                          radius: 0.90,
                                          colors: selectedGender.value == 1
                                              ? [
                                                  const Color(0xFFFFCAF9),
                                                  Colors.white
                                                ]
                                              : [
                                                  const Color(0xFFE1D5FF),
                                                  Colors.white
                                                ],
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(64),
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          AssetsConstant.makePackageImage,
                                          width: 40,
                                          height: 40,
                                          color: changeTheme(
                                              SharedPrefs.readStringValue(
                                                  PrefConstants.gender)),
                                        ),
                                      )),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Make Your \n Package",
                                    style: TextStyle(
                                      fontFamily: "Outfit",
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: current.length,
                                itemBuilder: (context, index) {
                                  var item = current[index];
                                  return GestureDetector(
                                    onTap: () {
                                      List<String> storeServiceId = [];
                                      var id = item.id;

                                      storeServiceId.add(id ?? "");

                                      _homeController.doAddPackageOneData(
                                          serviceCategoryIds: storeServiceId,
                                          callback: () {
                                            _homeController
                                                .doGetMakePackageData();
                                            _homeController.doGetHomeSalonList(
                                                serviceGender:
                                                    selectedGender.value == 0
                                                        ? "male"
                                                        : "female",
                                                homeService: atHome,
                                                offset: 1,
                                                size: 500,
                                                lat: double.parse(
                                                    SharedPrefs.readStringValue(
                                                        PrefConstants
                                                            .latitude)),
                                                lng: double.parse(
                                                    SharedPrefs.readStringValue(
                                                        PrefConstants
                                                            .longitude)),
                                                orderBy: "",
                                                nearest: false,
                                                fourPlusRating: false);
                                          });
                                    },
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: CachedNetworkImage(
                                            height: 60,
                                            width: 60,
                                            fit: BoxFit.cover,
                                            imageUrl:
                                                // SharedPrefs.readStringValue(
                                                //     PrefConstants.gender) ==
                                                //     "0"
                                                selectedGender.value == 0
                                                    ? "${APIConstants.image}${item.imageMale}"
                                                    : "${APIConstants.image}${item.imageFemale}",
                                            // memCacheWidth: 60,
                                            // memCacheHeight: 60,
                                            //
                                            // fadeInDuration: index < 4
                                            //     ? Duration.zero
                                            //     : const Duration(milliseconds: 300),
                                            placeholder: (context, url) =>
                                                Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            // Row 21: neutral placeholder instead
                                            // of a red exclamation when an image
                                            // fails to load.
                                            errorWidget: (context, url, error) =>
                                                Container(
                                              height: 60,
                                              width: 60,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.image_not_supported_outlined,
                                                size: 22,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              height: 60,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: Get.width * 0.2,
                                          child: Text(
                                            current[index].name ?? "",
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: AppTextTheme.medium.copyWith(
                                              fontFamily: "Outfit", // ✅ added
                                              fontWeight: FontWeight
                                                  .w500, // ✅ Medium weight
                                              fontSize: 13,
                                              color: ColorConstant.blackColor,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: displaySelected.length,
                                itemBuilder: (context, index) {
                                  final item = displaySelected[index];

                                  return GestureDetector(
                                    onTap: () {
                                      var id = item.id;

                                      for (int i = 0;
                                          i <
                                              _homeController
                                                  .homeCategoryListResponseModel
                                                  .data!
                                                  .length;
                                          i++) {
                                        if (id ==
                                            _homeController
                                                .homeCategoryListResponseModel
                                                .data?[i]
                                                .id) {
                                          _homeController
                                              .homeCategoryListResponseModel
                                              .data?[i]
                                              .isSelectCategory = false;
                                        }
                                      }

                                      List<String> storeServiceId = [];
                                      storeServiceId.add(item.id ?? "");

                                      _homeController.doRemovePackageData(
                                          serviceCategoryIds: storeServiceId,
                                          callback: () {
                                            _homeController
                                                .doGetMakePackageData();
                                          });

                                      _homeController.doGetHomeSalonList(
                                          serviceGender:
                                              selectedGender.value == 0
                                                  ? "male"
                                                  : "female",
                                          homeService: atHome,
                                          offset: 1,
                                          size: 500,
                                          lat: double.parse(
                                              SharedPrefs.readStringValue(
                                                  PrefConstants.latitude)),
                                          lng: double.parse(
                                              SharedPrefs.readStringValue(
                                                  PrefConstants.longitude)),
                                          orderBy: "",
                                          nearest: false,
                                          fourPlusRating: false);
                                    },
                                    child: Column(
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: CachedNetworkImage(
                                                height: 60,
                                                width: 60,
                                                fit: BoxFit.cover,
                                                imageUrl:
                                                    // SharedPrefs.readStringValue(
                                                    //     PrefConstants.gender) ==
                                                    //     "0"
                                                    selectedGender.value == 0
                                                        ? "${APIConstants.image}${item.imageMale}"
                                                        : "${APIConstants.image}${item.imageFemale}",
                                                // memCacheWidth: 60,
                                                // memCacheHeight: 60,
                                                //
                                                // fadeInDuration: index < 4
                                                //     ? Duration.zero
                                                //     : const Duration(milliseconds: 300),
                                                placeholder: (context, url) =>
                                                    Container(
                                                  height: 60,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: -5,
                                              top: -1,
                                              child: Container(
                                                height: 20,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                    color: changeTheme(
                                                        SharedPrefs
                                                            .readStringValue(
                                                                PrefConstants
                                                                    .gender)),
                                                    shape: BoxShape.circle),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: Get.width * 0.2,
                                          child: Text(
                                            item.name ?? "",
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: AppTextTheme.medium.copyWith(
                                              fontFamily: "Outfit", // ✅ added
                                              fontWeight: FontWeight
                                                  .w500, // ✅ Medium weight
                                              fontSize: 13,
                                              color: ColorConstant.blackColor,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          ),
                          if (_homeController
                                  .getLastMakeYourOwnPackageModel.data?.last !=
                              null)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return MenuDialogWidget(
                                          categoryListData: _homeController
                                              .homeCategoryListResponseModel,
                                          callback: () {
                                            List<String> storeServiceId = [];
                                            setState(() {
                                              for (int i = 0;
                                                  i <
                                                      _homeController
                                                          .homeCategoryListResponseModel
                                                          .data!
                                                          .length;
                                                  i++) {
                                                if (_homeController
                                                        .homeCategoryListResponseModel
                                                        .data?[i]
                                                        .isSelectCategory ??
                                                    false) {
                                                  storeServiceId.add(_homeController
                                                          .homeCategoryListResponseModel
                                                          .data?[i]
                                                          .id ??
                                                      "");
                                                }
                                              }
                                            });

                                            if (storeServiceId.isNotEmpty) {
                                              _homeController
                                                  .doAddPackageOneData(
                                                      serviceCategoryIds:
                                                          storeServiceId,
                                                      callback: () {
                                                        _homeController
                                                            .doGetMakePackageData();
                                                      });
                                            }

                                            _homeController.doGetHomeSalonList(
                                                serviceGender:
                                                    selectedGender.value == 0
                                                        ? "male"
                                                        : "female",
                                                homeService: atHome,
                                                offset: 1,
                                                size: 500,
                                                lat: double.parse(
                                                    SharedPrefs.readStringValue(
                                                        PrefConstants
                                                            .latitude)),
                                                lng: double.parse(
                                                    SharedPrefs.readStringValue(
                                                        PrefConstants
                                                            .longitude)),
                                                orderBy: "",
                                                nearest: false,
                                                fourPlusRating: false);
                                          },
                                        );
                                      });
                                },
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: ShapeDecoration(
                                    gradient: RadialGradient(
                                      center: const Alignment(0.57, 0.07),
                                      radius: 0.90,
                                      colors: selectedGender.value == 1
                                          ? [
                                              const Color(0xFFFFCAF9),
                                              Colors.white
                                            ]
                                          : [
                                              const Color(0xFFE1D5FF),
                                              Colors.white
                                            ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(64),
                                    ),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      AssetsConstant.addPackageImage,
                                      width: 30,
                                      height: 30,
                                      color: changeTheme(
                                          SharedPrefs.readStringValue(
                                              PrefConstants.gender)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
              }))
        ],
      ),
    );
  }

  /*-------------------- Offer -------------------*/
  // Widget _offer() {
  //   return _homeController.getPromoCodeModel.data?.isEmpty ??
  //         false || _homeController.getPromoCodeModel.data == null
  //         ? const SizedBox()
  //         : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //       Padding(
  //         //padding: EdgeInsets.only(left: 12, bottom: 10),
  //         padding: const EdgeInsets.symmetric(horizontal: 20),
  //         child: Text(
  //           "Offer’s For You",
  //           style: const TextStyle(
  //             fontFamily: "Outfit", // ✅ MUST
  //             fontWeight: FontWeight.w700, // ✅ Bold
  //             fontSize: 14, // ✅ Matches your UI scale
  //             color: Colors.black,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Obx(
  //             () =>
  //             SizedBox(
  //               height: 62,
  //               width: Get.width,
  //               child: PageView.builder(
  //                 clipBehavior: Clip.hardEdge,
  //                 scrollDirection: Axis.horizontal,
  //                 itemCount: _homeController.getPromoCodeModel.data?.length,
  //                 itemBuilder: (context, index) {
  //                   return GestureDetector(
  //                       onTap: () async {
  //                         // Mark that user has visited a salon
  //                         await _markSalonVisited();
  //
  //                         Get.to(() =>
  //                             SaloonAfterSelectingServicesPage(
  //                               id: _homeController.getPromoCodeModel
  //                                   .data?[index].salon?.id ??
  //                                   "",
  //                               callback: () {
  //                                 _homeController.doGetHomeCategory(
  //                                   gender: selectedGender.value == 0
  //                                       ? "male"
  //                                       : "female",
  //                                 );
  //                                 _homeController.doGetMakePackageData();
  //
  //                                 _homeController.doGetPromoCode(
  //                                     fourPlusRating: false,
  //                                     homeService: SharedPrefs.readBoolValue(
  //                                         PrefConstants.isHomeService),
  //                                     nearest: false,
  //                                     orderBy: "",
  //                                     serviceGender: selectedGender.value == 0
  //                                         ? "male"
  //                                         : "female",
  //                                     lat: double.parse(
  //                                         SharedPrefs.readStringValue(
  //                                             PrefConstants.latitude)),
  //                                     lng: double.parse(
  //                                         SharedPrefs.readStringValue(
  //                                             PrefConstants.longitude)));
  //
  //                                 _homeController.doGetHomeSalonList(
  //                                     serviceGender: selectedGender.value == 0
  //                                         ? "male"
  //                                         : "female",
  //                                     homeService: atHome,
  //                                     offset: 1,
  //                                     size: 500,
  //                                     lat: double.parse(
  //                                         SharedPrefs.readStringValue(
  //                                             PrefConstants.latitude)),
  //                                     lng: double.parse(
  //                                         SharedPrefs.readStringValue(
  //                                             PrefConstants.longitude)),
  //                                     orderBy: "",
  //                                     nearest: false,
  //                                     fourPlusRating: false);
  //                               },
  //                             ));
  //                       },
  //                       child: Center(
  //                           child: SizedBox(
  //                               width: 343, // ✅ FIXED WIDTH
  //                               child: Stack(
  //                                 clipBehavior: Clip.hardEdge,
  //                                 children: [
  //
  //                                   /// MAIN OFFER CARD
  //                                   Container(
  //                                     //margin: const EdgeInsets.symmetric(horizontal: 12),
  //                                     //margin: const EdgeInsets.only(left: 12, right: 1),
  //                                     padding: const EdgeInsets.symmetric(
  //                                         horizontal: 18, vertical: 9),
  //                                     decoration: BoxDecoration(
  //                                       gradient: const LinearGradient(
  //                                         colors: [
  //                                           Color(0xFFFD98FB),
  //                                           Color(0xFFB479FF),
  //                                         ],
  //                                         begin: Alignment.centerLeft,
  //                                         end: Alignment.centerRight,
  //                                       ),
  //                                       borderRadius: BorderRadius.circular(
  //                                           20),
  //                                     ),
  //                                     child: Row(
  //                                       children: [
  //
  //                                         /// LEFT BIG DISCOUNT
  //                                         // Text(
  //                                         //   _homeController.getPromoCodeModel.data?[index].type == "percentage"
  //                                         //       ? "${_homeController.getPromoCodeModel.data?[index].amount}%"
  //                                         //       : "₹${_homeController.getPromoCodeModel.data?[index].amount}",
  //                                         //   style: AppTextTheme.bold.copyWith(
  //                                         //     fontSize: 45,
  //                                         //     letterSpacing: -4,
  //                                         //     color: Colors.white.withOpacity(0.7),
  //                                         //     shadows: [
  //                                         //       // Inner highlight — improves readability
  //                                         //       Shadow(
  //                                         //         color: Colors.white.withOpacity(0.30),
  //                                         //         blurRadius: 12,
  //                                         //       ),
  //                                         //
  //                                         //       // Mid glow — brand beauty tone
  //                                         //       Shadow(
  //                                         //         color: Colors.purpleAccent.withOpacity(0.25),
  //                                         //         blurRadius: 26,
  //                                         //       ),
  //                                         //
  //                                         //       // Outer aura — premium gold
  //                                         //       Shadow(
  //                                         //         color: Color(0xFFFFC107).withOpacity(0.35),
  //                                         //         blurRadius: 44,
  //                                         //       ),
  //                                         //     ],
  //                                         //   ),
  //                                         // ),
  //                                         Text(
  //                                           _homeController.getPromoCodeModel
  //                                               .data?[index].type ==
  //                                               "percentage"
  //                                               ? "${_homeController
  //                                               .getPromoCodeModel
  //                                               .data?[index].amount}%"
  //                                               : "₹${_homeController
  //                                               .getPromoCodeModel
  //                                               .data?[index].amount}",
  //                                           style: const TextStyle(
  //                                             fontFamily: "Outfit",
  //                                             fontWeight: FontWeight
  //                                                 .w700,
  //                                             // Bold (Figma)
  //                                             fontSize: 52,
  //                                             // Exact Figma size
  //                                             letterSpacing:
  //                                             -4,
  //                                             // Tight spacing like design
  //                                             height:
  //                                             1.0,
  //                                             // Prevent vertical overflow
  //                                             color: Colors
  //                                                 .white, // Pure white (no opacity)
  //                                           ),
  //                                         ),
  //                                         const SizedBox(width: 12),
  //                                         Expanded(
  //                                           child: OfferAnimatedTextWidget(
  //                                             salonName: _homeController
  //                                                 .getPromoCodeModel
  //                                                 .data?[index]
  //                                                 .salon
  //                                                 ?.name ??
  //                                                 "",
  //                                             title: _homeController
  //                                                 .getPromoCodeModel
  //                                                 .data?[index]
  //                                                 .title ??
  //                                                 "",
  //                                             description: _homeController
  //                                                 .getPromoCodeModel
  //                                                 .data?[index]
  //                                                 .description ??
  //                                                 "",
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ))));
  //                 },
  //                 controller: _offerPageController,
  //                 onPageChanged: (index) {
  //                   _currentOfferPage = index; // ⭐ VERY IMPORTANT
  //                 },
  //                 padEnds: true,
  //                 // ✅ ADD THIS
  //                 pageSnapping: true,
  //
  //                 // ✅ ADD THIS (VERY IMPORTANT)
  //                 physics: const PageScrollPhysics(),
  //               ),
  //             ),
  //       )
  //     ]);
  // }

  Widget _offer() {
    return Obx(() {
      final offers = _homeController.getPromoCodeModel.data;

      /// 🔴 Handle empty / null safely (reactive now)
      if (offers == null || offers.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Offer’s For You",
              style: const TextStyle(
                fontFamily: "Outfit",
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 62,
            width: Get.width,
            child: PageView.builder(
              clipBehavior: Clip.hardEdge,
              scrollDirection: Axis.horizontal,
              itemCount: offers.length,
              controller: _offerPageController,
              onPageChanged: (index) {
                _currentOfferPage = index;
              },
              padEnds: true,
              pageSnapping: true,
              physics: const PageScrollPhysics(),
              itemBuilder: (context, index) {
                final offer = offers[index];

                return GestureDetector(
                  onTap: () async {
                    await _markSalonVisited();

                    Get.to(() => SaloonAfterSelectingServicesPage(
                          isPayNowMode: true,
                          id: offer.salon?.id ?? "",
                          callback: () {
                            _homeController.doGetHomeCategory(
                              gender:
                                  selectedGender.value == 0 ? "male" : "female",
                            );
                            _homeController.doGetMakePackageData();

                            _homeController.doGetPromoCode(
                                fourPlusRating: false,
                                homeService: SharedPrefs.readBoolValue(
                                    PrefConstants.isHomeService),
                                nearest: false,
                                orderBy: "",
                                serviceGender: selectedGender.value == 0
                                    ? "male"
                                    : "female",
                                lat: double.parse(SharedPrefs.readStringValue(
                                    PrefConstants.latitude)),
                                lng: double.parse(SharedPrefs.readStringValue(
                                    PrefConstants.longitude)));

                            _homeController.doGetHomeSalonList(
                                serviceGender: selectedGender.value == 0
                                    ? "male"
                                    : "female",
                                homeService: atHome,
                                offset: 1,
                                size: 500,
                                lat: double.parse(SharedPrefs.readStringValue(
                                    PrefConstants.latitude)),
                                lng: double.parse(SharedPrefs.readStringValue(
                                    PrefConstants.longitude)),
                                orderBy: "",
                                nearest: false,
                                fourPlusRating: false);
                          },
                        ));
                  },
                  child: Center(
                    child: SizedBox(
                      width: 343,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 9),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFD98FB),
                                  Color(0xFFB479FF),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  offer.type == "percentage"
                                      ? "${offer.amount}%"
                                      : "₹${offer.amount}",
                                  style: const TextStyle(
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 52,
                                    letterSpacing: -4,
                                    height: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OfferAnimatedTextWidget(
                                    salonName: offer.salon?.name ?? "",
                                    title: offer.title ?? "",
                                    description: offer.description ?? "",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  /*------------ Saloons Found Near ----------- */
  bool atHome = false;
  int select = 0;
  bool isNearestSelected = false;

  // Row 26 (updated): budget = sort salons by starting price low→high.
  bool _budgetLowToHigh = false;

  // Row 25: operational-area check — is any salon within 12 km (12000 m)?
  bool _hasSalonWithin12km() {
    final salons = _homeController.getHomeSalonList.data?.rows ?? [];
    return salons.any((s) => (s.distance ?? (1 << 30)) <= 12000);
  }

  // Row 25: "We're not here yet" message + Request button (frontend snackbar).
  Widget _notHereYetWidget() {
    final Color themeColor =
        changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)) ??
            ColorConstant.primaryColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Icon(Icons.location_off_outlined, size: 60, color: themeColor),
          const SizedBox(height: 16),
          Text(
            "We are not Here Yet,\nWe'll be Here Soon",
            textAlign: TextAlign.center,
            style: AppTextTheme.bold
                .copyWith(fontSize: 18, color: ColorConstant.blackColor),
          ),
          const SizedBox(height: 8),
          Text(
            "We don't have any salons within 12 km of your location yet.",
            textAlign: TextAlign.center,
            style: AppTextTheme.medium
                .copyWith(fontSize: 13, color: ColorConstant.grayTextColor),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: () {
              Get.snackbar(
                "Request received",
                "Thanks! We've noted your request — we'll try to reach your area soon.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: themeColor,
                colorText: ColorConstant.whiteColor,
                margin: const EdgeInsets.all(12),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 12),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Request",
                style: AppTextTheme.bold
                    .copyWith(fontSize: 15, color: ColorConstant.whiteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Obx _saloonsFoundNear() {
    return Obx(
      () => !_hasSalonWithin12km()
          ? const SizedBox.shrink()
          : Container(
        color: ColorConstant.whiteColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_homeController.getHomeSalonList.data?.rows?.length ?? 0} Salons Found Near You",
                    textScaler: const TextScaler.linear(0.90), // ✅ untouched
                    style: AppTextTheme.bold.copyWith(
                      fontFamily: "Outfit", // ✅ added
                      fontWeight: FontWeight.w600, // ✅ SemiBold (matches Figma)
                      fontSize: 18,
                      color: ColorConstant.blackColor,
                    ),
                  ),
                  // const SizedBox(width: 5),
                  // Disabled home service temporarily
                  // Container(
                  //   height: 50,
                  //   color: ColorConstant.whiteColor,
                  //   child: Row(
                  //     children: [
                  //       // Text(
                  //       //   "Home Service",
                  //       //   style: AppTextTheme.bold.copyWith(
                  //       //       color: changeTheme(SharedPrefs.readStringValue(
                  //       //           PrefConstants.gender)),
                  //       //       fontSize: 13),
                  //       // ),
                  //       // SizedBox(
                  //       //   height: 30,
                  //       //   child: CupertinoSwitch(
                  //       //     value: atHome,
                  //       //     activeColor: changeTheme(
                  //       //         SharedPrefs.readStringValue(
                  //       //             PrefConstants.gender)),
                  //       //     onChanged: (bool value) {
                  //       //       setState(() {
                  //       //         atHome = value;
                  //       //         if (atHome) {
                  //       //           SharedPrefs.writeValue(
                  //       //               PrefConstants.isHomeService, true);
                  //       //         } else {
                  //       //           SharedPrefs.writeValue(
                  //       //               PrefConstants.isHomeService, false);
                  //       //         }
                  //       //         _homeController.doGetHomeSalonList(
                  //       //             serviceGender: selectedGender.value == 0
                  //       //                 ? "male"
                  //       //                 : "female",
                  //       //             homeService: atHome,
                  //       //             offset: 1,
                  //       //             size: 500,
                  //       //             lat: double.parse(
                  //       //                 SharedPrefs.readStringValue(
                  //       //                     PrefConstants.latitude)),
                  //       //             lng: double.parse(
                  //       //                 SharedPrefs.readStringValue(
                  //       //                     PrefConstants.longitude)),
                  //       //             orderBy: "",
                  //       //             nearest: false,
                  //       //             fourPlusRating: false);
                  //       //
                  //       //         _homeController.doGetPromoCode(
                  //       //             fourPlusRating: false,
                  //       //             homeService: SharedPrefs.readBoolValue(
                  //       //                 PrefConstants.isHomeService),
                  //       //             nearest: false,
                  //       //             orderBy: dropdownvalue == "Sort By"
                  //       //                 ? ""
                  //       //                 : dropdownvalue == "Newest"
                  //       //                     ? "createdAt"
                  //       //                     : dropdownvalue == "Price"
                  //       //                         ? "serviceStartingPrice"
                  //       //                         : "name",
                  //       //             serviceGender: selectedGender.value == 0
                  //       //                 ? "male"
                  //       //                 : "female",
                  //       //             lat: double.parse(
                  //       //                 SharedPrefs.readStringValue(
                  //       //                     PrefConstants.latitude)),
                  //       //             lng: double.parse(
                  //       //                 SharedPrefs.readStringValue(
                  //       //                     PrefConstants.longitude)));
                  //       //       });
                  //       //     },
                  //       //   ),
                  //       // ),
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,

                              /// 🔥 SHOW DEFAULT TEXT HERE
                              hint: Center(
                                  child: Text(
                                "Sort By",
                                textAlign: TextAlign.center,
                                style: AppTextTheme.medium.copyWith(
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: ColorConstant.blackColor,
                                ),
                              )),

                              items: items
                                  .map((String item) =>
                                      DropdownMenuItem<String>(
                                        value: item,
                                        alignment: Alignment.center,
                                        child: Text(
                                          item,
                                          style: AppTextTheme.medium.copyWith(
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: ColorConstant.blackColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),

                              value: dropdownvalue, // 🔥 can be null

                              onChanged: (value) {
                                setState(() {
                                  dropdownvalue = value;

                                  String orderBy = value == "Price: Low - High"
                                      ? "serviceStartingPrice"
                                      : "serviceMaxPrice";

                                  _homeController.doGetPromoCode(
                                    fourPlusRating: false,
                                    homeService: SharedPrefs.readBoolValue(
                                        PrefConstants.isHomeService),
                                    nearest: false,
                                    orderBy: orderBy,
                                    serviceGender: selectedGender.value == 0
                                        ? "male"
                                        : "female",
                                    lat: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.latitude)),
                                    lng: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.longitude)),
                                  );

                                  _homeController.doGetHomeSalonList(
                                    serviceGender: selectedGender.value == 0
                                        ? "male"
                                        : "female",
                                    homeService: atHome,
                                    offset: 1,
                                    size: 500,
                                    lat: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.latitude)),
                                    lng: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.longitude)),
                                    orderBy: orderBy,
                                    nearest: false,
                                    fourPlusRating: false,
                                  );
                                });
                              },

                              buttonStyleData: ButtonStyleData(
                                height: 30,
                                width: 150,
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black26),
                                  color: Colors.white,
                                ),
                              ),

                              iconStyleData: const IconStyleData(
                                icon: Icon(Icons.arrow_forward_ios_outlined),
                                iconSize: 14,
                                iconEnabledColor: ColorConstant.blackColor,
                                iconDisabledColor: ColorConstant.blackColor,
                              ),

                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: ColorConstant.whiteColor,
                                ),
                                offset: const Offset(-20, 0),
                              ),

                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                              ),
                            ),
                          ),
                          // Positioned(
                          //   left: 10,
                          //   top: 9,
                          //   child: Image.asset(AssetsConstant.filter,
                          //       height: 14, width: 14),
                          // ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                // if (select == 0 || select == 2) {
                                //   select = 1;
                                //   _homeController.doGetHomeSalonList(
                                //       serviceGender: selectedGender.value == 0
                                //           ? "male"
                                //           : "female",
                                //       homeService: atHome,
                                //       offset: 1,
                                //       size: 500,
                                //       lat: double.parse(
                                //           SharedPrefs.readStringValue(
                                //               PrefConstants.latitude)),
                                //       lng: double.parse(
                                //           SharedPrefs.readStringValue(
                                //               PrefConstants.longitude)),
                                //       orderBy: dropdownvalue == "Sort By"
                                //           ? ""
                                //           : dropdownvalue == "Price: Low - High"
                                //           ? "serviceStartingPrice"
                                //           : "serviceMaxPrice",
                                //       nearest: true,
                                //       fourPlusRating: false);
                                //
                                //   _homeController.doGetPromoCode(
                                //       fourPlusRating: false,
                                //       homeService: SharedPrefs.readBoolValue(
                                //           PrefConstants.isHomeService),
                                //       nearest: true,
                                //       orderBy: dropdownvalue == "Sort By"
                                //           ? ""
                                //           : dropdownvalue == "Price: Low - High"
                                //           ? "serviceStartingPrice"
                                //           : "serviceMaxPrice",
                                //       serviceGender: selectedGender.value == 0
                                //           ? "male"
                                //           : "female",
                                //       lat: double.parse(
                                //           SharedPrefs.readStringValue(
                                //               PrefConstants.latitude)),
                                //       lng: double.parse(
                                //           SharedPrefs.readStringValue(
                                //               PrefConstants.longitude)));
                                // } else {
                                //   select = 0;
                                //   _homeController.doGetHomeSalonList(
                                //       serviceGender: selectedGender.value == 0
                                //           ? "male"
                                //           : "female",
                                //       homeService: atHome,
                                //       offset: 1,
                                //       size: 500,
                                //       lat: double.parse(
                                //           SharedPrefs.readStringValue(
                                //               PrefConstants.latitude)),
                                //       lng: double.parse(
                                //           SharedPrefs.readStringValue(
                                //               PrefConstants.longitude)),
                                //       orderBy: dropdownvalue == "Sort By"
                                //           ? ""
                                //           : dropdownvalue == "Price: Low - High"
                                //           ? "serviceStartingPrice"
                                //           : "serviceMaxPrice",
                                //       nearest: false,
                                //       fourPlusRating: false);
                                //
                                //   _homeController.doGetPromoCode(
                                //       fourPlusRating: false,
                                //       homeService: SharedPrefs.readBoolValue(
                                //           PrefConstants.isHomeService),
                                //       nearest: false,
                                //       orderBy: dropdownvalue == "Sort By"
                                //           ? ""
                                //           : dropdownvalue == "Price: Low - High"
                                //           ? "serviceStartingPrice"
                                //           : "serviceMaxPrice",
                                //       serviceGender: selectedGender.value == 0
                                //           ? "male"
                                //           : "female",
                                //       lat: double.parse(
                                //           SharedPrefs.readStringValue(
                                //               PrefConstants.latitude)),
                                //       lng: double.parse(
                                //           SharedPrefs.readStringValue(
                                //               PrefConstants.longitude)));
                                // }
                                isNearestSelected = !isNearestSelected;
                              });
                              applyFilters();
                            },
                            child: Container(
                              width: Get.width * 0.25,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isNearestSelected //select == 1
                                    ? changeTheme(SharedPrefs.readStringValue(
                                        PrefConstants.gender))
                                    : ColorConstant.whiteColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: ColorConstant.grayBorderColor,
                                    width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  "Nearest",
                                  style: AppTextTheme.medium.copyWith(
                                    fontFamily: "Outfit", // ✅ added
                                    fontWeight: FontWeight.w400, // ✅ Regular
                                    fontSize: 14, // ✅ Figma size
                                    color: isNearestSelected //select == 1
                                        ? ColorConstant.whiteColor
                                        : ColorConstant.blackColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              setState(() {
                                // if (select == 0 || select == 1) {
                                //   select = 2;
                                //   // _homeController.doGetHomeSalonList(
                                //   //     serviceGender: selectedGender.value == 0
                                //   //         ? "male"
                                //   //         : "female",
                                //   //     homeService: atHome,
                                //   //     offset: 1,
                                //   //     size: 500,
                                //   //     lat: double.parse(
                                //   //         SharedPrefs.readStringValue(
                                //   //             PrefConstants.latitude)),
                                //   //     lng: double.parse(
                                //   //         SharedPrefs.readStringValue(
                                //   //             PrefConstants.longitude)),
                                //   //     orderBy: dropdownvalue == "Sort By"
                                //   //         ? ""
                                //   //         : dropdownvalue == "Newest"
                                //   //         ? "createdAt"
                                //   //         : dropdownvalue == "Price"
                                //   //         ? "serviceStartingPrice"
                                //   //         : "name",
                                //   //     nearest: false,
                                //   //     fourPlusRating: true);
                                //   //
                                //   // _homeController.doGetPromoCode(
                                //   //     fourPlusRating: true,
                                //   //     homeService: SharedPrefs.readBoolValue(
                                //   //         PrefConstants.isHomeService),
                                //   //     nearest: false,
                                //   //     orderBy: dropdownvalue == "Sort By"
                                //   //         ? ""
                                //   //         : dropdownvalue == "Newest"
                                //   //         ? "createdAt"
                                //   //         : dropdownvalue == "Price"
                                //   //         ? "serviceStartingPrice"
                                //   //         : "name",
                                //   //     serviceGender: selectedGender.value == 0
                                //   //         ? "male"
                                //   //         : "female",
                                //   //     lat: double.parse(
                                //   //         SharedPrefs.readStringValue(
                                //   //             PrefConstants.latitude)),
                                //   //     lng: double.parse(
                                //   //         SharedPrefs.readStringValue(
                                //   //             PrefConstants.longitude)));
                                //   sortSalonsByDiscount();
                                // } else {
                                //   select = 0;
                                //   _homeController.doGetHomeSalonList(
                                //       serviceGender: selectedGender.value == 0
                                //           ? "male"
                                //           : "female",
                                //       homeService: atHome,
                                //       offset: 1,
                                //       size: 500,
                                //       lat: double.parse(
                                //           SharedPrefs.readStringValue(
                                //               PrefConstants.latitude)),
                                //       lng: double.parse(
                                //           SharedPrefs.readStringValue(
                                //               PrefConstants.longitude)),
                                //       orderBy: dropdownvalue == "Sort By"
                                //           ? ""
                                //           : dropdownvalue == "Price: Low - High"
                                //           ? "serviceStartingPrice"
                                //           : "serviceMaxPrice",
                                //       nearest: false,
                                //       fourPlusRating: false);
                                //
                                //   _homeController.doGetPromoCode(
                                //       fourPlusRating: false,
                                //       homeService: SharedPrefs.readBoolValue(
                                //           PrefConstants.isHomeService),
                                //       nearest: false,
                                //       orderBy: dropdownvalue == "Sort By"
                                //           ? ""
                                //           : dropdownvalue == "Price: Low - High"
                                //           ? "serviceStartingPrice"
                                //           : "serviceMaxPrice",
                                //       serviceGender: selectedGender.value == 0
                                //           ? "male"
                                //           : "female",
                                //       lat: double.parse(
                                //           SharedPrefs.readStringValue(
                                //               PrefConstants.latitude)),
                                //       lng: double.parse(
                                //           SharedPrefs.readStringValue(
                                //               PrefConstants.longitude)));
                                // }
                                // Row 26 (updated): Budget = price low-to-high.
                                _budgetLowToHigh = !_budgetLowToHigh;
                              });
                            },
                            child: Container(
                              width: Get.width * 0.28,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _budgetLowToHigh //budget selected
                                    ? changeTheme(SharedPrefs.readStringValue(
                                        PrefConstants.gender))
                                    : ColorConstant.whiteColor,
                                border: Border.all(
                                    color: ColorConstant.grayBorderColor,
                                    width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  "Budget",
                                  style: AppTextTheme.medium.copyWith(
                                    fontFamily: "Outfit", // ✅ added
                                    fontWeight: FontWeight.w400, // ✅ Regular
                                    fontSize: 14, // ✅ Figma size
                                    color: _budgetLowToHigh //budget selected
                                        ? ColorConstant.whiteColor
                                        : ColorConstant.blackColor,
                                  ),
                                ),
                              ),
                            ),
                          ), /*const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  select = 3;
                                });
                              },
                              child: Container(
                                width: Get.width * 0.25,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: select == 3
                                      ? changeTheme(SharedPrefs.readStringValue(
                                          PrefConstants.gender))
                                      : ColorConstant.whiteColor,
                                  border: Border.all(
                                      color: ColorConstant.grayBorderColor,
                                      width: 1),
                                ),
                                child: Center(
                                  child: Text(
                                    "Great Offers",
                                    style: AppTextTheme.medium.copyWith(
                                        color: select == 3
                                            ? ColorConstant.whiteColor
                                            : ColorConstant.blackColor,
                                        fontSize: 13),
                                  ),
                                ),
                              ),
                            ),*/
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  /*------------------ DropDown  ------------*/
  String? dropdownvalue;
  var items = ['Price: Low - High', 'Price: High - Low'];

  void applyFilters() {
    final lat =
        double.parse(SharedPrefs.readStringValue(PrefConstants.latitude));
    final lng =
        double.parse(SharedPrefs.readStringValue(PrefConstants.longitude));

    final orderBy = dropdownvalue == "Sort By"
        ? ""
        : dropdownvalue == "Price: Low - High"
            ? "serviceStartingPrice"
            : "serviceMaxPrice";

    /// 🔥 CASE 1: NEAREST (alone OR combined)
    if (isNearestSelected) {
      _homeController.doGetHomeSalonList(
        serviceGender: selectedGender.value == 0 ? "male" : "female",
        homeService: atHome,
        offset: 1,
        size: 500,
        lat: lat,
        lng: lng,
        orderBy: orderBy,
        nearest: true,
        fourPlusRating: false,
      );

      // Row 27: keep the offers strip in sync when toggling Nearest on.
      _homeController.doGetPromoCode(
        fourPlusRating: false,
        homeService: SharedPrefs.readBoolValue(PrefConstants.isHomeService),
        nearest: true,
        orderBy: orderBy,
        serviceGender: selectedGender.value == 0 ? "male" : "female",
        lat: lat,
        lng: lng,
      );

      return;
    }

    /// 🔥 CASE 2: NONE (default)
    _homeController.doGetHomeSalonList(
      serviceGender: selectedGender.value == 0 ? "male" : "female",
      homeService: atHome,
      offset: 1,
      size: 500,
      lat: lat,
      lng: lng,
      orderBy: orderBy,
      nearest: false,
      fourPlusRating: false,
    );

    _homeController.doGetPromoCode(
      fourPlusRating: false,
      homeService: SharedPrefs.readBoolValue(PrefConstants.isHomeService),
      nearest: false,
      orderBy: orderBy,
      serviceGender: selectedGender.value == 0 ? "male" : "female",
      lat: lat,
      lng: lng,
    );
  }

  /*--------------------- Current location lat lng --------------------- */
  Future<void> getCurrentLatLng() async {
    if (SharedPrefs.readStringValue(PrefConstants.gender).isEmpty) {
      SharedPrefs.writeValue(PrefConstants.gender, "0");
    }
    await Permission.location.onDeniedCallback(() async {
      await Permission.location.request();
      showMessage("Location services are disabled.");
    }).onGrantedCallback(() async {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      SharedPrefs.writeValue(
          PrefConstants.longitude, position.longitude.toString());
      SharedPrefs.writeValue(
          PrefConstants.latitude, position.latitude.toString());

      Placemark place = placeMarks[0];
      _authController.userCity = "${place.locality}";
      _authController.userCurrentLocation =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
      SharedPrefs.writeValue(
          PrefConstants.address, _authController.userCurrentLocation);
      SharedPrefs.writeValue(PrefConstants.userCity, _authController.userCity);
      _homeController.doGetMakePackageData();
      _homeController.doGetHomeCategory(
        gender: selectedGender.value == 0 ? "male" : "female",
      );

      _homeController.doGetPromoCode(
          fourPlusRating: false,
          homeService: SharedPrefs.readBoolValue(PrefConstants.isHomeService),
          nearest: false,
          orderBy: "",
          serviceGender: selectedGender.value == 0 ? "male" : "female",
          lat:
              double.parse(SharedPrefs.readStringValue(PrefConstants.latitude)),
          lng: double.parse(
              SharedPrefs.readStringValue(PrefConstants.longitude)));

      _homeController
          .doGetHomeSalonList(
              serviceGender: selectedGender.value == 0 ? "male" : "female",
              homeService: atHome,
              offset: 1,
              size: 500,
              lat: position.latitude,
              lng: position.longitude,
              orderBy: "",
              nearest: false,
              fourPlusRating: false)
          .then((_) {
        // if (mounted) setState(() => _isInitialLoad = false);
      });
      SharedPrefs.writeValue(PrefConstants.isFirstTime, true);
    }).onPermanentlyDeniedCallback(() async {
      openAppSettings();
      Geolocator.openLocationSettings();
      showMessage(
          "Location permissions are permanently denied, we cannot request permissions.");
    }).onRestrictedCallback(() async {
      logger.e("Setting call Back");
    }).onLimitedCallback(() {
      showMessage("Notification Permission Request Limited");
    }).onProvisionalCallback(() {
      logger.e("Final Call Back");
    }).request();

    // if (await Permission.location.isGranted) {
    //   Position position = await Geolocator.getCurrentPosition();
    //   List<Placemark> placeMarks =
    //   await placemarkFromCoordinates(position.latitude, position.longitude);
    //
    //   SharedPrefs.writeValue(
    //       PrefConstants.longitude, position.longitude.toString());
    //   SharedPrefs.writeValue(
    //       PrefConstants.latitude, position.latitude.toString());
    //
    //   SharedPrefs.writeValue(PrefConstants.userCity, _authController.userCity);
    //   SharedPrefs.writeValue(
    //       PrefConstants.address, _authController.userCurrentLocation);
    //
    //   Placemark place = placeMarks[0];
    //   _authController.userCity = "${place.locality}";
    //   _authController.userCurrentLocation =
    //   "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
    //   SharedPrefs.writeValue(
    //       PrefConstants.address, _authController.userCurrentLocation);
    //   SharedPrefs.writeValue(PrefConstants.userCity, _authController.userCity);
    //
    //   _homeController.doGetMakePackageData();
    //   _homeController.doGetHomeCategory(
    //     gender: selectedGender.value == 0 ? "male" : "female",
    //   );
    //
    //   _homeController.doGetPromoCode(
    //       fourPlusRating: false,
    //       homeService: SharedPrefs.readBoolValue(PrefConstants.isHomeService),
    //       nearest: false,
    //       orderBy: "",
    //       serviceGender: selectedGender.value == 0 ? "male" : "female",
    //       lat:
    //       double.parse(SharedPrefs.readStringValue(PrefConstants.latitude)),
    //       lng: double.parse(
    //           SharedPrefs.readStringValue(PrefConstants.longitude)));
    //
    //   _homeController.doGetHomeSalonList(
    //       serviceGender: selectedGender.value == 0 ? "male" : "female",
    //       homeService: atHome,
    //       offset: 1,
    //       size: 500,
    //       lat: position.latitude,
    //       lng: position.longitude,
    //       orderBy: "",
    //       nearest: false,
    //       fourPlusRating: false);
    //   SharedPrefs.writeValue(PrefConstants.isFirstTime, true);
    // }
    loadHomeData();
  }

  void loadHomeData() {
    _homeController.doCheckPendingReview();
    //_homeController.doGetBookingHistory();
    _homeController.doGetCurrentBookingListData();
    if (SharedPrefs.readStringValue(PrefConstants.gender).isEmpty) {
      SharedPrefs.writeValue(PrefConstants.gender, "0");
    }
  }

  // Future<void> getCurrentLatLng() async {
  //   LocationPermission permission;
  //
  //   permission = await Geolocator.checkPermission();
  //
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     // 👉 ONLY here open settings
  //     showDialog(
  //       context: context,
  //       builder: (_) => AlertDialog(
  //         title: const Text("Location Permission Required"),
  //         content: const Text(
  //           "Please enable location access in Settings to find nearby salons.",
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Geolocator.openAppSettings();
  //               Get.back();
  //             },
  //             child: const Text("Open Settings"),
  //           ),
  //         ],
  //       ),
  //     );
  //     return;
  //   }
  //
  //   if (permission == LocationPermission.always ||
  //       permission == LocationPermission.whileInUse) {
  //
  //     final position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //
  //     final placeMarks =
  //     await placemarkFromCoordinates(position.latitude, position.longitude);
  //
  //     final place = placeMarks.first;
  //
  //     _authController.userCity = place.locality ?? "";
  //     _authController.userCurrentLocation =
  //     "${place.street}, ${place.locality}";
  //
  //     SharedPrefs.writeValue(PrefConstants.latitude, position.latitude.toString());
  //     SharedPrefs.writeValue(PrefConstants.longitude, position.longitude.toString());
  //     SharedPrefs.writeValue(PrefConstants.userCity, _authController.userCity);
  //     SharedPrefs.writeValue(PrefConstants.address, _authController.userCurrentLocation);
  //
  //     SharedPrefs.writeValue(PrefConstants.isFirstTime, true);
  //
  //     loadHomeData(position.latitude, position.longitude);
  //   }
  // }
  //
  // void loadHomeData(double lat, double lng) {
  //   _homeController.doGetMakePackageData();
  //   _homeController.doGetHomeCategory(
  //     gender: selectedGender.value == 0 ? "male" : "female",
  //   );
  //
  //   _homeController.doGetPromoCode(
  //     fourPlusRating: false,
  //     homeService: SharedPrefs.readBoolValue(PrefConstants.isHomeService),
  //     nearest: false,
  //     orderBy: "",
  //     serviceGender: selectedGender.value == 0 ? "male" : "female",
  //     lat: lat,
  //     lng: lng,
  //   );
  //
  //   _homeController.doGetHomeSalonList(
  //     serviceGender: selectedGender.value == 0 ? "male" : "female",
  //     homeService: atHome,
  //     offset: 1,
  //     size: 500,
  //     lat: lat,
  //     lng: lng,
  //     orderBy: "",
  //     nearest: false,
  //     fourPlusRating: false,
  //   );
  //   _homeController.doCheckPendingReview();
  //   _homeController.doGetBookingHistory();
  //   _homeController.doGetCurrentBookingListData();
  //   if (SharedPrefs.readStringValue(PrefConstants.gender).isEmpty) {
  //     SharedPrefs.writeValue(PrefConstants.gender, "0");
  //   }
  // }
}
