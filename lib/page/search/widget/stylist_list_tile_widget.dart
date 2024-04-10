import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../constant/color_constant.dart';
import '../../../project_specific/text_theme.dart';

class StylistListTileWidget extends StatelessWidget {
      final  VoidCallback onPress;
  const StylistListTileWidget({super.key, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
       onTap: onPress,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.network(
              "https://images.unsplash.com/photo-1560869713-7d0a29430803?q=80&w=2126&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
              height: 76,
              width: 76,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Neha Kakkar",
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.bold
                    .copyWith(fontSize: 19, color: ColorConstant.blackColor),
              ),
              const SizedBox(height: 5),
              Text(
                "Barber at RedBox Hair Saloon",
                textScaler: const TextScaler.linear(0.85),
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.grayTextColor),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RatingBar.builder(
                    initialRating: 3.5,
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
                    "(125 Reviews)",
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
