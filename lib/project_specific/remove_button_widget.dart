import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import '../constant/color_constant.dart';

class RemoveButtonWidget extends StatefulWidget {
  final VoidCallback onPress;
  final bool isRemoveIcon;
  const RemoveButtonWidget(
      {super.key, required this.onPress, this.isRemoveIcon = false});

  @override
  State<RemoveButtonWidget> createState() => _RemoveButtonWidgetState();
}

class _RemoveButtonWidgetState extends State<RemoveButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPress,
      child: Container(
        height: 39,
        width: 110,
        decoration: BoxDecoration(
          color: ColorConstant.removeBgStroke,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: ColorConstant.removeStroke),
        ),
        child: widget.isRemoveIcon
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Remove",
                    style: AppTextTheme.medium.copyWith(
                        fontSize: 13, color: ColorConstant.removeStroke),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    CupertinoIcons.minus_circle_fill,
                    color: ColorConstant.removeStroke,
                    size: 20,
                  )
                ],
              )
            : Container(
              color: Colors.transparent,
              height: 39,
              width: 110,
              child: Center(
                child: Text(
                  'Remove',
                  style: AppTextTheme.medium.copyWith(
                      fontSize: 13, color: ColorConstant.removeStroke),
                ),
              ),
            ),
      ),
    );
  }
}
