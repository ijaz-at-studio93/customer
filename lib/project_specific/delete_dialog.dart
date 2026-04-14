import 'package:flutter/material.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

class DeleteDialog extends StatefulWidget {
  final VoidCallback noPress;
  final VoidCallback yesPress;
  const DeleteDialog(
      {super.key, required this.noPress, required this.yesPress});

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AssetsConstant.signOut,
              height: 35,
              width: 35,
              color: changeTheme(
                  SharedPrefs.readStringValue(PrefConstants.gender)),
            ),
            const SizedBox(height: 10),
            Text(
              "Are You sure want to Delete Account?",
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
