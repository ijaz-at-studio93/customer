import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/variable_constant.dart';
import '../../service/analytics_service.dart';
import '../../util/SharedPrefs.dart';
import '../bottom_navigation_bar.dart';

class PaymentSuccessPage extends StatefulWidget {
  final int amount;
  final String bookingId;

  /// When true (e.g. opened from Completed Appointments to review a receipt),
  /// back returns to the previous screen instead of resetting to the home tab.
  final bool isViewOnly;

  const PaymentSuccessPage({
    super.key,
    required this.amount,
    required this.bookingId,
    this.isViewOnly = false,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logPaymentSuccessful(
      bookingId: widget.bookingId,
      value: widget.amount.toDouble(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Preload GIF
    precacheImage(
      const AssetImage("assets/gifs/payment_success.gif"),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isViewOnly) {
          Get.back();
        } else {
          Get.offAll(() => const BottomNavBarPage());
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (widget.isViewOnly) {
                Get.back();
              } else {
                Get.offAll(() => const BottomNavBarPage());
              }
            },
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [

              /// GREEN CARD
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF60F1A1).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      /// Title
                      // const Text(
                      //   "Payment Successful",
                      //   style: TextStyle(
                      //     fontFamily: "Outfit",
                      //     fontSize: 33,
                      //     fontWeight: FontWeight.bold,
                      //     color: Color(0xFF01AB4D),
                      //   ),
                      // ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text(
                          "Payment Successful",
                          style: TextStyle(
                            fontSize: 33,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF01AB4D),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// GIF
                      Image.asset(
                        "assets/gifs/payment_success.gif",
                        width: 180,
                        height: 180,
                        gaplessPlayback: true,
                      ),

                      //const SizedBox(height: 20),

                      /// Amount (auto-scales down so large values don't overflow)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          //"₹${widget.amount}/-",
                          "₹${widget.amount}",
                          maxLines: 1,
                          style: const TextStyle(
                            fontFamily: "Outfit",
                            fontSize: 90,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// Message
                      const Text(
                        "Thank You For Choosing Us ❤️\n"
                            "We Take Extreme Pleasure In Serving You "
                            "& Hoping to \nSee You Again Soon",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 18,
                          letterSpacing: 0.02,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 25),
                      const Text(
                        "* Show this to Salon Manager",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontSize: 16,
                          letterSpacing: 0.02,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}