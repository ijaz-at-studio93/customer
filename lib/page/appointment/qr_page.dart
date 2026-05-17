import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/appointment/payment_success_page.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api/home_api.dart';
import '../../constant/variable_constant.dart';
import '../../controller/auth_controller.dart';
import '../../main.dart';
import '../../util/SharedPrefs.dart';
import '../../util/snackbar_util.dart';
import '../booking/booking_home_page.dart';
import '../bottom_navigation_bar.dart';
import 'package:salon_customer/service/analytics_service.dart';

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

class _QRCodePageState extends State<QRCodePage> with TickerProviderStateMixin {
  late Razorpay razorpay;
  bool showBreakdown = false;
  final FocusNode _amountFocus = FocusNode();

  final _homeController = Get.find<HomeController>();
  final TextEditingController _amountController = TextEditingController();
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

    SharedPrefs.writeValue(
      PrefConstants.resumePayBillAppointmentId,
      widget.appointmentId,
    );

    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _amountController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _homeController.doCreateQrCode(
        appointmentId: widget.appointmentId,
      );

      final data = _homeController.getUserBookingQrCodeModel.data;
      final paymentStatus = data?.paymentStatus?.toLowerCase();
      final orderStatus = data?.orderStatus?.toLowerCase();

      // Connect socket to listen for booking_confirmed while appointment is pending.
      if (orderStatus == 'pending') {
        _homeController.ensureBookingConfirmedSocket(
          appointmentId: widget.appointmentId,
        );
      }

      _homeController.doClearCart(
        callback: () {
          // stylistId.value = "";
          // stylistId.notifyListeners();
          // _homeController.doGetCart();
        },
      );
      if (paymentStatus == 'paid') {
        await SharedPrefs.remove(PrefConstants.resumePayBillAppointmentId);
        // _homeController.doClearCart(
        //   callback: () {
        //     stylistId.value = "";
        //     stylistId.notifyListeners();
        //     _homeController.doGetCart();
        //   },
        // );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("SHOW PROGRESS: ${_homeController.showProgress}");
    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      body: SafeArea(
          //top:false,
          child: Obx(() {
        if (_homeController.showProgress) {
          return const ProgressBarView();
        }

        final data = _homeController.getUserBookingQrCodeModel.data;
        final paymentStatus = (data?.paymentStatus ?? "").toLowerCase();
        final orderStatus = (data?.orderStatus ?? "").toLowerCase();

        final canCancel = paymentStatus == "pending" &&
            (orderStatus == "pending" || orderStatus == "confirmed");

        return Stack(children: [
          GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).unfocus(); // 👈 closes keyboard
              },
              child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.black),
                              onPressed: () async {
                                final navigator = Navigator.of(context);
                                await SharedPrefs.remove(
                                    PrefConstants.resumePayBillAppointmentId);
                                if (!mounted) return;
                                if (widget.isBooking) {
                                  Get.offAll(() => const BottomNavBarPage());
                                } else if (navigator.canPop()) {
                                  navigator.pop(true);
                                } else {
                                  Get.offAll(() => const BottomNavBarPage());
                                }
                              },
                            ),
                          ),

                          bookingStatusWidget(data?.orderStatus ?? "pending"),

                          // TODO: remove after debugging
                          if (kDebugMode)
                            GestureDetector(
                              onTap: () => _homeController.debugSocketState(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text('[ tap to print socket state ]',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                              ),
                            ),

                          const SizedBox(height: 15),

                          /// SALON NAME
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              data?.salon?.displayName ?? "",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Outfit'),
                            ),
                          ),

                          const SizedBox(height: 5),
                          const Divider(),

                          /// DATE + TIME
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Date",
                                    //style: TextStyle(color: Colors.grey),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Outfit',
                                        color: Colors.grey),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    getBookingDate(data),
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Outfit'),
                                  ),
                                ],
                              ),
                              Flexible(
                                // 👈 wrap in Flexible
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .end, // 👈 align to right
                                  children: [
                                    const Text(
                                      "Time Slot",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Outfit',
                                          color: Colors.grey),
                                    ),
                                    const SizedBox(height: 5),
                                    buildSlotSection(data),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 15),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// LEFT → STAFF NAME (UNCHANGED)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          "Staff Name",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Outfit',
                                              color: Colors.grey),
                                        ),
                                        const SizedBox(width: 6),
                                        Tooltip(
                                          message:
                                              "Staff may change based on availability",
                                          triggerMode: TooltipTriggerMode.tap,
                                          showDuration:
                                              const Duration(seconds: 3),
                                          child: const Icon(
                                            Icons.info_outline,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    buildStylistSection(
                                        data), // 🔥 same as your code
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              /// RIGHT → SALON CONTACT
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Salon Contact",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Outfit',
                                        color: Colors.grey),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    data?.salon?.mobile ?? "",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Outfit'),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const Divider(height: 15),

                          /// ADDRESS
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Address",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Outfit',
                                      color: Colors.grey),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  data?.salon?.address ?? "",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Outfit'),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// ENTER AMOUNT
                          // Center(
                          //   child: SizedBox(
                          //       width: 246,
                          //       child: TextField(
                          //         controller: _amountController,
                          //         textAlign: TextAlign.center,
                          //         keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          //         decoration: InputDecoration(
                          //           hintText: "Enter The Amount",
                          //           hintStyle: const TextStyle(
                          //             fontFamily: "Outfit",
                          //             fontWeight: FontWeight.w800,
                          //             fontSize: 28,
                          //             color: Colors.black38,
                          //           ),
                          //           enabledBorder: const UnderlineInputBorder(
                          //             borderSide: BorderSide(
                          //               color: Colors.black,
                          //               width: 1.5,
                          //             ),
                          //           ),
                          //           focusedBorder: const UnderlineInputBorder(
                          //             borderSide: BorderSide(
                          //               color: Colors.black,
                          //               width: 1.5,
                          //             ),
                          //           ),
                          //           contentPadding: const EdgeInsets.only(bottom: 8),
                          //         ),
                          //       )
                          //   ),
                          // ),

                          Center(
                            child: SizedBox(
                              width: 246,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    focusNode: _amountFocus,
                                    controller: _amountController,
                                    textAlign: TextAlign.center,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    style: const TextStyle(
                                      // 🔥 this is for entered text
                                      fontFamily: "Outfit",
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          28, // match hint or adjust as needed
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      //hintText: "Enter The Amount",
                                      hintText: "Enter Actual Bill",
                                      hintStyle: const TextStyle(
                                        fontFamily: "Outfit",
                                        fontWeight: FontWeight.w800,
                                        fontSize: 28,
                                        color: Colors.black38,
                                      ),
                                      border: InputBorder
                                          .none, // remove default underline
                                      contentPadding:
                                          const EdgeInsets.only(bottom: 8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    width: 200, // 👈 underline width
                                    height: 1.5,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// PAY NOW BUTTON
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConstant.primaryColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              final enteredAmount = double.tryParse(
                                      _amountController.text.trim()) ??
                                  0;

                              if (enteredAmount <= 0) {
                                SnackbarUtil.show(
                                  "Enter Amount",
                                  "Please enter the amount first",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              print(data?.bookingId);
                              print('*******************');

                              _showServiceConfirmation(
                                  data?.bookingId, data?.salon?.id ?? "");
                            },
                            child: const Text(
                              //"Pay Now",
                              "Apply Discount",
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),

                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: "(Enter the Actual Bill, Discount will be Auto Applied)",
                                  style: TextStyle(
                                    color: ColorConstant.primaryColor,
                                    fontSize: 14,
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: "* ",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: "Provided By Manager at Salon",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          /// NOTE BOX
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: ColorConstant.primaryColor,
                                width: 1.5,
                              ),
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  height: 1.4,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Note : You Can ",
                                  ),
                                  TextSpan(
                                    text: "Add/ Remove",
                                    style: TextStyle(color: Colors.red), // 🔴 highlight
                                  ),
                                  TextSpan(
                                    text:
                                    " Services At The Salon, You don't have to Book a new Appointment And Pay In The App to Avail Your Discount",
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 13),

                          /// CANCEL BUTTON
                          if (canCancel) ...[
                            SizedBox(
                              width: 160,
                              height: 40,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF96B5C),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  _showCancelConfirmationDialog();
                                },
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),

                          /// BOOKING ID

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Booking Id : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorConstant.blackColor,
                                ),
                              ),
                              Text(
                                data?.idx ?? "",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorConstant.primaryColor,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ))),
        ]);
      })),
    );
  }

  Future<void> callSupport() async {
    final Uri url = Uri.parse("tel:9347882037");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  String getBookingDate(data) {
    final isPending = (data?.orderStatus ?? "").toLowerCase() == "pending";
    final isRejected =
        (data?.orderStatus ?? "").toLowerCase() == "salon_rejected";

    if (isPending || isRejected) {
      final slots = data?.selectedSlots ?? []; // ✅ FIXED

      if (slots.isNotEmpty) {
        return convertFinalDate(date: slots.first);
      }

      return "To be confirmed";
    }

    if (data?.startsAt != null && data!.startsAt!.isNotEmpty) {
      return convertFinalDate(date: data.startsAt!);
    }

    return "-";
  }

  Widget buildSlotSection(data) {
    final isPending = (data?.orderStatus ?? "").toLowerCase() == "pending";
    final isRejected =
        (data?.orderStatus ?? "").toLowerCase() == "salon_rejected";

    // if (isPending || isRejected) {
    //   return const Text(
    //     "To be confirmed",
    //     style: TextStyle(
    //         fontSize: 15,
    //         fontWeight: FontWeight.w500,
    //         fontFamily: 'Outfit'
    //     ),
    //   );
    // }
    if (isPending || isRejected) {
      return ShineWrapper(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Text(
            "To be confirmed",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: 'Outfit',
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // confirmed → show startsAt as chip
    return ShineWrapper(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0AB6CD),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          convertDate(date: data?.startsAt ?? ""),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "Outfit",
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget buildStylistSection(data) {
    final isPending = (data?.orderStatus ?? "").toLowerCase() == "pending";

    //if (isPending) {
    final stylists = data?.selectedStylists ?? [];

    if (stylists.isEmpty) {
      return ShineWrapper(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Text(
            "Not Specified",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: 'Outfit',
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8, // horizontal gap between chips
      runSpacing: 6, // vertical gap if wraps to next line
      children: stylists.map<Widget>((s) {
        return ShineWrapper(
          // ← ShineWrapper outside Container
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0AB6CD),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              s.name ?? "",
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "Outfit",
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> openWhatsapp() async {
    final Uri url = Uri.parse("https://wa.me/919347882037");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _startPayment() {
    final amount =
        (_homeController.getUserBookingQrCodeModel.data?.orderAmount ?? 0) *
            100;

    final options = {
      'key': _homeController.getOrderIdModel.data?.razorpayKey ?? "",
      'amount': amount.toInt(),
      'name': 'Scuts',
      'order_id': _homeController.getOrderIdModel.data?.orderId ?? "",
    };

    razorpay.open(options);
  }

  bool isNightTime() {
    final now = DateTime.now();
    final hour = now.hour;

    return hour >= 21 || hour < 10; // 9 PM to 10 AM
  }

  Widget bookingStatusWidget(String status) {
    if (status == "confirmed") {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/gifs/verified.gif",
            height: 100,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              "Your Booking Is Confirmed\n(Happy Service)",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Outfit",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
                color: Color(0xFF2AA92C),
                // color: changeTheme(
                //     SharedPrefs.readStringValue(PrefConstants.gender)),
              ),
            ),
          )
        ],
      );
    }

    if (status == "salon_rejected") {
      final data = _homeController.getUserBookingQrCodeModel.data;
      return Row(
        children: [
          Image.asset(
            "assets/gifs/rejected.gif",
            height: 100,
          ),
          const SizedBox(width: 5),
          // Center(
          //   child: Text(
          //     "Salon has rejected booking",
          //     textAlign: TextAlign.center,
          //     style: TextStyle(
          //       fontFamily: "Outfit",
          //       fontSize: 20,
          //       fontWeight: FontWeight.w700,
          //       letterSpacing: 0.1,
          //       color: changeTheme(
          //           SharedPrefs.readStringValue(PrefConstants.gender)),
          //     ),
          //   ),
          //
          // )
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Salon has rejected booking",
                  style: TextStyle(
                    fontFamily: "Outfit",
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                  ),
                ),
                if (data?.rejectionDisplayReason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    "(Reason : ${(data!.rejectionDisplayReason ?? "").split(":").last.trim()})",
                    style: const TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    /// DEFAULT → Pending
    final night = isNightTime();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          "assets/gifs/hourglass.gif",
          //height: 100,
          height: MediaQuery.of(context).size.width * 0.22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontFamily: "Outfit",
                color: changeTheme(
                  SharedPrefs.readStringValue(PrefConstants.gender),
                ),
              ),
              children: [
                TextSpan(
                  text: night
                      ? "Salon is closed right now\n"
                      : "Waiting For Confirmation\n",
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: night
                      ? "Appointment will be confirmed\nOnce the Salon opens"
                      : "(will take 10 - 15 mins)",
                  style: const TextStyle(
                    fontSize: 15, // 👈 smaller font
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            width: 382,
            height: 193,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)) ??
                    Colors.transparent,
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// TITLE
                  const Text(
                    "Are You Sure You Want To Cancel ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// NO / YES BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// NO
                      SizedBox(
                        height: 27,
                        width: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero, // important to fit text
                            backgroundColor: changeTheme(
                                    SharedPrefs.readStringValue(
                                        PrefConstants.gender)) ??
                                Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "No",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // slightly reduced to fit
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      /// YES
                      SizedBox(
                        height: 27,
                        width: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero, // important
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            _showCancelReasonDialog();

                            // /// SHOW LOADER
                            // Get.dialog(
                            //   const Center(child: CircularProgressIndicator()),
                            //   barrierDismissible: false,
                            // );
                            //
                            // try {
                            //   final bookingId =
                            //       _homeController.getUserBookingQrCodeModel.data?.idx ?? "";
                            //
                            //   final artistId =
                            //       _homeController.getUserBookingQrCodeModel.data?.appointment?.artist?.id ?? "";
                            //
                            //   final response = await _homeController.cancelBooking(
                            //     bookingId: bookingId,
                            //     //artistId: artistId,
                            //     status: "user_cancelled",
                            //   );
                            //
                            //   if (Get.isDialogOpen ?? false) {
                            //     Navigator.of(context).maybePop();
                            //   }
                            //
                            //   if (response.success) {
                            //     _homeController.getUserBookingQrCodeModel
                            //         .data?.orderStatus = "user_cancelled";
                            //     _homeController.doGetCurrentBookingListData();
                            //
                            //     Get.back(result: true);
                            //
                            //     SnackbarUtil.show(
                            //       "Success",
                            //       "Your booking has been cancelled successfully",
                            //       backgroundColor: Colors.green,
                            //       colorText: Colors.white,
                            //       snackPosition: SnackPosition.BOTTOM,
                            //     );
                            //   } else {
                            //     SnackbarUtil.show(
                            //       "Failed",
                            //       response.message ?? "Something went wrong.",
                            //       backgroundColor: Colors.red,
                            //       colorText: Colors.white,
                            //       snackPosition: SnackPosition.BOTTOM,
                            //     );
                            //   }
                            // } catch (e) {
                            //   if (Get.isDialogOpen ?? false) {
                            //     Navigator.of(context).maybePop();
                            //   }
                            //
                            //   SnackbarUtil.show(
                            //     "Error",
                            //     "Something went wrong: ${e.toString()}",
                            //     backgroundColor: Colors.red,
                            //     colorText: Colors.white,
                            //     snackPosition: SnackPosition.BOTTOM,
                            //   );
                            // }
                          },
                          child: const Text(
                            "Yes",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  /// RESCHEDULE TEXT
                  const Text(
                    "Looking For Rescheduling?",
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),

                  const SizedBox(height: 9),

                  /// CONTACT BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        height: 34,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            callSupport();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.phone, size: 18),
                              SizedBox(
                                  width:
                                      2), // 🔥 control spacing here (reduce/increase)
                              Text(
                                "Contact Us",
                                style: TextStyle(
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      SizedBox(
                        width: 90,
                        height: 34,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero, // important
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            openWhatsapp();
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: Colors.white, // Official WhatsApp Green
                            size: 18,
                          ),
                          label: const Text(
                            "Text Us",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCancelReasonDialog() async {
    List reasons = [];

    try {
      reasons = await HomeAPI.getCancellationReasons();
    } catch (e) {
      SnackbarUtil.show("Error", "Failed to load reasons");
      return;
    }

    String? selectedReasonId;
    String? selectedReasonCode;
    final TextEditingController remarkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  color: ColorConstant.whiteColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ColorConstant.primaryColor2,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Reason For Cancellation',
                        textAlign: TextAlign.center,
                        style: AppTextTheme.bold.copyWith(
                          color: ColorConstant.primaryColor2,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...reasons.map<Widget>((dynamic r) {
                      final idStr = r['id'].toString();
                      final code = (r['code'] ?? '').toString();
                      final label = (r['label'] ?? '').toString();

                      if (code == 'OTHER') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              _CancelRadioCircle(
                                selected: selectedReasonId == idStr,
                                onTap: () => setStateDialog(() {
                                  selectedReasonId = idStr;
                                  selectedReasonCode = code;
                                }),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setStateDialog(() {
                                    selectedReasonId = idStr;
                                    selectedReasonCode = code;
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ColorConstant.grayColor
                                          .withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: selectedReasonId == idStr
                                        ? TextField(
                                            controller: remarkController,
                                            autofocus: true,
                                            onChanged: (_) =>
                                                setStateDialog(() {}),
                                            style:
                                                AppTextTheme.semibold.copyWith(
                                              color: ColorConstant.blackColor,
                                              fontSize: 14,
                                            ),
                                            decoration:
                                                InputDecoration.collapsed(
                                              hintText:
                                                  'Write Your Own Remarks',
                                              hintStyle: AppTextTheme.semibold
                                                  .copyWith(
                                                color:
                                                    ColorConstant.grayTextColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            remarkController.text.isEmpty
                                                ? 'Write Your Own Remarks'
                                                : remarkController.text,
                                            style:
                                                AppTextTheme.semibold.copyWith(
                                              color:
                                                  ColorConstant.grayTextColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return _CancelRadioOption(
                        label: label,
                        selected: selectedReasonId == idStr,
                        onTap: () => setStateDialog(() {
                          selectedReasonId = idStr;
                          selectedReasonCode = code;
                        }),
                      );
                    }),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedReasonId == null) {
                            SnackbarUtil.show(
                              "Select Reason",
                              "Please select a reason",
                            );
                            return;
                          }

                          Navigator.pop(context);

                          Get.dialog(
                            const Center(child: CircularProgressIndicator()),
                            barrierDismissible: false,
                          );

                          try {
                            final bookingId = _homeController
                                    .getUserBookingQrCodeModel.data?.idx ??
                                "";

                            final response =
                                await _homeController.cancelBooking(
                              bookingId: bookingId,
                              status: "user_cancelled",
                              cancellationReasonId: selectedReasonId!,
                              cancellationRemark: selectedReasonCode == "OTHER"
                                  ? remarkController.text
                                  : null,
                            );

                            if (Get.isDialogOpen ?? false) {
                              //Navigator.of(context).maybePop();
                              Get.back();
                            }

                            if (response.success) {
                              // 📊 booking_cancelled
                              try {
                                final qrData = _homeController
                                    .getUserBookingQrCodeModel.data;
                                int minutesBefore = 0;
                                if (qrData?.startsAt != null) {
                                  minutesBefore =
                                      DateTime.parse(qrData!.startsAt!)
                                          .difference(DateTime.now())
                                          .inMinutes;
                                }
                                AnalyticsService.instance.logBookingCancelled(
                                  bookingId: bookingId,
                                  reason: selectedReasonCode ?? '',
                                  timeBeforeSlotMinutes: minutesBefore,
                                );
                                Get.snackbar(
                                  "Success",
                                  "Booking cancelled successfully",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              } catch (_) {}

                              //Get.back(result: true);
                              // Get.off(() => BottomNavBarPage());

                              SnackbarUtil.show(
                                "Success",
                                "Booking cancelled successfully",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );

                              await SharedPrefs.remove(
                                PrefConstants.resumePayBillAppointmentId,
                              );
                              Get.offAll(() => const BottomNavBarPage());
                              Future.microtask(
                                () => _homeController
                                    .doGetCurrentBookingListData(),
                              );
                            }
                          } catch (e) {
                            if (Get.isDialogOpen ?? false) {
                              //Navigator.of(context).maybePop();
                              Get.back();
                            }
                            Get.off(() => BottomNavBarPage());

                            SnackbarUtil.show(
                              "Error",
                              e.toString(),
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstant.primaryColor2,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Confirm',
                          style: AppTextTheme.bold.copyWith(
                            color: ColorConstant.whiteColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => remarkController.dispose());
  }

  void _showServiceConfirmation(String? bookingId, String salonId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54, // fades background
      builder: (context) {
        return Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 25,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: ColorConstant.primaryColor,
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// QUESTION
                  const Text(
                    "Have You Completed Your Service ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Outfit",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// NO BUTTON
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Text(
                            "No",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      /// YES BUTTON
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstant.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);

                          await _homeController.doGetSalonPromoCode(
                            salonId: salonId,
                          );
                          //await _homeController.doGetListPromoCode();
                          //await _homeController.doGetOrderId();

                          final enteredAmount =
                              double.tryParse(_amountController.text.trim()) ??
                                  0;

                          if (enteredAmount <= 0) {
                            SnackbarUtil.show(
                                "Invalid Amount", "Please enter amount");
                            return;
                          }
                          final result = _homeController
                              .getBestDiscount(enteredAmount.toInt());

                          if (result != null) {
                            int discount = result["discount"];

                            int finalAmount = enteredAmount.toInt() - discount;
                            String promoName = result["promo"].title ?? "";

                            _showPaymentSummaryDialog(
                                bookingId: bookingId,
                                actualAmount: enteredAmount.toInt(),
                                discount: discount,
                                finalAmount: finalAmount,
                                promoName: promoName);
                          } else {
                            _showPaymentSummaryDialog(
                                bookingId: bookingId,
                                actualAmount: enteredAmount.toInt(),
                                discount: 0,
                                finalAmount: enteredAmount.toInt(),
                                promoName: "NA");
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Text(
                            "Yes",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentSummaryDialog(
      {String? bookingId,
      required int actualAmount,
      required int discount,
      required int finalAmount,
      required String promoName}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) {
        bool showBreakdown = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {

            return Center(
                child: Stack(alignment: Alignment.center, children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  /// MAIN DIALOG
                  Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: ColorConstant.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// ACTUAL AMOUNT
                          const Text(
                            "Actual Amount",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                "₹$actualAmount",
                                style: const TextStyle(
                                  fontSize: 44,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 2.5,
                                  color: changeTheme(
                                    SharedPrefs.readStringValue(
                                        PrefConstants.gender),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// YOU PAY
                          Text(
                            "You Pay",
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Outfit',
                              color: changeTheme(SharedPrefs.readStringValue(
                                  PrefConstants.gender)),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "₹${finalAmount + 5}",
                            style: const TextStyle(
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Outfit',
                              color: Colors.green,
                            ),
                          ),

                          //const SizedBox(height: 10),

                          Container(
                            width: 120,
                            height: 1,
                            color: Colors.black,
                          ),

                          const SizedBox(height: 15),

                          /// EDIT PRICE
                          SizedBox(
                            width: 127,
                            height: 42,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: changeTheme(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.gender))
                                    ?.withOpacity(0.7),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10), // updated
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Edit Price",
                                style: TextStyle(
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w600, // semi-bold
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          /// VIEW BREAKDOWN
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                )
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                /// HEADER
                                InkWell(
                                  onTap: () {
                                    setStateDialog(() {
                                      showBreakdown = !showBreakdown;
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "View Breakdown",
                                          style: TextStyle(
                                              fontFamily: "Outfit",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        AnimatedRotation(
                                          turns: showBreakdown ? 0.5 : 0,
                                          duration:
                                              const Duration(milliseconds: 250),
                                          child: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: changeTheme(
                                                SharedPrefs.readStringValue(
                                                    PrefConstants.gender)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                /// BREAKDOWN CONTENT
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: showBreakdown
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12),
                                          child: Column(
                                            children: [
                                              _row("Actual Amount",
                                                  "₹$actualAmount"),

                                              _row(
                                                "Discount",
                                                "-₹$discount",
                                                color: Colors.green,
                                              ),

                                              //_row("($promoName Applied)", ""),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "($promoName Applied)",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              _row("Platform Fee", "+₹5"),

                                              const Divider(),

                                              _row(
                                                "You Pay",
                                                "₹${actualAmount - discount + 5}",
                                                isBold: true,
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// PROCEED TO PAY
                          SizedBox(
                            width: 289,
                            height: 43,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size
                                    .zero, // overrides the previous infinity size
                                backgroundColor: changeTheme(
                                    SharedPrefs.readStringValue(
                                        PrefConstants.gender)),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10), // updated
                                ),
                              ),
                              onPressed: () async {
                                Navigator.pop(context);

                                final payable = finalAmount + 5;

                                print(bookingId);
                                print('_____________________');

                                await _homeController.createPaymentOrder(
                                  bookingOrderId: bookingId,
                                  billAmount: actualAmount,
                                  payableAmount: payable,
                                );

                                openRazorpay(payable);
                              },
                              child: const Text(
                                "Proceed To Pay",
                                style: TextStyle(
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ]));
          },
        );
      },
    );
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final paidAmount = double.tryParse(_amountController.text.trim()) ?? 0;
    final bookingId = _homeController.getUserBookingQrCodeModel.data?.idx ?? "";
    final salonId =
        _homeController.getUserBookingQrCodeModel.data?.salon?.id ?? "";

    // 📊 book_and_pay_after_service
    AnalyticsService.instance.logBookAndPayAfterService(
      bookingId: bookingId,
      value: paidAmount,
      salonId: salonId,
    );

    try {

      await facebookAppEvents.logPurchase(
        amount: paidAmount,
        currency: "INR",
        parameters: {
          'content_type': 'service',
          'content_category': 'salon_booking',
          'booking_id': bookingId,
          'salon_id': salonId,
        },
      );

      print("✅ FB Purchase Event Sent");

      await facebookAppEvents.flush();

    } catch (e) {
      print("❌ FB Purchase Error: $e");
    }

    await SharedPrefs.remove(PrefConstants.resumePayBillAppointmentId);
    Get.offAll(
      () => PaymentSuccessPage(
        amount: paidAmount.toInt(),
        bookingId: bookingId,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    SnackbarUtil.show(
      "Payment Failed",
      response.message ?? "Something went wrong",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("Wallet: ${response.walletName}");
  }

  Widget _row(
    String title,
    String value, {
    Color color = Colors.black,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void openRazorpay(int payableAmount) {
    print(_homeController.getOrderIdModel.data?.orderId);
    print(_homeController.getOrderIdModel.data?.razorpayKey);

    var options = {
      'key': _homeController.getOrderIdModel.data?.razorpayKey ?? "",
      'amount': payableAmount * 100,
      'name': 'ScutS',
      'timeout': 120,
      'order_id': _homeController.getOrderIdModel.data?.orderId ?? "",
      'description': 'Booking Appointment',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact':
            _authController.userResponseModel.data?.userData?.mobile ?? "",
        'email': _authController.userResponseModel.data?.userData?.email ?? "",
      },
      // 'external': {}
      'method': {'upi': true, 'card': true, 'netbanking': true, 'wallet': true},
      'external': {
        'wallets': ['paytm']
      },
      'upi': {'flow': 'intent'},
    };

    razorpay.open(options);
  }

  String convertDate({required String date}) {
    if (date.isEmpty) return "-";

    try {
      DateTime dateTime = DateTime.parse(date.replaceAll(" ", "T"));
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return "-";
    }
  }

  String convertFinalDate({required String date}) {
    if (date.isEmpty) return "-";

    try {
      DateTime dateTime = DateTime.parse(date.replaceAll(" ", "T"));
      return DateFormat('EEE, dd MMM yyyy').format(dateTime);
    } catch (e) {
      return "-";
    }
  }

  @override
  void dispose() {
    razorpay.clear();
    _homeController.unbindBookingConfirmedSocket();
    super.dispose();
  }
}

class _CancelRadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CancelRadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _CancelRadioCircle(selected: selected, onTap: onTap),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onTap,
            child: Text(
              label,
              style: AppTextTheme.medium.copyWith(
                color: ColorConstant.primaryColor2,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelRadioCircle extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _CancelRadioCircle({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? ColorConstant.primaryColor2
                : ColorConstant.grayColor,
            width: 2,
          ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: ColorConstant.primaryColor2,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class ShineWrapper extends StatefulWidget {
  final Widget child;

  const ShineWrapper({super.key, required this.child});

  @override
  State<ShineWrapper> createState() => _ShineWrapperState();
}

class _ShineWrapperState extends State<ShineWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(); // infinite loop
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            final x = _controller.value;

            return LinearGradient(
              begin: Alignment(-2 + 3 * x, -1), // ← top shifted more to left
              end: Alignment(-1.2 + 3 * x, 1), // ← bottom stays
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
