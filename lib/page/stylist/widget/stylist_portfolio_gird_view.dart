import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';

class StylistPortfolioGridview extends StatefulWidget {
  const StylistPortfolioGridview({super.key});

  @override
  State<StylistPortfolioGridview> createState() =>
      _StylistPortfolioGridviewState();
}

class _StylistPortfolioGridviewState extends State<StylistPortfolioGridview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstant.whiteColor,
      height: Get.height,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.98),
        itemBuilder: (context, index) => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            height: 178,
            width: 178,
            fit: BoxFit.cover,
            imageUrl:
                'https://images.unsplash.com/photo-1488376739361-ed24c9beb6d0?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fHBsYXklMjBpY29ufGVufDB8fDB8fHww',
            placeholder: (context, url) => const Image(
                image: AssetImage(AssetsConstant.placeHolder),
                height: 178,
                width: 178,
                fit: BoxFit.cover),
            errorWidget: (context, url, error) => const Image(
                image: AssetImage(AssetsConstant.placeHolder),
                height: 178,
                width: 178,
                fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
