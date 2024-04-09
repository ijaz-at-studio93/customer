import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/page/home/saloon_after_selecting_page.dart';
import 'package:sallon_customer/page/home/widget/menu_dialog_widget.dart';
import 'package:sallon_customer/page/home/widget/saloon_card_widget.dart';
import 'package:sallon_customer/project_specific/status_bar_color_appbar.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: statusBarTheme(context),
      backgroundColor: ColorConstant.bgColor,
      body: SingleChildScrollView(
        child: Column(
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
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return SaloonCardWidget(
                    onPress: () {
                      Get.to(() => const SaloonAfterSelectingServicesPage());
                    },
                  );
                }),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return const MenuDialogWidget();
              });
        },
        child: Container(
          width: 130,
          height: 50,
          decoration: BoxDecoration(
              color: ColorConstant.primaryColor,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AssetsConstant.epMenu,
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Menu",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.whiteColor),
              )
            ],
          ),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                AssetsConstant.location,
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bengaluru",
                    style: AppTextTheme.bold.copyWith(
                        color: ColorConstant.blackColor, fontSize: 20),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "15/11, KG Halli, HRS Layout",
                    style: AppTextTheme.medium
                        .copyWith(color: ColorConstant.grayColor, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => const ProfilePage());
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: ColorConstant.primaryColor),
              child: Center(
                child: Text("AB",
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
    return Container(
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
                padding: const EdgeInsets.only(left: 14, right: 14),
                scrollDirection: Axis.horizontal,
                itemCount: 30,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            "https://static.toiimg.com/thumb/msid-108614769/108614769.jpg?width=500&resizemode=4",
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Hair Cut",
                          style: AppTextTheme.medium.copyWith(
                              fontSize: 13, color: ColorConstant.blackColor),
                        )
                      ],
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  /*------------  Offer ----------*/
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
                border: const Border(
                  right: BorderSide(width: 9, color: Color(0xFF8466CF)),
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
  bool atHome = true;
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
                  "37 Saloons Found Near You",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.bold.copyWith(
                      fontSize: 19, color: ColorConstant.blackColor),
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
                            color: ColorConstant.primaryColor,
                            fontSize: 13),
                      ),
                      SizedBox(
                        height: 30,
                        child: CupertinoSwitch(
                          value: atHome,
                          activeColor: ColorConstant.primaryColor,
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
}
