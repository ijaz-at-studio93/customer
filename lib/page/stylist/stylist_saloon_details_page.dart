import 'package:flutter/material.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:get/get.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/page/appointment/appointment_booking_page.dart';
import 'package:sallon_customer/page/stylist/widget/review_and_ratings_widget.dart';
import 'package:sallon_customer/page/stylist/widget/service_offered_page.dart';
import 'package:sallon_customer/page/stylist/widget/stylist_portfolio_gird_view.dart';
import 'package:sallon_customer/project_specific/button_widget.dart';
import 'package:sallon_customer/project_specific/status_bar_color_appbar.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

import '../../constant/assetsconstant.dart';
import 'about_stylist_page.dart';

class StylistSaloonDetailsPage extends StatefulWidget {
  const StylistSaloonDetailsPage({super.key});

  @override
  State<StylistSaloonDetailsPage> createState() =>
      _StylistSaloonDetailsPageState();
}

class _StylistSaloonDetailsPageState extends State<StylistSaloonDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: statusBarTheme(context),
      backgroundColor: ColorConstant.bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _imageHeaderWidget(),
            _nameContainColum(),
            _tabBarView(),
            isSelectedTab == 1
                ? const ServiceAndOfferedPage()
                : isSelectedTab == 2
                    ? const StylistPortfolioGridview()
                    : const ReviewAndRating()
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: Get.width,
        color: ColorConstant.whiteColor,
        height: 100,
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
                  itemBorderWidth: 3, // Border width around the images
                ),
                const SizedBox(width: 10),
                Column(
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
                          fontSize: 19, color: ColorConstant.blackColor),
                    )
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Get.to(()=> const AppointmentBookingPage());
              },
              child: Container(
                height: 45,
                width: Get.width * 0.4,
                decoration: BoxDecoration(
                  color: changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Book Now",
                      textScaler: const TextScaler.linear(0.85),
                      style: AppTextTheme.medium.copyWith(
                          fontSize: 16, color: ColorConstant.whiteColor),
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
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
      //   child: ButtonWidget(
      //     onPress: () {
      //
      //     },
      //     buttonTitleText: "Make a appointment",
      //   ),
      // ),
    );
  }


  /*---------  Dummy Image ------*/
  List<String> _images = [
    'https://images.unsplash.com/photo-1593642532842-98d0fd5ebc1a?ixid=MXwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=2250&q=80',
    'https://images.unsplash.com/photo-1612594305265-86300a9a5b5b?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
  ];
  /*-------------- Image header Widget ------------*/
  _imageHeaderWidget() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.network(
          'https://images.unsplash.com/photo-1485686531765-ba63b07845a7?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8bGFrbWUlMjBzYWxvb258ZW58MHx8MHx8fDA%3D',
          width: Get.width,
          height: Get.height * 0.28,
          fit: BoxFit.fitWidth,
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
                child: Image.network(
                  "https://www.iwmbuzz.com/wp-content/uploads/2020/08/neha-kakkar-hairstyle-take-hair-styling-tips-for-curly-hair-for-girls-4.jpg",
                  height: 100,
                  width: 100,
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
          "Neha Kakkar",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
        const SizedBox(height: 5),
        Text(
          "Barber at RedBox Hair Saloon",
          style: AppTextTheme.medium
              .copyWith(fontSize: 13, color: ColorConstant.grayTextColor),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RatingBar.builder(
              initialRating: 3.5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 25.0,
              ignoreGestures: true,
              itemBuilder: (context, _) =>   Icon(
                Icons.star,
                color:  changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor,
                size: 25,
              ),
              onRatingUpdate: (rating) {},
            ),
            Text(
              "(125 Reviews)",
              style: AppTextTheme.medium
                  .copyWith(fontSize: 13, color: ColorConstant.grayTextColor),
            ),
          ],
        )
      ],
    );
  }

  /*------------- Tab Bar View ------------*/
  int isSelectedTab = 1;
  _tabBarView() {
    return Column(
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
                              fontSize: 16, color:  changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor)
                          : AppTextTheme.medium.copyWith(
                              fontSize: 16, color: ColorConstant.grayTextColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      width: Get.width * 0.2,
                      decoration: BoxDecoration(
                          color: isSelectedTab == 1
                              ?  changeTheme(
                              SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor
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
                              fontSize: 16, color:  changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor)
                          : AppTextTheme.medium.copyWith(
                              fontSize: 16, color: ColorConstant.grayTextColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      width: Get.width * 0.2,
                      decoration: BoxDecoration(
                          color: isSelectedTab == 2
                              ? changeTheme(
                              SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor
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
                              fontSize: 16, color:  changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor)
                          : AppTextTheme.medium.copyWith(
                              fontSize: 16, color: ColorConstant.grayTextColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      width: Get.width * 0.2,
                      decoration: BoxDecoration(
                          color: isSelectedTab == 3
                              ?  changeTheme(
                              SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor
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
    );
  }
}
