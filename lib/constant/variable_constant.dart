import 'package:flutter/material.dart';
import 'package:sallon_customer/constant/color_constant.dart';

const double fixPadding = 10.0;

const SizedBox heightSpace = SizedBox(height: fixPadding);

/*----------- dynamic Color Change ------------*/
Color? changeTheme(String data) {
  if (data.isEmpty) {
    return ColorConstant.primaryColor;
  } else if (data == "0") {
    return ColorConstant.primaryColor;
  } else {
    return ColorConstant.primary2;
  }
}


String userServiceAddressIdSelect  =  "";
int yourApproval = 1;
