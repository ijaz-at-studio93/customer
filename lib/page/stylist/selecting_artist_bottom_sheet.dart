import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/page/stylist/widget/selected_fav_artist_card_widget.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

import '../../constant/assetsconstant.dart';

class SelectingArtistBottomSheetWidget extends StatefulWidget {
  const SelectingArtistBottomSheetWidget({super.key});

  @override
  State<SelectingArtistBottomSheetWidget> createState() =>
      _SelectingArtistBottomSheetWidgetState();
}

class _SelectingArtistBottomSheetWidgetState
    extends State<SelectingArtistBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Text(
                  "Select Your Favorite Stylist",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.bold.copyWith(
                    fontSize: 19,
                    color: ColorConstant.blackColor,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    mainAxisSpacing: 12.0, // Spacing between items vertically
                    crossAxisSpacing:
                        12.0, // Spacing between items horizontally
                    childAspectRatio: 0.65, // Aspect ratio of each item
                  ),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return SelectedFavArtistCardWidget(
                      onPress: () {},
                    );
                  },
                ),
              )
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: -50,
          left: 0,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                  color: ColorConstant.crossMarkColor, shape: BoxShape.circle),
              child: Center(
                child: Image.asset(
                  AssetsConstant.xMark,
                  width: 15,
                  height: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
