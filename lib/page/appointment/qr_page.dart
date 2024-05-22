import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/api_constant.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/controller/home_controller.dart';
import 'package:sallon_customer/project_specific/progressbar_view.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';
import 'package:ticket_widget/ticket_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bottom_navigation_bar.dart';

class QRCodePage extends StatefulWidget {
  final String appointmentId;
  const QRCodePage({super.key, required this.appointmentId});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  bool _canPopNow = true;
  DateTime? _currentBackPressTime;

  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doCreateQrCode(appointmentId: widget.appointmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPopNow,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          tapBackAgainToCloseApp();
        }
      },
      child: Scaffold(
        backgroundColor:
            changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)) ??
                ColorConstant.primaryColor,
        appBar: AppBar(
          backgroundColor: ColorConstant.primaryColor,
          elevation: 0.0,
          leading: IconButton(onPressed: (){
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const BottomNavBarPage()),
                    (route) => false);
          }, icon: const Icon(Icons.arrow_back)),
        ),
        body:  Obx(()=>
        _homeController.showProgress
            ? const ProgressBarView()
            : SingleChildScrollView(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CachedNetworkImage(
                    height: Get.height * 0.26,
                    width: Get.height,
                    fit: BoxFit.cover,
                    imageUrl:
                    "${APIConstants.image} ${_homeController.getUserBookingQrCodeModel.data?.salon?.image ?? ""}",
                    placeholder: (context, url) => Image(
                      image: const AssetImage(
                          AssetsConstant.placeHolder),
                      height: Get.height * 0.26,
                      width: Get.height,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => Image(
                      image: const AssetImage(
                          AssetsConstant.placeHolder),
                      height: Get.height * 0.26,
                      width: Get.height,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: Get.height * 0.18,
                  right: 15,
                  left: 15,
                  child: TicketWidget(
                    isCornerRounded: true,
                    padding: const EdgeInsets.all(23),
                    width: Get.width,
                    height: Get.height,
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          _homeController
                              .getUserBookingQrCodeModel
                              .data
                              ?.service
                              ?.name ??
                              "",
                          style: AppTextTheme.bold.copyWith(
                              fontSize: 16,
                              color: ColorConstant.blackColor),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          width: Get.width * 0.8,
                          height: 1,
                          decoration: const BoxDecoration(
                              color: ColorConstant.divider2Color),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date",
                                  style: AppTextTheme.medium
                                      .copyWith(
                                      color: ColorConstant
                                          .grayTextColor,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  convertFinalDate(
                                      date: _homeController
                                          .getUserBookingQrCodeModel
                                          .data
                                          ?.finalizedAt ??
                                          ''),
                                  style: AppTextTheme.medium
                                      .copyWith(
                                      color: ColorConstant
                                          .blackColor,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Time Slot",
                                  style: AppTextTheme.medium
                                      .copyWith(
                                      color: ColorConstant
                                          .grayTextColor,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "${convertDate(date: _homeController.getUserBookingQrCodeModel.data?.startsAt ?? "")} - ${convertDate(date: _homeController.getUserBookingQrCodeModel.data?.endsAt ?? "")}",
                                  style: AppTextTheme.medium
                                      .copyWith(
                                      color: ColorConstant
                                          .blackColor,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                          width: Get.width * 0.8,
                          height: 1,
                          decoration: const BoxDecoration(
                              color: ColorConstant.divider2Color),
                        ),
                        const SizedBox(height: 15),
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Address",
                              style: AppTextTheme.medium.copyWith(
                                  color:
                                  ColorConstant.grayTextColor,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _homeController
                                  .getUserBookingQrCodeModel
                                  .data
                                  ?.salon
                                  ?.address ??
                                  "",
                              style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.blackColor,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                          width: Get.width * 0.8,
                          height: 1,
                          decoration: const BoxDecoration(
                              color: ColorConstant.divider2Color),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Stylist Name",
                              style: AppTextTheme.medium.copyWith(
                                  color:
                                  ColorConstant.grayTextColor,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _homeController
                                  .getUserBookingQrCodeModel
                                  .data
                                  ?.artist
                                  ?.name ??
                                  '',
                              style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.blackColor,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                        Center(
                          child: QrImageView(
                            data: _homeController
                                .getUserBookingQrCodeModel
                                .data
                                ?.completionToken ??
                                "",
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: Text(
                            _homeController
                                .getUserBookingQrCodeModel
                                .data
                                ?.completionToken ??
                                "",
                            style: AppTextTheme.medium.copyWith(
                                fontSize: 13,
                                color: ColorConstant.blackColor),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _launchPhone(_homeController.getUserBookingQrCodeModel.data?.salon?.mobile ?? "");
          },
          backgroundColor: ColorConstant.removeStroke,
          child: Image.asset(
            AssetsConstant.sosIcon,
            width: 42,
            height: 19,
          ),
        ),
      ),
    );
  }

  /*-------------- Call Function -----------*/
  _launchPhone(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /*---------------- convertTime ------------*/
  String convertDate({required String date}) {
    String dateTimeString = date;
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedTime = DateFormat('hh:mm a').format(dateTime);
    return formattedTime;
  }

  /*--------------  convert Final  Date -----------*/
  String convertFinalDate({required String date}) {
    String dateTimeString = date;
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    String formattedTime = DateFormat('hh:mm a').format(dateTime);
    return "$formattedDate $formattedTime";
  }

  void tapBackAgainToCloseApp() {
    DateTime now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 3)) {
      _currentBackPressTime = now;

      setState(() {
        _canPopNow = true; // Temporarily let user exit app on the next back tap
      });
      Future.delayed(
        const Duration(seconds: 3),
        () {
          setState(() {
            _canPopNow = false;
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const BottomNavBarPage()),
                (route) => false);
            _currentBackPressTime = null;
          });
        },
      );
    }
  }
}
