import 'package:flutter/material.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

import '../constant/assetsconstant.dart';
import '../constant/color_constant.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String nameOfScreen;
  final bool isBackIcon;
  final VoidCallback? callback;
  final List<Widget>? actions;
  final bool? fontSize;

  const AppBarWidget(
      {super.key,
      required this.nameOfScreen,
      this.callback,
      this.isBackIcon = true,
      this.actions,
      this.fontSize = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1.0,
      backgroundColor: ColorConstant.whiteColor,
      centerTitle: true,
      title: Text(nameOfScreen,
          textScaler: const TextScaler.linear(0.85),
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19)),
      leadingWidth: isBackIcon ? 80 : 0,
      leading: InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          Navigator.pop(context);
          callback?.call();
        },
        child: Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.all(7),
          /* decoration: const BoxDecoration(shape: BoxShape.circle, color: ColorConstant.primary) */
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              AssetsConstant.arrowLeftIcon,
              color: ColorConstant.blackColor,
            ),
          ),
        ),
      ),
      actions: actions ?? [const SizedBox()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
