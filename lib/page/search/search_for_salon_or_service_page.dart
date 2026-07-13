import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/home/saloon_after_selecting_page.dart';
import 'package:salon_customer/page/search/widget/location_title_widget.dart';
import 'package:salon_customer/page/search/widget/service_list_tile.dart';
import 'package:salon_customer/page/search/widget/stylist_list_tile_widget.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

import '../stylist/stylist_saloon_details_page.dart';

class SearchForSalonService extends StatefulWidget {
  const SearchForSalonService({super.key});

  @override
  State<SearchForSalonService> createState() => _SearchForSalonServiceState();
}

class _SearchForSalonServiceState extends State<SearchForSalonService> {
  /*------------- Controller -------------*/
  final _searchTextEditingController = TextEditingController();
  final _homeController = Get.find<HomeController>();
  Timer? _debounce;

  // Row 24: search mode from the dropdown — backend values "salon" or "area".
  String _searchMode = "salon";

  @override
  void initState() {
    super.initState();
    _homeController.getSearchSalonModel.data = null;
    _homeController.update();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _markSalonVisited() async {
    await SharedPrefs.writeBoolValue(PrefConstants.hasVisitedSalon, true);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _homeController.doSalonSearch(
          query: _searchTextEditingController.text,
          lat: SharedPrefs.readStringValue(PrefConstants.latitude),
          lng: SharedPrefs.readStringValue(PrefConstants.longitude),
          searchBy: _searchMode);
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
          const SizedBox(height: 2),
          Obx(
                () => Expanded(
                child: _homeController.showProgress
                    ? const ProgressBarView()
                    : _homeController.getSearchSalonModel.data == null
                    ? const NoItemsWidget(
                  text: "Search for Salon",
                )
                    : _homeController.getSearchSalonModel.data?.isEmpty ??
                    false
                    ? const NoItemsWidget(
                  text: "No Salon found.",
                )
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
                        .getSearchSalonModel.data?.length ??
                        0,
                    shrinkWrap: true,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 5),
                    itemBuilder: (context, index) {
                      return _homeController.getSearchSalonModel
                          .data?[index].isService ??
                          false
                          ? ServiceListTile(
                        onPress: () async {
                          // Mark that user has visited a salon
                          await _markSalonVisited();
                          
                          Get.to(() =>
                              SaloonAfterSelectingServicesPage(
                                  isPayNowMode: true,
                                  id: _homeController
                                      .getSearchSalonModel
                                      .data?[index]
                                      .service
                                      ?.salon
                                      ?.id ??
                                      "",
                                  callback: () {}));
                        },
                        salonName: _homeController
                            .getSearchSalonModel
                            .data?[index]
                            .service
                            ?.salon
                            ?.name ??
                            "",
                        description: _homeController
                            .getSearchSalonModel
                            .data?[index]
                            .service
                            ?.description ??
                            "",
                        image: _homeController
                            .getSearchSalonModel
                            .data?[index]
                            .service
                            ?.image ??
                            "",
                        price: _homeController
                            .getSearchSalonModel
                            .data?[index]
                            .service
                            ?.price
                            .toString() ??
                            "",
                        name: _homeController
                            .getSearchSalonModel
                            .data?[index]
                            .service
                            ?.name ??
                            "",
                        duration: _homeController
                            .getSearchSalonModel
                            .data?[index]
                            .service
                            ?.duration
                            .toString() ??
                            "",
                        rating: _homeController
                            .getSearchSalonModel
                            .data?[index]
                            .salon
                            ?.rating
                            .toString() ??
                            "",
                      )
                          : _homeController.getSearchSalonModel
                          .data?[index].isArtist ??
                          false
                          ? StylistListTileWidget(
                        salonName: _homeController
                            .getSearchSalonModel
                            .data?[index]
                            .artist
                            ?.salon
                            ?.name ??
                            "",
                        image: _homeController
                            .getSearchSalonModel
                            .data?[index]
                            .artist
                            ?.profileImage ??
                            "",
                        name: _homeController
                            .getSearchSalonModel
                            .data?[index]
                            .artist
                            ?.name ??
                            "",
                        rating: _homeController
                            .getSearchSalonModel
                            .data?[index]
                            .artist
                            ?.rating ??
                            0.0,
                        review: _homeController
                            .getSearchSalonModel
                            .data?[index]
                            .artist
                            ?.reviewCount ??
                            0,
                        onPress: () {
                          Get.to(() =>
                              StylistSaloonDetailsPage(
                                isViewDetails: false,
                                salonId: _homeController
                                    .getSearchSalonModel
                                    .data?[index]
                                    .artist
                                    ?.salon
                                    ?.id ??
                                    "",
                                artiestId: _homeController
                                    .getSearchSalonModel
                                    .data?[index]
                                    .artist
                                    ?.id ??
                                    "",
                              ));
                        },
                      )
                          : LocationTileWidget(
                        salonListData: _homeController
                            .getSearchSalonModel
                            .data![index],
                        onPress: () async {
                          // Mark that user has visited a salon
                          await _markSalonVisited();
                          
                          Get.to(() =>
                              SaloonAfterSelectingServicesPage(
                                  isPayNowMode: true,
                                  id: _homeController
                                      .getSearchSalonModel
                                      .data?[index]
                                      .salon
                                      ?.id ??
                                      "",
                                  callback: () {}));
                        },
                      );
                    })),
          ),
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
            margin: const EdgeInsets.fromLTRB(15, 12, 15, 10),
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
                      color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: Get.width * 0.8,
                  child: TextField(
                    controller: _searchTextEditingController,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      if (value.trim().isEmpty) {
                        _searchTextEditingController.text =
                            value.trim(); // Remove leading spaces
                        _searchTextEditingController.selection =
                            TextSelection.fromPosition(
                              TextPosition(
                                  offset: _searchTextEditingController.text.length),
                            );
                        setState(() {});
                        _homeController.getSearchSalonModel.data = null;
                        _homeController.update();
                      } else {
                        _onSearchChanged();
                      }
                    },
                    onEditingComplete: () {
                      if (_searchTextEditingController.text.isEmpty) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {});
                        _homeController.getSearchSalonModel.data = null;
                        _homeController.update();
                      } else {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                    },
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.blackColor, fontSize: 14),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _searchMode == "area"
                            ? "Search by area"
                            : "Search for Salon",
                        hintStyle: AppTextTheme.medium.copyWith(
                            color: ColorConstant.grayTextColor, fontSize: 13)),
                  ),
                )
              ],
            ),
          ),
          /// Row 24: choose search mode — by Salon (name) or by Area.
          /// Style matches bookings home page CupertinoSlidingSegmentedControl.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              width: Get.width,
              child: CupertinoSlidingSegmentedControl<String>(
                backgroundColor: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)) ??
                    Colors.transparent,
                padding: const EdgeInsets.all(6),
                groupValue: _searchMode,
                thumbColor: ColorConstant.whiteColor,
                children: {
                  "salon": SizedBox(
                    width: Get.width,
                    height: Get.height * 0.05,
                    child: Center(
                      child: Text(
                        "Salon",
                        style: _searchMode == "salon"
                            ? AppTextTheme.bold.copyWith(
                                fontSize: 14,
                                color: ColorConstant.blackColor,
                              )
                            : AppTextTheme.medium.copyWith(
                                fontSize: 13,
                                color: ColorConstant.whiteColor,
                              ),
                      ),
                    ),
                  ),
                  "area": Text(
                    "Area",
                    textAlign: TextAlign.center,
                    style: _searchMode == "area"
                        ? AppTextTheme.bold.copyWith(
                            fontSize: 13,
                            color: ColorConstant.blackColor,
                          )
                        : AppTextTheme.medium.copyWith(
                            fontSize: 12,
                            color: ColorConstant.whiteColor,
                          ),
                  ),
                },
                onValueChanged: (value) {
                  if (value == null || value == _searchMode) return;
                  setState(() => _searchMode = value);
                  if (_searchTextEditingController.text.trim().isNotEmpty) {
                    _homeController.doSalonSearch(
                      query: _searchTextEditingController.text,
                      lat: SharedPrefs.readStringValue(PrefConstants.latitude),
                      lng: SharedPrefs.readStringValue(PrefConstants.longitude),
                      searchBy: _searchMode,
                    );
                  }
                },
              ),
            ),
          ),
          /*_yourCurrentLocationRow(onTap: () {}),*/
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}