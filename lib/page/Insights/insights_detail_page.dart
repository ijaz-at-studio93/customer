import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/page/stylist/widget/network_video_view_widget.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:url_launcher/url_launcher.dart';

class InsightsDetailPage extends StatefulWidget {
  final String image;
  final String video;
  final String title;
  final String subTitle;
  final String body;
  final String externalLink;
  const InsightsDetailPage(
      {super.key,
      required this.image,
      required this.title,
      required this.subTitle,
      required this.body,
      required this.video,
      required this.externalLink});

  @override
  State<InsightsDetailPage> createState() => _InsightsDetailPageState();
}

class _InsightsDetailPageState extends State<InsightsDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: ColorConstant.blackColor,
            )),
        centerTitle: true,
        title: Text(
          "Insights",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.image.isEmpty
                ? NetworkVideoViewWidget(videoString: widget.video)
                : CachedNetworkImage(
                    width: Get.width,
                    height: Get.height * 0.3,
                    fit: BoxFit.cover,
                    imageUrl: widget.image,
                    placeholder: (context, url) => Image(
                      image: const AssetImage(AssetsConstant.placeHolder),
                      width: Get.width,
                      height: Get.height * 0.3,
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => Image(
                      image: const AssetImage(AssetsConstant.placeHolder),
                      width: Get.width,
                      height: Get.height * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.title,
                style: AppTextTheme.medium.copyWith(
                    color: changeTheme(SharedPrefs.readStringValue(
                            PrefConstants.gender)) ??
                        ColorConstant.primaryColor,
                    fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                widget.subTitle,
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
            ),
            widget.externalLink.isEmpty
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: TextButton(
                      onPressed: () {
                        _launchURL(widget.externalLink);
                      },
                      child: Text(
                        widget.externalLink,
                        style: AppTextTheme.medium.copyWith(
                            color: ColorConstant.primaryColor, fontSize: 16),
                      ),
                    )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: ReadMoreText(
                widget.body,
                trimMode: TrimMode.Line,
                style: AppTextTheme.medium.copyWith(
                    height: 1.5, color: ColorConstant.blackColor, fontSize: 14),
                trimLines: 6,
                colorClickableText: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)) ??
                    ColorConstant.primaryColor,
                trimCollapsedText: 'more',
                trimExpandedText: 'Show less',
                moreStyle: AppTextTheme.medium.copyWith(
                  fontSize: 15,
                  color: changeTheme(
                          SharedPrefs.readStringValue(PrefConstants.gender)) ??
                      ColorConstant.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String urlData) async {
    if (await canLaunch(urlData)) {
      await launch(urlData);
    } else {
      throw 'Could not launch $urlData';
    }
  }
}
