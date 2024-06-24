import 'package:flutter/material.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

class HomeServiceDialog extends StatefulWidget {
  final VoidCallback noPress;
  final VoidCallback yesPress;
  const HomeServiceDialog(
      {super.key, required this.noPress, required this.yesPress});

  @override
  State<HomeServiceDialog> createState() => _HomeServiceDialogState();
}

class _HomeServiceDialogState extends State<HomeServiceDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Would You Like To Book For Home Service",
              textScaler: const TextScaler.linear(0.85),
              style: AppTextTheme.medium
                  .copyWith(color: ColorConstant.grayTextColor),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.noPress,
                  child: Text(
                    "NO",
                    textScaler: const TextScaler.linear(0.85),
                    style: AppTextTheme.medium
                        .copyWith(color: Colors.red, fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: widget.yesPress,
                  child: Text(
                    "YES",
                    textScaler: const TextScaler.linear(0.85),
                    style: AppTextTheme.medium.copyWith(
                        color: changeTheme(
                            SharedPrefs.readStringValue(PrefConstants.gender)),
                        fontSize: 16),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
