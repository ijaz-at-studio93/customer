import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/model/home_salon_list_model.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'dart:async';
import 'package:flutter/gestures.dart';

class SaloonCardWidget extends StatefulWidget {
  final VoidCallback onPress;
  final HomeSalonDataList homeSalonModel;
  final bool isFav;
  const SaloonCardWidget({
    super.key,
    required this.onPress,
    required this.homeSalonModel,
    required this.isFav,
  });

  @override
  State<SaloonCardWidget> createState() => _SaloonCardWidgetState();
}

class _SaloonCardWidgetState extends State<SaloonCardWidget> {
  final _homeController = Get.find<HomeController>();

  // --- Carousel state ---
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;
  static const Duration _autoPlayInterval = Duration(seconds: 2);
  static const Duration _autoPlayResumeDelay = Duration(seconds: 2);
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartAutoPlay());
  }

  @override
  void didUpdateWidget(covariant SaloonCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If images changed, reset page and timer
    if (_getImageList(oldWidget.homeSalonModel) != _getImageList(widget.homeSalonModel)) {
      _currentPage = 0;
      if (_pageController.hasClients) _pageController.jumpToPage(0);
      _restartAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // --- helpers ---
  List<String> _getImageList(HomeSalonDataList model) {
    final imgs = <String>[];
    // prefer a list property `images` if exists
    try {
      final dynamic candidate = model.images;
      if (candidate is List && candidate.isNotEmpty) {
        for (final e in candidate) {
          if (e != null && e.toString().isNotEmpty) imgs.add(e.toString());
        }
      }
    } catch (_) {}
    // fallback to single image field
    if (imgs.isEmpty) {
      if ((model.image ?? '').isNotEmpty) imgs.add("${APIConstants.image}${model.image}");
    } else {
      for (int i = 0; i < imgs.length; i++) {
        final s = imgs[i];
        if (!s.startsWith('http')) imgs[i] = "${APIConstants.image}$s";
      }
    }
    return imgs;
  }

  void _maybeStartAutoPlay() {
    final images = _getImageList(widget.homeSalonModel);
    if (images.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(_autoPlayInterval, (_) {
      if (_isUserInteracting) return;
      final images = _getImageList(widget.homeSalonModel);
      if (images.length <= 1) return;
      final nextPage = (_currentPage + 1) % images.length;
      if (!_pageController.hasClients) return;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _restartAutoPlay() {
    _stopAutoPlay();
    Future.delayed(_autoPlayResumeDelay, () {
      if (!_isUserInteracting) _startAutoPlay();
    });
  }

  void _onUserInteractionStart() {
    _isUserInteracting = true;
    _stopAutoPlay();
  }

  void _onUserInteractionEnd() {
    _isUserInteracting = false;
    _restartAutoPlay();
  }

  Widget _buildImageCarousel(BuildContext context) {
    final images = _getImageList(widget.homeSalonModel);
    final imageHeight = Get.height * 0.25; // EXACT original height

    if (images.isEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Image.asset(
          AssetsConstant.placeHolder,
          width: Get.width,
          height: imageHeight,
          fit: BoxFit.fitWidth,
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: SizedBox(
        width: Get.width,
        height: imageHeight, // FORCE same height
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (_) => _onUserInteractionStart(),
          onPanCancel: _onUserInteractionEnd,
          onPanEnd: (_) => _onUserInteractionEnd(),
          onTapDown: (_) => _onUserInteractionStart(),
          onTapUp: (_) => _onUserInteractionEnd(),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final imageUrl = images[index];
                  // replace the existing `return SizedBox(...)` inside itemBuilder with this:
                  return GestureDetector(
                    onTap: widget.onPress, // restore image tap (calls same callback as whole card)
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: Get.width,
                      height: imageHeight,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: Get.width,
                        height: imageHeight,
                        fit: BoxFit.fitWidth,
                        placeholder: (c, u) => Image.asset(
                          AssetsConstant.placeHolder,
                          width: Get.width,
                          height: imageHeight,
                          fit: BoxFit.fitWidth,
                        ),
                        errorWidget: (c, u, e) => Image.asset(
                          AssetsConstant.placeHolder,
                          width: Get.width,
                          height: imageHeight,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // gradient overlay (single copy inside carousel)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: Get.width,
                      height: Get.height * 0.25, // same overlay as original
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            ColorConstant.blackColor,
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // dots indicator
              if (images.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 10 : 7,
                        height: isActive ? 10 : 7,
                        decoration: BoxDecoration(
                          color: isActive ? ColorConstant.whiteColor : Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: GestureDetector(
        onTap: widget.onPress,
        child: Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: ColorConstant.crossMarkColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorConstant.strokeColor, width: 1.5),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  _buildImageCarousel(context),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       begin: Alignment.bottomCenter,
                  //       end: Alignment.topCenter,
                  //       colors: [
                  //         ColorConstant.blackColor,
                  //         Colors.black.withOpacity(0),
                  //         Colors.black.withOpacity(0),
                  //       ],
                  //     ),
                  //   ),
                  //   width: Get.width,
                  //   height: Get.height * 0.25,
                  // ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.homeSalonModel.isFavourite =
                              !(widget.homeSalonModel.isFavourite ?? false);
                          if (widget.homeSalonModel.isFavourite ?? false) {
                            _homeController.doAddFavouriteSalon(
                                salonId: widget.homeSalonModel.id ?? "");
                          } else {
                            _homeController.doRemoveFavouriteSalon(
                                callback: () {},
                                salonId: widget.homeSalonModel.id ?? "");
                          }
                        });
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorConstant.blackColor),
                        child: Center(
                          child: widget.homeSalonModel.isFavourite ?? false
                              ? const Icon(
                                  CupertinoIcons.heart_fill,
                                  color: Colors.red,
                                )
                              : Image.asset(
                                  AssetsConstant.likeBlank,
                                  height: 20,
                                  width: 20,
                                  color: ColorConstant.whiteColor,
                                ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star,
                          color: ColorConstant.yellowColor,
                          size: 20,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          (widget.homeSalonModel.averageArtistRatings ?? 0).toStringAsFixed(2),
                          style: AppTextTheme.medium.copyWith(
                              fontSize: 11, color: ColorConstant.yellowColor),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Average Stylist Rating',
                          style: AppTextTheme.medium.copyWith(
                              fontSize: 13, color: ColorConstant.whiteColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: Get.width * 0.5,
                          child: Text(
                            '${widget.homeSalonModel.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textScaler: const TextScaler.linear(0.85),
                            style: AppTextTheme.bold.copyWith(
                                fontSize: 19, color: ColorConstant.blackColor),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${widget.homeSalonModel.distanceTime} Min • ${widget.homeSalonModel.homeService == true ? "Available for Home" : "Available for Shop"}",
                          style: AppTextTheme.medium.copyWith(
                              color: ColorConstant.grayTextColor, fontSize: 13),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              "Starting From",
                              style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.grayTextColor,
                                  fontSize: 13),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "₹${widget.homeSalonModel.serviceStartingPrice} Onwards",
                              style: AppTextTheme.bold.copyWith(
                                  color: changeTheme(
                                      SharedPrefs.readStringValue(
                                          PrefConstants.gender)),
                                  fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height:
                                5), /* Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              AssetsConstant.locationNewIcon,
                              height: 15,
                              width: 15,
                              color: changeTheme(SharedPrefs.readStringValue(
                                  PrefConstants.gender)),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: Get.width * 0.75,
                              child: Text(
                                '${widget.homeSalonModel.address}',
                                style: AppTextTheme.medium.copyWith(
                                    fontSize: 13,
                                    color: ColorConstant.grayTextColor),
                              ),
                            ),
                          ],
                        ),*/
                      ],
                    ),
                    Container(
                      height: 28,
                      width: 52,
                      decoration: BoxDecoration(
                          color: ColorConstant.greenColor,
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star,
                              color: ColorConstant.whiteColor, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            widget.homeSalonModel.rating.toString(),
                            style: AppTextTheme.medium.copyWith(
                                color: ColorConstant.whiteColor, fontSize: 11),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Dash(
                direction: Axis.horizontal,
                length: Get.width * 0.8,
                dashLength: 2,
                dashColor: ColorConstant.grayTextColor,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    Image.asset(
                      AssetsConstant.newOfferIcon,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Upto 20% Off ",
                      style: AppTextTheme.bold.copyWith(
                          color: ColorConstant.offerTextColor, fontSize: 13),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
