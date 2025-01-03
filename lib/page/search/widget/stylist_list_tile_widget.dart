import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import '../../../constant/color_constant.dart';
import '../../../project_specific/text_theme.dart';

class StylistListTileWidget extends StatelessWidget {
  final VoidCallback onPress;
  final String image;
  final String name;
  final double rating;
  final int review;
  final String salonName;
  const StylistListTileWidget(
      {super.key,
      required this.onPress,
      required this.image,
      required this.name,
      required this.rating,
      required this.review, required this.salonName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CachedNetworkImage(
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              imageUrl: '${APIConstants.image}$image',
              placeholder: (context, url) => const Image(
                image: AssetImage(AssetsConstant.placeHolder),
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
              errorWidget: (context, url, error) => const Image(
                image: AssetImage(AssetsConstant.placeHolder),
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.bold
                    .copyWith(fontSize: 19, color: ColorConstant.blackColor),
              ),
              const SizedBox(height: 5),
              Text(
                "By : $salonName",
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.blackColor, fontSize: 18),
              ),
              const SizedBox(height: 5),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RatingBar.builder(
                    initialRating: rating,
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
                  Text(
                    "($review Reviews)",
                    style: AppTextTheme.medium.copyWith(
                        fontSize: 13, color: ColorConstant.grayTextColor),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
