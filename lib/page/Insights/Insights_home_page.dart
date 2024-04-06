import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        leading: GestureDetector(
            onTap: () {
             Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: ColorConstant.blackColor,
            )),
        centerTitle: true,
        title: Text(
          "Booking Appointment",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            width: Get.width,
            child: ListView.builder(
                padding: const EdgeInsets.only(left: 20),
                itemCount: 10,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context,i){
              return  Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: ColorConstant.grayBorderColor,
                      width: 1),
                ),
                child: Center(
                  child: Text(
                    "Nearest",
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.blackColor,
                        fontSize: 13),
                  ),
                ),
              );
            }),
          )


        ],
      ),
    );
  }
}
