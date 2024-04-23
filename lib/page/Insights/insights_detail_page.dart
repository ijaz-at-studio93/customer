import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';

class InsightsDetailPage extends StatefulWidget {
  final String image;
  const InsightsDetailPage({super.key, required this.image});

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
            Image.network(
              widget.image,
              width: Get.width,
              height: Get.height * 0.3,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Posted By Amrit Saloon •28 Feb",
                style: AppTextTheme.medium
                    .copyWith(color: changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor, fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                "SML Isuzu Ltd. (SMLI) is a trusted and reliable",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: ReadMoreText(
                'n publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content. Lorem ipsum may be used as a placeholder before the final copy is available.n publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content. Lorem ipsum may be used as a placeholder before the final copy n publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content. Lorem ipsum may be used as a placeholder before the final copy is available.n publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content. Lorem ipsum may be used as a placeholder before the final copy ',
                trimMode: TrimMode.Line,
                style: AppTextTheme.medium.copyWith(
                    height: 1.5, color: ColorConstant.blackColor, fontSize: 14),
                trimLines: 6,
                colorClickableText: changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor,
                trimCollapsedText: 'more',
                trimExpandedText: 'Show less',
                moreStyle: AppTextTheme.medium
                    .copyWith(fontSize: 15, color: changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender)) ?? ColorConstant.primaryColor,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
