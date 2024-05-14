import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/api/dio_client.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/project_specific/button_widget.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

class NoInternetConnection extends StatefulWidget {
  const NoInternetConnection({super.key});

  @override
  State<NoInternetConnection> createState() => _NoInternetConnectionState();
}

class _NoInternetConnectionState extends State<NoInternetConnection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Image.asset(
              AssetsConstant.noInterNet,
              height: 230,
              width: 230,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: Get.width - 170,
            child: Center(
              child: Text(
                "No Internet",
                style: AppTextTheme.bold
                    .copyWith(fontSize: 25, color: ColorConstant.blackColor),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text(
              "Something wrong with your connection \n please check and try again.",
              textScaler: const TextScaler.linear(0.85),
              style: AppTextTheme.medium
                  .copyWith(fontSize: 16, color: ColorConstant.blackColor),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: ButtonWidget(
              onPress: () {
                showMessage("Please check your internet connection");
              },
              buttonTitleText: 'TRY AGAIN',
            ),
          ),
        ],
      ),
    );
  }
}
