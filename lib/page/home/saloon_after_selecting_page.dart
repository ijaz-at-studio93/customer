import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/home/salon_rating_page.dart';
import 'package:salon_customer/page/home/widget/add_product_sheet_widget.dart';
import 'package:salon_customer/page/home/widget/over_view_list_tile_widget.dart';
import 'package:salon_customer/page/home/widget/selected_services_sheet_page.dart';
import 'package:salon_customer/page/home/widget/stylist_list_grid_widget.dart';
import 'package:salon_customer/page/stylist/selecting_artist_bottom_sheet.dart';
import 'package:salon_customer/project_specific/ProgressContainerView.dart';
import 'package:salon_customer/project_specific/remove_and_add_service_dialog.dart';
import 'package:salon_customer/project_specific/status_bar_color_appbar.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:salon_customer/util/stylist_to_user_location.dart';
import 'package:share_plus/share_plus.dart';
import '../../constant/color_constant.dart';
import '../../project_specific/text_theme.dart';
import '../appointment/appointment_booking_page.dart';
import '../search/stylist_search_page.dart';
import 'dart:async';
import 'dart:convert';

class SaloonAfterSelectingServicesPage extends StatefulWidget {
  final String id;

  final VoidCallback callback;

  const SaloonAfterSelectingServicesPage({
    super.key,
    required this.id,
    required this.callback,
  });

  @override
  State<SaloonAfterSelectingServicesPage> createState() =>
      _SaloonAfterSelectingServicesPageState();
}

class _SaloonAfterSelectingServicesPageState
    extends State<SaloonAfterSelectingServicesPage> {
  final _homeController = Get.find<HomeController>();

  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  List<String> _images = [];
  Worker? _dataWatcher; // GetX worker to listen to data updates

  bool loading = false;
  final box = GetStorage();

  @override
  @override
  void initState() {
    super.initState();

    // init page controller for pageview
    _pageController = PageController(initialPage: 0);

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

      try {
        await _homeController.doGetSalonArtiestListData(salonId: widget.id);
      } catch (_) {}

      try {
        await _homeController.doGetCart();
      } catch (_) {}

      // Now that the main fetch has finished (or at least attempted), load images
      _loadImagesFromData();
    });
  }

  void _loadImagesFromData() {
    final data = _homeController.homeSalonDetailsData.data;
    final dynamic raw = data?.images; // dynamic because backend might send different types

    List<String> imgs = [];

    try {
      if (raw == null) {
        imgs = [];
      } else if (raw is List) {
        // Case 1: already a List from backend
        imgs = raw.map((e) => e?.toString() ?? "").where((e) => e.isNotEmpty).toList();
      } else if (raw is String) {
        // Case 2: backend gave a string
        final str = raw.trim();
        if (str.startsWith('[') && str.endsWith(']')) {
          // JSON array in string
          final parsed = jsonDecode(str);
          if (parsed is List) {
            imgs = parsed.map((e) => e?.toString() ?? "").where((e) => e.isNotEmpty).toList();
          }
        } else if (str.contains(',')) {
          // Comma-separated
          imgs = str.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
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


  String serviceId = "";

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        widget.callback.call();
      },
      child: SafeArea(
        bottom: true,
        top: false,
        child: Scaffold(
          appBar: statusBarTheme(context),
          backgroundColor: ColorConstant.bgColor,
          body: Obx(
            () => ProgressContainerView(
              isProgressRunning: _homeController.showProgress,
              child: ListView(
                children: [
                  _imageHeaderWidget(),
                  _headerWidget(),
                  const SizedBox(height: 5),
                  _tabBarView(),
                  const SizedBox(height: 110)
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Obx(
            () => _homeController.getServiceAddCartModel.data
                        ?.servicesWithProduct?.isEmpty ??
                    false ||
                        _homeController.getServiceAddCartModel.data
                                ?.servicesWithProduct ==
                            null
                ? const SizedBox()
                : Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    _homeController.getServiceAddCartModel.data
                                                ?.previewImages?.isEmpty ??
                                            false
                                        ? const SizedBox()
                                        : Row(
                                            children: [
                                              _homeController
                                                          .getServiceAddCartModel
                                                          .data
                                                          ?.previewImages
                                                          ?.length ==
                                                      1
                                                  ? Row(
                                                      children: [
                                                        for (int i = 0; i < 1; i++)
                                                          Align(
                                                            widthFactor: 0.8,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              child:
                                                                  CachedNetworkImage(
                                                                fit: BoxFit.cover,
                                                                width: 30,
                                                                height: 30,
                                                                imageUrl:
                                                                    "${APIConstants.image}${_homeController.getServiceAddCartModel.data?.previewImages?[i] ?? ""}",
                                                                placeholder:
                                                                    (context,
                                                                            url) =>
                                                                        const Image(
                                                                  image: AssetImage(
                                                                      AssetsConstant
                                                                          .placeHolder),
                                                                  fit: BoxFit.cover,
                                                                  width: 30,
                                                                  height: 30,
                                                                ),
                                                                errorWidget:
                                                                    (context, url,
                                                                            error) =>
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
                                                  : _homeController
                                                              .getServiceAddCartModel
                                                              .data
                                                              ?.previewImages
                                                              ?.length ==
                                                          2
                                                      ? Row(
                                                          children: [
                                                            for (int i = 0;
                                                                i < 2;
                                                                i++)
                                                              Align(
                                                                widthFactor: 0.8,
                                                                child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              100),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    width: 30,
                                                                    height: 30,
                                                                    imageUrl:
                                                                        "${APIConstants.image}${_homeController.getServiceAddCartModel.data?.previewImages?[i] ?? ""}",
                                                                    placeholder: (context,
                                                                            url) =>
                                                                        const Image(
                                                                      image: AssetImage(
                                                                          AssetsConstant
                                                                              .placeHolder),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: 30,
                                                                      height: 30,
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        const Image(
                                                                      image: AssetImage(
                                                                          AssetsConstant
                                                                              .placeHolder),
                                                                      fit: BoxFit
                                                                          .cover,
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
                                                            for (int i = 0;
                                                                i < 2;
                                                                i++)
                                                              Align(
                                                                widthFactor: 0.7,
                                                                child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              100),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    width: 35,
                                                                    height: 35,
                                                                    imageUrl:
                                                                        "${APIConstants.image}${_homeController.getServiceAddCartModel.data?.previewImages?[i] ?? ""}",
                                                                    placeholder: (context,
                                                                            url) =>
                                                                        const Image(
                                                                      image: AssetImage(
                                                                          AssetsConstant
                                                                              .placeHolder),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: 35,
                                                                      height: 35,
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        const Image(
                                                                      image: AssetImage(
                                                                          AssetsConstant
                                                                              .placeHolder),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: 35,
                                                                      height: 35,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            const SizedBox(
                                                                width: 2),
                                                            Container(
                                                              width: 33,
                                                              height: 33,
                                                              decoration: const BoxDecoration(
                                                                  color: ColorConstant
                                                                      .primaryColor,
                                                                  shape: BoxShape
                                                                      .circle),
                                                              child: Center(
                                                                child: Text(
                                                                  _homeController
                                                                          .getServiceAddCartModel
                                                                          .data
                                                                          ?.previewImages
                                                                          ?.length
                                                                          .toString() ??
                                                                      "",
                                                                  style:
                                                                      AppTextTheme
                                                                          .medium
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
                                    const SizedBox(width: 15),
                                    GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(32),
                                              topRight: Radius.circular(32),
                                            )),
                                            context: context,
                                            builder: (context) {
                                              return SelectedServiceSheetPage(
                                                salonId: widget.id,
                                                artiestId: stylistId.value,
                                                serviceId: serviceId,
                                              );
                                            });
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "${_homeController.getServiceAddCartModel.data?.items?.length} Added",
                                                style: AppTextTheme.bold.copyWith(
                                                    fontSize: 13,
                                                    color: ColorConstant
                                                        .grayTextColor),
                                              ),
                                              const SizedBox(width: 2),
                                              Image.asset(
                                                AssetsConstant.arrowUpIcon,
                                                height: 8,
                                                width: 11,
                                                color: changeTheme(
                                                    SharedPrefs.readStringValue(
                                                        PrefConstants.gender)),
                                              )
                                            ],
                                          ),
                                          Text(
                                            "₹${(_homeController.getServiceAddCartModel.data?.price ?? 0).toStringAsFixed(2)}",
                                            style: AppTextTheme.bold.copyWith(
                                              fontSize: 19,
                                              color: ColorConstant.blackColor,
                                            ),
                                          )

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "GST is included",
                                  style: AppTextTheme.regular.copyWith(
                                      color: ColorConstant.blackColor,
                                      fontSize: 12),
                                )
                              ],
                            ),

                            GestureDetector(
                              onTap: () {
                                if (stylistId.value != "") {
                                  Get.to(() => AppointmentBookingPage(
                                        artiestId: stylistId.value,
                                      ));
                                } else {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      isDismissible: false,
                                      enableDrag: false,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(32),
                                        topRight: Radius.circular(32),
                                      )),
                                      context: context,
                                      builder: (context) {
                                        return SelectingArtistBottomSheetWidget(
                                          salonId: widget.id,
                                          serviceId: serviceId,
                                          callback: () {
                                            setState(() {});
                                          },
                                        );
                                      });
                                }
                              },
                              child: Container(
                                height: 45,
                                width: Get.width * 0.4,
                                decoration: BoxDecoration(
                                  color: changeTheme(
                                      SharedPrefs.readStringValue(
                                          PrefConstants.gender)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ValueListenableBuilder(
                                        valueListenable: stylistId,
                                        builder: (context, v, c) {
                                          return Text(
                                            stylistId.value.isNotEmpty
                                                ? "Book Slot"
                                                : "Select Stylist",
                                            textScaler:
                                                const TextScaler.linear(0.70),
                                            style: AppTextTheme.medium.copyWith(
                                                fontSize: 16,
                                                color:
                                                    ColorConstant.whiteColor),
                                          );
                                        }),
                                    const SizedBox(width: 10),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _dataWatcher?.dispose();
    super.dispose();
  }

  /*------------ Back Button --------------*/
  buttonWidget(
      {required String imageUrl,
      required VoidCallback onPress,
      required double h,
      required double w}) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
          height: 40,
          width: 40,
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

  /*-------------- Image header Widget ------------*/
  Widget _imageHeaderWidget() {
    final data = _homeController.homeSalonDetailsData.data;
    return Stack(
      children: [
        SizedBox(
          width: Get.width,
          height: Get.height * 0.28,
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
              width: Get.width,
              height: Get.height * 0.28,
              fit: BoxFit.fitWidth,
              imageUrl:
              "${APIConstants.image}${_homeController.homeSalonDetailsData.data?.image ?? ""}",
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              placeholder: (context, url) => Image(
                image: const AssetImage(AssetsConstant.placeHolder),
                width: Get.width,
                height: Get.height * 0.28,
                fit: BoxFit.fitWidth,
              ),
              errorWidget: (context, url, error) => Image(
                image: const AssetImage(AssetsConstant.placeHolder),
                width: Get.width,
                height: Get.height * 0.28,
                fit: BoxFit.fitWidth,
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
                  width: Get.width,
                  height: Get.height * 0.28,
                  fit: BoxFit.fitWidth,
                  imageUrl: imageUrl,
                  placeholder: (context, url) => Image(
                    image: const AssetImage(AssetsConstant.placeHolder),
                    width: Get.width,
                    height: Get.height * 0.28,
                    fit: BoxFit.fitWidth,
                  ),
                  errorWidget: (context, url, error) => Image(
                    image: const AssetImage(AssetsConstant.placeHolder),
                    width: Get.width,
                    height: Get.height * 0.28,
                    fit: BoxFit.fitWidth,
                  ),
                );
              },
            ),
          ),
        ),

        // --- ORIGINAL GRADIENT (unchanged) ---
        Positioned(
          child: Container(
            width: Get.width,
            height: Get.height * 0.28,
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
          top: 12,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buttonWidget(
                imageUrl: AssetsConstant.backArrow,
                onPress: () {
                  Get.back();
                  widget.callback.call();
                },
                h: 15,
                w: 15,
              ),
              Row(
                children: [
                  buttonWidget(
                    imageUrl: AssetsConstant.iconSearch,
                    onPress: () {
                      Get.to(() => StylistSearchPage(
                        salonName: _homeController
                            .homeSalonDetailsData.data?.name ??
                            "",
                        salonId: widget.id,
                      ));
                    },
                    h: 24,
                    w: 24,
                  ),
                  const SizedBox(width: 15),
                  buttonWidget(
                    imageUrl: AssetsConstant.shareIcon,
                    onPress: () {
                      Share.share(
                          "https://play.google.com/store/apps/details?id=com.anantax.scuts");
                    },
                    h: 18,
                    w: 18,
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _homeController.homeSalonDetailsData.data?.isFavourite =
                        !(_homeController
                            .homeSalonDetailsData.data?.isFavourite ??
                            false);
                        if (_homeController
                            .homeSalonDetailsData.data?.isFavourite ??
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorConstant.blackColor.withOpacity(0.50)),
                      child: Center(
                          child: _homeController
                              .homeSalonDetailsData.data?.isFavourite ??
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
              )
            ],
          ),
        ),

        // --- ORIGINAL BOTTOM RATING BLOCK (UNCHANGED) ---
        Positioned(
          bottom: 16,
          left: 19,
          right: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: ColorConstant.greenColor,
                        borderRadius: BorderRadius.circular(5)),
                    width: 60,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 3),
                        SizedBox(
                          child: Text(
                            "${_homeController.homeSalonDetailsData.data?.rating}",
                            style: AppTextTheme.medium.copyWith(
                                fontSize: 11, color: ColorConstant.whiteColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 13),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => SalonRatingPage(
                        salonId: widget.id,
                      ));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_homeController.homeSalonDetailsData.data?.rating} Ratings",
                          style: AppTextTheme.medium.copyWith(
                              color: ColorConstant.whiteColor, fontSize: 13),
                        ),
                        const SizedBox(height: 5),
                        const Dash(
                          direction: Axis.horizontal,
                          length: 70,
                          dashLength: 2,
                          dashColor: ColorConstant.whiteColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: ColorConstant.yellowColor,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: Get.width * 0.05,
                    child: Text(
                      (_homeController.homeSalonDetailsData.data?.averageArtistRatings ?? 0)
                          .toStringAsFixed(2),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AppTextTheme.medium.copyWith(
                          fontSize: 11, color: ColorConstant.yellowColor),
                    ),
                  ),
                  Text(
                    'Average Stylist Rating',
                    style: AppTextTheme.medium.copyWith(
                        fontSize: 13, color: ColorConstant.whiteColor),
                  ),
                ],
              )
            ],
          ),
        ),

        // --- DOT INDICATOR (keeps bottom position) ---
        if (_images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }

  /*---------- Header Widget ------------*/
  _headerWidget() {
    return Container(
      width: Get.width,
      color: ColorConstant.whiteColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Get.width * 0.9,
            child: Text(
              maxLines: 1,
              _homeController.homeSalonDetailsData.data?.name ?? "",
              overflow: TextOverflow.ellipsis,
              style: AppTextTheme.bold
                  .copyWith(fontSize: 19, color: ColorConstant.blackColor),
            ),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: List.generate(
                _homeController
                        .homeSalonDetailsData.data?.serviceCategories?.length ??
                    0,
                (index) => Text(
                      index == 0
                          ? "${_homeController.homeSalonDetailsData.data?.serviceCategories?[index].name}"
                          : " •  ${_homeController.homeSalonDetailsData.data?.serviceCategories?[index].name}",
                      style: AppTextTheme.medium.copyWith(
                          color: ColorConstant.grayTextColor, fontSize: 13),
                    )),
          ),
          const SizedBox(height: 20),
          Dash(
            direction: Axis.horizontal,
            length: Get.width * 0.9,
            dashLength: 2,
            dashColor: const Color(0xffCFCFCF),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    AssetsConstant.manWalk,
                    height: 13,
                    width: 13,
                    color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)),
                  ),
                  const SizedBox(width: 5),
                  Row(
                    children: [
                      Text(
                        "${_homeController.homeSalonDetailsData.data?.distanceTime ?? ""} min • ${_homeController.homeSalonDetailsData.data?.distance.toString() == "" ? "" : convertMetersToKilometers(_homeController.homeSalonDetailsData.data?.distance ?? 0.0)} km",
                        style: AppTextTheme.medium.copyWith(
                            color: ColorConstant.blackColor, fontSize: 13),
                      ),
                    ],
                  )
                ],
              ),
              Text(
                "|",
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.grayBorderColor),
              ),
              Row(
                children: [
                  Image.asset(
                    AssetsConstant.calender,
                    height: 13,
                    width: 13,
                    color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)),
                  ),
                  const SizedBox(width: 5),
                  Row(
                    children: [
                      Text(
                        "Mon-Sat •${_homeController.homeSalonDetailsData.data?.startTiming == null ? "" : convertTimeTo12HourFormat(_homeController.homeSalonDetailsData.data?.startTiming ?? "")} ${_homeController.homeSalonDetailsData.data?.endTiming == null ? "" : convertTimeTo12HourFormat(_homeController.homeSalonDetailsData.data?.endTiming ?? "")}",
                        textScaler: const TextScaler.linear(0.85),
                        style: AppTextTheme.medium.copyWith(
                            color: ColorConstant.blackColor, fontSize: 15),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    AssetsConstant.locationNewIcon,
                    height: 13,
                    width: 13,
                    color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: Get.width * 0.5,
                    child: Text(
                      _homeController.homeSalonDetailsData.data?.address ?? "",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AppTextTheme.medium.copyWith(
                          color: ColorConstant.blackColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => StylistToUserLocation(
                        latitude: _homeController.homeSalonDetailsData.data
                                ?.geoLocationPoint?.coordinates?[1] ??
                            0.0,
                        longitude: _homeController.homeSalonDetailsData.data
                                ?.geoLocationPoint?.coordinates?[0] ??
                            0.0,
                      ));
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ColorConstant.pinkBgColor,
                    border: Border.all(color: ColorConstant.pinkStrokeColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        AssetsConstant.locationShare,
                        width: 12,
                        height: 12,
                        color: changeTheme(
                            SharedPrefs.readStringValue(PrefConstants.gender)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Get Direction",
                        textScaler: const TextScaler.linear(0.85),
                        style: AppTextTheme.medium.copyWith(
                            fontSize: 12,
                            color: changeTheme(SharedPrefs.readStringValue(
                                PrefConstants.gender))),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  /*------------- Tab Bar View ------------*/
  int isSelectedTab = 1;

  /*------------  Is Home Service -------------*/
  bool isHomeService = false;
  bool serviceOffered = false;

  _tabBarView() {
    return Container(
      color: ColorConstant.whiteColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20),
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
                                fontSize: 16,
                                color: changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender)))
                            : AppTextTheme.medium.copyWith(
                                fontSize: 16,
                                color: ColorConstant.grayTextColor),
                      ),
                      const SizedBox(height: 12),
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
                                fontSize: 16,
                                color: changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender)))
                            : AppTextTheme.medium.copyWith(
                                fontSize: 16,
                                color: ColorConstant.grayTextColor),
                      ),
                      const SizedBox(height: 12),
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
              ],
            ),
          ),
          Container(
              height: 1, width: Get.width, color: const Color(0xffADADAD)),

          /*------------------  OverView  and  Stylist Widget -----------------*/
          if (isSelectedTab == 1)
            Container(
              color: ColorConstant.whiteColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: ReadMoreText(
                      _homeController.homeSalonDetailsData.data?.description ??
                          "",
                      trimMode: TrimMode.Line,
                      style: AppTextTheme.medium.copyWith(
                          height: 1.5,
                          color: ColorConstant.blackColor,
                          fontSize: 14),
                      trimLines: 6,
                      colorClickableText: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)),
                      trimCollapsedText: 'more',
                      trimExpandedText: 'Show less',
                      moreStyle: AppTextTheme.medium.copyWith(
                          fontSize: 15,
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
                              child: Text(
                                "Selected Categories",
                                style: AppTextTheme.bold.copyWith(
                                    fontSize: 19,
                                    color: ColorConstant.blackColor),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: _homeController.salonDetailsListData
                                        .data?.selectedCategories?.length ??
                                    0,
                                itemBuilder: (context, index) {
                                  return ExpansionTile(
                                    initiallyExpanded:
                                        index == 0 ? true : false,
                                    title: Text(
                                      _homeController
                                              .salonDetailsListData
                                              .data
                                              ?.selectedCategories?[index]
                                              .name ??
                                          "",
                                      textScaler: const TextScaler.linear(0.85),
                                      style: AppTextTheme.bold.copyWith(
                                          color: ColorConstant.blackColor,
                                          fontSize: 20),
                                    ),
                                    children: [
                                      ListView.separated(
                                          separatorBuilder: (context, index) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  top: 20, bottom: 20),
                                              height: 1,
                                              width: Get.width,
                                              color: ColorConstant.dividerColor,
                                            );
                                          },
                                          shrinkWrap: true,
                                          itemCount: _homeController
                                                  .salonDetailsListData
                                                  .data
                                                  ?.selectedCategories?[index]
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
                                                  .selectedCategories![index]
                                                  .services![i],
                                              isSelect: _homeController
                                                      .salonDetailsListData
                                                      .data!
                                                      .selectedCategories?[
                                                          index]
                                                      .services?[i]
                                                      .isAddedToCart ??
                                                  false,
                                              addButtonTap: () {
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
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return RemoveAndAddServiceDialog(
                                                            noPress: () {
                                                          Get.back();
                                                        }, yesPress: () {
                                                          setState(() {
                                                            _homeController
                                                                .doClearCart(
                                                                    callback:
                                                                        () {
                                                              _homeController.doGetHomeSalonDetails(
                                                                  serviceGender:
                                                                      SharedPrefs.readStringValue(PrefConstants.gender) ==
                                                                              "0"
                                                                          ? "male"
                                                                          : "female",
                                                                  salonId:
                                                                      widget.id,
                                                                  lat: SharedPrefs
                                                                      .readStringValue(
                                                                          PrefConstants
                                                                              .latitude),
                                                                  lng: SharedPrefs
                                                                      .readStringValue(
                                                                          PrefConstants
                                                                              .longitude));
                                                              _homeController
                                                                  .doGetSalonDetailsService(
                                                                  serviceGender:
                                                                  SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                                                                      ? "male"
                                                                      : "female",
                                                                      salonId:
                                                                          widget
                                                                              .id);
                                                              _homeController
                                                                  .doGetSalonArtiestListData(
                                                                      salonId:
                                                                          widget
                                                                              .id);
                                                              _homeController
                                                                  .doGetCart();
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
                                                              _homeController
                                                                  .doGetSalonDetailsService(
                                                                  serviceGender:
                                                                  SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                                                                      ? "male"
                                                                      : "female",
                                                                      salonId:
                                                                          widget
                                                                              .id);
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                            serviceId = "";
                                                            stylistId.value =
                                                                "";
                                                          });
                                                        });
                                                      });
                                                } else {
                                                  setState(() {
                                                    _homeController
                                                        .salonDetailsListData
                                                        .data!
                                                        .selectedCategories?[
                                                            index]
                                                        .services?[i]
                                                        .isAddedToCart = !(_homeController
                                                            .salonDetailsListData
                                                            .data!
                                                            .selectedCategories?[
                                                                index]
                                                            .services?[i]
                                                            .isAddedToCart ??
                                                        false);

                                                    if (_homeController
                                                            .salonDetailsListData
                                                            .data!
                                                            .selectedCategories?[
                                                                index]
                                                            .services?[i]
                                                            .isAddedToCart ??
                                                        false) {
                                                      _homeController.doAddCart(
                                                          isHomeService: SharedPrefs
                                                              .readBoolValue(
                                                                  PrefConstants
                                                                      .isHomeService),
                                                          salonServiceId: _homeController
                                                                  .salonDetailsListData
                                                                  .data!
                                                                  .selectedCategories?[
                                                                      index]
                                                                  .services?[i]
                                                                  .id ??
                                                              "",
                                                          callback: () {
                                                            _homeController
                                                                .doGetCart();
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
                                                            _homeController
                                                                .doGetSalonDetailsService(
                                                                serviceGender:
                                                                SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                                                                    ? "male"
                                                                    : "female",
                                                                    salonId:
                                                                        widget
                                                                            .id);
                                                            showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                shape:
                                                                    const RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius
                                                                                .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          32),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          32),
                                                                )),
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AddProductSheetWidget(
                                                                    price: _homeController
                                                                            .salonDetailsListData
                                                                            .data!
                                                                            .selectedCategories?[index]
                                                                            .services?[i]
                                                                            .price ??
                                                                        0,
                                                                    rating: _homeController
                                                                            .salonDetailsListData
                                                                            .data!
                                                                            .selectedCategories?[index]
                                                                            .services?[i]
                                                                            .rating ??
                                                                        0.0,
                                                                    review: 0,
                                                                    nameOfService: _homeController
                                                                            .salonDetailsListData
                                                                            .data!
                                                                            .selectedCategories?[index]
                                                                            .services?[i]
                                                                            .name ??
                                                                        "",
                                                                    serviceId: _homeController
                                                                            .salonDetailsListData
                                                                            .data!
                                                                            .selectedCategories?[index]
                                                                            .services?[i]
                                                                            .id ??
                                                                        "",
                                                                  );
                                                                });
                                                          });
                                                    } else {
                                                      _homeController
                                                          .doRemoveCart(
                                                              salonServiceId: _homeController
                                                                      .salonDetailsListData
                                                                      .data!
                                                                      .selectedCategories?[
                                                                          index]
                                                                      .services?[
                                                                          i]
                                                                      .id ??
                                                                  "",
                                                              callback: () {
                                                                serviceId = "";
                                                                stylistId
                                                                    .value = "";
                                                                _homeController
                                                                    .doGetCart();
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
                                                                _homeController
                                                                    .doGetSalonDetailsService(
                                                                    serviceGender:
                                                                    SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                                                                        ? "male"
                                                                        : "female",
                                                                        salonId:
                                                                            widget.id);
                                                              });
                                                    }
                                                  });
                                                }
                                              },
                                              onTap: () {},
                                            );
                                          }),
                                      const SizedBox(height: 20),
                                    ],
                                  );
                                }),
                          ],
                        ),

                  /*-------------------- Recommend  Service -------------------*/

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 19, top: 15),
                        child: Text(
                          "Recommended Services",
                          style: AppTextTheme.bold.copyWith(
                              fontSize: 19, color: ColorConstant.blackColor),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _homeController.salonDetailsListData.data
                                  ?.recommendedCategories?.isEmpty ??
                              false
                          ? _homeController.showProgress
                              ? const SizedBox()
                              : const NoItemsWidget(
                                  text: "Recommended services not found.",
                                )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: _homeController.salonDetailsListData
                                      .data?.recommendedCategories?.length ??
                                  0,
                              itemBuilder: (context, index) {
                                return ExpansionTile(
                                  initiallyExpanded: index == 0 ? true : false,
                                  title: Text(
                                    _homeController
                                            .salonDetailsListData
                                            .data
                                            ?.recommendedCategories?[index]
                                            .name ??
                                        "",
                                    textScaler: const TextScaler.linear(0.85),
                                    style: AppTextTheme.bold.copyWith(
                                        color: ColorConstant.blackColor,
                                        fontSize: 20),
                                  ),
                                  children: [
                                    ListView.separated(
                                        separatorBuilder: (context, index) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                top: 30, bottom: 20),
                                            height: 1,
                                            width: Get.width,
                                            color: ColorConstant.dividerColor,
                                          );
                                        },
                                        shrinkWrap: true,
                                        itemCount: _homeController
                                                .salonDetailsListData
                                                .data
                                                ?.recommendedCategories?[index]
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
                                                .recommendedCategories![index]
                                                .services![i],
                                            isSelect: _homeController
                                                    .salonDetailsListData
                                                    .data!
                                                    .recommendedCategories?[
                                                        index]
                                                    .services?[i]
                                                    .isAddedToCart ??
                                                false,
                                            addButtonTap: () {
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
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return RemoveAndAddServiceDialog(
                                                          noPress: () {
                                                        Get.back();
                                                      }, yesPress: () {
                                                        stylistId.value = "";
                                                        stylistId
                                                            .notifyListeners();
                                                        setState(() {
                                                          _homeController
                                                              .doClearCart(
                                                                  callback: () {
                                                            _homeController.doGetHomeSalonDetails(
                                                                serviceGender:
                                                                    SharedPrefs.readStringValue(PrefConstants.gender) ==
                                                                            "0"
                                                                        ? "male"
                                                                        : "female",
                                                                salonId:
                                                                    widget.id,
                                                                lat: SharedPrefs
                                                                    .readStringValue(
                                                                        PrefConstants
                                                                            .latitude),
                                                                lng: SharedPrefs
                                                                    .readStringValue(
                                                                        PrefConstants
                                                                            .longitude));
                                                            _homeController
                                                                .doGetSalonDetailsService(
                                                                serviceGender:
                                                                SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                                                                    ? "male"
                                                                    : "female",
                                                                    salonId:
                                                                        widget
                                                                            .id);
                                                            _homeController
                                                                .doGetSalonArtiestListData(
                                                                    salonId:
                                                                        widget
                                                                            .id);
                                                            _homeController
                                                                .doGetCart();
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
                                                            _homeController
                                                                .doGetSalonDetailsService(
                                                                serviceGender:
                                                                SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                                                                    ? "male"
                                                                    : "female",
                                                                    salonId:
                                                                        widget
                                                                            .id);
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                          serviceId = "";
                                                          stylistId.value = "";
                                                        });
                                                      });
                                                    });
                                              } else {
                                                setState(() {
                                                  _homeController
                                                      .salonDetailsListData
                                                      .data!
                                                      .recommendedCategories?[
                                                          index]
                                                      .services?[i]
                                                      .isAddedToCart = !(_homeController
                                                          .salonDetailsListData
                                                          .data!
                                                          .recommendedCategories?[
                                                              index]
                                                          .services?[i]
                                                          .isAddedToCart ??
                                                      false);

                                                  if (_homeController
                                                          .salonDetailsListData
                                                          .data!
                                                          .recommendedCategories?[
                                                              index]
                                                          .services?[i]
                                                          .isAddedToCart ??
                                                      false) {
                                                    _homeController.doAddCart(
                                                        isHomeService: SharedPrefs
                                                            .readBoolValue(
                                                                PrefConstants
                                                                    .isHomeService),
                                                        salonServiceId: _homeController
                                                                .salonDetailsListData
                                                                .data!
                                                                .recommendedCategories?[
                                                                    index]
                                                                .services?[i]
                                                                .id ??
                                                            "",
                                                        callback: () {
                                                          _homeController
                                                              .doGetCart();
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
                                                          _homeController
                                                              .doGetSalonDetailsService(
                                                              serviceGender:
                                                              SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                                                                  ? "male"
                                                                  : "female",
                                                                  salonId:
                                                                      widget
                                                                          .id);
                                                          showModalBottomSheet(
                                                              isScrollControlled:
                                                                  true,
                                                              shape:
                                                                  const RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        32),
                                                                topRight: Radius
                                                                    .circular(
                                                                        32),
                                                              )),
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AddProductSheetWidget(
                                                                  price: _homeController
                                                                          .salonDetailsListData
                                                                          .data!
                                                                          .recommendedCategories?[
                                                                              index]
                                                                          .services?[
                                                                              i]
                                                                          .price ??
                                                                      0,
                                                                  rating: _homeController
                                                                          .salonDetailsListData
                                                                          .data!
                                                                          .recommendedCategories?[
                                                                              index]
                                                                          .services?[
                                                                              i]
                                                                          .rating ??
                                                                      0.0,
                                                                  review: 0,
                                                                  nameOfService: _homeController
                                                                          .salonDetailsListData
                                                                          .data!
                                                                          .recommendedCategories?[
                                                                              index]
                                                                          .services?[
                                                                              i]
                                                                          .name ??
                                                                      "",
                                                                  serviceId: _homeController
                                                                          .salonDetailsListData
                                                                          .data!
                                                                          .recommendedCategories?[
                                                                              index]
                                                                          .services?[
                                                                              i]
                                                                          .id ??
                                                                      "",
                                                                );
                                                              });
                                                        });
                                                  } else {
                                                    _homeController
                                                        .doRemoveCart(
                                                            salonServiceId: _homeController
                                                                    .salonDetailsListData
                                                                    .data!
                                                                    .recommendedCategories?[
                                                                        index]
                                                                    .services?[
                                                                        i]
                                                                    .id ??
                                                                "",
                                                            callback: () {
                                                              _homeController
                                                                  .doGetCart();
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
                                                              _homeController
                                                                  .doGetSalonDetailsService(
                                                                  serviceGender:
                                                                  SharedPrefs.readStringValue(PrefConstants.gender) == "0"
                                                                      ? "male"
                                                                      : "female",
                                                                      salonId:
                                                                          widget
                                                                              .id);
                                                            });
                                                  }
                                                });
                                              }
                                            },
                                            onTap: () {},
                                          );
                                        }),
                                    const SizedBox(height: 20),
                                  ],
                                );
                              }),
                    ],
                  )
                ],
              ),
            )
          else
            _homeController.getSalonDetailsArtiestData.data?.isEmpty ?? false
                ? const NoItemsWidget(
                    text: "No stylists are currently available.",
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.0,
                      crossAxisSpacing: 12.0,
                      childAspectRatio: 0.75, // Aspect ratio of each item
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
                  ),
          const SizedBox(height: 20)
        ],
      ),
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
      String time12 = DateFormat("h:m a").format(dateTime);
      return time12;
    }
  }
}
