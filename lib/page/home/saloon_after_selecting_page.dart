import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:readmore/readmore.dart';
import 'package:sallon_customer/constant/api_constant.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/controller/home_controller.dart';
import 'package:sallon_customer/page/home/widget/customized_sheet_widget.dart';
import 'package:sallon_customer/page/home/widget/over_view_list_tile_widget.dart';
import 'package:sallon_customer/page/home/widget/stylist_list_grid_widget.dart';
import 'package:sallon_customer/page/stylist/selecting_artist_bottom_sheet.dart';
import 'package:sallon_customer/project_specific/ProgressContainerView.dart';
import 'package:sallon_customer/project_specific/remove_and_add_service_dialog.dart';
import 'package:sallon_customer/project_specific/status_bar_color_appbar.dart';
import 'package:sallon_customer/util/NoItemsWidget.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';
import '../../constant/color_constant.dart';
import '../../project_specific/text_theme.dart';
import '../appointment/appointment_booking_page.dart';
import '../search/stylist_search_page.dart';

class SaloonAfterSelectingServicesPage extends StatefulWidget {
  final String salonId;
  const SaloonAfterSelectingServicesPage({
    super.key,
    required this.salonId,
  });

  @override
  State<SaloonAfterSelectingServicesPage> createState() =>
      _SaloonAfterSelectingServicesPageState();
}

class _SaloonAfterSelectingServicesPageState
    extends State<SaloonAfterSelectingServicesPage> {
  final _homeController = Get.find<HomeController>();

  bool loading = false;
  final box = GetStorage();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetHomeSalonDetails(salonId: widget.salonId);
      _homeController.doGetSalonDetailsService(salonId: widget.salonId);
      _homeController.doGetSalonArtiestListData(salonId: widget.salonId);
    });
  }

  String serviceId = "";
  String artiestId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: statusBarTheme(context),
      backgroundColor: ColorConstant.bgColor,
      body: Obx(
        () => ProgressContainerView(
          isProgressRunning: _homeController.showProgress,
          child: ListView(
            children: [
              _imageHeaderWidget(),
              _headerWidget(),
              const SizedBox(height: 5),
              _tabBarView(),
              const SizedBox(height: 110)
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: serviceId == ""
          ? const SizedBox()
          : Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: Get.width,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: ColorConstant.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1E000000),
                        blurRadius: 8,
                        offset: Offset(-2, -2),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          FlutterImageStack(
                            imageList: _images,
                            showTotalCount: false,
                            totalCount: 4,
                            imageSource: ImageSource.network,
                            itemRadius: 35,
                            itemCount: 2,
                            itemBorderWidth:
                                3, // Border width around the images
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(32),
                                    topRight: Radius.circular(32),
                                  )),
                                  context: context,
                                  builder: (context) {
                                    return const CustomizedSheetWidget();
                                  });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "1 Added",
                                      style: AppTextTheme.bold.copyWith(
                                          fontSize: 13,
                                          color: ColorConstant.grayTextColor),
                                    ),
                                    const SizedBox(width: 2),
                                    Image.asset(
                                      AssetsConstant.arrowUpIcon,
                                      height: 8,
                                      width: 11,
                                    )
                                  ],
                                ),
                                Text(
                                  "₹4,000",
                                  style: AppTextTheme.bold.copyWith(
                                      fontSize: 19,
                                      color: ColorConstant.blackColor),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          if (serviceId != "" && artiestId != "") {
                            Get.to(() => AppointmentBookingPage(
                                  serviceId: serviceId,
                                  salonId: widget.salonId,
                                  artiestId: artiestId,
                                ));
                          } else {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                isDismissible: false,
                                enableDrag: false,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                )),
                                context: context,
                                builder: (context) {
                                  return SelectingArtistBottomSheetWidget(
                                    serviceId: serviceId,
                                    callback: () {
                                      artiestId = box.read('artiestId');
                                    },
                                  );
                                });
                          }

                          /*showModalBottomSheet(
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            )),
                            context: context,
                            builder: (context) {
                              return const ViewCartWidget(
                              );
                            });*/
                        },
                        child: Container(
                          height: 45,
                          width: Get.width * 0.4,
                          decoration: BoxDecoration(
                            color: changeTheme(SharedPrefs.readStringValue(
                                PrefConstants.gender)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Select Stylist",
                                textScaler: const TextScaler.linear(0.85),
                                style: AppTextTheme.medium.copyWith(
                                    fontSize: 16,
                                    color: ColorConstant.whiteColor),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_forward,
                                color: ColorConstant.whiteColor,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /*---------  Dummy Image ------*/
  List<String> _images = [
    'https://images.unsplash.com/photo-1593642532842-98d0fd5ebc1a?ixid=MXwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=2250&q=80',
    'https://images.unsplash.com/photo-1612594305265-86300a9a5b5b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
  ];

  /*------------ Back Button --------------*/
  buttonWidget(
      {required String imageUrl,
      required VoidCallback onPress,
      required double h,
      required double w}) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorConstant.blackColor.withOpacity(0.50),
          ),
          child: Center(
            child: Image.asset(
              imageUrl,
              width: w,
              height: h,
              fit: BoxFit.contain,
            ),
          )),
    );
  }

  /*-------------- Image header Widget ------------*/
  _imageHeaderWidget() {
    return Stack(
      children: [
        CachedNetworkImage(
          width: Get.width,
          height: Get.height * 0.28,
          fit: BoxFit.fitWidth,
          imageUrl:
              "${APIConstants.image}${_homeController.homeSalonDetailsData.data?.image ?? ""}",
          placeholder: (context, url) => Image(
            image: const AssetImage(AssetsConstant.placeHolder),
            width: Get.width,
            height: Get.height * 0.28,
            fit: BoxFit.fitWidth,
          ),
          errorWidget: (context, url, error) => Image(
            image: const AssetImage(AssetsConstant.placeHolder),
            width: Get.width,
            height: Get.height * 0.28,
            fit: BoxFit.fitWidth,
          ),
        ),
        Positioned(
            child: Container(
          width: Get.width,
          height: Get.height * 0.28,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.02, 1.00),
              end: Alignment(-0.02, -1),
              colors: [Colors.black, Color(0x003D3636)],
            ),
          ),
        )),
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buttonWidget(
                imageUrl: AssetsConstant.backArrow,
                onPress: () {
                  Get.back();
                },
                h: 15,
                w: 15,
              ),
              Row(
                children: [
                  buttonWidget(
                    imageUrl: AssetsConstant.iconSearch,
                    onPress: () {
                      Get.to(() => const StylistSearchPage());
                    },
                    h: 24,
                    w: 24,
                  ),
                  const SizedBox(width: 15),
                  buttonWidget(
                    imageUrl: AssetsConstant.shareIcon,
                    onPress: () {},
                    h: 18,
                    w: 18,
                  ),
                  const SizedBox(width: 15),
                  buttonWidget(
                    imageUrl: AssetsConstant.likeBlank,
                    onPress: () {},
                    h: 20,
                    w: 20,
                  ),
                ],
              )
            ],
          ),
        ),
        Positioned(
            bottom: 16,
            left: 19,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: ColorConstant.greenColor,
                      borderRadius: BorderRadius.circular(5)),
                  width: 60,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '4.8',
                        style: AppTextTheme.medium.copyWith(
                            fontSize: 11, color: ColorConstant.whiteColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 13),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "7.6K Ratings",
                      style: AppTextTheme.medium.copyWith(
                          color: ColorConstant.whiteColor, fontSize: 13),
                    ),
                    const SizedBox(height: 5),
                    const Dash(
                      direction: Axis.horizontal,
                      length: 80,
                      dashLength: 2,
                      dashColor: ColorConstant.whiteColor,
                    ),
                  ],
                )
              ],
            )),
      ],
    );
  }

  /*---------- Header Widget ------------*/
  _headerWidget() {
    return Container(
      width: Get.width,
      color: ColorConstant.whiteColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Get.width * 0.9,
            child: Text(
              maxLines: 1,
              _homeController.homeSalonDetailsData.data?.name ?? "",
              overflow: TextOverflow.ellipsis,
              style: AppTextTheme.bold
                  .copyWith(fontSize: 19, color: ColorConstant.blackColor),
            ),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: List.generate(
              _homeController
                      .homeSalonDetailsData.data?.serviceCategories?.length ??
                  0,
              (index) => FilterChip(
                labelStyle: AppTextTheme.medium
                    .copyWith(color: ColorConstant.whiteColor, fontSize: 13),
                label: Text(
                    "${_homeController.homeSalonDetailsData.data!.serviceCategories?[index].name}"),
                backgroundColor: ColorConstant.primaryColor,
                onSelected: (bool value) {},
              ),
            ),
          ),
          const SizedBox(height: 20),
          Dash(
            direction: Axis.horizontal,
            length: Get.width * 0.9,
            dashLength: 2,
            dashColor: const Color(0xffCFCFCF),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    AssetsConstant.manWalk,
                    height: 13,
                    width: 13,
                    color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "20-25 min • 2.5 km",
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.blackColor, fontSize: 13),
                  )
                ],
              ),
              Container(
                height: 15,
                width: 1.5,
                color: ColorConstant.grayColor,
              ),
              Row(
                children: [
                  Image.asset(
                    AssetsConstant.calender,
                    height: 13,
                    width: 13,
                    color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Mon-Sat • 11 am - 11 pm",
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.blackColor, fontSize: 13),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    AssetsConstant.locationNewIcon,
                    height: 13,
                    width: 13,
                    color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: Get.width * 0.5,
                    child: Text(
                      _homeController.homeSalonDetailsData.data?.address ?? "",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AppTextTheme.medium.copyWith(
                          color: ColorConstant.blackColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: ColorConstant.pinkBgColor,
                  border: Border.all(color: ColorConstant.pinkStrokeColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      AssetsConstant.locationShare,
                      width: 12,
                      height: 12,
                      color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Get Direction",
                      textScaler: const TextScaler.linear(0.85),
                      style: AppTextTheme.medium.copyWith(
                          fontSize: 12,
                          color: changeTheme(SharedPrefs.readStringValue(
                              PrefConstants.gender))),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  /*------------- Tab Bar View ------------*/
  int isSelectedTab = 1;

  /*------------  Is Home Service -------------*/
  bool isHomeService = false;
  bool serviceOffered = false;

  _tabBarView() {
    return Container(
      color: ColorConstant.whiteColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      isSelectedTab = 1;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        "Overview",
                        style: isSelectedTab == 1
                            ? AppTextTheme.bold.copyWith(
                                fontSize: 16,
                                color: changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender)))
                            : AppTextTheme.medium.copyWith(
                                fontSize: 16,
                                color: ColorConstant.grayTextColor),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 4,
                        width: Get.width * 0.2,
                        decoration: BoxDecoration(
                            color: isSelectedTab == 1
                                ? changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender))
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12))),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    setState(() {
                      isSelectedTab = 2;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        "Stylist List",
                        style: isSelectedTab == 2
                            ? AppTextTheme.bold.copyWith(
                                fontSize: 16,
                                color: changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender)))
                            : AppTextTheme.medium.copyWith(
                                fontSize: 16,
                                color: ColorConstant.grayTextColor),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 4,
                        width: Get.width * 0.2,
                        decoration: BoxDecoration(
                            color: isSelectedTab == 2
                                ? changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender))
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12))),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
              height: 1, width: Get.width, color: const Color(0xffADADAD)),

          /*------------------  OverView  and  Stylist Widget -----------------*/
          if (isSelectedTab == 1)
            Container(
              color: ColorConstant.whiteColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: ReadMoreText(
                      _homeController.homeSalonDetailsData.data?.description ??
                          "",
                      trimMode: TrimMode.Line,
                      style: AppTextTheme.medium.copyWith(
                          height: 1.5,
                          color: ColorConstant.blackColor,
                          fontSize: 14),
                      trimLines: 6,
                      colorClickableText: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)),
                      trimCollapsedText: 'more',
                      trimExpandedText: 'Show less',
                      moreStyle: AppTextTheme.medium.copyWith(
                          fontSize: 15,
                          color: changeTheme(SharedPrefs.readStringValue(
                              PrefConstants.gender))),
                    ),
                  ),
                  /*--------------------- Title amd List  ---------------*/
                  _homeController.salonDetailsListData.data?.isEmpty ?? false
                      ? _homeController.showProgress
                          ? const SizedBox()
                          : const NoItemsWidget(
                              text: "This Salon No Provide Any Service",
                            )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _homeController
                                  .salonDetailsListData.data?.length ??
                              0,
                          itemBuilder: (context, index) {
                            return ExpansionTile(
                              initiallyExpanded: index == 0 ? true : false,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _homeController.salonDetailsListData
                                            .data?[index].name ??
                                        "",
                                    style: AppTextTheme.bold.copyWith(
                                        color: ColorConstant.blackColor,
                                        fontSize: 19),
                                  ),
                                  const SizedBox(height: 15),
                                  Dash(
                                    direction: Axis.horizontal,
                                    length: Get.width * 0.75,
                                    dashLength: 2,
                                    dashColor: ColorConstant.grayTextColor,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                              children: [
                                ListView.separated(
                                    separatorBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(
                                            top: 20, bottom: 20),
                                        height: 1,
                                        width: Get.width,
                                        color: ColorConstant.dividerColor,
                                      );
                                    },
                                    shrinkWrap: true,
                                    itemCount: _homeController
                                            .salonDetailsListData
                                            .data?[index]
                                            .services
                                            ?.length ??
                                        0,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, i) {
                                      return OverviewListTileWidget(
                                        servicesList: _homeController
                                            .salonDetailsListData
                                            .data![index]
                                            .services![i],
                                        isSelect: _homeController
                                                .salonDetailsListData
                                                .data?[index]
                                                .services?[i]
                                                .isSelect ??
                                            false,
                                        addButtonTap: () {
                                          setState(() {
                                            if (serviceId != "") {
                                              if (_homeController
                                                      .salonDetailsListData
                                                      .data?[index]
                                                      .services?[i]
                                                      .isSelect ??
                                                  false) {
                                                _homeController
                                                    .salonDetailsListData
                                                    .data?[index]
                                                    .services?[i]
                                                    .isSelect = !(_homeController
                                                        .salonDetailsListData
                                                        .data?[index]
                                                        .services?[i]
                                                        .isSelect ??
                                                    false);
                                                serviceId = "";
                                                artiestId = "";
                                              } else {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return RemoveAndAddServiceDialog(
                                                          noPress: () {
                                                        Get.back();
                                                      }, yesPress: () {
                                                        setState(() {
                                                          _homeController
                                                              .doGetHomeSalonDetails(
                                                                  salonId: widget
                                                                      .salonId);
                                                          _homeController
                                                              .doGetSalonDetailsService(
                                                                  salonId: widget
                                                                      .salonId);
                                                          _homeController
                                                              .doGetSalonArtiestListData(
                                                                  salonId: widget
                                                                      .salonId);
                                                          Navigator.pop(
                                                              context);
                                                          serviceId = "";
                                                          artiestId = "";
                                                        });
                                                      });
                                                    });
                                              }
                                            } else {
                                              _homeController
                                                  .salonDetailsListData
                                                  .data?[index]
                                                  .services?[i]
                                                  .isSelect = !(_homeController
                                                      .salonDetailsListData
                                                      .data?[index]
                                                      .services?[i]
                                                      .isSelect ??
                                                  false);

                                              if (_homeController
                                                      .salonDetailsListData
                                                      .data?[index]
                                                      .services?[i]
                                                      .isSelect ??
                                                  false) {
                                                serviceId = _homeController
                                                        .salonDetailsListData
                                                        .data?[index]
                                                        .services?[i]
                                                        .id ??
                                                    "";
                                              } else {
                                                serviceId = "";
                                                artiestId = "";
                                              }
                                            }
                                          });
                                        },
                                        onTap: () {},
                                      );
                                    }),
                                const SizedBox(height: 20),
                              ],
                            );
                          }),
                ],
              ),
            )
          else
            _homeController.getSalonDetailsArtiestData.data?.isEmpty ?? false
                ? const NoItemsWidget(
                    text: "No Stylist Available",
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.0,
                      crossAxisSpacing: 12.0,
                      childAspectRatio: 0.62, // Aspect ratio of each item
                    ),
                    itemCount: _homeController
                            .getSalonDetailsArtiestData.data?.length ??
                        0,
                    itemBuilder: (context, index) {
                      return StylistListGridWidget(
                        isView: false,
                        salonArtiestListModel: _homeController
                            .getSalonDetailsArtiestData.data![index],
                        onPress: () {},
                      );
                    },
                  ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}
