import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/model/home_category_list_model.dart';
import 'package:salon_customer/page/home/widget/dilaog_menu_list_widget.dart';
import 'package:salon_customer/project_specific/button_widget.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:salon_customer/util/logger.dart';

class MenuDialogWidget extends StatefulWidget {
  final HomeCategoryListModel categoryListData;
  final VoidCallback callback;
  const MenuDialogWidget(
      {super.key, required this.categoryListData, required this.callback});

  @override
  State<MenuDialogWidget> createState() => _MenuDialogWidgetState();
}

class _MenuDialogWidgetState extends State<MenuDialogWidget> {
  final _homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              itemCount: widget.categoryListData.data?.length ?? 0,
              // Total number of items
              itemBuilder: (context, index) {
                return DialogMenuListWidget(
                  categoryListData: widget.categoryListData.data![index],
                  onPress: () {
                    setState(() {
                      widget.categoryListData.data?[index].isSelectCategory =
                          !(widget.categoryListData.data?[index]
                                  .isSelectCategory ??
                              false);
                      if (widget
                              .categoryListData.data?[index].isSelectCategory ??
                          false) {
                        _homeController.categoryId
                            .add(widget.categoryListData.data?[index].id);
                      } else {
                        _homeController.categoryId
                            .remove(widget.categoryListData.data?[index].id);

                        _homeController.doRemovePackageData(
                            serviceCategoryIds: ["${widget.categoryListData.data?[index].id}"],
                            callback: () {
                              _homeController.doGetMakePackageData();
                            });
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _homeController.categoryId.isNotEmpty
                ? ButtonWidget(
                    buttonTitleText: "Done",
                    onPress: () {
                      logger.f("Data Length ${_homeController.categoryId.length}");
                      widget.callback.call();
                      Get.back();
                    },
                    color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)),
                  )
                : GestureDetector(
                    onTap: () {
                      widget.callback.call();
                      _homeController.categoryId.clear();
                      Get.back();
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: changeTheme(SharedPrefs.readStringValue(
                              PrefConstants.gender)),
                          shape: BoxShape.circle),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.xmark,
                          color: ColorConstant.whiteColor,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
