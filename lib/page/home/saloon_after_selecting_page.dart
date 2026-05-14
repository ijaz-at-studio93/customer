import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/home/_ImageViewerSheet.dart';
import 'package:salon_customer/page/home/home_page.dart';
import 'package:salon_customer/page/home/salon_rating_page.dart';
import 'package:salon_customer/page/home/widget/over_view_list_tile_widget.dart';
import 'package:salon_customer/page/home/widget/selected_services_sheet_page.dart';
import 'package:salon_customer/page/home/widget/stylist_list_grid_widget.dart';
import 'package:salon_customer/page/stylist/selecting_artist_bottom_sheet.dart';
import 'package:salon_customer/project_specific/ProgressContainerView.dart';
import 'package:salon_customer/project_specific/remove_and_add_service_dialog.dart';
import 'package:salon_customer/project_specific/status_bar_color_appbar.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:share_plus/share_plus.dart';
import '../../constant/color_constant.dart';
import '../../main.dart';
import '../../project_specific/text_theme.dart';
import '../appointment/appointment_booking_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:salon_customer/service/analytics_service.dart';

import '../appointment/qr_page.dart';

class SaloonAfterSelectingServicesPage extends StatefulWidget {
  late bool isPayNowMode;
  final String id;
  final VoidCallback callback;

  SaloonAfterSelectingServicesPage({
    super.key,
    required this.id,
    required this.isPayNowMode,
    required this.callback,
  });

  @override
  State<SaloonAfterSelectingServicesPage> createState() =>
      _SaloonAfterSelectingServicesPageState();
}

class _SaloonAfterSelectingServicesPageState
    extends State<SaloonAfterSelectingServicesPage>
    with SingleTickerProviderStateMixin {
  final _homeController = Get.find<HomeController>();

  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};
  bool showFullName = false;
  String expandedCategoryId = "";
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  PageController? _offerPageController;
  Timer? _offerAutoScrollTimer;
  int _currentOfferPage = 0;
  List<String> _images = [];
  Worker? _dataWatcher; // GetX worker to listen to data updates
  late AnimationController _waController;
  late Animation<double> _waScale;

  bool loading = false;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();

    // init page controller for pageview
    _pageController = PageController(initialPage: 0);
    _offerPageController = PageController(initialPage: 0);

    // Fetch data and then load images once the API response is received.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // Await the fetch so we can load images right after data is available
      try {
        await _homeController.doGetHomeSalonDetails(
          salonId: widget.id,
          serviceGender:
              SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                  ? "male"
                  : "female",
          lat: SharedPrefs.readStringValue(PrefConstants.latitude),
          lng: SharedPrefs.readStringValue(PrefConstants.longitude),
        );
      } catch (_) {
        // ignore fetch error here; still attempt to parse whatever is available
      }

      // 📊 view_item — salon page opened
      try {
        final salonData = _homeController.homeSalonDetailsData.data;
        AnalyticsService.instance.logViewItem(
          salonId: widget.id,
          salonName: salonData?.displayName ?? salonData?.name ?? '',
        );
      } catch (_) {}

      // load other data (you can await these too if they return futures)
      try {
        await _homeController.doGetSalonDetailsService(
          salonId: widget.id,
          serviceGender:
              SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                  ? "male"
                  : "female",
        );
      } catch (_) {}

      if (expandedCategoryId.isEmpty) {
        final selected =
            _homeController.salonDetailsListData.data?.selectedCategories;

        final recommended =
            _homeController.salonDetailsListData.data?.recommendedCategories;

        if (selected != null && selected.isNotEmpty) {
          expandedCategoryId = selected.first.id ?? "";
        } else if (recommended != null && recommended.isNotEmpty) {
          expandedCategoryId = recommended.first.id ?? "";
        }
      }

      try {
        await _homeController.doGetSalonPromoCode(
          salonId: widget.id,
        );
      } catch (_) {}

      try {
        await _homeController.doGetSalonArtiestListData(salonId: widget.id);
      } catch (_) {}

      try {
        await _homeController.doGetCart();
        await _homeController.doGetSalonCart(salonId: widget.id);
        await _homeController.doGetSalonProducts(salonId: widget.id);
      } catch (_) {}

      // Now that the main fetch has finished (or at least attempted), load images
      _loadImagesFromData();
      //prepareCategoryKeys();
    });

    _waController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // slow
    )..repeat(reverse: true);

    _waScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _waController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _genderSwitch() {
    return GestureDetector(
      onTap: () async {
        String newGender =
            SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                ? "1"
                : "0";

        SharedPrefs.writeValue(PrefConstants.gender, newGender);
        selectedGender.value = newGender == "0" ? 0 : 1;

        await _homeController.doGetSalonDetailsService(
          salonId: widget.id,
          serviceGender: newGender == "0" ? "male" : "female",
        );

        setState(() {});
      },
      child: Container(
        width: 93,
        height: 24,
        //padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: changeTheme(
                  SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                      ? "1"
                      : "0",
                ) ??
                ColorConstant.primaryColor,
            width: 2, // 👈 adjust thickness if needed
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center, // 👈 CENTER
          crossAxisAlignment: CrossAxisAlignment.center, // 👈 vertical center
          children: [
            Image.asset(
              SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                  ? AssetsConstant.genderSwitchIcon
                  : AssetsConstant.genderSwitchIcon1,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 3),
            Text(
              SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                  ? "Women"
                  : "Men",
              style: TextStyle(
                fontFamily: "Outfit",
                fontWeight: FontWeight.w800,
                fontSize: 14,
                //color: Colors.white,
                color: changeTheme(
                  SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                      ? "1"
                      : "0",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadImagesFromData() {
    final data = _homeController.homeSalonDetailsData.data;
    final dynamic raw =
        data?.images; // dynamic because backend might send different types

    List<String> imgs = [];

    try {
      if (raw == null) {
        imgs = [];
      } else if (raw is List) {
        // Case 1: already a List from backend
        imgs = raw
            .map((e) => e?.toString() ?? "")
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (raw is String) {
        // Case 2: backend gave a string
        final str = raw.trim();
        if (str.startsWith('[') && str.endsWith(']')) {
          // JSON array in string
          final parsed = jsonDecode(str);
          if (parsed is List) {
            imgs = parsed
                .map((e) => e?.toString() ?? "")
                .where((e) => e.isNotEmpty)
                .toList();
          }
        } else if (str.contains(',')) {
          // Comma-separated
          imgs = str
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        } else {
          // Single URL string
          if (str.isNotEmpty) imgs = [str];
        }
      } else {
        // Case 3: unknown type → fallback to toString
        final s = raw.toString();
        if (s.isNotEmpty) imgs = [s];
      }
    } catch (e) {
      // Fallback to "image" field if parsing fails
      final fallback = data?.image;
      if (fallback != null && fallback.toString().isNotEmpty) {
        imgs = [fallback.toString()];
      } else {
        imgs = [];
      }
    }

    // Prefix with APIConstants.image if it's a relative path
    imgs = imgs.map((url) {
      if (url.startsWith("http") || url.startsWith("https")) return url;
      return "${APIConstants.image}$url";
    }).toList();

    setState(() {
      _images = imgs;
      _currentPage = 0;
    });

// Instead of starting auto-scroll immediately, prefetch first 1–2 images
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final toPrefetch = _images.length >= 2 ? 2 : _images.length;
      for (int i = 0; i < toPrefetch; i++) {
        final url = _images[i];
        try {
          await precacheImage(CachedNetworkImageProvider(url), context);
        } catch (e) {
          // ignore prefetch errors
        }
      }

      // Now start auto-scroll only if multiple images exist
      if (_images.length > 1) {
        _startAutoScroll();
      } else {
        _stopAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    if (_images.length <= 1) return;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_pageController.hasClients && _images.isNotEmpty) {
        final next = (_currentPage + 1) % _images.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _startOfferAutoScroll(int length) {
    if (length <= 1) return;
    if (_offerPageController == null) return;

    _offerAutoScrollTimer?.cancel();

    _offerAutoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      if (_offerPageController == null) return;
      if (!_offerPageController!.hasClients) return;

      final next = (_currentOfferPage + 1) % length;

      _offerPageController!.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopOfferAutoScroll() {
    _offerAutoScrollTimer?.cancel();
  }

  String serviceId = "";

  @override
  Widget build(BuildContext context) {
    final isNonMandatory =
        _homeController.homeSalonDetailsData.data?.isNonMandatory ?? false;

    final noServices = (_homeController
                .salonDetailsListData.data?.selectedCategories?.isEmpty ??
            true) &&
        (_homeController
                .salonDetailsListData.data?.recommendedCategories?.isEmpty ??
            true);
    final noRecommendedCategories = _homeController
            .salonDetailsListData.data?.recommendedCategories?.isEmpty ??
        true;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        widget.callback.call();
      },
      child: SafeArea(
          bottom: true,
          top: false,
          child: Stack(children: [
            Scaffold(
              appBar: statusBarTheme(context),
              backgroundColor: ColorConstant.whiteColor,
              body: Obx(
                () => ProgressContainerView(
                  isProgressRunning: _homeController.showProgress,
                  // child: ListView(
                  //   controller: _scrollController,
                  //   physics: noServices
                  //       ? const NeverScrollableScrollPhysics()
                  //       : const BouncingScrollPhysics(),
                  //   children: [
                  //     _imageHeaderWidget(),
                  //     _headerWidget(),
                  //     const SizedBox(height: 15),
                  //     _offerWidget(),
                  //     const SizedBox(height: 10),
                  //     _tabBarView(),
                  //     const SizedBox(height: 110)
                  //   ],
                  // ),
                  child: Stack(
                    children: [
                      /// 🔥 MAIN CONTENT
                      Opacity(
                        //opacity: isPayNowMode ? 0.4 : 1,
                        opacity: (isNonMandatory && widget.isPayNowMode) ? 0.4 : 1,
                        child: IgnorePointer(
                          ignoring: (isNonMandatory && widget.isPayNowMode),
                          child: ListView(
                            controller: _scrollController,
                            physics: noServices
                                ? const NeverScrollableScrollPhysics()
                                : const BouncingScrollPhysics(),
                            children: [
                              _imageHeaderWidget(),
                              _headerWidget(),
                              const SizedBox(height: 15),
                              _offerWidget(),
                              const SizedBox(height: 10),
                              _tabBarView(),
                              const SizedBox(height: 110),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: (isNonMandatory && widget.isPayNowMode)
                ? const SizedBox()
                : Obx(
                () =>
                    _homeController.getSalonServiceAddCartModel.data
                                ?.salonServicesWithProduct?.isEmpty ??
                            false ||
                                _homeController.getSalonServiceAddCartModel.data
                                        ?.salonServicesWithProduct ==
                                    null
                        ? const SizedBox()
                        : Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: Get.width,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: ColorConstant.whiteColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x1E000000),
                                      blurRadius: 10,
                                      offset: Offset(0, -7),
                                      spreadRadius: 0,
                                    )
                                  ],
                                ),
                                clipBehavior: Clip.none,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            _homeController
                                                        .getSalonServiceAddCartModel
                                                        .data
                                                        ?.previewImages
                                                        ?.isEmpty ??
                                                    false
                                                ? const SizedBox()
                                                : Row(
                                                    children: [
                                                      _homeController
                                                                  .getSalonServiceAddCartModel
                                                                  .data
                                                                  ?.previewImages
                                                                  ?.length ==
                                                              1
                                                          ? Row(
                                                              children: [
                                                                for (int i = 0;
                                                                    i < 1;
                                                                    i++)
                                                                  Align(
                                                                    widthFactor:
                                                                        0.8,
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              100),
                                                                      child:
                                                                          CachedNetworkImage(
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        width:
                                                                            30,
                                                                        height:
                                                                            30,
                                                                        imageUrl:
                                                                            "${APIConstants.image}${_homeController.getSalonServiceAddCartModel.data?.previewImages?[i] ?? ""}",
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                const Image(
                                                                          image:
                                                                              AssetImage(AssetsConstant.placeHolder),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          width:
                                                                              30,
                                                                          height:
                                                                              30,
                                                                        ),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            const Image(
                                                                          image:
                                                                              AssetImage(AssetsConstant.placeHolder),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          width:
                                                                              30,
                                                                          height:
                                                                              30,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                              ],
                                                            )
                                                          : _homeController
                                                                      .getSalonServiceAddCartModel
                                                                      .data
                                                                      ?.previewImages
                                                                      ?.length ==
                                                                  2
                                                              ? Row(
                                                                  children: [
                                                                    for (int i =
                                                                            0;
                                                                        i < 2;
                                                                        i++)
                                                                      Align(
                                                                        widthFactor:
                                                                            0.8,
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(100),
                                                                          child:
                                                                              CachedNetworkImage(
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            width:
                                                                                30,
                                                                            height:
                                                                                30,
                                                                            imageUrl:
                                                                                "${APIConstants.image}${_homeController.getSalonServiceAddCartModel.data?.previewImages?[i] ?? ""}",
                                                                            placeholder: (context, url) =>
                                                                                const Image(
                                                                              image: AssetImage(AssetsConstant.placeHolder),
                                                                              fit: BoxFit.cover,
                                                                              width: 30,
                                                                              height: 30,
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                const Image(
                                                                              image: AssetImage(AssetsConstant.placeHolder),
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
                                                                    for (int i =
                                                                            0;
                                                                        i < 2;
                                                                        i++)
                                                                      Align(
                                                                        widthFactor:
                                                                            0.7,
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(100),
                                                                          child:
                                                                              CachedNetworkImage(
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            width:
                                                                                35,
                                                                            height:
                                                                                35,
                                                                            imageUrl:
                                                                                "${APIConstants.image}${_homeController.getSalonServiceAddCartModel.data?.previewImages?[i] ?? ""}",
                                                                            placeholder: (context, url) =>
                                                                                const Image(
                                                                              image: AssetImage(AssetsConstant.placeHolder),
                                                                              fit: BoxFit.cover,
                                                                              width: 35,
                                                                              height: 35,
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                const Image(
                                                                              image: AssetImage(AssetsConstant.placeHolder),
                                                                              fit: BoxFit.cover,
                                                                              width: 35,
                                                                              height: 35,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    const SizedBox(
                                                                        width:
                                                                            2),
                                                                    Container(
                                                                      width: 33,
                                                                      height:
                                                                          33,
                                                                      decoration: const BoxDecoration(
                                                                          color: ColorConstant
                                                                              .primaryColor,
                                                                          shape:
                                                                              BoxShape.circle),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          _homeController.getSalonServiceAddCartModel.data?.previewImages?.length.toString() ??
                                                                              "",
                                                                          style: AppTextTheme
                                                                              .medium
                                                                              .copyWith(
                                                                            color:
                                                                                ColorConstant.whiteColor,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                    ],
                                                  ),
                                            const SizedBox(width: 15),
                                            GestureDetector(
                                              onTap: () {
                                                showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                      topLeft:
                                                          Radius.circular(32),
                                                      topRight:
                                                          Radius.circular(32),
                                                    )),
                                                    context: context,
                                                    builder: (context) {
                                                      return SelectedServiceSheetPage(
                                                        salonId: widget.id,
                                                        artistIds:
                                                            selectedArtistIdsGlobal
                                                                .value,
                                                        serviceId: serviceId,
                                                      );
                                                    });
                                              },
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Obx(() {
                                                    final totalItems =
                                                        _homeController
                                                            .getTotalItems();
                                                    final totalPrice =
                                                        _homeController
                                                            .getTotalPrice();
                                                    final priceNoGST =
                                                        _homeController
                                                            .getPriceNoGST();

                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "$totalItems Added",
                                                              style:
                                                                  AppTextTheme
                                                                      .bold
                                                                      .copyWith(
                                                                fontSize: 11,
                                                                color: ColorConstant
                                                                    .grayTextColor,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 2),
                                                            Image.asset(
                                                              AssetsConstant
                                                                  .arrowUpIcon,
                                                              height: 8,
                                                              width: 11,
                                                              color:
                                                                  changeTheme(
                                                                SharedPrefs.readStringValue(
                                                                    PrefConstants
                                                                        .gender),
                                                              ),
                                                            )
                                                          ],
                                                        ),

                                                        Text(
                                                          //"₹${totalPrice.toStringAsFixed(2)}",
                                                          "₹${priceNoGST.toStringAsFixed(2)}",
                                                          style: AppTextTheme
                                                              .bold
                                                              .copyWith(
                                                            fontSize: 17,
                                                            color: ColorConstant
                                                                .blackColor,
                                                          ),
                                                        ),

                                                        // Text(
                                                        //   "GST is included",
                                                        //   style: AppTextTheme.regular.copyWith(
                                                        //     color: ColorConstant.blackColor,
                                                        //     fontSize: 12,
                                                        //   ),
                                                        // )
                                                      ],
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      // onTap: () {
                                      //   if (selectedArtistIdsGlobal
                                      //       .value.isNotEmpty) {
                                      //     Get.to(() => AppointmentBookingPage(
                                      //           artistIds:
                                      //               selectedArtistIdsGlobal
                                      //                   .value,
                                      //         ));
                                      //   } else {
                                      //     // showModalBottomSheet(
                                      //     //     isScrollControlled: true,
                                      //     //     isDismissible: false,
                                      //     //     enableDrag: false,
                                      //     //     shape: const RoundedRectangleBorder(
                                      //     //         borderRadius: BorderRadius.only(
                                      //     //           topLeft: Radius.circular(32),
                                      //     //           topRight: Radius.circular(32),
                                      //     //         )),
                                      //     //     context: context,
                                      //     //     builder: (context) {
                                      //     //       return SelectingArtistBottomSheetWidget(
                                      //     //         salonId: widget.id,
                                      //     //         serviceId: serviceId,
                                      //     //         callback: () {
                                      //     //           setState(() {});
                                      //     //         },
                                      //     //       );
                                      //     //     });
                                      //
                                      //     Get.bottomSheet(
                                      //       SelectingArtistBottomSheetWidget(
                                      //         salonId: widget.id,
                                      //         serviceId: serviceId,
                                      //         callback: () {
                                      //           setState(() {});
                                      //         },
                                      //       ),
                                      //       isScrollControlled: true,
                                      //       isDismissible: false,
                                      //       enableDrag: false,
                                      //       shape: const RoundedRectangleBorder(
                                      //         borderRadius: BorderRadius.only(
                                      //           topLeft: Radius.circular(32),
                                      //           topRight: Radius.circular(32),
                                      //         ),
                                      //       ),
                                      //     );
                                      //   }
                                      // },
                                      onTap: () async {
                                        // try {
                                        //   await facebookAppEvents.logAddToCart(
                                        //     id: widget.id,
                                        //     type: 'salon_services',
                                        //     currency: 'INR',
                                        //     price: _homeController.getTotalPrice(),
                                        //   );
                                        //   print("✅ FB AddToCart Event Sent");
                                        // } catch (e) {
                                        //   print("❌ FB AddToCart Error: $e");
                                        // }
                                        final cartData = _homeController
                                            .getSalonServiceAddCartModel.data?.salonServicesWithProduct ?? [];

                                        if (cartData.isEmpty) return;

                                        final contents = cartData.map((item) => {
                                          'id': item.serviceId.toString(), // adjust field if needed
                                          'quantity': 1,
                                          'item_price': (item.price ?? 0).toDouble(),
                                        }).toList();

                                        final totalPrice = _homeController.getTotalPrice().toDouble();

                                        try {
                                          await facebookAppEvents.logAddToCart(
                                            id: cartData.first.serviceId.toString(), // ✅ REQUIRED by SDK
                                            type: 'product', // ✅ REQUIRED
                                            currency: 'INR',
                                            price: totalPrice,
                                            parameters: {
                                              'content_type': 'product',
                                              'contents': contents, // ✅ THIS FIXES META WARNING
                                              'num_items': cartData.length,
                                            },
                                          );

                                          print("✅ FB AddToCart (Multi-Service) Sent");
                                        } catch (e) {
                                          print("❌ FB Error: $e");
                                        }
                                        await facebookAppEvents.flush();
                                        selectedArtistIdsGlobal.value = [];
                                        print("CLICK");
                                        print("selected: ${selectedArtistIdsGlobal.value}");
                                        print("data: ${_homeController.getSalonDetailsArtiestData.data}");
                                        final selected = selectedArtistIdsGlobal.value;

                                        final data = _homeController.getSalonDetailsArtiestData.data;

                                        final hasNoArtist = data == null || data.isEmpty;

                                        /// ✅ CASE 1: stylist selected
                                        if (selected.isNotEmpty) {
                                          print('1111111111111 is causing issue');
                                          Get.to(() => AppointmentBookingPage(
                                            artistIds: selected,
                                          ));
                                        }

                                        /// ✅ CASE 2: no artist available → auto assign
                                        else if (hasNoArtist) {
                                          print('222222222 is causing issue');
                                          Get.to(() => AppointmentBookingPage(
                                            artistIds: const [],
                                          ));
                                        }

                                        /// ❌ CASE 3: artists exist but not selected → open bottom sheet
                                        else {
                                          print('333333333333');
                                          Get.bottomSheet(
                                            SelectingArtistBottomSheetWidget(
                                              salonId: widget.id,
                                              serviceId: serviceId,
                                              callback: () {
                                                setState(() {});
                                              },
                                            ),
                                            isScrollControlled: true,
                                            isDismissible: false,
                                            enableDrag: false,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(32),
                                                topRight: Radius.circular(32),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 155, //Get.width*0.28,
                                        decoration: BoxDecoration(
                                          color: changeTheme(
                                              SharedPrefs.readStringValue(
                                                  PrefConstants.gender)),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ValueListenableBuilder(
                                                valueListenable:
                                                    selectedArtistIdsGlobal,
                                                builder: (context, v, c) {
                                                  final hasSelectedStylist = selectedArtistIdsGlobal.value.isNotEmpty;
                                                  final hasNoArtist = (_homeController.getSalonDetailsArtiestData.data ?? []).isEmpty;
                                                  return Text(
                                                    (hasSelectedStylist || hasNoArtist)
                                                        ? "Book Slot"
                                                        : "Select Stylist",
                                                    style: const TextStyle(
                                                      fontFamily: "Outfit",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                }),
                                            //const SizedBox(width: 5),
                                            const Icon(
                                              Icons.arrow_forward,
                                              color: ColorConstant.whiteColor,
                                              size: 20,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
              ),
              bottomNavigationBar: (isNonMandatory && widget.isPayNowMode)
                  ? Stack(
                clipBehavior: Clip.none,
                children: [

                  /// 🔥 CURVED BOX (BUTTON CONTAINER)
                  Container(
                    margin: const EdgeInsets.only(top: 20), // space for banner overlap
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10)
                      ],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      border: Border.all(
                        color: ColorConstant.primaryColor, // ✅ BORDER COLOR
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            /// BOOK NOW
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 40,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: ColorConstant.primaryColor,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    widget.isPayNowMode = false;
                                  });
                                },
                                child: Text(
                                  "Book Now",
                                  style: TextStyle(
                                    color: ColorConstant.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Outfit'
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 25),

                            /// PAY BILL
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorConstant.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {

                                  /// STEP 1: Refresh current bookings
                                  await _homeController.doGetCurrentBookingListData();

                                  /// STEP 2: Find existing pay-now booking
                                  await _homeController.findPayNowBooking(widget.id);

                                  final existing = _homeController.payNowBooking.value;

                                  /// ✅ STEP 3: If exists → reuse
                                  if (existing != null) {
                                    Get.to(() => QRCodePage(
                                      appointmentId: existing.appointmentId ?? '',
                                      isBooking: true,
                                    ));
                                    return;
                                  }

                                  /// ❌ STEP 4: Else create new
                                  final res = await _homeController.createNonMandatoryBooking(
                                    salonId: widget.id,
                                  );

                                  Get.to(() => QRCodePage(
                                    appointmentId: res?.data?.salonAppointmentId ?? '',
                                    isBooking: false,
                                  ));
                                },
                                child: const Text("Pay Bill",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      fontFamily: 'Outfit'
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  ),

                  /// 🔥 FLOATING BANNER (OVERLAP EFFECT)
                  Positioned(
                    top: -15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 250,
                        height: 35,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: ColorConstant.primaryColor,
                        ),
                        child: const Text(
                          "Booking Not Mandatory",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : null,
            ),

            Positioned(
              top: 50,
              left: 10,
              child: buttonWidget(
                imageUrl: AssetsConstant.backArrow,
                onPress: () {
                  Navigator.of(context).maybePop();
                  widget.callback.call();
                },
                h: 15,
                w: 15,
              ),
            ),
            /// ✅ ADD THIS NEW MENU BOOK BUTTON HERE
            if (!noRecommendedCategories && !(isNonMandatory && widget.isPayNowMode))
              Positioned(
                  right: 6,
                  // bottom: (_homeController.getServiceAddCartModel.data
                  //     ?.servicesWithProduct?.isNotEmpty ??
                  //     false)
                  //     ? 70   // when cart visible
                  //     : 30,  // when cart empty
                  bottom: 65,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        openMenuBook();
                      },
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        padding: const EdgeInsets.all(6),

                        /// ✅ OUTER LAYER (full color)
                        decoration: BoxDecoration(
                          // color: changeTheme(
                          //   SharedPrefs.readStringValue(PrefConstants.gender),
                          // ),
                          color: Colors.black,
                          shape: BoxShape.circle,
                          // boxShadow: const [
                          //   BoxShadow(
                          //     color: Colors.black26,
                          //     blurRadius: 6,
                          //     offset: Offset(0, 3),
                          //   )
                          // ],
                        ),

                        child: Container(
                          width: 55,
                          height: 55,

                          /// ✅ INNER CIRCLE (light opacity)
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // color: changeTheme(
                            //   SharedPrefs.readStringValue(PrefConstants.gender),
                            // )?.withOpacity(0.12), // 👈 LOW OPACITY
                            color: Colors.black,
                            // border: Border.all(
                            //   color: changeTheme(
                            //     SharedPrefs.readStringValue(PrefConstants.gender),
                            //   ) ?? ColorConstant.primaryColor, // 👈 SAME AS GENDER
                            //   width: 1.5,
                            // ),
                          ),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.book_open,
                                color: Colors.white,
                                // color: changeTheme(
                                //   SharedPrefs.readStringValue(PrefConstants.gender),
                                // ), // 👈 MATCH ICON
                                size: 30,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Menu",
                                style: TextStyle(
                                  fontFamily: "Outfit",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
          ])),
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _offerAutoScrollTimer?.cancel();
    _offerPageController?.dispose();
    _dataWatcher?.dispose();
    _waController.dispose();
    super.dispose();
  }

  /*------------ Back Button --------------*/
  GestureDetector buttonWidget(
      {required String imageUrl,
      required VoidCallback onPress,
      required double h,
      required double w}) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorConstant.blackColor.withOpacity(0.50),
          ),
          child: Center(
            child: Image.asset(
              imageUrl,
              width: w,
              height: h,
              fit: BoxFit.contain,
            ),
          )),
    );
  }

  void prepareCategoryKeys() {
    final selected =
        _homeController.salonDetailsListData.data?.selectedCategories ?? [];

    final recommended =
        _homeController.salonDetailsListData.data?.recommendedCategories ?? [];

    for (var c in selected) {
      _categoryKeys.putIfAbsent(c.id!, () => GlobalKey());
    }

    for (var c in recommended) {
      _categoryKeys.putIfAbsent(c.id!, () => GlobalKey());
    }
  }

  // void openMenuBook() {
  //
  //   final selected =
  //       _homeController.salonDetailsListData.data?.selectedCategories ?? [];
  //
  //   final recommended =
  //       _homeController.salonDetailsListData.data?.recommendedCategories ?? [];
  //
  //   final List<dynamic> categories = [...selected, ...recommended];
  //
  //   showModalBottomSheet(
  //     context: context,
  //     useRootNavigator: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //
  //       return ListView.builder(
  //         itemCount: categories.length,
  //         itemBuilder: (context, index) {
  //
  //           final cat = categories[index];
  //
  //           return ListTile(
  //             title: Text(cat.name ?? ""),
  //             onTap: () {
  //
  //               Navigator.pop(context);
  //
  //               scrollToCategory(cat.id ?? "");
  //             },
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void openMenuBook() {
    final selected =
        _homeController.salonDetailsListData.data?.selectedCategories ?? [];

    final recommended =
        _homeController.salonDetailsListData.data?.recommendedCategories ?? [];

    final List<dynamic> categories = [...selected, ...recommended];

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent, // 👈 important
            child: Container(
              width: Get.width * 0.75,
              constraints: BoxConstraints(
                maxHeight: Get.height * 0.6,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      scrollToCategory(cat.id ?? "");
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              cat.name ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if ((cat.services?.length ?? 0) > 0)
                            Text(
                              "${cat.services?.length ?? 0}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void scrollToCategory(String id) async {
    setState(() {
      expandedCategoryId = id;
    });

    /// Wait for expansion animation
    await Future.delayed(const Duration(milliseconds: 350));

    final ctx = _categoryKeys[id]?.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    /// 🔥 THIS IS THE KEY PART
    final offset = _scrollController.offset + position.dy;

    _scrollController.animateTo(
      offset - 80, // 👈 adjust for header height
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  /*-------------- Image header Widget ------------*/
  Widget _imageHeaderWidget() {
    final data = _homeController.homeSalonDetailsData.data;
    return Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 6), // 👈 THIS creates gap
        child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                SizedBox(
                  width: 391, //Get.width,
                  height: 210, //Get.height * 0.30,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanDown: (_) => _stopAutoScroll(),
                    onPanCancel: () {
                      if (_images.length > 1) _startAutoScroll();
                    },
                    onPanEnd: (_) {
                      if (_images.length > 1) _startAutoScroll();
                    },
                    child: _images.isEmpty
                        ? CachedNetworkImage(
                            width: 391, //Get.width,
                            height: 210, //Get.height * 0.30,
                            fit: BoxFit.cover,
                            imageUrl:
                                "${APIConstants.image}${_homeController.homeSalonDetailsData.data?.image ?? ""}",
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            placeholder: (context, url) => Image(
                              image:
                                  const AssetImage(AssetsConstant.placeHolder),
                              width: 391, //Get.width,
                              height: 210, // Get.height * 0.30,
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) => Image(
                              image:
                                  const AssetImage(AssetsConstant.placeHolder),
                              width: 391, //Get.width,
                              height: 210, //Get.height * 0.30,
                              fit: BoxFit.cover,
                            ),
                          )
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: _images.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final imageUrl = _images[index];
                              return CachedNetworkImage(
                                width: 391, //Get.width,
                                height: 210, //Get.height * 0.30,
                                fit: BoxFit.cover,
                                imageUrl: imageUrl,
                                placeholder: (context, url) => Image(
                                  image: const AssetImage(
                                      AssetsConstant.placeHolder),
                                  width: 391, //Get.width,
                                  height: 210, //Get.height * 0.30,
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (context, url, error) => Image(
                                  image: const AssetImage(
                                      AssetsConstant.placeHolder),
                                  width: 391, //Get.width,
                                  height: 210, //Get.height * 0.30,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                  ),
                ),

                // --- ORIGINAL GRADIENT (unchanged) ---
                Positioned(
                  child: Container(
                    width: 391, //Get.width,
                    height: 210, //Get.height * 0.30,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.02, 1.00),
                        end: Alignment(-0.02, -1),
                        colors: [Colors.black, Color(0x003D3636)],
                      ),
                    ),
                  ),
                ),

                // --- ORIGINAL TOP CONTROLS: back, search, share, favourite (UNCHANGED) ---
                Positioned(
                  top: 5,
                  left: 5,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // buttonWidget(
                      //   imageUrl: AssetsConstant.iconSearch,
                      //   onPress: () {
                      //     Get.to(() => StylistSearchPage(
                      //       salonName: _homeController
                      //           .homeSalonDetailsData.data?.name ??
                      //           "",
                      //       salonId: widget.id,
                      //     ));
                      //   },
                      //   h: 24,
                      //   w: 24,
                      // ),
                      // const SizedBox(width: 15),
                      buttonWidget(
                        imageUrl: AssetsConstant.shareIcon,
                        onPress: () {
                          // Get the link safely
                          final String? mapUrl = _homeController
                              .homeSalonDetailsData.data?.googleplaceid
                              ?.toString();
                          final String? name = _homeController
                              .homeSalonDetailsData.data?.name
                              ?.toString();

                          // Check if it exists and isn't empty
                          if (mapUrl != null && mapUrl.isNotEmpty) {
                            // Share the link with a clear message
                            Share.share(
                                "Visit $name on Google Maps: $mapUrl");
                          } else {
                            // Optional: Let the user know if the link is missing
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Location link not available.")),
                            );
                          }
                        },
                        h: 18,
                        w: 18,
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _homeController.homeSalonDetailsData.data
                                ?.isFavourite = !(_homeController
                                    .homeSalonDetailsData
                                    .data
                                    ?.isFavourite ??
                                false);
                            if (_homeController.homeSalonDetailsData.data
                                    ?.isFavourite ??
                                false) {
                              _homeController.doAddFavouriteSalon(
                                  salonId: widget.id);
                            } else {
                              _homeController.doRemoveFavouriteSalon(
                                  callback: () {}, salonId: widget.id);
                            }
                          });
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorConstant.blackColor
                                  .withOpacity(0.25)),
                          child: Center(
                              child: _homeController.homeSalonDetailsData
                                          .data?.isFavourite ??
                                      false
                                  ? const Icon(
                                      CupertinoIcons.heart_fill,
                                      color: Colors.red,
                                    )
                                  : const Icon(
                                      CupertinoIcons.heart,
                                      color: ColorConstant.whiteColor,
                                    )),
                        ),
                      )
                    ],
                  ),
                ),

                // --- ORIGINAL BOTTOM RATING BLOCK (UNCHANGED) ---
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 26,
                            width: 50,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.5),
                            decoration: BoxDecoration(
                              color: Color(0xFF16A34A), // better green
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _homeController
                                          .homeSalonDetailsData.data?.rating
                                          ?.toStringAsFixed(1) ??
                                      "0.0",
                                  style: const TextStyle(
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => SalonRatingPage(salonId: widget.id));
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// NUMBER
                                // Text(
                                //   "${_homeController.homeSalonDetailsData.data?.reviewCount ?? 0} ",
                                //   style: const TextStyle(
                                //     fontFamily: "Outfit",
                                //     fontSize: 13,
                                //     //color: Color(0xFF787878),
                                //     color: ColorConstant.whiteColor,
                                //     fontWeight: FontWeight.w800,
                                //   ),
                                // ),

                                /// REVIEWS + CUSTOM UNDERLINE
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${_homeController.homeSalonDetailsData.data?.reviewCount ?? 0}",
                                          style: const TextStyle(
                                            fontFamily: "Outfit",
                                            fontSize: 13,
                                            color: ColorConstant.whiteColor,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        const Text(
                                          "Reviews",
                                          style: TextStyle(
                                            fontFamily: "Outfit",
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: ColorConstant.whiteColor,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                        height:
                                            1), // 👈 slight spacing (better than 0)

                                    Container(
                                      height: 1.5,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        color: changeTheme(
                                              SharedPrefs.readStringValue(
                                                  PrefConstants.gender),
                                            ) ??
                                            ColorConstant.primaryColor,
                                        borderRadius: BorderRadius.circular(
                                            2), // 👈 smooth edges
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),

                // --- DOT INDICATOR (keeps bottom position) ---
                if (_images.length > 1)
                  Positioned(
                    bottom: 4,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(_images.length, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 18 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? ColorConstant.whiteColor
                                  : ColorConstant.whiteColor.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
              ],
            )));
  }

  /*---------- Header Widget ------------*/
  Container _headerWidget() {
    return Container(
      width: Get.width,
      color: ColorConstant.whiteColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(
          //   width: Get.width * 0.9,
          //   child: Text(
          //     maxLines: 2,
          //     _homeController.homeSalonDetailsData.data?.name ?? "",
          //     overflow: TextOverflow.ellipsis,
          //     style: AppTextTheme.bold.copyWith(
          //       fontFamily: "Outfit",        // ✅ Figma font
          //       fontWeight: FontWeight.w700, // ✅ Bold (not extra heavy)
          //       fontSize: 17,                // ✅ matches design
          //       color: ColorConstant.blackColor,
          //       height: 1.2,                 // ✅ tighter line spacing (important for 2 lines)
          //       letterSpacing: 0.2,          // ✅ slight polish (Figma feel)
          //     ),
          //   ),
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 TOP ROW (DISPLAY NAME + ARROW)
              Row(
                children: [
                  Flexible(
                    // ✅ FIXED
                    child: Text(
                      _homeController.homeSalonDetailsData.data?.displayName ??
                          "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTheme.bold.copyWith(
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: ColorConstant.blackColor,
                        height: 1,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 1),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          showFullName = !showFullName;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          showFullName
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 30,
                          color: changeTheme(
                            SharedPrefs.readStringValue(PrefConstants.gender),
                          ),
                        ),
                      )),
                ],
              ),

              /// 🔹 EXPANDED FULL NAME (BELOW)
              if (showFullName)
                Transform.translate(
                    offset: const Offset(0, -5),
                    child: Text(
                      _homeController.homeSalonDetailsData.data?.address ?? "",
                      style: AppTextTheme.medium.copyWith(
                        fontFamily: "Outfit",
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.6),
                        height: 1,
                      ),
                    ))
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// LEFT → Timing
              Row(
                children: [
                  Image.asset(
                    AssetsConstant.calender,
                    height: 12,
                    width: 12,
                    color: changeTheme(SharedPrefs.readStringValue(PrefConstants
                        .gender)), // fixed purple (better than dynamic here)
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Mon - Sun ${convertTimeTo12HourFormat(_homeController.homeSalonDetailsData.data?.startTiming ?? "")} to ${convertTimeTo12HourFormat(_homeController.homeSalonDetailsData.data?.endTiming ?? "")}",
                    style: const TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              /// RIGHT → Distance
              Row(
                children: [
                  Image.asset(
                    AssetsConstant
                        .locationNewIcon, // 🔥 IMPORTANT (use location, not walk)
                    height: 12,
                    width: 12,
                    color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${convertMetersToKilometers(_homeController.homeSalonDetailsData.data?.distance ?? 0.0)} Km Drive",
                    style: const TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   padding: const EdgeInsets.symmetric(horizontal: 7),
          //   children: [
          //     // Row(
          //     //   children: [
          //     //     Image.asset(
          //     //       AssetsConstant.locationNewIcon,
          //     //       height: 16,
          //     //       width: 16,
          //     //       color: changeTheme(
          //     //           SharedPrefs.readStringValue(PrefConstants.gender)),
          //     //     ),
          //     //     const SizedBox(width: 5),
          //     //     SizedBox(
          //     //       width: Get.width * 0.5,
          //     //       child: Text(
          //     //         _homeController.homeSalonDetailsData.data?.address ?? "",
          //     //         overflow: TextOverflow.ellipsis,
          //     //         maxLines: 1,
          //     //         style: AppTextTheme.medium.copyWith(
          //     //             color: ColorConstant.blackColor, fontSize: 12,
          //     //           fontFamily: "Outfit",
          //     //           fontWeight: FontWeight.w600,
          //     //       ),
          //     //     )
          //     //     ),
          //     //   ],
          //     // ),
          //     Row(
          //       children: [
          //         Icon(
          //           Icons.lightbulb_outline, // 👈 common amenities icon
          //           size: 16,
          //           color: changeTheme(
          //             SharedPrefs.readStringValue(PrefConstants.gender),
          //           ),
          //         ),
          //         const SizedBox(width: 3),
          //         Text(
          //           "Amenities : ",
          //           overflow: TextOverflow.ellipsis,
          //           maxLines: 1,
          //           style: AppTextTheme.medium.copyWith(
          //             color: Colors.black,
          //             fontSize: 12,
          //             fontFamily: "Outfit",
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //         SizedBox(
          //           width: Get.width * 0.5,
          //           child: Text(
          //             _homeController.homeSalonDetailsData.data?.amenities ??
          //                 "",
          //             overflow: TextOverflow.ellipsis,
          //             maxLines: 1,
          //             style: AppTextTheme.medium.copyWith(
          //               color: changeTheme(
          //                   SharedPrefs.readStringValue(PrefConstants.gender)),
          //               fontSize: 12,
          //               fontFamily: "Outfit",
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //     GestureDetector(
          //       onTap: () {
          //         _openGoogleMapsForSalon();
          //       },
          //       child: Container(
          //         height: 25, // ✅ Figma-like compact height (22–28 works best)
          //         padding: const EdgeInsets.symmetric(
          //             horizontal: 10.5), // ❌ remove vertical padding
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(6),
          //           //color: ColorConstant.pinkBgColor,
          //           color: changeTheme(
          //               SharedPrefs.readStringValue(PrefConstants.gender)),
          //           //border: Border.all(color: ColorConstant.pinkStrokeColor),
          //         ),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             Image.asset(
          //               AssetsConstant.locationShare,
          //               width: 15,
          //               height: 15,
          //               color: Colors.white,
          //               // color: changeTheme(
          //               //     SharedPrefs.readStringValue(PrefConstants.gender)),
          //             ),
          //             const SizedBox(width: 3),
          //             Text("Get Direction",
          //                 textScaler: const TextScaler.linear(0.85),
          //                 style: AppTextTheme.medium.copyWith(
          //                   fontSize: 12,
          //                   color: Colors.white,
          //                   // color: changeTheme(SharedPrefs.readStringValue(
          //                   //     PrefConstants.gender))),
          //                 ))
          //           ],
          //         ),
          //       ),
          //     )
          //   ],
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// LEFT SIDE (flexible)
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      "Amenities : ",
                      style: AppTextTheme.medium.copyWith(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    /// 🔥 IMPORTANT FIX HERE
                    Expanded(
                      child: Text(
                        _homeController.homeSalonDetailsData.data?.amenities ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppTextTheme.medium.copyWith(
                          color: changeTheme(
                            SharedPrefs.readStringValue(PrefConstants.gender),
                          ),
                          fontSize: 12,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //const SizedBox(width: 8),

              /// RIGHT SIDE (fixed button)
              GestureDetector(
                onTap: () {
                  _openGoogleMapsForSalon();
                },
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        AssetsConstant.locationShare,
                        width: 13,
                        height: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "Get Directions",
                        textScaler: const TextScaler.linear(0.85),
                        style: AppTextTheme.semibold.copyWith(
                          fontSize: 13,
                          color: Colors.white,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _offerWidget() {
    final allOffers = _homeController.getSalonPromoCodeModel.data;

    if (allOffers == null || allOffers.isEmpty) {
      return const SizedBox();
    }

    /// FILTER HERE
    final offers = allOffers.where((promo) {
      final salonIds = promo.salonId ?? [];
      return salonIds.contains(widget.id);
    }).toList();

    if (offers.isEmpty) {
      return const SizedBox();
    }

    /// START AUTO SCROLL SAFELY
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_offerAutoScrollTimer == null) {
        _startOfferAutoScroll(offers.length);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Offer's for you",
            style: const TextStyle(
              fontFamily: "Outfit",
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 20 / 16, // ✅ line height = 20px
              color: Colors.black,
            ),
          ),
        ),

        const SizedBox(height: 5),

        SizedBox(
          height: 62, // slightly increased for proper vertical balance
          child: PageView.builder(
            controller:
                _offerPageController ?? PageController(viewportFraction: 1),
            itemCount: offers.length,
            onPageChanged: (index) {
              _currentOfferPage = index;
            },
            itemBuilder: (context, index) {
              final promo = offers[index];

              const Color startColor = Color(0xFFFD98FB);
              const Color endColor = Color(0xFFB479FF);

              return GestureDetector(
                onPanDown: (_) => _stopOfferAutoScroll(),
                onPanEnd: (_) => _startOfferAutoScroll(offers.length),
                child: Center(
                  // ✅ ensures center alignment
                  child: Container(
                    width: 343, // ✅ exact Figma width
                    height: 62, // ✅ exact Figma height
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [startColor, endColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// 🔥 LEFT BIG %
                        Text(
                          promo.type == "percentage"
                              ? "${promo.amount}%"
                              : "₹${promo.amount}",
                          style: const TextStyle(
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w700,
                            fontSize: 53,
                            letterSpacing: -4,
                            height: 1.23,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 14),

                        /// 🔥 RIGHT CONTENT
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// TITLE
                              Text(
                                promo.code ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  //height: 18 / 12,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 2),

                              /// DESCRIPTION
                              Text(
                                promo.description ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  //height: 18 / 12,
                                  color: Colors.black87,
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

        //const SizedBox(height: 8),
      ],
    );
  }

  /*------------- Tab Bar View ------------*/
  int isSelectedTab = 1;

  /*------------  Is Home Service -------------*/
  bool isHomeService = false;
  bool serviceOffered = false;

  Container _tabBarView() {
    final hasArtists =
        (_homeController.getSalonDetailsArtiestData.data ?? []).isNotEmpty;
    final hasProducts = _homeController.salonProducts.isNotEmpty;
    final noRecommendedCategories = _homeController
            .salonDetailsListData.data?.recommendedCategories?.isEmpty ??
        true;
    final hasSelectedCategories = _homeController
            .salonDetailsListData.data?.selectedCategories?.isNotEmpty ??
        false;
    return Container(
      color: ColorConstant.whiteColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 15),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      isSelectedTab = 1;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        "Overview",
                        style: isSelectedTab == 1
                            ? AppTextTheme.bold.copyWith(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender)))
                            : AppTextTheme.medium.copyWith(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: ColorConstant.grayTextColor),
                      ),
                      // Text(
                      //   "Services",
                      //   style: isSelectedTab == 1
                      //       ? AppTextTheme.bold.copyWith(
                      //       fontSize: 16,
                      //       color: changeTheme(SharedPrefs.readStringValue(
                      //           PrefConstants.gender)))
                      //       : AppTextTheme.medium.copyWith(
                      //       fontSize: 16,
                      //       color: ColorConstant.grayTextColor),
                      // ),
                      const SizedBox(height: 3),
                      Container(
                        height: 4,
                        width: Get.width * 0.2,
                        decoration: BoxDecoration(
                            color: isSelectedTab == 1
                                ? changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender))
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12))),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                if (hasArtists)
                  InkWell(
                    onTap: () {
                      setState(() {
                        isSelectedTab = 2;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          "Stylist List",
                          style: isSelectedTab == 2
                              ? AppTextTheme.bold.copyWith(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)))
                              : AppTextTheme.medium.copyWith(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: ColorConstant.grayTextColor),
                        ),
                        const SizedBox(height: 0),
                        Container(
                          height: 4,
                          width: Get.width * 0.2,
                          decoration: BoxDecoration(
                              color: isSelectedTab == 2
                                  ? changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender))
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12))),
                        )
                      ],
                    ),
                  ),

                const SizedBox(width: 20),
                if (hasProducts)
                  InkWell(
                    onTap: () {
                      setState(() {
                        isSelectedTab = 3; // 👈 new tab
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          "Products",
                          style: isSelectedTab == 3
                              ? AppTextTheme.bold.copyWith(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: changeTheme(
                              SharedPrefs.readStringValue(PrefConstants.gender),
                            ),
                          )
                              : AppTextTheme.medium.copyWith(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: ColorConstant.grayTextColor,
                          ),
                        ),
                        const SizedBox(height: 0),
                        Container(
                          height: 4,
                          width: Get.width * 0.2,
                          decoration: BoxDecoration(
                            color: isSelectedTab == 3
                                ? changeTheme(
                              SharedPrefs.readStringValue(PrefConstants.gender),
                            )
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Container(
          //     height: 1, width: Get.width, color: const Color(0xffADADAD)),

          /*------------------  OverView  and  Stylist Widget -----------------*/
          if (isSelectedTab == 1)
            Container(
              color: ColorConstant.whiteColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: ReadMoreText(
                      _homeController.homeSalonDetailsData.data?.description ??
                          "",
                      trimMode: TrimMode.Line,
                      style: AppTextTheme.medium.copyWith(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w500,
                          height: 1,
                          color: ColorConstant.blackColor,
                          fontSize: 12),
                      trimLines: 2,
                      colorClickableText: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)),
                      trimCollapsedText: 'more',
                      trimExpandedText: 'Show less',
                      moreStyle: AppTextTheme.medium.copyWith(
                          fontSize: 15,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w500,
                          color: changeTheme(SharedPrefs.readStringValue(
                              PrefConstants.gender))),
                    ),
                  ),

                  /*-------------------- Selected Category -------------------*/
                  _homeController.salonDetailsListData.data?.selectedCategories
                              ?.isEmpty ??
                          false
                      ? const SizedBox()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 19),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Selected Categories",
                                    style: AppTextTheme.bold.copyWith(
                                      fontSize: 17,
                                      color: ColorConstant.blackColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 25,
                                  ),

                                  if (_homeController.homeSalonDetailsData.data
                                          ?.serviceGender ==
                                      'unisex')
                                    if (hasSelectedCategories)
                                      _genderSwitch(), // ✅ HERE
                                ],
                              ),
                            ),
                            //const SizedBox(height: 10),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: _homeController.salonDetailsListData
                                        .data?.selectedCategories?.length ??
                                    0,
                                itemBuilder: (context, index) {
                                  final category = _homeController
                                      .salonDetailsListData
                                      .data!
                                      .selectedCategories![index];

                                  return Container(
                                      key: _categoryKeys.putIfAbsent(
                                          category.id!, () => GlobalKey()),
                                      decoration: const BoxDecoration(
                                        // 👈 ADD THIS BLOCK
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Color(
                                                0xFFE0E0E0), // 👈 line color
                                            width:
                                                2, // 👈 thickness (adjust 1.5–2.5)
                                          ),
                                        ),
                                      ),
                                      child: Theme(
                                          data: Theme.of(context).copyWith(
                                            dividerColor: Colors.transparent,
                                          ), // 🔥 REMOVE LINE ),
                                          child: ExpansionTile(
                                            // key: _categoryKeys.putIfAbsent(
                                            //     category.id!, () => GlobalKey()),

                                            key: ValueKey(
                                                "${category.id}_$expandedCategoryId"),
                                            initiallyExpanded:
                                                expandedCategoryId ==
                                                    category
                                                        .id, //|| index == 0,
                                            title: Text(
                                              _homeController
                                                      .salonDetailsListData
                                                      .data
                                                      ?.selectedCategories?[
                                                          index]
                                                      .name ??
                                                  "",
                                              textScaler:
                                                  const TextScaler.linear(0.85),
                                              style: AppTextTheme.bold.copyWith(
                                                  fontFamily: 'Outfit',
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      ColorConstant.blackColor,
                                                  fontSize: 18),
                                            ),
                                            children: [
                                              ListView.separated(
                                                  separatorBuilder:
                                                      (context, index) {
                                                    //return const SizedBox(height: 30,);
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 20,
                                                              bottom: 20),
                                                      height: 1,
                                                      width: Get.width,
                                                      color: ColorConstant
                                                          .dividerColor,
                                                    );
                                                  },
                                                  shrinkWrap: true,
                                                  itemCount: _homeController
                                                          .salonDetailsListData
                                                          .data
                                                          ?.selectedCategories?[
                                                              index]
                                                          .services
                                                          ?.length ??
                                                      0,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemBuilder: (context, i) {
                                                    return OverviewListTileWidget(
                                                      servicesList: _homeController
                                                          .salonDetailsListData
                                                          .data!
                                                          .selectedCategories![
                                                              index]
                                                          .services![i],
                                                      quantity: _homeController
                                                          .getQuantity(
                                                        _homeController
                                                                .salonDetailsListData
                                                                .data!
                                                                .selectedCategories![
                                                                    index]
                                                                .services![i]
                                                                .id ??
                                                            "",
                                                      ),
                                                      onAdd: () {
                                                        final serviceId =
                                                            _homeController
                                                                    .salonDetailsListData
                                                                    .data!
                                                                    .selectedCategories![
                                                                        index]
                                                                    .services![
                                                                        i]
                                                                    .id ??
                                                                "";

                                                        /// 🔴 CROSS SALON CHECK (KEEP SAME)
                                                        if (widget.id !=
                                                                _homeController
                                                                    .getServiceAddCartModel
                                                                    .data
                                                                    ?.salonId &&
                                                            (_homeController
                                                                    .getServiceAddCartModel
                                                                    .data
                                                                    ?.items
                                                                    ?.isNotEmpty ??
                                                                false)) {
                                                          _homeController
                                                              .doClearCart(
                                                                  callback: () {
                                                            _homeController
                                                                .doGetCart();
                                                            _homeController
                                                                .doGetSalonCart(
                                                                    salonId:
                                                                        widget
                                                                            .id);
                                                            selectedArtistIdsGlobal
                                                                .value = [];
                                                          });
                                                          //Navigator.pop(context);

                                                          // final salonName = _homeController
                                                          //     .getServiceAddCartModel.data
                                                          //     ?.salon
                                                          //     ?.displayName;
                                                          //
                                                          // print("SALON BEFORE DIALOG: $salonName");
                                                          // showDialog(
                                                          //   context: context,
                                                          //   builder: (context) {
                                                          //     print(_homeController.getServiceAddCartModel.data?.salon?.displayName);
                                                          //     print('&&&&&&&&&&&&');
                                                          //     return RemoveAndAddServiceDialog(
                                                          //       salonName: salonName,
                                                          //       noPress: () {
                                                          //         Navigator.of(context).maybePop();
                                                          //       },
                                                          //       yesPress: () {
                                                          //         _homeController.doClearCart(callback: () {
                                                          //           _homeController.doGetCart();
                                                          //            _homeController.doGetSalonCart(salonId: widget.id);
                                                          //           selectedArtistIdsGlobal.value = [];
                                                          //         });
                                                          //         Navigator.pop(context);
                                                          //       },
                                                          //     );
                                                          //   },
                                                          // );
                                                          // return;
                                                        }

                                                        /// 🔥 TEMP UI UPDATE (+1 instantly)
                                                        _homeController.tempQty[
                                                            serviceId] = (_homeController
                                                                        .tempQty[
                                                                    serviceId] ??
                                                                _homeController
                                                                    .getQuantity(
                                                                        serviceId)) +
                                                            1;

                                                        /// 🔥 BACKEND CALL
                                                        _homeController
                                                            .doAddCart(
                                                          salonServiceId:
                                                              serviceId,
                                                          isHomeService: SharedPrefs
                                                              .readBoolValue(
                                                                  PrefConstants
                                                                      .isHomeService),
                                                          callback: () {
                                                            _homeController
                                                                .doGetCart();
                                                            _homeController
                                                                .doGetSalonCart(
                                                                    salonId:
                                                                        widget
                                                                            .id);
                                                            // 📊 select_item
                                                            try {
                                                              final svc = _homeController
                                                                  .salonDetailsListData
                                                                  .data!
                                                                  .selectedCategories![
                                                                      index]
                                                                  .services![i];
                                                              AnalyticsService
                                                                  .instance
                                                                  .logSelectItem(
                                                                serviceId:
                                                                    svc.id ??
                                                                        '',
                                                                serviceName:
                                                                    svc.name ??
                                                                        '',
                                                                salonId:
                                                                    widget.id,
                                                              );
                                                            } catch (_) {}
                                                            final items =
                                                                _homeController
                                                                    .getServiceAddCartModel
                                                                    .data
                                                                    ?.servicesWithProduct;

                                                            if (items == null ||
                                                                items.isEmpty) {
                                                              selectedArtistIdsGlobal
                                                                  .value = [];
                                                            }
                                                          },
                                                        );
                                                      },
                                                      onRemove: () {
                                                        final serviceId =
                                                            _homeController
                                                                    .salonDetailsListData
                                                                    .data!
                                                                    .selectedCategories![
                                                                        index]
                                                                    .services![
                                                                        i]
                                                                    .id ??
                                                                "";

                                                        /// 🔥 CURRENT VALUE (local OR backend)
                                                        int current = _homeController
                                                                    .tempQty[
                                                                serviceId] ??
                                                            _homeController
                                                                .getQuantity(
                                                                    serviceId);

                                                        /// 🔥 TEMP UI UPDATE (-1 instantly)
                                                        if (current > 1) {
                                                          _homeController
                                                                      .tempQty[
                                                                  serviceId] =
                                                              current - 1;
                                                        } else {
                                                          _homeController
                                                              .tempQty
                                                              .remove(
                                                                  serviceId);
                                                        }

                                                        /// 🔥 BACKEND CALL
                                                        _homeController
                                                            .doRemoveCart(
                                                          salonServiceId:
                                                              serviceId,
                                                          callback: () {
                                                            _homeController
                                                                .doGetCart();
                                                            _homeController
                                                                .doGetSalonCart(
                                                                    salonId:
                                                                        widget
                                                                            .id);
                                                            final items =
                                                                _homeController
                                                                    .getServiceAddCartModel
                                                                    .data
                                                                    ?.servicesWithProduct;

                                                            if (items == null ||
                                                                items.isEmpty) {
                                                              selectedArtistIdsGlobal
                                                                  .value = [];
                                                            }
                                                          },
                                                        );
                                                      },
                                                      onTap: () {},
                                                    );
                                                  }),
                                              const SizedBox(height: 20),
                                            ],
                                          )));
                                }),
                          ],
                        ),

                  /*-------------------- Recommend  Service -------------------*/

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!noRecommendedCategories)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 19, right: 19, top: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Service Categories",
                                style: AppTextTheme.bold.copyWith(
                                  fontFamily: "Outfit",
                                  fontSize: 17,
                                  height: 20 / 17, // same as before
                                  color: ColorConstant.blackColor,
                                ),
                              ),
                              const SizedBox(
                                width: 25,
                              ),
                              if (_homeController.homeSalonDetailsData.data
                                      ?.serviceGender ==
                                  'unisex')
                                if (!hasSelectedCategories) _genderSwitch(),
                            ],
                          ),
                        ),
                      _homeController.salonDetailsListData.data
                                  ?.recommendedCategories?.isEmpty ??
                              false
                          ? _homeController.showProgress
                              ? const SizedBox()
                              : _buildNoServicesUI()
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: _homeController.salonDetailsListData
                                      .data?.recommendedCategories?.length ??
                                  0,
                              itemBuilder: (context, index) {
                                final category = _homeController
                                    .salonDetailsListData
                                    .data!
                                    .recommendedCategories![index];

                                return Container(
                                    key: _categoryKeys.putIfAbsent(
                                        category.id!, () => GlobalKey()),
                                    decoration: const BoxDecoration(
                                      // 👈 ADD THIS BLOCK
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color(
                                              0xFFE0E0E0), // 👈 line color
                                          width:
                                              2, // 👈 thickness (adjust 1.5–2.5)
                                        ),
                                      ),
                                    ),
                                    child: Theme(
                                        data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent,
                                        ),
                                        child: ExpansionTile(
                                          // key: _categoryKeys.putIfAbsent(
                                          //     category.id!, () => GlobalKey()),

                                          key: ValueKey(
                                              "${category.id}_$expandedCategoryId"),
                                          initiallyExpanded:
                                              expandedCategoryId ==
                                                  category.id, //|| index == 0,
                                          title: Text(
                                            _homeController
                                                    .salonDetailsListData
                                                    .data
                                                    ?.recommendedCategories?[
                                                        index]
                                                    .name ??
                                                "",
                                            textScaler:
                                                const TextScaler.linear(0.85),
                                            style: AppTextTheme.bold.copyWith(
                                                fontFamily: 'Outfit',
                                                fontWeight: FontWeight.w800,
                                                color: ColorConstant.blackColor,
                                                fontSize: 18),
                                          ),
                                          children: [
                                            ListView.separated(
                                                separatorBuilder:
                                                    (context, index) {
                                                  //return const SizedBox(height: 25,);
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 25,
                                                            bottom: 10),
                                                    height: 1,
                                                    width: Get.width,
                                                    color: ColorConstant
                                                        .dividerColor,
                                                  );
                                                },
                                                shrinkWrap: true,
                                                itemCount: _homeController
                                                        .salonDetailsListData
                                                        .data
                                                        ?.recommendedCategories?[
                                                            index]
                                                        .services
                                                        ?.length ??
                                                    0,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, i) {
                                                  return OverviewListTileWidget(
                                                    servicesList: _homeController
                                                        .salonDetailsListData
                                                        .data!
                                                        .recommendedCategories![
                                                            index]
                                                        .services![i],
                                                    quantity: _homeController
                                                        .getQuantity(
                                                      _homeController
                                                              .salonDetailsListData
                                                              .data!
                                                              .recommendedCategories![
                                                                  index]
                                                              .services![i]
                                                              .id ??
                                                          "",
                                                    ),
                                                    onAdd: () {
                                                      final serviceId = _homeController
                                                              .salonDetailsListData
                                                              .data!
                                                              .recommendedCategories![
                                                                  index]
                                                              .services![i]
                                                              .id ??
                                                          "";

                                                      var isClearCart = false;

                                                      /// 🔴 CROSS SALON CHECK (KEEP SAME)
                                                      if (widget.id !=
                                                              _homeController
                                                                  .getServiceAddCartModel
                                                                  .data
                                                                  ?.salonId &&
                                                          (_homeController
                                                                  .getServiceAddCartModel
                                                                  .data
                                                                  ?.items
                                                                  ?.isNotEmpty ??
                                                              false)) {
                                                        // showDialog(
                                                        //   context: context,
                                                        //   builder: (context) {
                                                        //     return RemoveAndAddServiceDialog(
                                                        //       noPress: () {
                                                        //         Navigator.of(context).maybePop();
                                                        //       },
                                                        //       yesPress: () {
                                                        //         _homeController.doClearCart(callback: () {
                                                        //           _homeController.doGetCart();
                                                        //           _homeController.doGetSalonCart(salonId: widget.id);
                                                        //           selectedArtistIdsGlobal.value = [];
                                                        //         });
                                                        //         Navigator.pop(context);
                                                        //       },
                                                        //     );
                                                        //   },
                                                        // );
                                                        // return;

                                                        isClearCart = true;
                                                        _homeController
                                                            .doClearCart(
                                                                callback: () {
                                                          _homeController
                                                              .doGetCart();
                                                          _homeController
                                                              .doGetSalonCart(
                                                                  salonId:
                                                                      widget
                                                                          .id);
                                                          selectedArtistIdsGlobal
                                                              .value = [];
                                                        });
                                                        //Navigator.pop(context);
                                                      }

                                                      if (!isClearCart) {
                                                        /// 🔥 TEMP UI UPDATE (+1 instantly)
                                                        _homeController.tempQty[
                                                            serviceId] = (_homeController
                                                                        .tempQty[
                                                                    serviceId] ??
                                                                _homeController
                                                                    .getQuantity(
                                                                        serviceId)) +
                                                            1;

                                                        /// 🔥 BACKEND CALL
                                                        _homeController
                                                            .doAddCart(
                                                          salonServiceId:
                                                              serviceId,
                                                          isHomeService: SharedPrefs
                                                              .readBoolValue(
                                                                  PrefConstants
                                                                      .isHomeService),
                                                          callback: () {
                                                            _homeController
                                                                .doGetCart();
                                                            _homeController
                                                                .doGetSalonCart(
                                                                    salonId:
                                                                        widget
                                                                            .id);
                                                            // 📊 select_item
                                                            try {
                                                              final svc = _homeController
                                                                  .salonDetailsListData
                                                                  .data!
                                                                  .recommendedCategories![
                                                                      index]
                                                                  .services![i];
                                                              AnalyticsService
                                                                  .instance
                                                                  .logSelectItem(
                                                                serviceId:
                                                                    svc.id ??
                                                                        '',
                                                                serviceName:
                                                                    svc.name ??
                                                                        '',
                                                                salonId:
                                                                    widget.id,
                                                              );
                                                            } catch (_) {}
                                                            final items =
                                                                _homeController
                                                                    .getServiceAddCartModel
                                                                    .data
                                                                    ?.servicesWithProduct;

                                                            if (items == null ||
                                                                items.isEmpty) {
                                                              selectedArtistIdsGlobal
                                                                  .value = [];
                                                            }
                                                          },
                                                        );
                                                      } else {
                                                        _homeController
                                                            .showProgress;
                                                      }
                                                    },
                                                    onRemove: () {
                                                      final serviceId = _homeController
                                                              .salonDetailsListData
                                                              .data!
                                                              .recommendedCategories![
                                                                  index]
                                                              .services![i]
                                                              .id ??
                                                          "";

                                                      /// 🔥 CURRENT VALUE (local OR backend)
                                                      int current =
                                                          _homeController
                                                                      .tempQty[
                                                                  serviceId] ??
                                                              _homeController
                                                                  .getQuantity(
                                                                      serviceId);

                                                      /// 🔥 TEMP UI UPDATE (-1 instantly)
                                                      if (current > 1) {
                                                        _homeController.tempQty[
                                                                serviceId] =
                                                            current - 1;
                                                      } else {
                                                        _homeController.tempQty
                                                            .remove(serviceId);
                                                      }

                                                      /// 🔥 BACKEND CALL
                                                      _homeController
                                                          .doRemoveCart(
                                                        salonServiceId:
                                                            serviceId,
                                                        callback: () {
                                                          _homeController
                                                              .doGetCart();
                                                          _homeController
                                                              .doGetSalonCart(
                                                                  salonId:
                                                                      widget
                                                                          .id);
                                                          final items = _homeController
                                                              .getServiceAddCartModel
                                                              .data
                                                              ?.servicesWithProduct;

                                                          if (items == null ||
                                                              items.isEmpty) {
                                                            selectedArtistIdsGlobal
                                                                .value = [];
                                                          }
                                                        },
                                                      );
                                                    },
                                                    onTap: () {},
                                                  );
                                                
                                                }),
                                            const SizedBox(height: 30),
                                          ],
                                        )));
                              }),
                    ],
                  )
                ],
              ),
            )
          else if (isSelectedTab == 2)
            _homeController.getSalonDetailsArtiestData.data?.isEmpty ?? false
                ? const NoItemsWidget(
                    text:
                        "    Stylists will be visible \nonce the Salon is onboarded",
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        // const SliverGridDelegateWithFixedCrossAxisCount(
                        //   crossAxisCount: 2,
                        //   mainAxisSpacing: 12.0,
                        //   crossAxisSpacing: 12.0,
                        //   childAspectRatio: 0.75, // Aspect ratio of each item
                        // ),
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 138,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 138 / 200,
                    ),
                    itemCount: _homeController
                            .getSalonDetailsArtiestData.data?.length ??
                        0,
                    itemBuilder: (context, index) {
                      return StylistListGridWidget(
                        isView: true,
                        id: widget.id,
                        salonArtiestListModel: _homeController
                            .getSalonDetailsArtiestData.data![index],
                        onPress: () {},
                      );
                    },
                  )
          else if (isSelectedTab == 3)
            _buildProducts(),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  Widget _buildNoServicesUI() {
    final rawImages =
        _homeController.homeSalonDetailsData.data?.menuImages ?? [];
    final images = rawImages.map<String>((url) {
      final u = url.toString();
      if (u.startsWith("http")) return u;
      return "${APIConstants.image}$u";
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 🔥 MENU TITLE
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Menu",
              style: TextStyle(
                fontFamily: "Outfit",
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// 🔥 IMAGES ROW
          SizedBox(
            height: 84, // ✅ match Figma height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length > 4 ? 4 : images.length,
              itemBuilder: (context, index) {
                final isLast = index == 3 && images.length > 4;
                final remaining = images.length - 3;

                return GestureDetector(
                  onTap: () {
                    _openImageViewer(images, index);
                  },
                  child: Container(
                    width: 75, // ✅ match Figma width
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      //borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200,
                    ),
                    child: ClipRRect(
                      //borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: images[index],
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.image),
                            ),
                          ),
                          if (isLast)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text(
                                    "+$remaining",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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

          const SizedBox(height: 5),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 🔥 LEFT SPACE (balance)
              const SizedBox(width: 80),

              /// 🔥 CENTER IMAGE
              Expanded(
                child: Center(
                  child: Image.asset(
                    AssetsConstant.waiting,
                    width: 90,
                    height: 90,
                  ),
                ),
              ),

              /// 🔥 RIGHT BUTTON
              GestureDetector(
                onTap: () async {
                  final salon = _homeController.homeSalonDetailsData.data;
                  final name = salon?.name ?? "";
                  final phone = '9347882037';

                  final url =
                      "https://wa.me/$phone?text=Hi, I want to book an appointment with $name";

                  final uri = Uri.parse(url);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 27, top: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// 🔹 WHATSAPP ICON
                      ScaleTransition(
                        scale: _waScale,
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// 🔹 TEXT BELOW
                      const Text(
                        "24×7",
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          /// 🔥 TEXT
          SizedBox(
            width: 384, // optional (or use double.infinity with padding)
            child: const Text(
              "Salon Onboarding is Under Process,\nChat With Us To Book Appointment &\nAvail The Offer",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Outfit",
                fontWeight: FontWeight.w800, // ExtraBold
                fontSize: 20, // ✅ match Figma
                height: 1.1, // ✅ line height (~22px)
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProducts() {
    final products = _homeController.salonProducts;

    if (products.isEmpty) {
      return const SizedBox();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Image.network(
                  "${APIConstants.image}${product['image'] ?? ""}",
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),

              // VIEW BUTTON
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [

                                // MAIN DIALOG
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    // IMAGE
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: Image.network(
                                        "${APIConstants.image}${product['image'] ?? ""}",
                                        height: 250,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 200,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                        ),
                                      ),
                                    ),

                                    // CONTENT
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _productDialogRow("Name", product['name'] ?? "-"),
                                          const SizedBox(height: 8),
                                          _productDialogRow("Category", product['salonCategory'] ?? "-"),
                                          const SizedBox(height: 8),
                                          _productDialogRow("Description", product['description'] ?? "-"),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // ❌ CLOSE BUTTON — floating above center top
                                Positioned(
                                  top: -45,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender),
                        ) ?? ColorConstant.primaryColor,
                      ),
                      child: const Text(
                        "View",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _productDialogRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // 👈 FIX
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: "Outfit",
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            ":",
            style: TextStyle(
              fontFamily: "Outfit",
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: "Outfit",
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _openImageViewer(List<String> images, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: ImageViewerSheet(
            images: images,
            initialIndex: index,
          ),
        );
      },
    );
  }

  double convertMetersToKilometers(double meters) {
    return (meters / 1000 * 10).roundToDouble() / 10;
  }

  String convertTimeTo12HourFormat(String time24) {
    if (time24.isEmpty) {
      return "";
    } else {
      // Parse the 24-hour format time
      DateTime dateTime = DateFormat("HH:mm").parse(time24);
      // Format the time to 12-hour format with AM/PM
      String time12 = DateFormat("hh:mm aa").format(dateTime);
      return time12;
    }
  }

  Future<void> _openGoogleMapsForSalon() async {
    final salon = _homeController.homeSalonDetailsData.data;

    final mapUrl = salon?.googleplaceid;

    if (mapUrl != null && mapUrl.isNotEmpty) {
      final uri = Uri.parse(mapUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }

    // Fallback: open coordinates if link not available or invalid
    final lat = salon?.geoLocationPoint?.coordinates?[1];
    final lng = salon?.geoLocationPoint?.coordinates?[0];

    if (lat != null && lng != null) {
      final fallbackUrl =
          "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
      final uri = Uri.parse(fallbackUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
