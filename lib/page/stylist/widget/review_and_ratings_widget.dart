import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/model/artiest_portfolio_model.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';

class ReviewAndRating extends StatefulWidget {
  final ArtiestPortfolio artiestPortfolio;
  const ReviewAndRating({super.key, required this.artiestPortfolio});

  @override
  State<ReviewAndRating> createState() => _ReviewAndRatingState();
}

class _ReviewAndRatingState extends State<ReviewAndRating> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstant.whiteColor,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: widget.artiestPortfolio.data?.reviews?.isEmpty ?? false
          ? const NoItemsWidget(
              text: "No reviews or ratings are available.",
            )
          : Column(
              children: [
                ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    separatorBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        height: 1,
                        width: Get.width,
                        color: ColorConstant.idColor,
                      );
                    },
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        widget.artiestPortfolio.data?.reviews?.length ?? 0,
                    itemBuilder: (context, index) {
                      return _listTileWidget(
                          rate: widget.artiestPortfolio.data?.reviews?[index]
                                  .rating ??
                              0.0,
                          title: widget.artiestPortfolio.data?.reviews?[index]
                                  .review ??
                              "",
                          userName: widget.artiestPortfolio.data
                                  ?.reviews?[index].user?.name ??
                              "");
                    }),
                SizedBox(height: Get.height * 0.12)
              ],
            ),
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
            dashColor: ColorConstant.crossMarkColor,
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
                "$userName • Posted On ${widget.artiestPortfolio.data?.createdAt == "" || widget.artiestPortfolio.data?.createdAt == null ? "" : convertDate(widget.artiestPortfolio.data?.createdAt ?? "")}",
                style: AppTextTheme.medium
                    .copyWith(fontSize: 13, color: ColorConstant.grayTextColor),
              ),
            ],
          ),
        )
      ],
    );
  }

  String convertDate(String dateString) {
    // Parse the input date string to a DateTime object
    DateTime dateTime = DateTime.parse(dateString);

    // Format the DateTime object to the desired format
    String formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);

    return formattedDate;
  }
}
