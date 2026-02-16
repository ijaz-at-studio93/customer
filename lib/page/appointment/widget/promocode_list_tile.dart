import 'package:flutter/material.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import '../../../constant/assetsconstant.dart';

class PromoCodeListTile extends StatelessWidget {
  final VoidCallback? onTapApplyBtn;


  final  num amount;
  final  String maxDiscount;
  final int minOrder;
  final String id;
  final String title;
  final String description;
  final String image;
  final String startsAt;
  final String endsAt;
  final String code;
  final String type;
  final bool isDisabled;
  final int unlockAmount;


  const PromoCodeListTile(
      {super.key, this.onTapApplyBtn, required this.amount, required this.maxDiscount, required this.minOrder, required this.id, required this.title, required this.description, required this.image, required this.startsAt, required this.endsAt, required this.code, required this.type,  this.isDisabled = false, this.unlockAmount = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ColorConstant.primaryColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: type == "percentage"
                        ? Text('Flat $amount% OFF',
                            style: AppTextTheme.bold
                                .copyWith(color: ColorConstant.whiteColor))
                        : Text('Flat $amount OFF',
                            style: AppTextTheme.bold
                                .copyWith(color: ColorConstant.whiteColor)),
                  ),
                  // GestureDetector(
                  //   onTap: onTapApplyBtn,
                  //   child: Container(
                  //     padding:  EdgeInsets.all(8),
                  //     decoration: BoxDecoration(
                  //       color: changeTheme(SharedPrefs.readStringValue(
                  //           PrefConstants.gender)) ??
                  //           ColorConstant.primaryColor,
                  //       borderRadius: BorderRadius.circular(5),
                  //     ),
                  //     child: Text('APPLY',
                  //         style: AppTextTheme.bold
                  //             .copyWith(color: ColorConstant.whiteColor)),
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: isDisabled ? null : onTapApplyBtn,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDisabled
                            ? Colors.grey
                            : changeTheme(SharedPrefs.readStringValue(
                            PrefConstants.gender)) ??
                            ColorConstant.primaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        isDisabled ? 'LOCKED' : 'APPLY',
                        style: AppTextTheme.bold.copyWith(color: ColorConstant.whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Image.asset(
                    AssetsConstant.offerIcon,
                    width: 25,
                    height: 25,
                    color: changeTheme(SharedPrefs.readStringValue(
                        PrefConstants.gender)) ??
                        ColorConstant.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Text(title,
                      style: AppTextTheme.bold.copyWith(
                          fontSize: 16, color: ColorConstant.blackColor)),
                ],
              ),
              const SizedBox(height: 10),
              Text(description,
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.medium
                      .copyWith(color: ColorConstant.blackColor)),

              if (isDisabled)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    "Add services worth ₹$unlockAmount to unlock this offer",
                    style: AppTextTheme.medium.copyWith(color: Colors.red),
                  ),
                )
              // else
              //   Padding(
              //     padding: const EdgeInsets.only(top: 6),
              //     child: Text(
              //       "You are eligible 🎉",
              //       style: AppTextTheme.medium.copyWith(color: Colors.green),
              //     ),
              //   ),

              // const SizedBox(height: 10),
              // Text(
              //   code,
              //   textScaler: const TextScaler.linear(0.85),
              //   style: AppTextTheme.bold
              //       .copyWith(color: changeTheme(SharedPrefs.readStringValue(
              //       PrefConstants.gender)) ??
              //       ColorConstant.primaryColor),
              // ),
            ],
          ),
        ));
  }
}
