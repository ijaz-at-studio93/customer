import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import '../../project_specific/text_theme.dart';

class SalonRatingPage extends StatefulWidget {
  final String salonId;

  const SalonRatingPage({super.key, required this.salonId});

  @override
  State<SalonRatingPage> createState() => _SalonRatingPageState();
}

class _SalonRatingPageState extends State<SalonRatingPage> {
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetSalonReview(salonId: widget.salonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
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
          "Salon Rating",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: Obx(
        () => _homeController.showProgress
            ? const ProgressBarView()
            : _homeController.getSalonIdReviewsModel.data?.isEmpty ?? false
                ? const NoItemsWidget(
                    text: "No reviews or ratings found for this salon.")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount:
                        _homeController.getSalonIdReviewsModel.data?.length ??
                            0,
                    itemBuilder: (context, index) {
                      return (_homeController.getSalonIdReviewsModel
                                      .data?[index].isArtist ==
                                  false &&
                              _homeController.getSalonIdReviewsModel
                                      .data?[index].isServices ==
                                  false)
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: _listTileWidget(
                                  rate: _homeController.getSalonIdReviewsModel
                                          .data?[index].rating ??
                                      0.0,
                                  title: _homeController.getSalonIdReviewsModel
                                          .data?[index].review ??
                                      "",
                                  userName: _homeController
                                          .getSalonIdReviewsModel
                                          .data?[index]
                                          .user
                                          ?.name ??
                                      ""),
                            )
                          : const SizedBox();
                    }),
      ),
    );
  }

  /*----------------- ReviewAndRating List Tile Widget  --------------*/
  _listTileWidget(
      {required double rate, required String title, required String userName}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: ColorConstant.dividerColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextTheme.medium
                .copyWith(color: ColorConstant.blackColor, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Dash(
            direction: Axis.horizontal,
            length: Get.width * 0.8,
            dashLength: 2,
            dashColor: ColorConstant.grayTextColor.withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          RatingBar.builder(
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
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Posted On $userName",
                style: AppTextTheme.bold
                    .copyWith(fontSize: 13, color: ColorConstant.blackColor),
              ),
            ],
          )
        ],
      ),
    );
  }
}
