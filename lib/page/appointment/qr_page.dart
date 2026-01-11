import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/appointment/widget/promocode_sheet_widget.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:ticket_widget/ticket_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api/dio_client.dart';
import '../../controller/auth_controller.dart';
import '../../model/user_booking_qr_code_model.dart';
import '../../util/call_wrapper.dart';
import '../bottom_navigation_bar.dart';
import 'dart:ui';

class QRCodePage extends StatefulWidget {
  final String appointmentId;
  final bool isBooking;

  const QRCodePage({
    super.key,
    required this.appointmentId,
    required this.isBooking,
  });

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  late Razorpay razorpay;
  final _authController = Get.find<AuthController>();
  final _homeController = Get.find<HomeController>();
  final Rx<UserBookingQrCodeModel> getUserBookingQrCodeModel =
      UserBookingQrCodeModel().obs;

  @override
  void initState() {
    super.initState();

    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _homeController.doCreateQrCode(
        appointmentId: widget.appointmentId,
      );

      final paymentStatus = _homeController
          .getUserBookingQrCodeModel
          .data
          ?.paymentStatus
          ?.toLowerCase();

      if (paymentStatus == 'paid') {
        _homeController.doClearCart(
          callback: () {
            stylistId.value = "";
            stylistId.notifyListeners();
            _homeController.doGetCart();
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPaymentPending =
        _homeController.getUserBookingQrCodeModel.data?.paymentStatus
            ?.toLowerCase() ==
            "pending";
    return Scaffold(
      backgroundColor:
      changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)) ??
          ColorConstant.primaryColor,
      appBar: AppBar(
        backgroundColor: changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)) ??
            ColorConstant.primaryColor,
        elevation: 0.0,
        leading: IconButton(
            onPressed: () {
              if (widget.isBooking) {
                Get.offAll(() => const BottomNavBarPage());
              } else {
                Get.back();
              }
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Obx(
            () => _homeController.showProgress
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
                  "${APIConstants.image}${_homeController.getUserBookingQrCodeModel.data?.salon?.image ?? ""}",
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
                top: Get.height * 0.18,
                right: 15,
                left: 15,
                child: TicketWidget(
                  isCornerRounded: true,
                  padding: const EdgeInsets.all(23),
                  width: Get.width,
                  height: Get.height * 0.75,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _homeController.getUserBookingQrCodeModel.data
                            ?.salon?.name ??
                            "",
                        style: AppTextTheme.bold.copyWith(
                            color: ColorConstant.blackColor,
                            fontSize: 15),
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
                              _homeController.getUserBookingQrCodeModel
                                  .data?.startsAt ==
                                  null
                                  ? const SizedBox()
                                  : Text(
                                convertFinalDate(
                                    date: _homeController
                                        .getUserBookingQrCodeModel
                                        .data
                                        ?.startsAt ??
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
                              _homeController.getUserBookingQrCodeModel
                                  .data?.startsAt ==
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
                      const SizedBox(height: 15),
                      Container(
                        width: Get.width * 0.8,
                        height: 1,
                        decoration: const BoxDecoration(
                            color: ColorConstant.divider2Color),
                      ),
                      const SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Address",
                            style: AppTextTheme.medium.copyWith(
                                color: ColorConstant.grayTextColor,
                                fontSize: 13),
                          ),
                          const SizedBox(height: 10),
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
                      const SizedBox(height: 15),
                      Container(
                        width: Get.width * 0.8,
                        height: 1,
                        decoration: const BoxDecoration(
                            color: ColorConstant.divider2Color),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT – Stylist (unchanged)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Stylist Name",
                                style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.grayTextColor,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _homeController
                                    .getUserBookingQrCodeModel
                                    .data
                                    ?.appointment
                                    ?.artist
                                    ?.name ??
                                    "",
                                style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.blackColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 12),

                          // RIGHT – Services (make this flexible)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Services",
                                  style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.grayTextColor,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _homeController
                                      .getUserBookingQrCodeModel
                                      .data
                                      ?.items
                                      ?.where((e) => e.isService == true)
                                      .map((e) => e.service?.name ?? "")
                                      .where((name) => name.isNotEmpty)
                                      .join(", ") ??
                                      "",
                                  style: AppTextTheme.medium.copyWith(
                                    color: ColorConstant.blackColor,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.right,
                                  maxLines: 3,              // you can increase if you want
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      /* old flow of showing QR to only confirmed.*/
                      // Center(
                      //   child: QrImageView(
                      //     data: _homeController.getUserBookingQrCodeModel
                      //             .data?.completionToken ??
                      //         "",
                      //     version: QrVersions.auto,
                      //     size: 200.0,
                      //   ),
                      // ),

                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: QrImageView(
                                data: _homeController.getUserBookingQrCodeModel.data?.completionToken ?? "",
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ),

                            if (_homeController.getUserBookingQrCodeModel.data?.orderStatus?.toLowerCase() == "pending")
                              Positioned(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: Container(
                                      width: 200,
                                      height: 200,
                                      color: Colors.black.withOpacity(0.2),
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        "QR will be shown once stylist accepts appointment",
                                        textAlign: TextAlign.center,
                                        style: AppTextTheme.medium.copyWith(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),
                      Center(
                        child: Text(
                          _homeController
                              .getUserBookingQrCodeModel.data?.idx ??
                              "",
                          style: AppTextTheme.medium.copyWith(
                              fontSize: 13,
                              color: ColorConstant.blackColor),
                        ),
                      ),

                      const SizedBox(height: 5)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() {
        final isPaymentPending =
            _homeController.getUserBookingQrCodeModel.data?.paymentStatus
                ?.toLowerCase() == "pending";

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 👈 VERY IMPORTANT
            children: [

              // 🔵 Apply Offer & Pay (TOP)
              if (isPaymentPending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstant.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _openApplyOfferSheet,
                    child: Text(
                      "Apply Offer & Pay",
                      style: AppTextTheme.bold.copyWith(color: Colors.white),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // 🔴 Cancel Booking (BOTTOM)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _showCancelConfirmationDialog,
                  child: Text(
                    "Cancel Booking",
                    style: AppTextTheme.bold.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }),

    );
  }

  /*-------------  On Payment Fail Method ------------- */
  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    final user = _authController.userResponseModel.data?.userData;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return CallWrapper( // ✅ adds your Help 24×7 call button
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              "Payment Failed",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView( // ✅ ensures content never overflows
              child: ListBody(
                children: [
                  const Text(
                    "You may have cancelled the payment or there was a delay in response from the UPI app.",
                  ),
                  const SizedBox(height: 12),
                  Text("Mobile: +91 ${user?.mobile ?? ''}"),
                  Text("Email: ${user?.email ?? ''}"),
                  Text("Name: ${user?.name ?? ''}"),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();       // ✅ close dialog
                  //Navigator.of(context).maybePop(); // ✅ go back if possible
                },
                child: const Text(
                  "OK",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /*---------------  On Payment Success Method ------------ */
  Future<void> handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    print("🎯 Razorpay Success Response: $response");
    print("PaymentId: ${response.paymentId}");
    print("OrderId: ${response.orderId}");
    print("Signature: ${response.signature}");
    showMessage("Payment Successful");
    Get.back();
  }

  void _startPayment() {
    final amount =
        (_homeController.getUserBookingQrCodeModel.data?.orderAmount ?? 0) * 100;

    final options = {
      'key': _homeController.getOrderIdModel.data?.razorpayKey ?? "",
      'amount': amount.toInt(),
      'name': 'ScutS',
      'order_id': _homeController.getOrderIdModel.data?.orderId ?? "",
      'description': 'Pay After Service',
      'timeout': 120,
      'prefill': {
        'contact': _authController.userResponseModel
            .data?.userData?.mobile ??
            "",
        'email': _authController.userResponseModel
            .data?.userData?.email ??
            ""
      },
    };

    razorpay.open(options);
  }

  void _openApplyOfferSheet() async {
    String discountId = await showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      context: context,
      builder: (_) => const PromoCodeSheetWidget(),
    );

    if (discountId.isNotEmpty) {
      _homeController.doApplyPromoCode(
        data: {"discountId": discountId},
        callback: () {
          _homeController.doCreateQrCode(
            appointmentId: widget.appointmentId,
          );
          _startPayment(); // 👈 ADD THIS
        },
      );
    }
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
    String formattedDate = DateFormat('EEE, dd MMM yyyy').format(dateTime);
    return formattedDate;
  }

  void _showCancelConfirmationDialog() {
    Get.defaultDialog(
      title: "Cancel Booking?",
      middleText: "Are you sure you want to cancel this appointment?",
      textCancel: "No",
      textConfirm: "Yes",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        // close confirmation dialog
        Get.back();

        // show a single loader dialog
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        try {
          final bookingId = _homeController.getUserBookingQrCodeModel.data?.idx ?? "";
          final artistId = _homeController.getUserBookingQrCodeModel.data?.appointment?.artist?.id ?? "";

          // call cancelBooking and await the response
          final response = await _homeController.cancelBooking(
            bookingId: bookingId,
            artistId: artistId,
            status: "user_cancelled",
            // IMPORTANT: do NOT use a callback that calls Get.back() or shows snackbars here
            // because we will handle UI flow in this method after awaiting the response.
            //callback: () {},
          );

          // close loader (only once)
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

          if (response.success) {
            // Update local model (optional)
            _homeController.getUserBookingQrCodeModel.data?.orderStatus = "user_cancelled";

            // Pop this QR page and send result true to the previous page to trigger a refresh
            Get.back(result: true);

            // show success snackbar (this is safe; we are not trying to close a disposed snackbar)
            Get.snackbar(
              "Success",
              "Your booking has been cancelled. Refund will be processed shortly, if it is paid booking",
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          } else {
            // show failure snackbar
            Get.snackbar(
              "Failed",
              response.message ?? "Something went wrong.",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } catch (e) {
          // close loader (if still open)
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

          Get.snackbar(
            "Error",
            "Something went wrong: ${e.toString()}",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }
}
