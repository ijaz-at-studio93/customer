import 'package:flutter/material.dart';
import 'package:salon_customer/project_specific/text_theme.dart';

import '../constant/color_constant.dart';

class EditProductButtonWidget extends StatefulWidget {
  final  VoidCallback  onTap;
  const EditProductButtonWidget({super.key, required this.onTap});

  @override
  State<EditProductButtonWidget> createState() => _EditProductButtonWidgetState();
}

class _EditProductButtonWidgetState extends State<EditProductButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        height: 39,
        width: 110,
        decoration: BoxDecoration(
            border: Border.all(color: ColorConstant.editProduct),
            color: ColorConstant.editBgProduct,
            borderRadius: BorderRadius.circular(5)),
        child: Center(
            child: Text(
              'Edit Product',
              style: AppTextTheme.medium.copyWith(
                  fontSize: 13, color: ColorConstant.blackColor),
            )),
      ),
    );
  }
}
