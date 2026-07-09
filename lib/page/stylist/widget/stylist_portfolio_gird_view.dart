import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/model/artiest_portfolio_model.dart';
import 'package:salon_customer/page/stylist/widget/video_view_model_sheet.dart';
import 'package:salon_customer/page/stylist/widget/video_zoom_viewer.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';

class StylistPortfolioGridview extends StatefulWidget {
  final ArtiestPortfolio artiestPortfolio;
  const StylistPortfolioGridview({super.key, required this.artiestPortfolio});

  @override
  State<StylistPortfolioGridview> createState() =>
      _StylistPortfolioGridviewState();
}

class _StylistPortfolioGridviewState extends State<StylistPortfolioGridview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstant.whiteColor,
      child: widget.artiestPortfolio.data?.portfolio?.isEmpty ?? false
          ? const NoItemsWidget(
              text: "No portfolio is available.",
            )
          : Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount:
                      widget.artiestPortfolio.data?.portfolio?.length ?? 0,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.0),
                  itemBuilder: (context, index) {
                    final item =
                        widget.artiestPortfolio.data?.portfolio?[index];
                    return GestureDetector(
                    // onTap: () {
                    //   if (widget.artiestPortfolio.data?.portfolio?[index]
                    //           .isVideo ??
                    //       false) {
                    //     showModalBottomSheet(
                    //         isScrollControlled: true,
                    //         isDismissible: false,
                    //         enableDrag: false,
                    //         shape: const RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.only(
                    //             topLeft: Radius.circular(32),
                    //             topRight: Radius.circular(32),
                    //           ),
                    //         ),
                    //         context: context,
                    //         builder: (context) {
                    //           return VideoViewModelSheet(
                    //               videoString:
                    //                   "${APIConstants.image}${widget.artiestPortfolio.data?.portfolio?[index].video}");
                    //         });
                    //   }
                    // },
                    onTap: () {
                      if (widget.artiestPortfolio.data?.portfolio?[index].isVideo ?? false) {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierColor: Colors.black.withOpacity(0.6),
                          builder: (_) => Center(
                            child: Container(
                              width: Get.width * 3,
                              height: Get.height * 0.6,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: VideoPopupViewer(
                                  videoUrl:
                                  "${APIConstants.image}${widget.artiestPortfolio.data?.portfolio?[index].video}",
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: (item?.isVideo ?? false)
                          // Row 7: video tile styled identically to the Content
                          // grid — thumbnail image + dark scrim + play icon.
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      "${APIConstants.image}${item?.image}",
                                  placeholder: (context, url) => Image.asset(
                                    AssetsConstant.placeHolder,
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    AssetsConstant.placeHolder,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  color: Colors.black.withOpacity(0.3),
                                ),
                                const Center(
                                  child: Icon(
                                    Icons.play_circle_filled,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ],
                            )
                          : CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: "${APIConstants.image}${item?.image}",
                              placeholder: (context, url) => Image.asset(
                                AssetsConstant.placeHolder,
                                fit: BoxFit.cover,
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                AssetsConstant.placeHolder,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  );
                  },
                ),
                SizedBox(height: Get.height * 0.20),
              ],
            ),
    );
  }
}
