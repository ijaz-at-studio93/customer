import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/search/widget/stylist_list_tile_widget.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';

import '../../constant/assetsconstant.dart';
import '../../constant/color_constant.dart';
import '../stylist/stylist_saloon_details_page.dart';

class StylistSearchPage extends StatefulWidget {
  final String salonId;

  const StylistSearchPage({
    super.key,
    required this.salonId,
  });

  @override
  State<StylistSearchPage> createState() => _StylistSearchPageState();
}

class _StylistSearchPageState extends State<StylistSearchPage> {
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetSearchArtiest(salonId: widget.salonId, q: "");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: ColorConstant.blackColor,
          ),
        ),
      ),
      body: Column(
        children: [
          _searchTextField(),
          Obx(
            () => Expanded(
                child: _homeController.showProgress
                    ? const ProgressBarView()
                    : _homeController.getArtistSearchModel.data?.isEmpty ??
                            false
                        ? const NoItemsWidget(text: "Search artist not found")
                        : ListView.separated(
                            separatorBuilder: (context, index) {
                              return Column(
                                children: [
                                  const SizedBox(height: 15),
                                  Container(
                                    height: 1,
                                    width: Get.width,
                                    color: ColorConstant.dividerColor,
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              );
                            },
                            itemCount: _homeController
                                    .getArtistSearchModel.data?.length ??
                                0,
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            itemBuilder: (context, index) {
                              return StylistListTileWidget(
                                image: _homeController.getArtistSearchModel
                                        .data?[index].item?.profileImage ??
                                    "",
                                name: _homeController.getArtistSearchModel
                                        .data?[index].item?.name ??
                                    "",
                                rating: _homeController.getArtistSearchModel
                                        .data?[index].item?.rating ??
                                    0.0,
                                review: _homeController.getArtistSearchModel
                                        .data?[index].item?.reviewCount ??
                                    0,
                                onPress: () {
                                  Get.to(() => StylistSaloonDetailsPage(
                                        isViewDetails: false,
                                        salonId: widget.salonId,
                                        artiestId: _homeController
                                                .getArtistSearchModel
                                                .data?[index]
                                                .item
                                                ?.id ??
                                            "",
                                      ));
                                },
                              );
                            })),
          )
        ],
      ),
    );
  }

  /*-----------------  Search TextField -------------------*/
  _searchTextField() {
    return Container(
      color: ColorConstant.whiteColor,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            height: 48,
            width: Get.width,
            decoration: ShapeDecoration(
              color: ColorConstant.whiteColor,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFFE4E4E4)),
                borderRadius: BorderRadius.circular(12),
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
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      AssetsConstant.search,
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: Get.width * 0.8,
                  child: TextField(
                    textInputAction: TextInputAction.search,
                    onSubmitted: (val) {
                      if (val.isEmpty) {
                        _homeController.doGetSearchArtiest(
                            salonId: widget.salonId, q: "");
                      } else {
                        _homeController.doGetSearchArtiest(
                            salonId: widget.salonId, q: val);
                      }
                    },
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.blackColor, fontSize: 14),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search For stylist",
                        hintStyle: AppTextTheme.medium.copyWith(
                            color: ColorConstant.grayTextColor, fontSize: 13)),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /*-------------- Stylist Found -------------*/
  _stylistFoundWidget() {
    return Container(
      width: Get.width,
      color: ColorConstant.whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "${_homeController.getArtistSearchModel.data?.length} Stylist Found",
              style: AppTextTheme.bold
                  .copyWith(fontSize: 16, color: ColorConstant.blackColor),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Dash(
                direction: Axis.horizontal,
                length: Get.width * 0.9,
                dashLength: 3,
                dashColor: ColorConstant.grayColor),
          ),
        ],
      ),
    );
  }
}
