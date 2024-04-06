import 'package:sallon_customer/constant/color_constant.dart';
import 'package:flutter/material.dart';

class ProgressBarView extends StatelessWidget {
  const ProgressBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: const BoxDecoration(
            color: ColorConstant.primaryColor, shape: BoxShape.circle),
        padding: const EdgeInsets.all(10),
        height: 50,
        width: 50,
        child: const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
