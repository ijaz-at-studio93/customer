import 'package:flutter/material.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
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
    return GestureDetector(
      onTap: widget.onPress,
      child: Container(
        height: 39,
        width: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: ColorConstant.pinkBgColor,
          border: Border.all(color: widget.color),
        ),
        child: Container(
          color: Colors.transparent,
          height: 39,
          width: 110,
          child: Center(
            child: Text(
              "Add",
              style: AppTextTheme.medium
                  .copyWith(fontSize: 13, color: widget.color),
            ),
          ),
        ),
      ),
    );
  }
}
