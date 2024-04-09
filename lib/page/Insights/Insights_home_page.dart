import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/page/Insights/insights_detail_page.dart';
import 'package:sallon_customer/page/Insights/widget/Insights_card_widget.dart';

import '../../constant/color_constant.dart';
import '../../project_specific/text_theme.dart';

class InsightsHomePage extends StatefulWidget {
  const InsightsHomePage({super.key});

  @override
  State<InsightsHomePage> createState() => _InsightsHomePageState();
}

class _InsightsHomePageState extends State<InsightsHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading:const SizedBox(),
        centerTitle: true,
        title: Text(
          "Insights",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            width: Get.width,
            child: ListView.builder(
                padding: const EdgeInsets.only(left: 20),
                itemCount: 10,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  return Container(
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
                            color: ColorConstant.blackColor, fontSize: 13),
                      ),
                    ),
                  );
                }),
          ),
          Expanded(
            child: ListView.separated(
                separatorBuilder: (context, i) {
                  return const Divider(
                    thickness: 2,
                    color: ColorConstant.divider2Color,
                    indent: 20,
                    endIndent: 20,
                  );
                },
                shrinkWrap: true,
                itemCount: 5,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                itemBuilder: (context, i) {
                  return   InsightsCardWidget(
                    onPress: (){
                      Get.to(()=> const InsightsDetailPage(image: "https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",));
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}
