import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/color_constant.dart';

class NoItemsWidget extends StatelessWidget {
  final String? text;
  const NoItemsWidget({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: Get.width,
        height: Get.height * 0.2,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_people_outlined,
                  size: 40, color: ColorConstant.primaryColor),
              const SizedBox(height: 12),
              Text(text ?? 'No Data Found',
                  style: Get.textTheme.titleMedium!.copyWith(
                      color: Colors.black, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
