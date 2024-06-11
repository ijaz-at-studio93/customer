import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/controller/home_controller.dart';
import 'package:sallon_customer/page/home/saloon_after_selecting_page.dart';
import 'package:sallon_customer/page/search/widget/location_title_widget.dart';
import 'package:sallon_customer/project_specific/progressbar_view.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/NoItemsWidget.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

class AreaOfCitySearchPage extends StatefulWidget {
  const AreaOfCitySearchPage({super.key});

  @override
  State<AreaOfCitySearchPage> createState() => _AreaOfCitySearchPageState();
}

class _AreaOfCitySearchPageState extends State<AreaOfCitySearchPage> {
  /*------------- Controller -------------*/
  final _searchTextEditingController = TextEditingController();
  final _homeController = Get.find<HomeController>();

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
                            text: "Search Your Favourite Salon.",
                          )
                        : _homeController.getSearchSalonModel.data?.isEmpty ??
                                false
                            ? const NoItemsWidget(
                                text: "No Search Result Found.",
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
                                  return LocationTileWidget(
                                    salonListData: _homeController
                                        .getSearchSalonModel.data![index],
                                    onPress: () {
                                      Get.to(() =>
                                          SaloonAfterSelectingServicesPage(
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
            height: 55,
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
                    controller: _searchTextEditingController,
                    textInputAction: TextInputAction.search,
                    onEditingComplete: () {
                      if (_searchTextEditingController.text.isNotEmpty) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        _homeController.doSalonSearch(
                            query: _searchTextEditingController.text,
                            lat: SharedPrefs.readStringValue(
                                PrefConstants.latitude),
                            lng: SharedPrefs.readStringValue(
                                PrefConstants.longitude));
                      } else {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {});
                        _homeController.getSearchSalonModel.data = null;
                        _homeController.update();
                      }
                    },
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.blackColor, fontSize: 14),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search For saloon ..........",
                        hintStyle: AppTextTheme.medium.copyWith(
                            color: ColorConstant.grayTextColor, fontSize: 13)),
                  ),
                )
              ],
            ),
          ),
          /*_yourCurrentLocationRow(onTap: () {}),*/
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /*----------------------- Your Current Location ----------------*/
  _yourCurrentLocationRow({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: ColorConstant.whiteColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetsConstant.location,
              height: 17,
              width: 17,
            ),
            Text(
              "YOUR CURRENT LOCATION",
              style: AppTextTheme.bold.copyWith(
                  color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)) ??
                      ColorConstant.primaryColor,
                  fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
