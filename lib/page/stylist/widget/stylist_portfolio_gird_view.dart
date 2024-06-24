import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/model/artiest_portfolio_model.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';

class StylistPortfolioGridview extends StatefulWidget {
  final ArtiestPortfolio artiestPortfolio;
  const StylistPortfolioGridview({super.key, required this.artiestPortfolio});

  @override
  State<StylistPortfolioGridview> createState() =>
      _StylistPortfolioGridviewState();
}

class _StylistPortfolioGridviewState extends State<StylistPortfolioGridview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstant.whiteColor,
      child: widget.artiestPortfolio.data?.portfolio?.isEmpty ?? false
          ? const NoItemsWidget(
              text: "No Any PortFolio Found",
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: widget.artiestPortfolio.data?.portfolio?.length ?? 0,
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
                      '${APIConstants.image}${widget.artiestPortfolio.data?.portfolio?[index].image}',
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
