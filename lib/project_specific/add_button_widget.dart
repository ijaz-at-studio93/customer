import 'package:flutter/material.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

import '../constant/color_constant.dart';

class AddButtonWidget extends StatefulWidget {
  final VoidCallback onPress;
  final  Color  color;
  const AddButtonWidget({super.key, required this.onPress, required this.color});

  @override
  State<AddButtonWidget> createState() => _AddButtonWidgetState();
}

class _AddButtonWidgetState extends State<AddButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPress,
      child: Container(
        width: 70,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: ColorConstant.pinkBgColor,
          border: Border.all(color: widget.color),
        ),
        child: Center(
          child: Text(
            "Add",
            style: AppTextTheme.medium
                .copyWith(fontSize: 13, color: widget.color),
          ),
        ),
      ),
    );
  }
}
