import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/stylist/widget/review_and_ratings_widget.dart';
import 'package:salon_customer/page/stylist/widget/service_offered_page.dart';
import 'package:salon_customer/page/stylist/widget/stylist_portfolio_gird_view.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/status_bar_color_appbar.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import '../../constant/assetsconstant.dart';

class StylistSaloonDetailsPage extends StatefulWidget {
  final String artiestId;
  const StylistSaloonDetailsPage({super.key, required this.artiestId});

  @override
  State<StylistSaloonDetailsPage> createState() =>
      _StylistSaloonDetailsPageState();
}

class _StylistSaloonDetailsPageState extends State<StylistSaloonDetailsPage>
    with SingleTickerProviderStateMixin {
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _tabController = TabController(length: 3, vsync: this);
      _homeController.doGetArtiestPortfolio(artistId: widget.artiestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: statusBarTheme(context),
      backgroundColor: ColorConstant.bgColor,
      body: Obx(
        () => _homeController.showProgress
            ? const ProgressBarView()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _imageHeaderWidget(),
                    _nameContainColum(),
                    _tabBarView(),
                    isSelectedTab == 0
                        ? ServiceAndOfferedPage(
                            artiestPortfolio:
                                _homeController.getArtiestDetailsModel,
                          )
                        : isSelectedTab == 1
                            ? StylistPortfolioGridview(
                                artiestPortfolio:
                                    _homeController.getArtiestDetailsModel,
                              )
                            : ReviewAndRating(
                                artiestPortfolio:
                                    _homeController.getArtiestDetailsModel,
                              )
                  ],
                ),
              ),
      ),
    );
  }

  /*-------------- Image header Widget ------------*/
  _imageHeaderWidget() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CachedNetworkImage(
          width: Get.width,
          height: Get.height * 0.28,
          fit: BoxFit.fitWidth,
          imageUrl:
              "${APIConstants.image}${_homeController.getArtiestDetailsModel.data?.salon?.image ?? ""}",
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
                    onPress: () {},
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
          bottom: -50,
          left: 0,
          right: 0,
          child: Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: ColorConstant.bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  imageUrl:
                      "${APIConstants.image}${_homeController.getArtiestDetailsModel.data?.profileImage ?? ""}",
                  placeholder: (context, url) => const Image(
                    image: AssetImage(AssetsConstant.placeHolder),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  errorWidget: (context, url, error) => const Image(
                    image: AssetImage(AssetsConstant.placeHolder),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

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

  /*------------ Naming Contain Colum --------*/
  _nameContainColum() {
    return Column(
      children: [
        SizedBox(height: Get.height * 0.07),
        Text(
          "Basic Information",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
        const SizedBox(height: 5),
        Text(
          _homeController.getArtiestDetailsModel.data?.name ?? "",
          style: AppTextTheme.bold.copyWith(
              color: ColorConstant.blackColor, fontSize: 14),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RatingBar.builder(
                initialRating:
                    _homeController.getArtiestDetailsModel.data?.rating ??
                        0.0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 25.0,
                ignoreGestures: true,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: changeTheme(SharedPrefs.readStringValue(
                          PrefConstants.gender)) ??
                      ColorConstant.primaryColor,
                  size: 25,
                ),
                onRatingUpdate: (rating) {},
              ),
              const  SizedBox(width: 5),
              Text(
                "(${_homeController.getArtiestDetailsModel.data?.reviewCount ?? 0} Reviews)",
                style: AppTextTheme.medium.copyWith(
                    fontSize: 13, color: ColorConstant.grayTextColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /*------------- Tab Bar View ------------*/
  int isSelectedTab = 0;
  _tabBarView() {
    return TabBar(
      labelPadding: EdgeInsets.zero,
      controller: _tabController,
      labelColor: _selectedColor,
      indicatorColor: _selectedColor,
      indicatorWeight: 2,
      unselectedLabelColor: _unselectedColor,
      indicatorSize: TabBarIndicatorSize.tab,
      /* indicator: MaterialDesignIndicator(
          indicatorHeight: 4, indicatorColor: _selectedColor),*/
      tabs: _tabs,
      onTap: (val) {
        setState(() {
          isSelectedTab = val;
        });
      },
    );
    /*return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      "Service Offered",
                      style: isSelectedTab == 1
                          ? AppTextTheme.bold.copyWith(
                              fontSize: 16,
                              color: changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  ColorConstant.primaryColor)
                          : AppTextTheme.medium.copyWith(
                              fontSize: 16, color: ColorConstant.grayTextColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      width: Get.width * 0.2,
                      decoration: BoxDecoration(
                          color: isSelectedTab == 1
                              ? changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  ColorConstant.primaryColor
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12))),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isSelectedTab = 2;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      "Portfolio",
                      style: isSelectedTab == 2
                          ? AppTextTheme.bold.copyWith(
                              fontSize: 16,
                              color: changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  ColorConstant.primaryColor)
                          : AppTextTheme.medium.copyWith(
                              fontSize: 16, color: ColorConstant.grayTextColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      width: Get.width * 0.2,
                      decoration: BoxDecoration(
                          color: isSelectedTab == 2
                              ? changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  ColorConstant.primaryColor
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12))),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isSelectedTab = 3;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      "Review & ratings",
                      style: isSelectedTab == 3
                          ? AppTextTheme.bold.copyWith(
                              fontSize: 16,
                              color: changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  ColorConstant.primaryColor)
                          : AppTextTheme.medium.copyWith(
                              fontSize: 16, color: ColorConstant.grayTextColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      width: Get.width * 0.2,
                      decoration: BoxDecoration(
                          color: isSelectedTab == 3
                              ? changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  ColorConstant.primaryColor
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
          height: 1,
          width: Get.width,
          color: const Color(0xffADADAD),
        ),
      ],
    );*/
  }

  /*------------- Tab Bar View  -------------*/
  late TabController _tabController;
  final _selectedColor =
      changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)) ??
          ColorConstant.primaryColor;
  final _unselectedColor = ColorConstant.grayTextColor;

  final _tabs = [
    Tab(text: 'Service Offered'),
    Tab(text: 'Portfolio'),
    Tab(text: 'Review & ratings'),
  ];
}
