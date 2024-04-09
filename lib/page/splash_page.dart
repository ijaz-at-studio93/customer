import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/page/auth/login_page.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    startTime();
    super.initState();
  }

  /*------------ Route Time -----------*/
  startTime() async {
    var duration = const Duration(seconds: 4);
    return Timer(duration, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        color: ColorConstant.primaryColor,
        child: Center(
          child: Text(
            "SALON",
            style: AppTextTheme.bold
                .copyWith(color: ColorConstant.whiteColor, fontSize: 35),
          ),
        ),
      ),
    );
  }

  /*-------------- Route For Welcome Page -----------------*/


  route() {
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            child: const LoginPage(splashPage: true,),
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 800),
            // type: PageTransitionType.rightToLeftWithFade
            type: PageTransitionType.size),
        (route) => false);
  }
}
