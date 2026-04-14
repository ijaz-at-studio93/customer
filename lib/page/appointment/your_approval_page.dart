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
  final String? name; // 👈 optional
  final String? phone;

  const YourApprovalPage({super.key, required this.salonAppointmentId, this.name, this.phone});

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
                  'We are collecting service images to increase the stylist efficiency and ultimately give you a better experience at Salon by eliminating Fake Reviews',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: changeTheme(SharedPrefs.readStringValue(
                        PrefConstants.gender)) ??
                        ColorConstant.primaryColor,
                    fontSize: 24,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
                const SizedBox(height: 0,),
                Column(
                  children: [
                    Text(
                      'Example Image’s',
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        // foreground: Paint()
                        //   ..style = PaintingStyle.stroke
                        //   ..strokeWidth = 1.5
                        //color : changeTheme(SharedPrefs.readStringValue(
                      //         PrefConstants.gender)) ??
                      //         ColorConstant.primaryColor, // Border color
                       ),
                    ),
                    //const SizedBox(height: 2),
                    Container(
                      height: 2,
                      // color: changeTheme(SharedPrefs.readStringValue(
                      //     PrefConstants.gender)) ??
                      //     ColorConstant.primaryColor,
                      color: Colors.black54,
                      width: 188,//Get.width * 0.6,
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 130,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(0),
                                color: Colors.white, // ✅ added for shadow
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
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
                              height: 130,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(0),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
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
                              height: 130,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(0),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: Image.asset(
                                  AssetsConstant.twoImage,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              //),
              //SizedBox(height: Get.height * 0.02),
              const SizedBox(height: 20,),
              Text(
                'Does Our Stylist Have Your Consent To Click Picture of the Service and Display it on His/Her Portfolio?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  // color: changeTheme(
                  //     SharedPrefs.readStringValue(PrefConstants.gender)) ??
                  //     ColorConstant.primaryColor,
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '(Stylist Will Make Sure Your Face is Covered)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  // color: changeTheme(
                  //     SharedPrefs.readStringValue(PrefConstants.gender)) ??
                  //     ColorConstant.primaryColor,
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 25),
              Container(
                height: 40,
                width: 140,//Get.width * 0.6,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      //width: 4,
                      color: changeTheme(SharedPrefs.readStringValue(
                          PrefConstants.gender)) ??
                          ColorConstant.primaryColor,
                    )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
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
                            const SizedBox(width: 5),
                            const Text(
                              'Yes',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
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
                            const SizedBox(width: 5),
                            const Text(
                              'No',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 0,),
              // Padding(
              //   padding:
              //   const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
              //   child: ButtonWidget(
              //       buttonTitleText: "Submit",
              //       onPress: () {
              //         _homeController.doUploadPortFolio(
              //             appointmentId: widget.salonAppointmentId,
              //             isUpload: yourApproval == 1 ? true : false,
              //             name: widget.name ?? '',
              //             phone: widget.phone ?? '');
              //         Navigator.pop(context);
              //         Navigator.pop(context);
              //         Navigator.pop(context);
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => QRCodePage(
              //                   isBooking: true,
              //                   appointmentId: widget.salonAppointmentId
              //               )
              //           ),
              //         );
              //         // Get.off(
              //         //       () => BookingConfirmedPage(
              //         //     appointmentId: widget.salonAppointmentId,
              //         //   ),
              //         // );
              //       }),
              // )
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _homeController.doUploadPortFolio(
                        appointmentId: widget.salonAppointmentId,
                        isUpload: yourApproval == 1 ? true : false,
                        name: widget.name ?? '',
                        phone: widget.phone ?? '',
                      );

                      // Navigator.pop(context);
                      // Navigator.pop(context);
                      // Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRCodePage(
                            isBooking: true,
                            appointmentId: widget.salonAppointmentId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 40,
                      width: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender),
                        ) ??
                            ColorConstant.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}