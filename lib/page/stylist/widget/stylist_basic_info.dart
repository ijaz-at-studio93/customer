import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/project_specific/text_theme.dart';

class StylistBasicInfo extends StatefulWidget {
  const StylistBasicInfo({super.key});

  @override
  State<StylistBasicInfo> createState() => _StylistBasicInfoState();
}

class _StylistBasicInfoState extends State<StylistBasicInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorConstant.whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Dash(
                    direction: Axis.horizontal,
                    length: Get.width * 0.89,
                    dashLength: 2,
                    dashColor: ColorConstant.grayTextColor,
                  ),
                );
              },
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (context, index) {
                return _myTextWidget(title: "Name", value: "Sourabh Kumar");
              }),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              "Description",
              style: AppTextTheme.medium
                  .copyWith(color: ColorConstant.blackColor, fontSize: 16),
            ),
          ),


          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 20),
            child: ReadMoreText(
              'n publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content. Lorem ipsum may be used as a placeholder before the final copy is available.n publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content. Lorem ipsum may be used as a placeholder before the final copy ',
              trimMode: TrimMode.Line,
              style: AppTextTheme.medium.copyWith(
                  height: 1.5,
                  color: ColorConstant.grayTextColor,
                  fontSize: 14),
              trimLines: 6,
              colorClickableText: ColorConstant.primaryColor,
              trimCollapsedText: 'more',
              trimExpandedText: 'Show less',
              moreStyle: AppTextTheme.medium.copyWith(
                  fontSize: 15, color: ColorConstant.primaryColor),
            ),
          ),
          const SizedBox(height: 78),

        ],
      ),
    );
  }

  /*--------------- Text  Row  Widget ----------------*/
  _myTextWidget({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextTheme.medium
                .copyWith(color: ColorConstant.blackColor, fontSize: 16),
          ),
          Text(
            value,
            style: AppTextTheme.medium
                .copyWith(color: ColorConstant.grayTextColor, fontSize: 16),
          ),
        ],
      ),
    );
  }
}