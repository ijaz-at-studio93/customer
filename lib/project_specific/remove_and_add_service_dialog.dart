import 'package:flutter/material.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

class RemoveAndAddServiceDialog extends StatefulWidget {
  final VoidCallback noPress;
  final VoidCallback yesPress;
  final String? descriptionText;
  final String? salonName;
  const RemoveAndAddServiceDialog(
      {super.key,
      required this.noPress,
      required this.yesPress,
      this.descriptionText = "Are You Sure You Want a Clear Your Cart",
      this.salonName});

  @override
  State<RemoveAndAddServiceDialog> createState() =>
      _RemoveAndAddServiceDialogState();
}

class _RemoveAndAddServiceDialogState extends State<RemoveAndAddServiceDialog> {
  @override
  Widget build(BuildContext context) {
    print(widget.salonName);
    print('&&&&&&&&&&&&');
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(10),
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
              style:
                  AppTextTheme.bold.copyWith(color: ColorConstant.blackColor),
            ),
            const SizedBox(height: 10),
            Text(
              "${widget.descriptionText} ${widget.salonName ?? ""}" ?? "",
              textScaler: const TextScaler.linear(0.90),
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
