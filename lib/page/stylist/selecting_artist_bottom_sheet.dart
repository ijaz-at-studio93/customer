import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/controller/home_controller.dart';
import 'package:sallon_customer/page/stylist/widget/selected_fav_artist_card_widget.dart';
import 'package:sallon_customer/project_specific/progressbar_view.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/NoItemsWidget.dart';

import '../../constant/assetsconstant.dart';

class SelectingArtistBottomSheetWidget extends StatefulWidget {
  final String serviceId;
  final VoidCallback callback;

  const SelectingArtistBottomSheetWidget(
      {super.key, required this.serviceId, required this.callback});

  @override
  State<SelectingArtistBottomSheetWidget> createState() =>
      _SelectingArtistBottomSheetWidgetState();
}

class _SelectingArtistBottomSheetWidgetState
    extends State<SelectingArtistBottomSheetWidget> {
  final _homeController = Get.find<HomeController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetArtiestListData();
    });
  }

  final box = GetStorage();
  String artiestId = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.7,
      width: Get.width,
      decoration: const BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    box.remove("artiestId");
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                        color: ColorConstant.crossMarkColor,
                        shape: BoxShape.circle),
                    child: Center(
                      child: Image.asset(
                        AssetsConstant.xMark,
                        width: 15,
                        height: 15,
                      ),
                    ),
                  ),
                ),
                Text(
                  "Select Your Favorite Stylist",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.bold.copyWith(
                    fontSize: 19,
                    color: ColorConstant.blackColor,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    widget.callback.call();
                  },
                  child: Text(
                    "Done",
                    style: AppTextTheme.medium.copyWith(
                        fontSize: 14, color: ColorConstant.whiteColor),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Expanded(
              child: _homeController.showProgress
                  ? const ProgressBarView()
                  : _homeController.getArtiestListData.data?.isEmpty ??
                          false ||
                              _homeController.getArtiestListData.data == null
                      ? const NoItemsWidget(
                          text: "No Artiest Available For Selected Services",
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 15),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of columns
                            mainAxisSpacing:
                                12.0, // Spacing between items vertically
                            crossAxisSpacing:
                                12.0, // Spacing between items horizontally
                            childAspectRatio: 0.56, // Aspect ratio of each item
                          ),
                          itemCount:
                              _homeController.getArtiestListData.data?.length ??
                                  0,
                          itemBuilder: (context, index) {
                            return SelectedFavArtistCardWidget(
                              artiest: _homeController
                                  .getArtiestListData.data![index],
                              onPress: () {
                                setState(() {
                                  _homeController
                                      .getArtiestListData
                                      .data![index]
                                      .isSelectArtist = !(_homeController
                                          .getArtiestListData
                                          .data![index]
                                          .isSelectArtist ??
                                      false);

                                  if (_homeController.getArtiestListData
                                          .data![index].isSelectArtist ??
                                      false) {
                                    artiestId = _homeController
                                            .getArtiestListData
                                            .data![index]
                                            .id ??
                                        "";
                                    box.write("artiestId", artiestId);
                                  } else {
                                    artiestId = "";
                                    box.remove("artiestId");
                                  }
                                });
                              },
                            );
                          },
                        ),
            ),
          )
        ],
      ),
    );
  }
}
