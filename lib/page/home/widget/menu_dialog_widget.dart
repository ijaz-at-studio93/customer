import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/model/home_category_list_model.dart';
import 'package:salon_customer/page/home/widget/dilaog_menu_list_widget.dart';
import 'package:salon_customer/project_specific/button_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

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
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 360, //Get.width * 1.2,
        height: 715, //Get.height * 0.85, // 🔥 SAME height – do NOT change
        child: Stack(
          children: [
            Column(
              children: [
                /// 🔹 HEADER (FIXED)
                Container(
                  padding: const EdgeInsets.fromLTRB(15, 16, 15, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: "Outfit",
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                      children: [
                        const TextSpan(
                          text: "Select ",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: "One/ More ",
                          style: TextStyle(
                            color: changeTheme(
                              SharedPrefs.readStringValue(PrefConstants.gender),
                            ),
                          ),
                        ),
                        const TextSpan(
                          text: "Categories",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),

                /// 🔹 GRID
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 80), // 👈 bottom safe space
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.5,
                    ),
                    itemCount: widget.categoryListData.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return DialogMenuListWidget(
                        categoryListData: widget.categoryListData.data![index],
                        onPress: () {
                          setState(() {
                            final item = widget.categoryListData.data![index];
                            item.isSelectCategory =
                            !(item.isSelectCategory ?? false);

                            if (item.isSelectCategory ?? false) {
                              _homeController.categoryId.add(item.id);
                            } else {
                              _homeController.categoryId.remove(item.id);
                              _homeController.doRemovePackageData(
                              serviceCategoryIds: [item.id ?? ""],
                              callback: () {
                                _homeController.doGetMakePackageData();
                              },
                              );
                            }
                          });
                        },

                      );
                    },
                  ),
                ),
              ],
            ),

            /// 🔹 FIXED BOTTOM BUTTON
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: _homeController.categoryId.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    widget.callback.call();
                    Get.back();
                  },
                  child: Container(
                    width: 124,
                    height: 40,
                    decoration: BoxDecoration(
                      color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Done",
                        style: TextStyle(
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
                    : GestureDetector(
                  onTap: () {
                    _homeController.categoryId.clear();
                    debugPrint("categoryId AFTER → ${_homeController.categoryId}");
                    Get.back();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.xmark,
                        color: ColorConstant.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
