import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/colorconstant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        color: ColorConstant.primaryColor,
        child: Center(
          child: Text(
            "SALLON",
            style: AppTextTheme.bold
                .copyWith(color: ColorConstant.whiteColor, fontSize: 35),
          ),
        ),
      ),
    );
  }
}
