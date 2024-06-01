import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/controller/home_controller.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';
import '../../../constant/api_constant.dart';
import '../../../constant/variable_constant.dart';
import '../../../project_specific/progressbar_view.dart';

class CompleteBookingDetailsView extends StatefulWidget {
  final String appointmentId;
  const CompleteBookingDetailsView({super.key, required this.appointmentId});

  @override
  State<CompleteBookingDetailsView> createState() =>
      _CompleteBookingDetailsViewState();
}

class _CompleteBookingDetailsViewState
    extends State<CompleteBookingDetailsView> {
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
    return Scaffold(
      backgroundColor:
          changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)) ??
              ColorConstant.primaryColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.primaryColor,
        elevation: 0.0,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Obx(
        () => _homeController.showProgress
            ? const ProgressBarView()
            : Stack(
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
                        image: const AssetImage(AssetsConstant.placeHolder),
                        height: Get.height * 0.26,
                        width: Get.height,
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (context, url, error) => Image(
                        image: const AssetImage(AssetsConstant.placeHolder),
                        height: Get.height * 0.26,
                        width: Get.height,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: Get.height * 0.2,
                    right: 15,
                    left: 15,
                    child: Container(
                      width: Get.width,
                      height: Get.height * 0.5,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: ColorConstant.whiteColor,
                          borderRadius: BorderRadius.circular(6)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Order Status : ",
                                style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.grayTextColor,
                                    fontSize: 13),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Completed",
                                style: AppTextTheme.bold.copyWith(
                                    color: Colors.green, fontSize: 14),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 8.0, // gap between adjacent chips
                            runSpacing: 4.0, // gap between lines
                            children: List.generate(
                              _homeController.getUserBookingQrCodeModel.data
                                      ?.items?.length ??
                                  0,
                              (index) => _homeController
                                          .getUserBookingQrCodeModel
                                          .data
                                          ?.items?[index]
                                          .isService ??
                                      false
                                  ? FilterChip(
                                      labelStyle: AppTextTheme.medium.copyWith(
                                          color: ColorConstant.whiteColor,
                                          fontSize: 13),
                                      label: Text(_homeController
                                              .getUserBookingQrCodeModel
                                              .data
                                              ?.items?[index]
                                              .service
                                              ?.name ??
                                          ""),
                                      backgroundColor:
                                          ColorConstant.primaryColor,
                                      onSelected: (bool value) {},
                                    )
                                  : const SizedBox(),
                            ),
                          ),
                          Container(
                            width: Get.width,
                            height: 1,
                            decoration: const BoxDecoration(
                                color: ColorConstant.divider2Color),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Date",
                                    style: AppTextTheme.medium.copyWith(
                                        color: ColorConstant.grayTextColor,
                                        fontSize: 13),
                                  ),
                                  const SizedBox(height: 10),
                                  _homeController.getUserBookingQrCodeModel.data
                                              ?.finalizedAt ==
                                          null
                                      ? const SizedBox()
                                      : Text(
                                          convertFinalDate(
                                              date: _homeController
                                                      .getUserBookingQrCodeModel
                                                      .data
                                                      ?.finalizedAt ??
                                                  ''),
                                          style: AppTextTheme.medium.copyWith(
                                              color: ColorConstant.blackColor,
                                              fontSize: 13),
                                        ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Time Slot",
                                    style: AppTextTheme.medium.copyWith(
                                        color: ColorConstant.grayTextColor,
                                        fontSize: 13),
                                  ),
                                  const SizedBox(height: 10),
                                  _homeController.getUserBookingQrCodeModel.data
                                                  ?.startsAt ==
                                              null &&
                                          _homeController
                                                  .getUserBookingQrCodeModel
                                                  .data
                                                  ?.endsAt ==
                                              null
                                      ? const SizedBox()
                                      : Text(
                                          "${convertDate(date: _homeController.getUserBookingQrCodeModel.data?.startsAt ?? "")} - ${convertDate(date: _homeController.getUserBookingQrCodeModel.data?.endsAt ?? "")}",
                                          style: AppTextTheme.medium.copyWith(
                                              color: ColorConstant.blackColor,
                                              fontSize: 13),
                                        ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: Get.width,
                            height: 1,
                            decoration: const BoxDecoration(
                                color: ColorConstant.divider2Color),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Salon Details",
                            style: AppTextTheme.bold.copyWith(
                                color: ColorConstant.blackColor, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: Get.width,
                            height: 1,
                            decoration: const BoxDecoration(
                                color: ColorConstant.divider2Color),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name",
                                style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.grayTextColor,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _homeController.getUserBookingQrCodeModel.data
                                        ?.salon?.name ??
                                    "",
                                style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.blackColor,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Address",
                                style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.grayTextColor,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _homeController.getUserBookingQrCodeModel.data
                                        ?.salon?.address ??
                                    "",
                                style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.blackColor,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mobile",
                                style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.grayTextColor,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _homeController.getUserBookingQrCodeModel.data
                                        ?.salon?.mobile ??
                                    "",
                                style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.blackColor,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Email",
                                style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.grayTextColor,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _homeController.getUserBookingQrCodeModel.data
                                        ?.salon?.email ??
                                    "",
                                style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.blackColor,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
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
}
