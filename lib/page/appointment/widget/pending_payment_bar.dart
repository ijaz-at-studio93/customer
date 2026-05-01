import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constant/color_constant.dart';
import '../../../project_specific/text_theme.dart';
import '../../../util/SharedPrefs.dart';
import '../../../constant/variable_constant.dart';
import '../qr_page.dart';

class PendingPaymentBar extends StatelessWidget {
  final String bookingId;
  final String salonName;
  final String? startsAt;

  const PendingPaymentBar({
    super.key,
    required this.bookingId,
    required this.salonName,
    this.startsAt
  });

  @override
  Widget build(BuildContext context) {

    final Color themeColor =
        changeTheme(SharedPrefs.readStringValue(PrefConstants.gender))
            ?? ColorConstant.primaryColor;

    return Center(
      child: GestureDetector(
        onTap: () {
          Get.to(() => QRCodePage(
            appointmentId: bookingId,
            isBooking: false,
          ));
        },
        child: Container(
          width: Get.width * 0.90,
          height: 56,
          padding: const EdgeInsets.only(left: 16, right: 3),
          decoration: BoxDecoration(
            gradient: const LinearGradient( // 🔥 ADDED GRADIENT
              colors: [
                Color(0xFF8454E5), // start
                Color(0xFFCD73B4), // end
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white, // 🔥 white border
              width: 0.5,          // adjust (1–2 based on Figma)
            ),// cylindrical
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// LEFT TEXT
              Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.event_available,
                    color: Colors.white,
                  ),

                  const SizedBox(width: 8),

                  Flexible(
                    child: AppointmentText(
                      salonName: salonName,
                      dateTime: startsAt,
                      themeColor: Colors.white,
                    )
                  ),
                ],
              )
              ),

              /// PAY BUTTON


              Container(
                width: 90,
                height: 48,

                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text(
                      "₹ Pay",
                      style: TextStyle(
                        fontFamily: "Outfit",          // ✅ Figma font
                        fontWeight: FontWeight.w600,   // ✅ SemiBold (not bold)
                        fontSize: 18,                  // ✅ balanced inside pill
                        letterSpacing: 0.3,            // ✅ slight polish
                        color: Colors.white,
                        height: 1,                     // ✅ vertical alignment
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AppointmentText extends StatefulWidget {
  final String salonName;
  final String? dateTime;
  final Color themeColor;

  const AppointmentText({
    super.key,
    required this.salonName,
    this.dateTime,
    required this.themeColor,
  });

  @override
  State<AppointmentText> createState() => _AppointmentTextState();
}

class _AppointmentTextState extends State<AppointmentText> {

  int index = 0;
  bool slideUp = false;

  late List<String> messages;

  @override
  void initState() {
    super.initState();

    // messages = [
    //   "Appointment Booked",
    //   "By ${widget.salonName}",
    //   "At ${widget.dateTime}",
    // ];

    messages = [
      "Appointment Booked",
      "${widget.salonName}",
      widget.dateTime != null && widget.dateTime!.isNotEmpty
          ? "${widget.dateTime}"
          : "Time to be confirmed",
    ];

    _startLoop();
  }

  void _startLoop() async {

    while (mounted) {

      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      setState(() {
        slideUp = true;
      });

      await Future.delayed(const Duration(milliseconds: 350));

      if (!mounted) return;

      setState(() {
        index = (index + 1) % messages.length;
        slideUp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 210,
      height: 15,
      child: ClipRect(
        child: AnimatedSlide(
          offset: slideUp ? const Offset(0, -1) : Offset.zero,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          child: Text(
            messages[index],
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: AppTextTheme.bold.copyWith(
              fontFamily: "Outfit",        // ✅ Figma font
              fontWeight: FontWeight.w800, // ✅ SemiBold (not too heavy)
              fontSize: 17,                // ✅ balanced size
              letterSpacing: 0.3,          // ✅ slight spacing like Figma
              color: widget.themeColor,
              height: 1,                   // ✅ vertical centering
            ),
          ),
        ),
      ),
    );
  }
}