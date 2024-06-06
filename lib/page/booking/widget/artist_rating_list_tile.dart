import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/api/dio_client.dart';
import 'package:sallon_customer/constant/api_constant.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/controller/home_controller.dart';
import 'package:sallon_customer/model/review_list_data_model.dart';
import 'package:sallon_customer/project_specific/button_widget.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

class ArtistRatingListTile extends StatefulWidget {
  final String appointmentId;
  final Artists  artists;
  const ArtistRatingListTile({super.key, required this.appointmentId, required this.artists});

  @override
  State<ArtistRatingListTile> createState() => _ArtistRatingListTileState();
}

class _ArtistRatingListTileState extends State<ArtistRatingListTile> {
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _reviewTextEditingController.text =
        widget.artists.review ?? "";
    rate = widget.artists.rating ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: ColorConstant.primaryColor.withOpacity(0.3), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 7, // Blur radius
            offset: const Offset(0, 2), // Offset in x and y
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    imageUrl:
                        '${APIConstants.image}${widget.artists.image}',
                    placeholder: (context, url) => const Image(
                      image: AssetImage(AssetsConstant.placeHolder),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => const Image(
                      image: AssetImage(AssetsConstant.placeHolder),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.artists.name ?? "",
                      style: AppTextTheme.bold.copyWith(
                          fontSize: 14, color: ColorConstant.blackColor),
                    ),
                    Text(
                      widget.artists.salonName ?? "",
                      style: AppTextTheme.medium.copyWith(
                          fontSize: 14, color: ColorConstant.blackColor),
                    ),
                    SizedBox(
                      width: Get.width * 0.6,
                      child: Text(
                        maxLines: 3,
                        widget.artists.salonAddress ?? "",
                        style: AppTextTheme.medium.copyWith(
                            fontSize: 14, color: ColorConstant.blackColor),
                      ),
                    ),
                    Text(
                      widget.artists.salonName ?? "",
                      style: AppTextTheme.medium.copyWith(
                          fontSize: 14, color: ColorConstant.blackColor),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Divider(
            color: ColorConstant.primaryColor,
          ),
          _ratingWidget(),
        ],
      ),
    );
  }


  final _reviewTextEditingController = TextEditingController();
  double rate = 0.0;
  int selectEmoji = 4;

  _ratingWidget() {
    return Column(
      children: [
        Text(
          "Rate The",
          style: AppTextTheme.bold
              .copyWith(fontSize: 14, color: ColorConstant.blackColor),
        ),
        const SizedBox(height: 5),
        RatingBar.builder(
          initialRating: rate,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 30.0,
          ignoreGestures: false,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: ColorConstant.primaryColor,
            size: 25,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              rate = rating;
            });
          },
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              emojiList.length,
                  (index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectEmoji = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                            width: 2,
                            color: selectEmoji == index
                                ? ColorConstant.primaryColor
                                : Colors.transparent)),
                    child: Center(
                      child: Text(
                        emojiList[index],
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                ),
              )),
        ),
        Text(
          "Share Your Opinion",
          style: AppTextTheme.bold
              .copyWith(fontSize: 14, color: ColorConstant.blackColor),
        ),
        _address(
          hintText: "Write Your Review Here....",
          textEditingController: _reviewTextEditingController,
          textInputType: TextInputType.text,
          textInputAction: TextInputAction.none,
          title: '',
        ),
        const SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
          child: Obx(
                () => _homeController.gteShowAddProgress
                ? const CircularProgressIndicator()
                : widget.artists.isReviewGiven ?? false
                ? const SizedBox()
                : ButtonWidget(
                buttonTitleText: "Submit",
                onPress: () {
                  if (rate == 0.0) {
                    showMessage("Please Give Yore Rate Opinion");
                    return;
                  } else if (_reviewTextEditingController
                      .text.isEmpty) {
                    showMessage("Please Enter Your Opinion");
                    return;
                  } else {
                    String review = selectEmoji == 0
                        ? "😡"
                        : selectEmoji == 1
                        ? "😐"
                        : selectEmoji == 2
                        ? "😐"
                        : selectEmoji == 3
                        ? "😊"
                        : "😍";

                    _homeController.doAddArtiestReview(
                        appointmentId: widget.appointmentId,
                        rate: rate,
                        salonArtistId: widget.artists.id ?? "",
                        review:
                        review + _reviewTextEditingController.text,
                        callback: () {
                          _homeController.doGetReviewDataList(
                              appointmentId: widget.appointmentId);
                          _reviewTextEditingController.text =
                              widget.artists.review ?? "";
                          rate = widget.artists.rating ?? 0.0;
                        });
                  }
                }),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /*------------ Saloon Address TextField -----------*/
  _address({
    required TextEditingController textEditingController,
    required String hintText,
    required String title,
    required TextInputType textInputType,
    required TextInputAction textInputAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextTheme.regular
                .copyWith(fontSize: 13, color: ColorConstant.blackColor),
          ),
          const SizedBox(height: 12),
          Container(
              height: 130,
              width: Get.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorConstant.borderColor,
                ),
              ),
              child: TextField(
                readOnly: widget.artists.isReviewGiven ?? false ? true : false,
                canRequestFocus:
                widget.artists.isReviewGiven ?? false ? false : true,
                controller: textEditingController,
                maxLines: 8,
                keyboardType: textInputType,
                textInputAction: textInputAction,
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 13),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 12, top: 15),
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: AppTextTheme.medium.copyWith(
                        color: ColorConstant.grayColor, fontSize: 13)),
              )),
        ],
      ),
    );
  }

  /*----------------  List Emoji ------------------*/
  List emojiList = ["😡", "☹️", "😐", "😊", "😍"];
}
