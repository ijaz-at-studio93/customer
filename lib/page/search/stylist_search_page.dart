import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/page/search/widget/stylist_list_tile_widget.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

import '../../constant/assetsconstant.dart';
import '../../constant/color_constant.dart';

class StylistSearchPage extends StatefulWidget {
  const StylistSearchPage({super.key});

  @override
  State<StylistSearchPage> createState() => _StylistSearchPageState();
}

class _StylistSearchPageState extends State<StylistSearchPage> {
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
          _stylistFoundWidget(),
          Expanded(
              child: ListView.separated(
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
                  itemCount: 15,
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  itemBuilder: (context, index) {
                    return StylistListTileWidget(
                      onPress: () {},
                    );
                  }))
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
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.blackColor, fontSize: 14),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search For saloon Service or stylist",
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
              "24 Stylist Found",
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
          const SizedBox(height: 20),
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
                              "Highest Rating",
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
