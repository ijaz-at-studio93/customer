import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';

class PersonOfTheYearPage extends StatefulWidget {
  final String salonAppointmentId;

  const PersonOfTheYearPage({
    super.key,
    required this.salonAppointmentId,
  });

  @override
  State<PersonOfTheYearPage> createState() => _PersonOfTheYearPageState();
}

class _PersonOfTheYearPageState extends State<PersonOfTheYearPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 👈 IMPORTANT
      body: Stack(
        children: [

          /// 🔹 GIF Background
          Positioned.fill(
            child: Image.asset(
              'assets/gifs/person_of_year.gif',
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Dark overlay (important for readability)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          /// 🔹 Foreground Content
          SafeArea(
            bottom: false, // 👈 REMOVE bottom safe space
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
              constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    const SizedBox(height: 40),

                    /// Attention badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Attention!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Nominate Your Person\nof the Year",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Someone stood by you throughout 2025, "
                          "through every high, low, and everything in between.\n"
                          "Tell us who that person is, and we’ll send them a "
                          "special gift from Scuts.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "How it works",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _showHowItWorksPopup(context),
                          child: const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: ColorConstant.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    /// Phone Input
                    SizedBox(
                      width: 220, // 👈 adjust (240–280 works well)
                      child: _inputField(
                        controller: phoneController,
                        hint: "Phone Number",
                        keyboardType: TextInputType.phone,
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// Name Input
                    SizedBox(
                      width: 160,
                      child: _inputField(
                        controller: nameController,
                        hint: "Name",
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Submit
                    SizedBox(
                      width: 260,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstant.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submitNomination,
                        child: const Text(
                          "Submit Nomination",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Skip
                    TextButton(
                      onPressed: () => Get.back(result: null),
                      child: const Text(
                        "Skip for now",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _submitNomination() {
    final phone = phoneController.text.trim();
    final name = nameController.text.trim();

    if (phone.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    Get.back(result: {
      'name': name,
      'phone': phone,
    });
  }

  void _showHowItWorksPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7, // 👈 bigger
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.96), // 👈 soft white
                borderRadius: BorderRadius.circular(20), // 👈 rounder
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.5,
                    color: ColorConstant.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                  children: const [
                    TextSpan(
                      text:
                      "When you Book \nan Appointment in the Scuts, "
                          "\nHalf of the order value(upto 750)\n of your cart will be given as an "
                          "\nexclusive coupon for your ",
                    ),
                    TextSpan(
                      text: "Person of the Year",
                      style: TextStyle(
                        color: Colors.red, // 👈 RED ONLY HERE
                      ),
                    ),
                    TextSpan(
                      text:
                      " which they can Redeem on Any Service at Any of Our Partnered Salons "
                          "When they Book their Appointment using Scuts",
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
