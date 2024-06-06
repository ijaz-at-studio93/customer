import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

import '../constant/color_constant.dart';

class SimpleTextFieldWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final String title;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  const SimpleTextFieldWidget(
      {super.key,
      required this.textEditingController,
      required this.hintText,
      required this.textInputType,
      required this.textInputAction,
      required this.title, this.onChanged});

  @override
  State<SimpleTextFieldWidget> createState() => _SimpleTextFieldWidgetState();
}

class _SimpleTextFieldWidgetState extends State<SimpleTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: AppTextTheme.regular
                .copyWith(fontSize: 13, color: ColorConstant.blackColor),
          ),
          const SizedBox(height: 12),
          Container(
              height: 50,
              width: Get.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorConstant.borderColor,
                ),
              ),
              child: TextField(
                onChanged: widget.onChanged,
                controller: widget.textEditingController,
                keyboardType: widget.textInputType,
                textInputAction: widget.textInputAction,
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 13),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 12),
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: AppTextTheme.medium.copyWith(
                        color: ColorConstant.grayColor, fontSize: 13)),
              )),
        ],
      ),
    );
  }
}
