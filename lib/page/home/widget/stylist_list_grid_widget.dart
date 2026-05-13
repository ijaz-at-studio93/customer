import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/model/salon_details_artiest.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import '../../../constant/api_constant.dart';
import '../../../constant/variable_constant.dart';
import '../../../util/SharedPrefs.dart';
import '../../stylist/stylist_saloon_details_page.dart';

class StylistListGridWidget extends StatefulWidget {
  final VoidCallback onPress;
  final bool isView;
  final String id;
  final SalonArtiestListModel salonArtiestListModel;

  const StylistListGridWidget({
    super.key,
    required this.onPress,
    required this.salonArtiestListModel,
    required this.isView,
    required this.id,
  });

  @override
  State<StylistListGridWidget> createState() => _StylistListGridWidgetState();
}

class _StylistListGridWidgetState extends State<StylistListGridWidget> {
  @override
  Widget build(BuildContext context) {
    final themeColor = changeTheme(
      SharedPrefs.readStringValue(PrefConstants.gender),
    ) ??
        ColorConstant.primaryColor;
    return GestureDetector(
      onTap: widget.onPress,
      child: Container(
        height: 200,
        // height: 180,
        // width: 138,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: themeColor.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
        ),
    //     child: Column(
    //       children: [
    //         Stack(
    //           children: [
    //             ClipRRect(
    //               borderRadius: const BorderRadius.only(
    //                 topLeft: Radius.circular(15),
    //                 topRight: Radius.circular(15),
    //               ),
    //               child: CachedNetworkImage(
    //                 width: 106,//Get.width,
    //                 height: 100,
    //                 fit: BoxFit.fitHeight,
    //                 imageUrl:
    //                     "${APIConstants.image}${widget.salonArtiestListModel.profileImage}",
    //                 placeholder: (context, url) => Image(
    //                   image: const AssetImage(AssetsConstant.placeHolder),
    //                   width: 106,//Get.width,
    //                   height: 100,
    //                   fit: BoxFit.cover,
    //                 ),
    //                 errorWidget: (context, url, error) => Image(
    //                   image: const AssetImage(AssetsConstant.placeHolder),
    //                   width: 106,//Get.width,
    //                   height: 100,
    //                   fit: BoxFit.cover,
    //                 ),
    //               ),
    //             ), /*  Positioned(
    //               top: 10,
    //               left: 12,
    //               child: Container(
    //                 height: 25,
    //                 width: Get.width * 0.22,
    //                 decoration: BoxDecoration(
    //                     color: ColorConstant.topRatedColor,
    //                     borderRadius: BorderRadius.circular(6)),
    //                 child: Center(
    //                   child: Text(
    //                     "TOP RATED",
    //                     style: AppTextTheme.medium.copyWith(
    //                         color: ColorConstant.whiteColor, fontSize: 11),
    //                   ),
    //                 ),
    //               ),
    //             )*/
    //           ],
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Text(
    //                 widget.salonArtiestListModel.name ?? "",
    //                 maxLines: 1,
    //                 overflow: TextOverflow.ellipsis,
    //                 style: AppTextTheme.bold.copyWith(
    //                   fontFamily: 'Outfit',
    //                   fontWeight: FontWeight.w700,
    //                   fontSize: 13, // ✅ reduced
    //                   color: Colors.black,
    //                 ),
    //               ),
    //               Row(
    //                 children: [
    //                   const Icon(
    //                     Icons.star,
    //                     color: Colors.red,
    //                     size: 13,
    //                   ),
    //                   const SizedBox(width: 3),
    //                   Text(
    //                     widget.salonArtiestListModel.rating.toString(),
    //                     style: const TextStyle(
    //                       fontSize: 11,
    //                       fontWeight: FontWeight.w500,
    //                       color: Colors.red,
    //                     ),
    //                   ),
    //                 ],
    //               )
    //             ],
    //           ),
    //         ),
    //         /* !widget.isView
    //             ? const SizedBox()
    //             : GestureDetector(
    //                 onTap: () {
    //                   setState(() {
    //                     widget.salonArtiestListModel.isSelected =
    //                         !(widget.salonArtiestListModel.isSelected ?? false);
    //                   });
    //                 },
    //                 child: widget.salonArtiestListModel.isSelected ?? false
    //                     ? RemoveButtonWidget(onPress: () {
    //                         setState(() {
    //                           widget.salonArtiestListModel.isSelected = false;
    //                         });
    //                       })
    //                     : Container(
    //                         height: 39,
    //                         width: 110,
    //                         decoration: BoxDecoration(
    //                             borderRadius: BorderRadius.circular(56),
    //                             border: Border.all(
    //                               color: changeTheme(
    //                                       SharedPrefs.readStringValue(
    //                                           PrefConstants.gender)) ??
    //                                   ColorConstant.primaryColor,
    //                             )),
    //                         child: Center(
    //                           child: Text(
    //                             "Select Artist",
    //                             style: AppTextTheme.medium.copyWith(
    //                                 color: changeTheme(
    //                                         SharedPrefs.readStringValue(
    //                                             PrefConstants.gender)) ??
    //                                     ColorConstant.primaryColor,
    //                                 fontSize: 13),
    //                           ),
    //                         ),
    //                       ),
    //               ),*/
    //         /*!widget.isView ? const SizedBox() : const SizedBox(),*/
    //         TextButton(
    //           onPressed: () {
    //             Get.to(() => StylistSaloonDetailsPage(
    //                   isViewDetails: true,
    //                   salonId: widget.id,
    //                   artiestId: widget.salonArtiestListModel.id ?? "",
    //                 ));
    //           },
    //           child: Text(
    //             "View Profile",
    //             style: TextStyle(
    //               fontFamily: 'Outfit',
    //               fontSize: 12,
    //               fontWeight: FontWeight.w600,
    //               color: changeTheme(
    // SharedPrefs.readStringValue(PrefConstants.gender)),
    //               decoration: TextDecoration.underline,
    //               decorationColor: changeTheme(
    // SharedPrefs.readStringValue(PrefConstants.gender)), // same color as text
    //               decorationThickness: 2,    // 🔥 thickness like design
    //               decorationStyle: TextDecorationStyle.solid,
    //
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 🔥 KEY
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: CachedNetworkImage(
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
                imageUrl:
                "${APIConstants.image}${widget.salonArtiestListModel.profileImage}",
                placeholder: (context, url) => Image.asset(
                  AssetsConstant.placeHolder,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) => Image.asset(
                  AssetsConstant.placeHolder,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// NAME + RATING
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AutoSizeText(
                      widget.salonArtiestListModel.name ?? "",
                      maxLines: 1,
                      minFontSize: 10,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTheme.bold.copyWith(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.red, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        widget.salonArtiestListModel.rating.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            /// VIEW PROFILE (TIGHT)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 6),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => StylistSaloonDetailsPage(
                    isViewDetails: true,
                    salonId: widget.id,
                    artiestId: widget.salonArtiestListModel.id ?? "",
                  ));
                },
                child: Center(
                  child: Text(
                    "View Profile",
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: themeColor,
                      decoration: TextDecoration.underline,
                      decorationColor: themeColor,
                      decorationThickness: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
