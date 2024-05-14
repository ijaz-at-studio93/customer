import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/controller/auth_controller.dart';
import 'package:sallon_customer/page/home/widget/dilaog_menu_list_widget.dart';
import 'package:sallon_customer/project_specific/button_widget.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

class MenuDialogWidget extends StatefulWidget {
  const MenuDialogWidget({super.key});

  @override
  State<MenuDialogWidget> createState() => _MenuDialogWidgetState();
}

class _MenuDialogWidgetState extends State<MenuDialogWidget> {
  final _authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: ColorConstant.whiteColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of columns
                mainAxisSpacing: 20.0, // Spacing between items vertically
                crossAxisSpacing: 20.0, // Spacing between items horizontally
                childAspectRatio: 0.6, // Aspect ratio of each item
              ),
              itemCount: 5,
              // Total number of items
              itemBuilder: (context, index) {
                return DialogMenuListWidget(
                  authController: _authController,
                  onPress: () {
                    if (_authController.isSelectMenu) {
                      _authController.isSelectMenu = false;
                    } else {
                      _authController.isSelectMenu = true;
                    }
                  },
                );
              },
            ),
          ),
          Obx(
            () => _authController.isSelectMenu
                ? Positioned(
                    bottom: -60,
                    left: 0,
                    right: 0,
                    child: ButtonWidget(
                      buttonTitleText: "Done",
                      onPress: () {},
                      color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)),
                    ),
                  )
                : Positioned(
                    bottom: -60,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                            color: ColorConstant.whiteColor,
                            shape: BoxShape.circle),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.xmark,
                            color: ColorConstant.grayTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
