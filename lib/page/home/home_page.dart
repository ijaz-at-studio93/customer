import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/home/saloon_after_selecting_page.dart';
import 'package:salon_customer/page/home/widget/menu_dialog_widget.dart';
import 'package:salon_customer/page/home/widget/saloon_card_widget.dart';
import 'package:salon_customer/page/location/google_map.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/status_bar_color_appbar.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

import '../../constant/variable_constant.dart';
import '../../util/logger.dart';
import '../profile/profile_page.dart';
import '../search/area_of_city_search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /*-------------------  Controller ----------------------*/

  final _authController = Get.find<AuthController>();
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    getCurrentLatLng();
    if (SharedPrefs.readBoolValue(PrefConstants.isHomeService)) {
      atHome = true;
    } else {
      atHome = false;
    }
    if (SharedPrefs.readStringValue(PrefConstants.gender).isEmpty) {
      selectedGender.value = 0;
    } else {
      if (SharedPrefs.readStringValue(PrefConstants.gender) == "0") {
        selectedGender.value = 0;
      } else {
        selectedGender.value = 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: statusBarTheme(context),
      backgroundColor: ColorConstant.bgColor,
      body: Obx(
        () => _homeController.showProgress
            ? const ProgressBarView()
            : ListView(
                shrinkWrap: true,
                children: [
                  _headerWidget(),
                  const SizedBox(height: 10),
                  _searchWidget(),
                  const SizedBox(height: 10),
                  _ourService(),
                  const SizedBox(height: 15),
                  _offer(),
                  _homeController.getPromoCodeModel.data?.isEmpty ?? false
                      ? const SizedBox()
                      : const SizedBox(height: 15),
                  _saloonsFoundNear(),
                  _homeController.getHomeSalonList.data?.rows?.isEmpty ?? false
                      ? const NoItemsWidget(
                          text: "No salons were found.",
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _homeController
                                  .getHomeSalonList.data?.rows?.length ??
                              0,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return SaloonCardWidget(
                              homeSalonModel: _homeController
                                  .getHomeSalonList.data!.rows![index],
                              onPress: () {
                                Get.to(() => SaloonAfterSelectingServicesPage(
                                      id: _homeController.getHomeSalonList.data
                                              ?.rows?[index].id ??
                                          "",
                                      callback: () {
                                        getCurrentLatLng();
                                      },
                                    ));
                              },
                              isFav: false,
                            );
                          })
                ],
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: Get.width * 0.58,
        height: 50,
        decoration: BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedGender.value = 0;
                    SharedPrefs.writeValue(
                        PrefConstants.isSelectedGender, true);
                    SharedPrefs.writeValue(PrefConstants.gender, "0");
                    _homeController.doGetHomeCategory(
                      gender: "male",
                    );
                  });
                },
                child: Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                    color: selectedGender.value == 0
                        ? ColorConstant.primaryColor
                        : ColorConstant.whiteColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AssetsConstant.man,
                          height: 24,
                          width: 24,
                          color: selectedGender.value == 0
                              ? ColorConstant.whiteColor
                              : ColorConstant.grayTextColor),
                      const SizedBox(width: 8),
                      Text(
                        "Men",
                        style: AppTextTheme.medium.copyWith(
                            color: selectedGender.value == 0
                                ? ColorConstant.whiteColor
                                : ColorConstant.grayTextColor),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedGender.value = 1;
                    SharedPrefs.writeValue(
                        PrefConstants.isSelectedGender, true);
                    SharedPrefs.writeValue(PrefConstants.gender, "1");
                    _homeController.doGetHomeCategory(
                      gender: "female",
                    );
                  });
                },
                child: Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                      color: selectedGender.value == 1
                          ? ColorConstant.primary2
                          : ColorConstant.whiteColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetsConstant.woman,
                        height: 24,
                        width: 24,
                        color: selectedGender.value == 1
                            ? ColorConstant.whiteColor
                            : ColorConstant.grayTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Women",
                        style: AppTextTheme.medium.copyWith(
                            color: selectedGender.value == 1
                                ? ColorConstant.whiteColor
                                : ColorConstant.grayTextColor),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*--------------  Header Widget ----------------*/
  _headerWidget() {
    return Container(
      color: ColorConstant.whiteColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => GoogleMapGetLocation(
                    callback: () {
                      _homeController.doGetHomeSalonList(
                          serviceGender:
                              selectedGender.value == 0 ? "male" : "female",
                          homeService: atHome,
                          offset: 1,
                          size: 50,
                          lat: double.parse(SharedPrefs.readStringValue(
                              PrefConstants.latitude)),
                          lng: double.parse(SharedPrefs.readStringValue(
                              PrefConstants.longitude)),
                          orderBy: "",
                          nearest: false,
                          fourPlusRating: false);
                    },
                  ));
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  AssetsConstant.location,
                  width: 35,
                  height: 35,
                  color: changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender)),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _authController.userCity,
                      style: AppTextTheme.bold.copyWith(
                          color: ColorConstant.blackColor, fontSize: 18),
                    ),
                    const SizedBox(height: 3),
                    _homeController.showProgress
                        ? const SizedBox()
                        : SizedBox(
                            width: Get.width * 0.6,
                            child: Text(
                              _authController.userCurrentLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.grayColor, fontSize: 12),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => ProfilePage(
                    callback: () {
                      getCurrentLatLng();
                    },
                  ));
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender))),
              child: Center(
                child: Text(
                    _authController.userResponseModel.data?.userData?.name
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        "",
                    style: AppTextTheme.bold.copyWith(
                        color: ColorConstant.whiteColor, fontSize: 18)),
              ),
            ),
          )
        ],
      ),
    );
  }

  /*--------------- Search Widget ------------*/
  _searchWidget() {
    return GestureDetector(
      onTap: () {
        Get.to(() => const AreaOfCitySearchPage());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        width: Get.width,
        height: 48,
        decoration: ShapeDecoration(
          color: ColorConstant.whiteColor,
          shape: RoundedRectangleBorder(
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
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Image.asset(
                  AssetsConstant.search,
                  width: 24,
                  height: 24,
                  color: changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender)),
                ),
                const SizedBox(width: 10),
                Text(
                  "Search for Salon, Stylist or Service",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.medium
                      .copyWith(color: ColorConstant.grayColor),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*---------------- Our Service ------------*/
  _ourService() {
    return Container(
      color: ColorConstant.whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Our Services",
                  textScaler: const TextScaler.linear(0.90),
                  style: AppTextTheme.bold
                      .copyWith(fontSize: 17, color: ColorConstant.blackColor),
                ),
                TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return MenuDialogWidget(
                              categoryListData:
                                  _homeController.homeCategoryListResponseModel,
                              callback: () {
                                List<String> storeServiceId = [];
                                setState(() {
                                  for (int i = 0;
                                      i <
                                          _homeController
                                              .homeCategoryListResponseModel
                                              .data!
                                              .length;
                                      i++) {
                                    if (_homeController
                                            .homeCategoryListResponseModel
                                            .data?[i]
                                            .isSelectCategory ??
                                        false) {
                                      storeServiceId.add(_homeController
                                              .homeCategoryListResponseModel
                                              .data?[i]
                                              .id ??
                                          "");
                                    }
                                  }
                                });

                                if (storeServiceId.isNotEmpty) {
                                  _homeController.doAddPackageOneData(
                                      serviceCategoryIds: storeServiceId,
                                      callback: () {
                                        _homeController.doGetMakePackageData();
                                      });
                                }

                                _homeController.doGetHomeSalonList(
                                    serviceGender: selectedGender.value == 0
                                        ? "male"
                                        : "female",
                                    homeService: atHome,
                                    offset: 1,
                                    size: 50,
                                    lat: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.latitude)),
                                    lng: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.longitude)),
                                    orderBy: "",
                                    nearest: false,
                                    fourPlusRating: false);
                              },
                            );
                          });
                    },
                    child: Text(
                      "VIEW ALL",
                      style: AppTextTheme.medium.copyWith(
                          fontSize: 13, color: ColorConstant.grayTextColor),
                    ))
              ],
            ),
          ),
          SizedBox(
            height: 150,
            child: _homeController
                        .getLastMakeYourOwnPackageModel.data?.isEmpty ??
                    false
                ? Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return MenuDialogWidget(
                                  categoryListData: _homeController
                                      .homeCategoryListResponseModel,
                                  callback: () {
                                    List<String> storeServiceId = [];
                                    setState(() {
                                      for (int i = 0;
                                          i <
                                              _homeController
                                                  .homeCategoryListResponseModel
                                                  .data!
                                                  .length;
                                          i++) {
                                        if (_homeController
                                                .homeCategoryListResponseModel
                                                .data?[i]
                                                .isSelectCategory ??
                                            false) {
                                          storeServiceId.add(_homeController
                                                  .homeCategoryListResponseModel
                                                  .data?[i]
                                                  .id ??
                                              "");
                                        }
                                      }
                                    });

                                    if (storeServiceId.isNotEmpty) {
                                      _homeController.doAddPackageOneData(
                                          serviceCategoryIds: storeServiceId,
                                          callback: () {
                                            _homeController
                                                .doGetMakePackageData();
                                          });
                                    }
                                    _homeController.doGetHomeSalonList(
                                        serviceGender: selectedGender.value == 0
                                            ? "male"
                                            : "female",
                                        homeService: atHome,
                                        offset: 1,
                                        size: 50,
                                        lat: double.parse(
                                            SharedPrefs.readStringValue(
                                                PrefConstants.latitude)),
                                        lng: double.parse(
                                            SharedPrefs.readStringValue(
                                                PrefConstants.longitude)),
                                        orderBy: "",
                                        nearest: false,
                                        fourPlusRating: false);
                                  },
                                );
                              });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            children: [
                              Container(
                                  width: 70,
                                  height: 70,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    gradient: RadialGradient(
                                      center: const Alignment(0.57, 0.07),
                                      radius: 0.90,
                                      colors: selectedGender.value == 1
                                          ? [
                                              const Color(0xFFFFCAF9),
                                              Colors.white
                                            ]
                                          : [
                                              const Color(0xFFE1D5FF),
                                              Colors.white
                                            ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(64),
                                    ),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      AssetsConstant.makePackageImage,
                                      width: 40,
                                      height: 40,
                                      color: changeTheme(
                                          SharedPrefs.readStringValue(
                                              PrefConstants.gender)),
                                    ),
                                  )),
                              const SizedBox(height: 10),
                              Text(
                                "Make Your \n Package",
                                style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.blackColor,
                                    fontSize: 13),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: _homeController
                                    .homeCategoryListResponseModel
                                    .data
                                    ?.length ??
                                0,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  List<String> storeServiceId = [];
                                  var id = _homeController
                                      .homeCategoryListResponseModel
                                      .data?[index]
                                      .id;

                                  storeServiceId.add(id ?? "");

                                  _homeController.doAddPackageOneData(
                                      serviceCategoryIds: storeServiceId,
                                      callback: () {
                                        _homeController.doGetMakePackageData();
                                      });

                                  _homeController.doGetHomeSalonList(
                                      serviceGender: selectedGender.value == 0
                                          ? "male"
                                          : "female",
                                      homeService: atHome,
                                      offset: 1,
                                      size: 50,
                                      lat: double.parse(
                                          SharedPrefs.readStringValue(
                                              PrefConstants.latitude)),
                                      lng: double.parse(
                                          SharedPrefs.readStringValue(
                                              PrefConstants.longitude)),
                                      orderBy: "",
                                      nearest: false,
                                      fourPlusRating: false);
                                },
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: CachedNetworkImage(
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.cover,
                                        imageUrl: SharedPrefs.readStringValue(
                                                    PrefConstants.gender) ==
                                                "0"
                                            ? "${APIConstants.image}${_homeController.homeCategoryListResponseModel.data?[index].imageMale}"
                                            : "${APIConstants.image}${_homeController.homeCategoryListResponseModel.data?[index].imageFemale}",
                                        placeholder: (context, url) =>
                                            const Image(
                                          image: AssetImage(
                                              AssetsConstant.placeHolder),
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.cover,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Image(
                                          image: AssetImage(
                                              AssetsConstant.placeHolder),
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: Get.width * 0.25,
                                      child: Text(
                                        _homeController
                                                .homeCategoryListResponseModel
                                                .data?[index]
                                                .name ??
                                            "",
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: AppTextTheme.medium.copyWith(
                                            fontSize: 13,
                                            color: ColorConstant.blackColor),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: _homeController
                                    .getLastMakeYourOwnPackageModel
                                    .data
                                    ?.length ??
                                0,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  var id = _homeController
                                      .getLastMakeYourOwnPackageModel
                                      .data?[index]
                                      .id;

                                  for (int i = 0;
                                      i <
                                          _homeController
                                              .homeCategoryListResponseModel
                                              .data!
                                              .length;
                                      i++) {
                                    if (id ==
                                        _homeController
                                            .homeCategoryListResponseModel
                                            .data?[i]
                                            .id) {
                                      _homeController
                                          .homeCategoryListResponseModel
                                          .data?[i]
                                          .isSelectCategory = false;
                                    }
                                  }

                                  List<String> storeServiceId = [];
                                  storeServiceId.add(_homeController
                                          .getLastMakeYourOwnPackageModel
                                          .data?[index]
                                          .id ??
                                      "");
                                  _homeController.doRemovePackageData(
                                      serviceCategoryIds: storeServiceId,
                                      callback: () {
                                        _homeController.doGetMakePackageData();
                                      });
                                  _homeController.doGetHomeSalonList(
                                      serviceGender: selectedGender.value == 0
                                          ? "male"
                                          : "female",
                                      homeService: atHome,
                                      offset: 1,
                                      size: 50,
                                      lat: double.parse(
                                          SharedPrefs.readStringValue(
                                              PrefConstants.latitude)),
                                      lng: double.parse(
                                          SharedPrefs.readStringValue(
                                              PrefConstants.longitude)),
                                      orderBy: "",
                                      nearest: false,
                                      fourPlusRating: false);
                                },
                                child: Column(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: CachedNetworkImage(
                                            height: 70,
                                            width: 70,
                                            fit: BoxFit.cover,
                                            imageUrl: SharedPrefs
                                                        .readStringValue(
                                                            PrefConstants
                                                                .gender) ==
                                                    "0"
                                                ? "${APIConstants.image}${_homeController.getLastMakeYourOwnPackageModel.data?[index].imageMale}"
                                                : "${APIConstants.image}${_homeController.getLastMakeYourOwnPackageModel.data?[index].imageFemale}",
                                            placeholder: (context, url) =>
                                                const Image(
                                              image: AssetImage(
                                                  AssetsConstant.placeHolder),
                                              height: 70,
                                              width: 70,
                                              fit: BoxFit.cover,
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Image(
                                              image: AssetImage(
                                                  AssetsConstant.placeHolder),
                                              height: 70,
                                              width: 70,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: -5,
                                          top: -1,
                                          child: Container(
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                                color: changeTheme(
                                                    SharedPrefs.readStringValue(
                                                        PrefConstants.gender)),
                                                shape: BoxShape.circle),
                                            child: Center(
                                              child: Image.asset(
                                                AssetsConstant.xMark,
                                                color: ColorConstant.whiteColor,
                                                width: 10,
                                                height: 10,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: Get.width * 0.25,
                                      child: Text(
                                        _homeController
                                                .getLastMakeYourOwnPackageModel
                                                .data?[index]
                                                .name ??
                                            "",
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: AppTextTheme.medium.copyWith(
                                            fontSize: 13,
                                            color: ColorConstant.blackColor),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                      if (_homeController
                              .getLastMakeYourOwnPackageModel.data?.last !=
                          null)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return MenuDialogWidget(
                                      categoryListData: _homeController
                                          .homeCategoryListResponseModel,
                                      callback: () {
                                        List<String> storeServiceId = [];
                                        setState(() {
                                          for (int i = 0;
                                              i <
                                                  _homeController
                                                      .homeCategoryListResponseModel
                                                      .data!
                                                      .length;
                                              i++) {
                                            if (_homeController
                                                    .homeCategoryListResponseModel
                                                    .data?[i]
                                                    .isSelectCategory ??
                                                false) {
                                              storeServiceId.add(_homeController
                                                      .homeCategoryListResponseModel
                                                      .data?[i]
                                                      .id ??
                                                  "");
                                            }
                                          }
                                        });

                                        if (storeServiceId.isNotEmpty) {
                                          _homeController.doAddPackageOneData(
                                              serviceCategoryIds:
                                                  storeServiceId,
                                              callback: () {
                                                _homeController
                                                    .doGetMakePackageData();
                                              });
                                        }
                                        _homeController.doGetHomeSalonList(
                                            serviceGender:
                                                selectedGender.value == 0
                                                    ? "male"
                                                    : "female",
                                            homeService: atHome,
                                            offset: 1,
                                            size: 50,
                                            lat: double.parse(
                                                SharedPrefs.readStringValue(
                                                    PrefConstants.latitude)),
                                            lng: double.parse(
                                                SharedPrefs.readStringValue(
                                                    PrefConstants.longitude)),
                                            orderBy: "",
                                            nearest: false,
                                            fourPlusRating: false);
                                      },
                                    );
                                  });
                            },
                            child: Container(
                                height: 70,
                                width: 70,
                                clipBehavior: Clip.none,
                                decoration: ShapeDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(0.57, 0.07),
                                    radius: 0.90,
                                    colors: selectedGender.value == 1
                                        ? [
                                            const Color(0xFFFFCAF9),
                                            Colors.white
                                          ]
                                        : [
                                            const Color(0xFFE1D5FF),
                                            Colors.white
                                          ],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(64),
                                  ),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    AssetsConstant.addPackageImage,
                                    width: 30,
                                    height: 30,
                                    color: changeTheme(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.gender)),
                                  ),
                                )),
                          ),
                        ),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  /*-------------------- Offer -------------------*/
  _offer() {
    return _homeController.getPromoCodeModel.data?.isEmpty ??
            false || _homeController.getPromoCodeModel.data == null
        ? const SizedBox()
        : SizedBox(
            height: 100,
            width: Get.width,
            child: PageView.builder(
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                itemCount: _homeController.getPromoCodeModel.data?.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => SaloonAfterSelectingServicesPage(
                            id: _homeController
                                    .getPromoCodeModel.data?[index].salon?.id ??
                                "",
                            callback: () {
                              getCurrentLatLng();
                            },
                          ));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: ColorConstant.whiteColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          right: BorderSide(
                              width: 9,
                              color: changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  Colors.transparent),
                        ),
                        boxShadow: const [
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
                          CachedNetworkImage(
                            height: 78,
                            width: 78,
                            fit: BoxFit.cover,
                            imageUrl:
                                "${APIConstants.image}${_homeController.getPromoCodeModel.data?[index].image}",
                            placeholder: (context, url) => const Image(
                              image: AssetImage(AssetsConstant.offer),
                              height: 78,
                              width: 78,
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) => const Image(
                              image: AssetImage(AssetsConstant.offer),
                              height: 78,
                              width: 78,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Dash(
                              direction: Axis.vertical,
                              length: 100,
                              dashLength: 3,
                              dashColor: ColorConstant.grayColor),
                          const SizedBox(width: 17),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _homeController
                                        .getPromoCodeModel.data?[index].title ??
                                    "",
                                style: AppTextTheme.bold.copyWith(
                                    color: ColorConstant.blackColor,
                                    fontSize: 20),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _homeController.getPromoCodeModel.data?[index]
                                        .description ??
                                    "",
                                style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.grayColor,
                                    fontSize: 13),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }),
          );
  }

  /*------------ Saloons Found Near ----------- */
  bool atHome = false;
  int select = 0;

  _saloonsFoundNear() {
    return Container(
      color: ColorConstant.whiteColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_homeController.getHomeSalonList.data?.rows?.length ?? 0} Salons Found Near You",
                  textScaler: const TextScaler.linear(0.90),
                  style: AppTextTheme.bold
                      .copyWith(fontSize: 17, color: ColorConstant.blackColor),
                ),
                const SizedBox(width: 5),
                Container(
                  height: 50,
                  color: ColorConstant.whiteColor,
                  child: Row(
                    children: [
                      Text(
                        "Home Service",
                        style: AppTextTheme.bold.copyWith(
                            color: changeTheme(SharedPrefs.readStringValue(
                                PrefConstants.gender)),
                            fontSize: 13),
                      ),
                      SizedBox(
                        height: 30,
                        child: CupertinoSwitch(
                          value: atHome,
                          activeColor: changeTheme(SharedPrefs.readStringValue(
                              PrefConstants.gender)),
                          onChanged: (bool value) {
                            setState(() {
                              atHome = value;
                              if (atHome) {
                                SharedPrefs.writeValue(
                                    PrefConstants.isHomeService, true);
                              } else {
                                SharedPrefs.writeValue(
                                    PrefConstants.isHomeService, false);
                              }
                              _homeController.doGetHomeSalonList(
                                  serviceGender: selectedGender.value == 0
                                      ? "male"
                                      : "female",
                                  homeService: atHome,
                                  offset: 1,
                                  size: 50,
                                  lat: double.parse(SharedPrefs.readStringValue(
                                      PrefConstants.latitude)),
                                  lng: double.parse(SharedPrefs.readStringValue(
                                      PrefConstants.longitude)),
                                  orderBy: "",
                                  nearest: false,
                                  fourPlusRating: false);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: Get.width * 0.3,
                      height: 40,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: ColorConstant.grayBorderColor, width: 1)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            AssetsConstant.filter,
                            height: 14,
                            width: 14,
                          ),
                          DropdownButton(
                            value: dropdownvalue,
                            underline: const SizedBox(),
                            icon: const SizedBox(),
                            items: items.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items,
                                    style: AppTextTheme.medium.copyWith(
                                        color: ColorConstant.blackColor,
                                        fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownvalue = newValue ?? "";

                                _homeController.doGetHomeSalonList(
                                    serviceGender: selectedGender.value == 0
                                        ? "male"
                                        : "female",
                                    homeService: atHome,
                                    offset: 1,
                                    size: 50,
                                    lat: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.latitude)),
                                    lng: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.longitude)),
                                    orderBy: dropdownvalue == "Sort By"
                                        ? ""
                                        : dropdownvalue == "Newest"
                                            ? "createdAt"
                                            : "name",
                                    nearest: false,
                                    fourPlusRating: false);
                              });
                            },
                          ),
                          Image.asset(
                            AssetsConstant.arrowDown,
                            height: 10,
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (select == 0 || select == 2) {
                                select = 1;
                                _homeController.doGetHomeSalonList(
                                    serviceGender: selectedGender.value == 0
                                        ? "male"
                                        : "female",
                                    homeService: atHome,
                                    offset: 1,
                                    size: 50,
                                    lat: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.latitude)),
                                    lng: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.longitude)),
                                    orderBy: dropdownvalue == "Sort By"
                                        ? ""
                                        : dropdownvalue == "Newest"
                                            ? "createdAt"
                                            : "name",
                                    nearest: true,
                                    fourPlusRating: false);
                              } else {
                                select = 0;
                                _homeController.doGetHomeSalonList(
                                    serviceGender: selectedGender.value == 0
                                        ? "male"
                                        : "female",
                                    homeService: atHome,
                                    offset: 1,
                                    size: 50,
                                    lat: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.latitude)),
                                    lng: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.longitude)),
                                    orderBy: dropdownvalue == "Sort By"
                                        ? ""
                                        : dropdownvalue == "Newest"
                                            ? "createdAt"
                                            : "name",
                                    nearest: false,
                                    fourPlusRating: false);
                              }
                            });
                          },
                          child: Container(
                            width: Get.width * 0.25,
                            height: 40,
                            decoration: BoxDecoration(
                              color: select == 1
                                  ? changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender))
                                  : ColorConstant.whiteColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: ColorConstant.grayBorderColor,
                                  width: 1),
                            ),
                            child: Center(
                              child: Text(
                                "Nearest",
                                style: AppTextTheme.medium.copyWith(
                                    color: select == 1
                                        ? ColorConstant.whiteColor
                                        : ColorConstant.blackColor,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (select == 0 || select == 1) {
                                select = 2;
                                _homeController.doGetHomeSalonList(
                                    serviceGender: selectedGender.value == 0
                                        ? "male"
                                        : "female",
                                    homeService: atHome,
                                    offset: 1,
                                    size: 50,
                                    lat: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.latitude)),
                                    lng: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.longitude)),
                                    orderBy: dropdownvalue == "Sort By"
                                        ? ""
                                        : dropdownvalue == "Newest"
                                            ? "createdAt"
                                            : "name",
                                    nearest: false,
                                    fourPlusRating: true);
                              } else {
                                select = 0;
                                _homeController.doGetHomeSalonList(
                                    serviceGender: selectedGender.value == 0
                                        ? "male"
                                        : "female",
                                    homeService: atHome,
                                    offset: 1,
                                    size: 50,
                                    lat: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.latitude)),
                                    lng: double.parse(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.longitude)),
                                    orderBy: dropdownvalue == "Sort By"
                                        ? ""
                                        : dropdownvalue == "Newest"
                                            ? "createdAt"
                                            : "name",
                                    nearest: false,
                                    fourPlusRating: false);
                              }
                            });
                          },
                          child: Container(
                            width: Get.width * 0.25,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: select == 2
                                  ? changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender))
                                  : ColorConstant.whiteColor,
                              border: Border.all(
                                  color: ColorConstant.grayBorderColor,
                                  width: 1),
                            ),
                            child: Center(
                              child: Text(
                                "Rating 4.0+",
                                style: AppTextTheme.medium.copyWith(
                                    color: select == 2
                                        ? ColorConstant.whiteColor
                                        : ColorConstant.blackColor,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ), /*const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() {
                              select = 3;
                            });
                          },
                          child: Container(
                            width: Get.width * 0.25,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: select == 3
                                  ? changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender))
                                  : ColorConstant.whiteColor,
                              border: Border.all(
                                  color: ColorConstant.grayBorderColor,
                                  width: 1),
                            ),
                            child: Center(
                              child: Text(
                                "Great Offers",
                                style: AppTextTheme.medium.copyWith(
                                    color: select == 3
                                        ? ColorConstant.whiteColor
                                        : ColorConstant.blackColor,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ),*/
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  /*------------------ DropDown  ------------*/
  String dropdownvalue = 'Sort By';
  var items = ['Sort By', 'Newest', 'Name'];

  /*--------------------- Current location lat lng --------------------- */
  getCurrentLatLng() async {
    await Permission.location.onDeniedCallback(() async {
      await Permission.location.request();
      showMessage("Location services are disabled.");
    }).onGrantedCallback(() async {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      SharedPrefs.writeValue(
          PrefConstants.longitude, position.longitude.toString());
      SharedPrefs.writeValue(
          PrefConstants.latitude, position.latitude.toString());

      Placemark place = placeMarks[0];
      _authController.userCity = "${place.locality}";
      _authController.userCurrentLocation =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _homeController.doGetHomeCategory(
          gender: selectedGender.value == 0 ? "male" : "female",
        );
        _homeController.doGetPromoCode(
            lat: position.latitude, lng: position.longitude);
        _homeController.doGetHomeSalonList(
            serviceGender: selectedGender.value == 0 ? "male" : "female",
            homeService: atHome,
            offset: 1,
            size: 50,
            lat: position.latitude,
            lng: position.longitude,
            orderBy: "",
            nearest: false,
            fourPlusRating: false);
      });
    }).onPermanentlyDeniedCallback(() async {
      openAppSettings();
      OpenSettings.openLocationSourceSetting();
      showMessage(
          "Location permissions are permanently denied, we cannot request permissions.");
    }).onRestrictedCallback(() async {
      logger.e("Setting call Back");
    }).onLimitedCallback(() {
      showMessage("Notification Permission Request Limited");
    }).onProvisionalCallback(() {
      logger.e("Final Call Back");
    }).request();

    if (await Permission.location.isGranted) {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      SharedPrefs.writeValue(
          PrefConstants.longitude, position.longitude.toString());
      SharedPrefs.writeValue(
          PrefConstants.latitude, position.latitude.toString());

      Placemark place = placeMarks[0];
      _authController.userCity = "${place.locality}";
      _authController.userCurrentLocation =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";

      _homeController.doGetMakePackageData();

      _homeController.doGetPromoCode(
          lat: position.latitude, lng: position.longitude);
      _homeController.doGetHomeSalonList(
          serviceGender: selectedGender.value == 0 ? "male" : "female",
          homeService: atHome,
          offset: 1,
          size: 50,
          lat: position.latitude,
          lng: position.longitude,
          orderBy: "",
          nearest: false,
          fourPlusRating: false);
    }
  }
}
