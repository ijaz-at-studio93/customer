import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sallon_customer/api/dio_client.dart';
import 'package:sallon_customer/constant/api_constant.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/controller/auth_controller.dart';
import 'package:sallon_customer/controller/home_controller.dart';
import 'package:sallon_customer/page/home/saloon_after_selecting_page.dart';
import 'package:sallon_customer/page/home/widget/menu_dialog_widget.dart';
import 'package:sallon_customer/page/home/widget/saloon_card_widget.dart';
import 'package:sallon_customer/page/location/google_map.dart';
import 'package:sallon_customer/project_specific/ProgressContainerView.dart';
import 'package:sallon_customer/project_specific/progressbar_view.dart';
import 'package:sallon_customer/project_specific/status_bar_color_appbar.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';
import '../../constant/variable_constant.dart';
import '../profile/profile_page.dart';
import '../search/area_of_city_search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /*-------------------  Controller ----------------------*/
  int _selectedGender = 0;
  final _authController = Get.find<AuthController>();
  final _homeController = Get.find<HomeController>();

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getCurrentLatLng();
    scrollController.addListener(() {
      if (_homeController.lat != 0.0 && _homeController.lng != 0.0) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          _homeController.fetchPosts();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: statusBarTheme(context),
      backgroundColor: ColorConstant.bgColor,
      body: Obx(
        () => ProgressContainerView(
          isProgressRunning: _homeController.showProgress,
          child: ListView(
            controller: scrollController,
            shrinkWrap: true,
            children: [
              _headerWidget(),
              const SizedBox(height: 10),
              _searchWidget(),
              const SizedBox(height: 10),
              _ourService(),
              const SizedBox(height: 15),
              _offer(),
              const SizedBox(height: 10),
              _saloonsFoundNear(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _homeController.salonList.length +
                    (_homeController.isLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _homeController.salonList.length) {
                    return const ProgressBarView();
                  }
                  return SaloonCardWidget(
                    homeSalonModel: _homeController.salonList[index],
                    onPress: () {
                      Get.to(
                        () => SaloonAfterSelectingServicesPage(
                          salonId: _homeController.salonList[index].id ?? "",
                        ),
                      );
                    },
                  );
                },
              )
              /*ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _homeController.homeSalonList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return SaloonCardWidget(
                      homeSalonModel: _homeController.homeSalonList[index],
                      onPress: () {
                        Get.to(() => SaloonAfterSelectingServicesPage(
                              salonId:
                                  _homeController.homeSalonList[index].id ?? "",
                            ));
                      },
                    );
                  })*/
            ],
          ),
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
                    _selectedGender = 0;
                    SharedPrefs.writeValue(
                        PrefConstants.isSelectedGender, true);
                    SharedPrefs.writeValue(PrefConstants.gender, "0");
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const MenuDialogWidget();
                        });
                  });
                },
                child: Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                    color: _selectedGender == 0
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
                          color: _selectedGender == 0
                              ? ColorConstant.whiteColor
                              : ColorConstant.grayTextColor),
                      const SizedBox(width: 8),
                      Text(
                        "man",
                        style: AppTextTheme.medium.copyWith(
                            color: _selectedGender == 0
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
                    _selectedGender = 1;
                    SharedPrefs.writeValue(
                        PrefConstants.isSelectedGender, true);
                    SharedPrefs.writeValue(PrefConstants.gender, "1");
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const MenuDialogWidget();
                        });
                  });
                },
                child: Container(
                  height: 50,
                  width: 100,
                  decoration: BoxDecoration(
                      color: _selectedGender == 1
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
                        color: _selectedGender == 1
                            ? ColorConstant.whiteColor
                            : ColorConstant.grayTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Women",
                        style: AppTextTheme.medium.copyWith(
                            color: _selectedGender == 1
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
              Get.to(() => const GoogleMapGetLocation());
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  AssetsConstant.location,
                  width: 40,
                  height: 40,
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
                          color: ColorConstant.blackColor, fontSize: 20),
                    ),
                    const SizedBox(height: 3),
                    _homeController.showProgress
                        ? const SizedBox()
                        : SizedBox(
                            width: Get.width * 0.6,
                            child: FittedBox(
                              child: Text(
                                _authController.userCurrentLocation,
                                maxLines: 1,
                                style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.grayColor,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => const ProfilePage());
            },
            child: Container(
              width: 42,
              height: 42,
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
                        color: ColorConstant.whiteColor, fontSize: 20)),
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
            child: Image.asset(
              AssetsConstant.search,
              width: 24,
              height: 24,
              color: changeTheme(
                  SharedPrefs.readStringValue(PrefConstants.gender)),
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
                  style: AppTextTheme.bold
                      .copyWith(fontSize: 19, color: ColorConstant.blackColor),
                ),
                TextButton(
                    onPressed: () {},
                    child: Text(
                      "VIEW ALL",
                      style: AppTextTheme.medium.copyWith(
                          fontSize: 13, color: ColorConstant.grayTextColor),
                    ))
              ],
            ),
          ),
          SizedBox(
            height: 130,
            child: ListView.builder(
                // padding: const EdgeInsets.only(left: 14, right: 14),
                scrollDirection: Axis.horizontal,
                itemCount: _homeController
                        .homeCategoryListResponseModel.data?.length ??
                    0,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          imageUrl: _homeController
                                      .homeCategoryListResponseModel
                                      .data![index]
                                      .serviceableGender ==
                                  "male"
                              ? "${APIConstants.image}${_homeController.homeCategoryListResponseModel.data![index].imageFemale}"
                              : "${APIConstants.image}${_homeController.homeCategoryListResponseModel.data![index].imageFemale}",
                          placeholder: (context, url) => const Image(
                            image: AssetImage(AssetsConstant.placeHolder),
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => const Image(
                            image: AssetImage(AssetsConstant.placeHolder),
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: Get.width * 0.25,
                        child: Text(
                          _homeController.homeCategoryListResponseModel
                                  .data?[index].name ??
                              "",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: AppTextTheme.medium.copyWith(
                              fontSize: 13, color: ColorConstant.blackColor),
                        ),
                      )
                    ],
                  );
                }),
          )
        ],
      ),
    );
  }

  /*--------------------  Offer -------------------*/
  _offer() {
    return SizedBox(
      height: 100,
      width: Get.width,
      child: PageView.builder(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          itemCount: 20,
          itemBuilder: (context, index) {
            return Container(
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
                  Image.asset(
                    AssetsConstant.offer,
                    height: 78,
                    width: 78,
                    fit: BoxFit.cover,
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
                        "Flat 30% OFF",
                        style: AppTextTheme.bold.copyWith(
                            color: ColorConstant.blackColor, fontSize: 20),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Use This Coupon To avail The Offer",
                        style: AppTextTheme.medium.copyWith(
                            color: ColorConstant.grayColor, fontSize: 13),
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }

  /*------------ Saloons Found Near ----------- */
  bool atHome = false;
  _saloonsFoundNear() {
    return Container(
      color: ColorConstant.whiteColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_homeController.salonList.length} Saloons Found Near You",
                  textScaler: const TextScaler.linear(0.70),
                  style: AppTextTheme.bold
                      .copyWith(fontSize: 19, color: ColorConstant.blackColor),
                ),
                const SizedBox(width: 5),
                Container(
                  height: 50,
                  color: ColorConstant.whiteColor,
                  child: Row(
                    children: [
                      Text(
                        "Home Service",
                        style: AppTextTheme.medium.copyWith(
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
                          onChanged: (bool? value) {
                            setState(() {
                              atHome = value ?? false;
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
          SizedBox(
            height: 50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Container(
                      width: Get.width * 0.3,
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
                          Text(
                            "Sort By",
                            style: AppTextTheme.medium.copyWith(
                                color: ColorConstant.blackColor, fontSize: 13),
                          ),
                          Image.asset(
                            AssetsConstant.arrowDown,
                            height: 10,
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: ColorConstant.grayBorderColor, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              "Nearest",
                              style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.blackColor,
                                  fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*Current location lat lng*/
  getCurrentLatLng() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission;
    if (!serviceEnabled) {
      await Permission.location.request();
      showMessage("Location services are disabled.");
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await Permission.location.request();
        showMessage("Location permissions are denied");
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      openAppSettings();
      showMessage(
          "Location permissions are permanently denied, we cannot request permissions.");
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    _homeController.lat = position.latitude;
    _homeController.lng = position.longitude;

    Placemark place = placemarks[0];
    _authController.userCity = "${place.locality}";
    _authController.userCurrentLocation =
        "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetHomeCategory();
      _homeController.fetchPosts();
      // _homeController.doGetHomeSalonList(
      //     offset: 1, size: 10, lat: position.latitude, lng: position.longitude);
    });
  }
}
