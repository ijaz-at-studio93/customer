import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import 'package:salon_customer/page/auth/login_page.dart';
import 'package:salon_customer/page/bottom_navigation_bar.dart';
import 'package:salon_customer/project_specific/ProgressContainerView.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:salon_customer/util/app_conctant.dart';
import 'package:url_launcher/url_launcher.dart';

import '../project_specific/button_widget.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _authController = Get.find<AuthController>();
  @override
  void initState() {
    super.initState();
    getVersionApp();
    stylistId.value = "";
    stylistId.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => ProgressContainerView(
          isProgressRunning: _authController.showProgress,
          child: Container(
            height: Get.height,
            width: Get.width,
            color:
                changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)),
            child: Center(
              child: Text(
                "SCUTS",
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.whiteColor, fontSize: 35),
              ),
            ),
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
            child: SharedPrefs.readBoolValue(PrefConstants.isUserLogin)
                ? const BottomNavBarPage()
                : const LoginPage(
                    splashPage: true,
                  ),
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 800),
            // type: PageTransitionType.rightToLeftWithFade
            type: PageTransitionType.size),
        (route) => false);
  }

  /*-------------- GET VERSION  APP -------------------*/
  void getVersionApp() async {
    String? deviceId;
    var deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    }

    if (deviceId != null) {
      SharedPrefs.writeValue(PrefConstants.deviceId, deviceId);
    }

    String data = await getVersion();

    _authController.doAppUpdate(callback: () {
      if (_authController.getAppUpdateModel.data?.userAppLatestVersion != data) {
        if (_authController.getAppUpdateModel.data?.forceUpdateUserApp ?? false) {
          _forceUpdateDialog();
        } else {
          _normalUpdateDialog();
        }
      } else {
        route();
      }
    });
  }
  /*---------------  Force Update Widget ---------------*/
  _forceUpdateDialog() async {
    return Get.defaultDialog(
        title: "ABOUT UPDATE",
        barrierDismissible: false,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "1 . ",
                  style: AppTextTheme.bold
                      .copyWith(color: ColorConstant.blackColor, fontSize: 14),
                ),
                Text(
                  "Fix Some Bug",
                  style: AppTextTheme.medium
                      .copyWith(color: ColorConstant.grayColor, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "2 . ",
                  style: AppTextTheme.bold
                      .copyWith(color: ColorConstant.blackColor, fontSize: 14),
                ),
                Text(
                  "Improve Loading Experience",
                  style: AppTextTheme.medium
                      .copyWith(color: ColorConstant.grayColor, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "3 . ",
                  style: AppTextTheme.bold
                      .copyWith(color: ColorConstant.blackColor, fontSize: 14),
                ),
                Text(
                  "User Interface Bug Fixing",
                  style: AppTextTheme.medium
                      .copyWith(color: ColorConstant.grayColor, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "4 . ",
                  style: AppTextTheme.bold
                      .copyWith(color: ColorConstant.blackColor, fontSize: 14),
                ),
                Text(
                  "Crash Free App",
                  style: AppTextTheme.medium
                      .copyWith(color: ColorConstant.grayColor, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "5 . ",
                  style: AppTextTheme.bold
                      .copyWith(color: ColorConstant.blackColor, fontSize: 14),
                ),
                Text(
                  "New Navigation Interaction",
                  style: AppTextTheme.medium
                      .copyWith(color: ColorConstant.grayColor, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ButtonWidget(
                  buttonTitleText: "UPDATE",
                  onPress: () {
                    Get.back();
                    _launchURL();
                  }),
            )
          ],
        ));
  }

  /*---------------  Force Update Dialog -------------*/
  _normalUpdateDialog() async {
    return Get.defaultDialog(
      barrierDismissible: false,
      title: "Update Info",
      content: Text(
        "New Version Is Available . Please Update Application",
        style: AppTextTheme.medium
            .copyWith(color: ColorConstant.blackColor, fontSize: 12),
      ),
      confirm: TextButton(
          onPressed: () {
            Get.back();
            _launchURL();
          },
          child: Text(
            "UPDATE",
            style: AppTextTheme.medium
                .copyWith(color: ColorConstant.blackColor, fontSize: 14),
          )),
      cancel: TextButton(
          onPressed: () {
            route();
          },
          child: Text(
            "LATER",
            style: AppTextTheme.medium
                .copyWith(color: ColorConstant.primaryColor, fontSize: 14),
          )),
    );
  }

  /*----------------- Open PlayStore -------------*/
  void _launchURL() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.anantax.scuts';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
