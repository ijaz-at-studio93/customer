import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/model/artiest_list_model.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

import '../../../project_specific/text_theme.dart';
import '../stylist_saloon_details_page.dart';

class SelectedFavArtistCardWidget extends StatelessWidget {
  final VoidCallback onPress;
  final VoidCallback callback;
  final bool isSelected;
  final Artiest artiest;
  final String salonId;
  final String sectionType;
  final ServiceMeta serviceMeta;
  final bool isFromBeauty;
  final bool isAllRounder;

  const SelectedFavArtistCardWidget({
    super.key,
    required this.onPress,
    required this.artiest,
    required this.salonId,
    required this.callback,
    required this.sectionType,
    required this.serviceMeta,
    required this.isFromBeauty,
    required this.isAllRounder,
    required this.isSelected, // ✅ ADD THIS
  });

  String getTagText() {
    final hasHair =
        serviceMeta.hasMaleHair || serviceMeta.hasFemaleHair;

    final hasBeauty =
        serviceMeta.hasMaleBeauty || serviceMeta.hasFemaleBeauty;

    /// 🔥 CASE 1: Only Hair
    if (hasHair && !hasBeauty) {
      return "Stylist";
    }

    /// 🔥 CASE 2: Only Beauty
    if (!hasHair && hasBeauty) {
      return "Beautician";
    }

    /// 🔥 CASE 3: Mixed
    return isFromBeauty ? "Beautician" : "Stylist";
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = changeTheme(
      SharedPrefs.readStringValue(PrefConstants.gender),
    ) ??
        ColorConstant.primaryColor;

    //final isSelected = artiest.isSelectArtist ?? false;

    return Container(
      // ❌ Removed width (parent controls 138)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: themeColor.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ prevents overflow
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: SizedBox(
              height: 100,
              width: double.infinity,
              child: Stack(
                children: [

                  /// IMAGE
                  Positioned.fill(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: '${APIConstants.image}${artiest.profileImage}',
                      placeholder: (_, __) => Image.asset(
                        AssetsConstant.placeHolder,
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (_, __, ___) => Image.asset(
                        AssetsConstant.placeHolder,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  /// 🔥 TAG (TOP RIGHT)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        getTagText(), // 👈 THIS IS STEP 5
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),
                  if (isAllRounder)
                    Positioned(
                      top: 26, // 👈 slightly below existing tag
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "All Rounder",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// 🔥 NAME + RATING
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
            child: Row(
              children: [
                /// NAME
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final text = artiest.name ?? "";

                      final textPainter = TextPainter(
                        text: TextSpan(
                          text: text,
                          style: AppTextTheme.bold.copyWith(fontSize: 13),
                        ),
                        maxLines: 2,
                        textDirection: TextDirection.ltr,
                      )..layout(maxWidth: constraints.maxWidth);

                      final isTwoLines = textPainter.computeLineMetrics().length > 1;

                      return Text(
                        text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextTheme.bold.copyWith(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          fontSize: isTwoLines ? 9.15 : 13, // 🔥 KEY LOGIC
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ),

                /// RATING
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.red, size: 13),
                    const SizedBox(width: 2),
                    Text(
                      "${artiest.rating ?? "0"}",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          /// 🔥 FLEXIBLE BOTTOM AREA (fix overflow)
          // Expanded(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       /// SELECT BUTTON
          //       Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 10),
          //         child: GestureDetector(
          //           onTap: callback,
          //           child: Container(
          //             height: 24, // ✅ reduced from 32
          //             decoration: BoxDecoration(
          //               color: isSelected ? Colors.green : Colors.transparent,
          //               borderRadius: BorderRadius.circular(20),
          //               border: Border.all(color: themeColor),
          //             ),
          //             child: Center(
          //               child: Text(
          //                 isSelected ? "Selected" : "Select",
          //                 style: TextStyle(
          //                   fontSize: 12,
          //                   fontWeight: FontWeight.w500,
          //                   fontFamily: 'Outfit',
          //                   color:
          //                   isSelected ? Colors.white : Colors.black,
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //
          //       const SizedBox(height: 7),
          //
          //       /// VIEW PROFILE
          //       GestureDetector(
          //         onTap: () {
          //           //Get.back();
          //           Get.to(() => StylistSaloonDetailsPage(
          //             isViewDetails: true,
          //             salonId: salonId,
          //             artiestId: artiest.id ?? "",
          //           ));
          //         },
          //         child: Text(
          //           "View Profile",
          //           style: TextStyle(
          //             fontFamily: 'Outfit',
          //             fontSize: 12,
          //             fontWeight: FontWeight.w600,
          //             color: themeColor,
          //             decoration: TextDecoration.underline,
          //             decorationColor: themeColor, // same color as text
          //             decorationThickness: 2,    // 🔥 thickness like design
          //             decorationStyle: TextDecorationStyle.solid,
          //
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// 🔥 SELECT BUTTON (FIXED)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: callback,
                      child: Container(
                        height: 28, // 🔥 slightly increased for better tap
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: themeColor),
                        ),
                        child: Text(
                          isSelected ? "Selected" : "Select",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Outfit',
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                /// 🔥 VIEW PROFILE (FIXED)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      Get.to(() => StylistSaloonDetailsPage(
                        isViewDetails: true,
                        salonId: salonId,
                        artiestId: artiest.id ?? "",
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6, // 🔥 increases tap area
                      ),
                      child: Text(
                        "View Profile",
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                          decoration: TextDecoration.underline,
                          decorationColor: themeColor,
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}