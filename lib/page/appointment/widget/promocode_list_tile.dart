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
  final bool isDayValid;
  final bool isMinOrderFail;
  final List<int>? applicableDays;
  // Row 39: category-scoped coupon.
  final bool isCategoryValid;
  final List<String>? applicableCategoryNames;


  const PromoCodeListTile(
      {super.key, this.onTapApplyBtn, required this.amount, required this.maxDiscount, required this.minOrder,
        required this.id, required this.title, required this.description, required this.image, required this.startsAt,
        required this.endsAt, required this.code, required this.type,  this.isDisabled = false, this.unlockAmount = 0,
        this.isDayValid = true, this.applicableDays,this.isMinOrderFail = false,
        this.isCategoryValid = true, this.applicableCategoryNames,});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (isDayValid && isCategoryValid) ? 1 : 0.5,
      child:
       Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: ColorConstant.primaryColor,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: type == "percentage"
                          ? Text('Flat $amount% OFF',
                          style: AppTextTheme.bold
                              .copyWith(color: ColorConstant.whiteColor,fontFamily: "Outfit", ))
                          : Text('Flat $amount OFF',
                          style: AppTextTheme.bold
                              .copyWith(color: ColorConstant.whiteColor,fontFamily: "Outfit", )),
                    ),
                    GestureDetector(
                      onTap: isDisabled ? null : onTapApplyBtn,
                      child: Container(
                        width: 100,
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? Colors.grey
                              : null,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF8454E5), // 🔥 left
                              Color(0xFFCD73B4), // 🔥 right
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isDisabled
                              ? (isMinOrderFail
                                  ? 'Locked'
                                  : !isDayValid
                                      ? 'Not Today'
                                      : 'Not applicable')
                              : 'Apply',
                          style: AppTextTheme.bold.copyWith(color: ColorConstant.whiteColor,fontFamily: "Outfit", ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF8454E5),
                          Color(0xFFCD73B4),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: Image.asset(
                        AssetsConstant.offerIcon,
                        width: 25,
                        height: 25,
                        color: Colors.white, // 👈 important
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(title,
                        style: AppTextTheme.bold.copyWith(
                            fontSize: 16,fontFamily: "Outfit",  color: ColorConstant.blackColor)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.medium.copyWith(
                    fontFamily: "Outfit",          // 👈 added
                    color: ColorConstant.blackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (applicableDays != null && applicableDays!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "Valid on ${_getDayNames(applicableDays!)}",
                      style: TextStyle(
                        color: isDayValid ? Colors.green : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),

                // Row 39: category-scoped coupon — same treatment as days.
                if (applicableCategoryNames != null &&
                    applicableCategoryNames!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "Valid for ${applicableCategoryNames!.join(", ")}",
                      style: TextStyle(
                        color: isCategoryValid ? Colors.green : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),

                if (isMinOrderFail)
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
          )
      )
    );
  }
  String _getDayNames(List<int> days) {
    const names = [
      "Sunday", "Monday", "Tuesday", "Wednesday",
      "Thursday", "Friday", "Saturday"
    ];

    return days.map((d) => names[d]).join(", ");
  }
}