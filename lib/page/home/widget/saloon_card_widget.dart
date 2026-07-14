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
import 'package:salon_customer/project_specific/shine_wrapper.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  late List<String> _images;
  static const Duration _autoPlayResumeDelay = Duration(seconds: 2);
  bool _isUserInteracting = false;
  //static const String kLongPressHintShown = "long_press_image_hint_shown";

  @override
  void initState() {
    super.initState();
    _images = _getImageList(widget.homeSalonModel); // ← add this line
    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartAutoPlay());
  }

  // @override
  // void didUpdateWidget(covariant SaloonCardWidget oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   // If images changed, reset page and timer
  //   if (_getImageList(oldWidget.homeSalonModel) !=
  //       _getImageList(widget.homeSalonModel)) {
  //     _currentPage = 0;
  //     if (_pageController.hasClients) _pageController.jumpToPage(0);
  //     _restartAutoPlay();
  //   }
  // }

  @override
  void didUpdateWidget(covariant SaloonCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// 🔥 FIX: compare by ID (not list)
    if (oldWidget.homeSalonModel.id != widget.homeSalonModel.id) {
      _images = _getImageList(widget.homeSalonModel);

      _currentPage = 0;

      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }

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
    // prefer a list property ⁠ images ⁠ if exists
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
      if ((model.image ?? '').isNotEmpty)
        imgs.add("${APIConstants.image}${model.image}");
    } else {
      for (int i = 0; i < imgs.length; i++) {
        final s = imgs[i];
        if (!s.startsWith('http')) imgs[i] = "${APIConstants.image}$s";
      }
    }
    return imgs;
  }

  void _maybeStartAutoPlay() {
    if (_autoPlayTimer != null) return; // prevent duplicate timers

    //final images = _getImageList(widget.homeSalonModel);
    if (_images.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    // Row 18: auto-scroll of the salon image carousel is disabled.
    // Images now advance only when the user swipes manually.
    _autoPlayTimer?.cancel();
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
    final images = _images;
    //final imageHeight = 183.0; //Get.height * 0.30; // EXACT original height

    if (images.isEmpty) {
      // return ClipRRect(
      //   borderRadius: const BorderRadius.only(
      //     topLeft: Radius.circular(10),
      //     topRight: Radius.circular(10),
      //   ),
      //   child: Image.asset(
      //     AssetsConstant.placeHolder,
      //     width: Get.width,
      //     height: imageHeight,
      //     fit: BoxFit.cover,
      //   ),
      // );
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9, // 🔥 THIS FIXES YOUR ISSUE
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final imageUrl = images[index];

              return CachedNetworkImage(
                imageUrl: imageUrl,
                width: Get.width,
                fit: BoxFit.cover, // keep this
              );
            },
          ),
        ),
      );
    }

    // return ClipRRect(
    //   borderRadius: const BorderRadius.only(
    //     topLeft: Radius.circular(10),
    //     topRight: Radius.circular(10),
    //   ),
    //   child: SizedBox(
    //     width: Get.width,
    //     //height: imageHeight, // FORCE same height
    //     child: GestureDetector(
    //       behavior: HitTestBehavior.opaque,
    //       onPanDown: (_) => _onUserInteractionStart(),
    //       onPanCancel: _onUserInteractionEnd,
    //       onPanEnd: (_) => _onUserInteractionEnd(),
    //       onTapDown: (_) => _onUserInteractionStart(),
    //       onTapUp: (_) => _onUserInteractionEnd(),
    //       child: Stack(
    //         children: [
    //           PageView.builder(
    //             controller: _pageController,
    //             itemCount: images.length,
    //             onPageChanged: (index) {
    //               setState(() => _currentPage = index);
    //             },
    //             itemBuilder: (context, index) {
    //               final imageUrl = images[index];
    //               // replace the existing ⁠ return SizedBox(...) ⁠ inside itemBuilder with this:
    //               return GestureDetector(
    //                 onTap: widget
    //                     .onPress, // restore image tap (calls same callback as whole card)
    //                 onLongPress: () {
    //                   _showImagePreview(context, imageUrl);
    //                 },
    //                 behavior: HitTestBehavior.opaque,
    //                 child: SizedBox(
    //                   width: Get.width,
    //                   //height: imageHeight,
    //                   child: CachedNetworkImage(
    //                     imageUrl: imageUrl,
    //                     width: Get.width,
    //                     //height: imageHeight,
    //                     fit: BoxFit.cover,
    //                     memCacheWidth: Get.width.toInt(),  // ← add this
    //                     //memCacheHeight: imageHeight.toInt(),
    //                     placeholder: (c, u) => Image.asset(
    //                       AssetsConstant.placeHolder,
    //                       width: Get.width,
    //                       //height: imageHeight,
    //                       fit: BoxFit.cover,
    //                     ),
    //                     errorWidget: (c, u, e) => Image.asset(
    //                       AssetsConstant.placeHolder,
    //                       width: Get.width,
    //                       //height: imageHeight,
    //                       fit: BoxFit.cover,
    //                     ),
    //                   ),
    //                 ),
    //               );
    //             },
    //           ),
    //
    //           // gradient overlay (single copy inside carousel)
    //           Positioned.fill(
    //             child: IgnorePointer(
    //               ignoring: true,
    //               child: Container(
    //                 alignment: Alignment.bottomCenter,
    //                 child: Container(
    //                   width: Get.width,
    //                   height: Get.height * 0.25, // same overlay as original
    //                   decoration: BoxDecoration(
    //                     gradient: LinearGradient(
    //                       begin: Alignment.bottomCenter,
    //                       end: Alignment.topCenter,
    //                       colors: [
    //                         ColorConstant.blackColor,
    //                         Colors.black.withOpacity(0),
    //                         Colors.black.withOpacity(0),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ),
    //           // dots indicator
    //           if (images.length > 1)
    //             Positioned(
    //               bottom: 8,
    //               left: 0,
    //               right: 0,
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.end,
    //                 children: List.generate(images.length, (i) {
    //                   final isActive = i == _currentPage;
    //                   return AnimatedContainer(
    //                     duration: const Duration(milliseconds: 250),
    //                     margin: const EdgeInsets.symmetric(horizontal: 4),
    //                     width: isActive ? 10 : 7,
    //                     height: isActive ? 10 : 7,
    //                     decoration: BoxDecoration(
    //                       color: isActive
    //                           ? ColorConstant.whiteColor
    //                           : Colors.white54,
    //                       shape: BoxShape.circle,
    //                     ),
    //                   );
    //                 }),
    //               ),
    //             ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),

      /// 🔥 MAIN FIX: use AspectRatio instead of SizedBox height
      child: AspectRatio(
        aspectRatio: 16 / 9,

        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (_) => _onUserInteractionStart(),
          onPanCancel: _onUserInteractionEnd,
          onPanEnd: (_) => _onUserInteractionEnd(),
          onTapDown: (_) => _onUserInteractionStart(),
          onTapUp: (_) => _onUserInteractionEnd(),

          child: Stack(
            children: [

              /// 🔥 IMAGE CAROUSEL
              PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final imageUrl = images[index];

                  return GestureDetector(
                    onTap: widget.onPress,
                    onLongPress: () {
                      _showImagePreview(context, imageUrl);
                    },
                    behavior: HitTestBehavior.opaque,

                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: Get.width,
                      fit: BoxFit.cover, // ✅ correct

                      memCacheWidth: (Get.width * 2).toInt(),

                      placeholder: (c, u) => Image.asset(
                        AssetsConstant.placeHolder,
                        width: Get.width,
                        fit: BoxFit.cover,
                      ),

                      errorWidget: (c, u, e) => Image.asset(
                        AssetsConstant.placeHolder,
                        width: Get.width,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),

              /// 🔥 GRADIENT OVERLAY
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: Get.height * 0.25,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0x73000000),
                            Color(0x00000000),
                          ],
                          stops: [0.0, 0.35],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// 🔥 DOT INDICATOR
              if (images.length > 1)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Row(
                    children: List.generate(images.length, (i) {
                      final isActive = i == _currentPage;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 8 : 6,
                        height: isActive ? 8 : 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? ColorConstant.whiteColor
                              : Colors.white54,
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

  void _showImagePreview(BuildContext context, String imageUrl) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ImagePreview",
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Center(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Hero(
              tag: imageUrl,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(32),
                clipBehavior: Clip.antiAlias, // 🔥 THIS IS IMPORTANT
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  width: Get.width * 0.9,
                  height: Get.height * 0.7,
                  placeholder: (c, u) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return Transform.scale(
          scale: Curves.easeOut.transform(anim.value),
          child: Opacity(
            opacity: anim.value,
            child: child,
          ),
        );
      },
    );
  }

  // void _maybeShowLongPressHint(BuildContext context) async {
  //   final alreadyShown =
  //   SharedPrefs.readBoolValue(kLongPressHintShown);
  //
  //   if (alreadyShown) return;
  //
  //   await SharedPrefs.writeBoolValue(kLongPressHintShown, true);
  //
  //   await Future.delayed(const Duration(milliseconds: 600));
  //   if (!mounted) return;
  //
  //   showGeneralDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     barrierColor: Colors.black.withOpacity(0.35),
  //     pageBuilder: (, _, _) {
  //       return Center(
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //           decoration: BoxDecoration(
  //             color: Colors.black87,
  //             borderRadius: BorderRadius.circular(14),
  //           ),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: const [
  //               Icon(Icons.touch_app, color: Colors.white),
  //               SizedBox(width: 8),
  //               Text(
  //                 "Long press on the image to view full screen",
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  //
  //   Future.delayed(const Duration(seconds: 3), () {
  //     if (Get.isDialogOpen == true) Navigator.of(context).maybePop();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('salon-${widget.homeSalonModel.id}'),
      onVisibilityChanged: (info) {
        final visiblePercentage = info.visibleFraction * 100;

        if (visiblePercentage > 80) {
          // ✅ Mostly visible → allow autoplay
          _maybeStartAutoPlay();
          //_maybeShowLongPressHint(context);
        } else {
          // ❌ Partially visible → stop autoplay
          _stopAutoPlay();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: GestureDetector(
          onTap: widget.onPress,
          child: Container(
            width: Get.width,
            //height: 255,
            decoration: BoxDecoration(
              color: ColorConstant.whiteColor,
              borderRadius: BorderRadius.circular(10),
              // border: Border.all(
              //   color: changeTheme(
              //     SharedPrefs.readStringValue(PrefConstants.gender),
              //   )!,
              //   width: 1.5,
              // ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ]
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    _buildImageCarousel(context),
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
                    // Positioned(
                    //   top: 17,
                    //   left: 1,
                    //   child: Container(
                    //     //height: 18,
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 15, vertical: 5),
                    //     decoration: BoxDecoration(
                    //       color: Colors.white.withOpacity(0.7), // ✅ Figma color
                    //       borderRadius:
                    //           BorderRadius.circular(4), // ✅ pill shape
                    //     ),
                    //     child: Row(
                    //       mainAxisSize:
                    //           MainAxisSize.min, // ✅ important (no full width)
                    //       children: [
                    //         Image.asset(
                    //           AssetsConstant.newOfferIcon,
                    //           width: 18, // 🔥 slightly smaller (Figma match)
                    //           height: 18,
                    //         ),
                    //         const SizedBox(width: 4),
                    //         Builder(
                    //           builder: (_) {
                    //             final discountText =
                    //                 _getHighestDiscountForSalon();
                    //
                    //             if (discountText.isEmpty)
                    //               return const SizedBox();
                    //
                    //             return Text(
                    //               "${discountText} Off",
                    //               style: AppTextTheme.bold.copyWith(
                    //                 fontFamily: "Inter", // ✅ Figma font
                    //                 fontWeight:
                    //                     FontWeight.w900, // ✅ Black weight
                    //                 fontSize: 12, // ✅ exact size
                    //                 color: const Color(
                    //                     0xFFE800E4), // ✅ exact color
                    //               ),
                    //             );
                    //           },
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Builder(
                      builder: (_) {
                        final discountText = _getHighestDiscountForSalon();

                        /// ❌ No offer → hide completely
                        if (discountText.isEmpty) {
                          return const SizedBox();
                        }

                        /// ✅ Show only when offer exists
                        return Positioned(
                          top: 15,
                          left: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  AssetsConstant.newOfferIcon,
                                  width: 18,
                                  height: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "$discountText Off",
                                  style: AppTextTheme.bold.copyWith(
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color: const Color(0xFFE800E4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.homeSalonModel.displayName ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.homeSalonModel.address ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:  TextStyle(
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w400,
                              fontSize: 9,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                //const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7,vertical: 3.5),
                  //padding: const EdgeInsets.only(left: 7,right: 14,top: 2.5, bottom: 2.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TOP CONTENT
                          // SizedBox(
                          //   width: Get.width * 0.65,
                          //   child: Text(
                          //     //'${widget.homeSalonModel.name}',
                          //     '${widget.homeSalonModel.displayName}',
                          //     maxLines: 1,
                          //     overflow: TextOverflow.ellipsis,
                          //     style: AppTextTheme.bold.copyWith(
                          //       fontFamily: "Outfit",
                          //       fontWeight: FontWeight.w600,
                          //       fontSize: 18,
                          //       color: ColorConstant.blackColor,
                          //     ),
                          //   ),
                          // ),
                          //
                          // SizedBox(
                          //   width: Get.width * 0.6,
                          //   child: Text(
                          //     '${widget.homeSalonModel.address}',
                          //     maxLines: 2,
                          //     overflow: TextOverflow.ellipsis,
                          //     style: AppTextTheme.bold.copyWith(
                          //       fontFamily: "Outfit",
                          //       fontWeight: FontWeight.w600,
                          //       fontSize: 10.5,
                          //       color: Colors.black45,
                          //       height: 1,
                          //     ),
                          //   ),
                          // ),
                          //
                          // const SizedBox(height: 1),

                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12.5,
                                color: const Color(0xFF057336),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${(widget.homeSalonModel.distance! / 1000 * 10).roundToDouble() / 10} Km Drive",
                                style: AppTextTheme.medium.copyWith(
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                  color: const Color(0xFF057336),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 4),

                              Text(
                                "|",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: changeTheme(
                                    SharedPrefs.readStringValue(PrefConstants.gender),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 4),
                              Icon(
                                Icons.lightbulb_outline, // 👈 common amenities icon
                                size: 16,
                                color: changeTheme(
                                  SharedPrefs.readStringValue(PrefConstants.gender),
                                ),
                              ),

                              Text(
                                widget.homeSalonModel.amenities ??
                                    "",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: AppTextTheme.medium.copyWith(
                                  color: changeTheme(
                                      SharedPrefs.readStringValue(PrefConstants.gender)),
                                  fontSize: 12,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          /// 🔥 KEY FIX
                          //const SizedBox(height: 6), // 👈 fixed gap (won’t depend on above)

                          /// STARTS FROM (LOCKED POSITION RELATIVE)
                          Row(
                            children: [
                              Text(
                                "Starts From",
                                style: AppTextTheme.medium.copyWith(
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "₹${widget.homeSalonModel.serviceStartingPrice} Onwards",
                                style: AppTextTheme.bold.copyWith(
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: changeTheme(
                                    SharedPrefs.readStringValue(
                                        PrefConstants.gender),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      (widget.homeSalonModel.reviewCount ?? 0) == 0
                          // No reviews yet → show a "New" tag instead of a 0 rating.
                          ? ShineWrapper(
                              child: Container(
                                height: 26,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: ColorConstant.greenColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "New",
                                  style: AppTextTheme.medium.copyWith(
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: ColorConstant.whiteColor,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 26,
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            decoration: BoxDecoration(
                              color: ColorConstant.greenColor,
                              borderRadius:
                                  BorderRadius.circular(10), // 👈 pill shape
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: ColorConstant.whiteColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  widget.homeSalonModel.rating
                                          ?.toStringAsFixed(1) ??
                                      "0.0",
                                  style: AppTextTheme.medium.copyWith(
                                    fontFamily: "Outfit", // ✅ Figma font
                                    fontWeight: FontWeight.w600, // ✅ SemiBold
                                    fontSize: 16, // ✅ correct size
                                    color: ColorConstant.whiteColor,
                                    height: 1.2, // ✅ keeps it vertically tight
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 2),

                          Center(
                            child: Text(
                              "${_formatReviewCount(widget.homeSalonModel.reviewCount ?? 0)} Reviews",
                              style: AppTextTheme.medium.copyWith(
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: ColorConstant.blackColor,
                                height: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2), // 🔥 spacing like Figma

                          Container(
                            height: 2, // 🔥 stroke thickness
                            width: 40, // 🔥 adjust based on text width
                            decoration: BoxDecoration(
                              color: changeTheme(
                                SharedPrefs.readStringValue(
                                    PrefConstants.gender),
                              ), // ✅ Figma purple
                              borderRadius:
                                  BorderRadius.circular(10), // 👈 rounded ends
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 2),
                // Dash(
                //   direction: Axis.horizontal,
                //   length: Get.width * 0.8,
                //   dashLength: 2,
                //   dashColor: ColorConstant.grayTextColor,
                // ),
                // Padding(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                //   child: Row(
                //     children: [
                //       Image.asset(
                //         AssetsConstant.newOfferIcon,
                //         width: 20,
                //         height: 20,
                //       ),
                //       const SizedBox(width: 8),
                //
                //       Builder(
                //         builder: (_) {
                //           final discountText = _getHighestDiscountForSalon();
                //
                //           if (discountText.isEmpty) return const SizedBox();
                //
                //           return Text(
                //             discountText,
                //             style: AppTextTheme.bold.copyWith(
                //               color: ColorConstant.offerTextColor,
                //               fontSize: 13,
                //             ),
                //           );
                //         },
                //       ),
                //     ],
                //   )
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 10000) return "10K+";
    if (count >= 1000) return "${(count / 1000).toStringAsFixed(1)}K+";
    return count.toString();
  }

  String _getHighestDiscountForSalon() {
    final promoList = _homeController.getPromoCodeModel.data;
    final salonId = widget.homeSalonModel.id;

    if (promoList == null || promoList.isEmpty || salonId == null) return "";

    double maxPercent = 0;

    for (var promo in promoList) {
      if (promo.salon?.id == salonId && promo.type == "percentage") {
        final percent = (promo.amount ?? 0).toDouble();

        if (percent > maxPercent) {
          maxPercent = percent;
        }
      }
    }

    if (maxPercent == 0) return "";

    return _formatPercent(maxPercent);
  }

  String _formatPercent(double value) {
    if (value % 1 == 0) {
      return "${value.toInt()}%";
    } else {
      return "${value.toStringAsFixed(1)}%";
    }
  }
}
