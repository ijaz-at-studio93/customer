import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/controller/home_controller.dart';
import 'package:sallon_customer/project_specific/progressbar_view.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/NoItemsWidget.dart';

class ReviewAndRatingPage extends StatefulWidget {
  const ReviewAndRatingPage({super.key});

  @override
  State<ReviewAndRatingPage> createState() => _ReviewAndRatingPageState();
}

class _ReviewAndRatingPageState extends State<ReviewAndRatingPage> {
  final _homeController = Get.find<HomeController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doReviewRating();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: ColorConstant.blackColor,
          ),
        ),
        centerTitle: true,
        title: Text(
          "Review Rating",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: Obx(() => _homeController.showProgress
          ? const ProgressBarView()
          : _homeController.getReviewRatingUserModel.data?.artists?.isEmpty ??
                  false
              ? const NoItemsWidget(text: "No Any Review Rating Found")
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  separatorBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      height: 1,
                      width: Get.width,
                      color: const Color(0xffADADAD),
                    );
                  },
                  shrinkWrap: true,
                  itemCount: _homeController
                          .getReviewRatingUserModel.data?.artists?.length ??
                      0,
                  itemBuilder: (context, index) {
                    return _listTileWidget(
                        rate: _homeController.getReviewRatingUserModel.data
                                ?.artists?[index].rating ??
                            0.0,
                        title: _homeController.getReviewRatingUserModel.data
                                ?.artists?[index].review ??
                            "",
                        userName: _homeController.getReviewRatingUserModel.data
                                ?.artists?[index].artist?.name ??
                            "");
                  })),
    );
  }

  /*----------------- ReviewAndRating List Tile Widget  --------------*/
  _listTileWidget(
      {required double rate, required String title, required String userName}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: AppTextTheme.medium
                .copyWith(color: ColorConstant.blackColor, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Dash(
            direction: Axis.horizontal,
            length: Get.width * 0.89,
            dashLength: 2,
            dashColor: ColorConstant.grayTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: RatingBar.builder(
            initialRating: rate,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 25.0,
            ignoreGestures: true,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: ColorConstant.primaryColor,
              size: 25,
            ),
            onRatingUpdate: (rating) {},
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                "Posted On $userName",
                style: AppTextTheme.bold
                    .copyWith(fontSize: 13, color: ColorConstant.blackColor),
              ),
            ],
          ),
        )
      ],
    );
  }
}
