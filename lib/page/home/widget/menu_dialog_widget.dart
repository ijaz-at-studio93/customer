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
  final ScrollController _scrollController = ScrollController();
  final _homeController = Get.find<HomeController>();
  @override
  void initState() {
    super.initState();
    _homeController.categoryId.clear(); // ✅ FIX
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: Get.width * 0.9,
        height: Get.height * 0.85, // 🔥 SAME height – do NOT change
        child: Stack(
          children: [
            // 🔹 TOP HEADER
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select One/ More Categories",
                      style: AppTextTheme.bold.copyWith(
                        fontSize: 18,
                        color: ColorConstant.blackColor,
                      ),
                    )
                  ],
                ),
              ),
            ),



            // 🔹 SCROLLABLE GRID
            Padding(
              padding: const EdgeInsets.only(bottom: 70), // space for buttons
              child: widget.categoryListData.data?.isEmpty ?? false
                  ? Center(
                child: Text(
                  "No service available yet",
                  style: AppTextTheme.medium.copyWith(
                    color: ColorConstant.blackColor,
                    fontSize: 16,
                  ),
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.6,
                ),
                itemCount: widget.categoryListData.data?.length ?? 0,
                itemBuilder: (context, index) {
                  return DialogMenuListWidget(
                    categoryListData:
                    widget.categoryListData.data![index],
                    onPress: () {
                      setState(() {
                        final item =
                        widget.categoryListData.data![index];
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

            // 🔹 FIXED BOTTOM CENTER BUTTONS
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: _homeController.categoryId.isNotEmpty
                    ? ButtonWidget(
                  buttonTitleText: "Done",
                  onPress: () {
                    widget.callback.call();
                    Get.back();
                  },
                  color: changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender)),
                )
                    : GestureDetector(
                  onTap: () {
                    _homeController.categoryId.clear();
                    Get.back();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)),
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

// Widget build(BuildContext context) {
//   return SingleChildScrollView(
//     child: Dialog(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           widget.categoryListData.data?.isEmpty ?? false
//               ? Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   child: Text(
//                     "No service available yet",
//                     style: AppTextTheme.medium.copyWith(
//                         color: ColorConstant.blackColor, fontSize: 16),
//                   ),
//                 )
//               : Container(
//                   width: Get.width,
//                   decoration: BoxDecoration(
//                     color: ColorConstant.whiteColor,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     padding: const EdgeInsets.all(20),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3, // Number of columns
//                       mainAxisSpacing:
//                           20.0, // Spacing between items vertically
//                       crossAxisSpacing:
//                           20.0, // Spacing between items horizontally
//                       childAspectRatio: 0.6, // Aspect ratio of each item
//                     ),
//                     itemCount: widget.categoryListData.data?.length ?? 0,
//                     // Total number of items
//                     itemBuilder: (context, index) {
//                       return DialogMenuListWidget(
//                         categoryListData:
//                             widget.categoryListData.data![index],
//                         onPress: () {
//                           setState(() {
//                             widget.categoryListData.data?[index]
//                                 .isSelectCategory = !(widget.categoryListData
//                                     .data?[index].isSelectCategory ??
//                                 false);
//                             if (widget.categoryListData.data?[index]
//                                     .isSelectCategory ??
//                                 false) {
//                               _homeController.categoryId.add(
//                                   widget.categoryListData.data?[index].id);
//                             } else {
//                               _homeController.categoryId.remove(
//                                   widget.categoryListData.data?[index].id);
//
//                               _homeController.doRemovePackageData(serviceCategoryIds: [
//                       "${widget.categoryListData.data?[index].id}"
//                     ], callback: () {
//                       _homeController.doGetMakePackageData();
//                     });
//                   }
//                 });
//               },);
//           },),),
//       Padding(padding: const EdgeInsets.all(8.0),
//         child: _homeController.categoryId.isNotEmpty
//             ? ButtonWidget(buttonTitleText: "Done",
//           onPress: () {
//             widget.callback.call();
//             Get.back();
//           },
//           color: changeTheme(
//               SharedPrefs.readStringValue(PrefConstants.gender)),)
//             : GestureDetector(onTap: () {
//           if (widget.categoryListData.data?.isEmpty ?? false) {
//             Get.back();
//           } else {
//             widget.callback.call();
//             _homeController.categoryId.clear();
//             Get.back();
//           }
//         },
//           child: Container(width: 48,
//             height: 48,
//             decoration: BoxDecoration(color: changeTheme(
//                 SharedPrefs.readStringValue(PrefConstants.gender)),
//                 shape: BoxShape.circle),
//             child: const Center(child: Icon(
//               CupertinoIcons.xmark, color: ColorConstant.whiteColor,),),),),),
//     ],),
//     ),
//   );
// }
}