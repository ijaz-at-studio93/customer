import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

class ReviewAndRating extends StatefulWidget {
  const ReviewAndRating({super.key});

  @override
  State<ReviewAndRating> createState() => _ReviewAndRatingState();
}

class _ReviewAndRatingState extends State<ReviewAndRating> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstant.whiteColor,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 5),
          separatorBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              height: 1,
              width: Get.width,
              color: const Color(0xffADADAD),
            );
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return _listTileWidget();
          }),
    );
  }

  /*----------------- ReviewAndRating List Tile Widget  --------------*/
  _listTileWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "n publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content.",
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
            initialRating: 3.5,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 25.0,
            ignoreGestures: true,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color:  ColorConstant.primaryColor,
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
                "Aditya Mishra",
                style: AppTextTheme.medium
                    .copyWith(fontSize: 13, color: ColorConstant.grayTextColor),
              ),
              Text(
                "•Posted on 24 March 2024",
                style: AppTextTheme.medium
                    .copyWith(fontSize: 13, color: ColorConstant.grayTextColor),
              ),
            ],
          ),
        )
      ],
    );
  }
}
