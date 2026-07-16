import 'package:flutter/material.dart';
import 'package:salon_customer/constant/color_constant.dart';

const double fixPadding = 10.0;

const SizedBox heightSpace = SizedBox(height: fixPadding);

/*----------- dynamic Color Change ------------*/
/// Single source of truth for the gender accent colour.
///
/// The colour derives ONLY from [selectedGender] — the exact same value the
/// Men/Women toggle reads — so the toggle and every themed widget can never
/// disagree (e.g. "Men" selected while the UI shows the female pink). The
/// [data] parameter is ignored and kept only so existing call sites keep
/// compiling; a caller that needs the *opposite* gender's colour must compute
/// it explicitly instead of passing a flipped string here.
Color? changeTheme([String? data]) {
  return selectedGender.value == 1
      ? ColorConstant.primary2 // female → pink
      : ColorConstant.primaryColor; // male / default → purple
}


String userServiceAddressIdSelect  =  "";
int yourApproval = 1;


ValueNotifier<int> selectedGender =  ValueNotifier(0);

ValueNotifier<String>  stylistId = ValueNotifier("");

ValueNotifier<List<String>> selectedArtistIdsGlobal = ValueNotifier([]);
