import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/appointment/qr_page.dart';
import 'package:salon_customer/project_specific/ProgressContainerView.dart';
import 'package:salon_customer/project_specific/button_widget.dart';
import 'package:salon_customer/project_specific/status_bar_color_appbar.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

class YourApprovalPage extends StatefulWidget {
  final String salonAppointmentId;

  const YourApprovalPage({super.key, required this.salonAppointmentId});

  @override
  State<YourApprovalPage> createState() => _YourApprovalPageState();
}

class _YourApprovalPageState extends State<YourApprovalPage> {
  int yourApproval = 1;
  final _homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: statusBarTheme(context),
      body: ProgressContainerView(
        isProgressRunning: _homeController.showProgress,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 19, vertical: 30),
                child: Text(
                  'We are collecting service images to increase the stylist efficiency and ultimately give you a better experience AT salon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: changeTheme(SharedPrefs.readStringValue(
                            PrefConstants.gender)) ??
                        ColorConstant.primaryColor,
                    fontSize: 25,
                    fontFamily: 'Bungee',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: Get.width,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: changeTheme(SharedPrefs.readStringValue(
                              PrefConstants.gender)) ??
                          ColorConstant.primaryColor,
                    )),
                child: Column(
                  children: [
                    Text(
                      'Our customer’s Image’s',
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w500,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1.5
                          ..color = changeTheme(SharedPrefs.readStringValue(
                                  PrefConstants.gender)) ??
                              ColorConstant.primaryColor, // Border color
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 2,
                      color: changeTheme(SharedPrefs.readStringValue(
                              PrefConstants.gender)) ??
                          ColorConstant.primaryColor,
                      width: Get.width * 0.6,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 119,
                            width: 119,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: changeTheme(
                                          SharedPrefs.readStringValue(
                                              PrefConstants.gender)) ??
                                      ColorConstant
                                          .primaryColor, // Border color
                                )),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                AssetsConstant.oneImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 119,
                            width: 119,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: changeTheme(
                                          SharedPrefs.readStringValue(
                                              PrefConstants.gender)) ??
                                      ColorConstant
                                          .primaryColor, // Border color
                                )),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                AssetsConstant.threeImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 119,
                            width: 119,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: changeTheme(
                                          SharedPrefs.readStringValue(
                                              PrefConstants.gender)) ??
                                      ColorConstant
                                          .primaryColor, // Border color
                                )),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                AssetsConstant.twoImage,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Get.height * 0.02),
              Text(
                'Do our stylist have the consent to click service picture and show it on his/her portfolio ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)) ??
                      ColorConstant.primaryColor,
                  fontSize: 19,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                '(if needed, stylist make’s sure your face is not revealed)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)) ??
                      ColorConstant.primaryColor,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                height: 42,
                width: Get.width * 0.6,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 4,
                      color: changeTheme(SharedPrefs.readStringValue(
                              PrefConstants.gender)) ??
                          ColorConstant.primaryColor,
                    )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            yourApproval = 1;
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: ColorConstant.blackColor),
                              ),
                              child: Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: yourApproval == 1
                                          ? ColorConstant.blackColor
                                          : Colors.transparent),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Yes',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            yourApproval = 2;
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: ColorConstant.blackColor),
                              ),
                              child: Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: yourApproval == 2
                                          ? ColorConstant.blackColor
                                          : Colors.transparent),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'No',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                child: ButtonWidget(
                    buttonTitleText: "Done",
                    onPress: () {
                      _homeController.doUploadPortFolio(
                          appointmentId: widget.salonAppointmentId,
                          isUpload: yourApproval == 1 ? true : false);
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRCodePage(
                              isBooking: true,
                              appointmentId: widget.salonAppointmentId),
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
