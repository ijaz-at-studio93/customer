import 'package:flutter/material.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

class RemoveAndAddServiceDialog extends StatefulWidget {
  final VoidCallback noPress;
  final VoidCallback yesPress;
  const RemoveAndAddServiceDialog(
      {super.key, required this.noPress, required this.yesPress});

  @override
  State<RemoveAndAddServiceDialog> createState() =>
      _RemoveAndAddServiceDialogState();
}

class _RemoveAndAddServiceDialogState extends State<RemoveAndAddServiceDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete,
              color: ColorConstant.redBgColor,
              size: 35,
            ),
            const SizedBox(height: 10),
            Text(
              "Are You sure?",
              style: AppTextTheme.medium
                  .copyWith(color: ColorConstant.grayTextColor),
            ),
            const SizedBox(height: 10),
            Text(
              "Please Remove Previous Select Service",
              style: AppTextTheme.medium
                  .copyWith(color: ColorConstant.grayTextColor, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.noPress,
                  child: Text(
                    "NO",
                    style: AppTextTheme.medium
                        .copyWith(color: Colors.red, fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: widget.yesPress,
                  child: Text(
                    "YES",
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
