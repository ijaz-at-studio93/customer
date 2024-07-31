import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/Insights/insights_detail_page.dart';
import 'package:salon_customer/page/Insights/widget/Insights_card_widget.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import '../../constant/color_constant.dart';
import '../../project_specific/text_theme.dart';

class InsightsHomePage extends StatefulWidget {
  const InsightsHomePage({super.key});

  @override
  State<InsightsHomePage> createState() => _InsightsHomePageState();
}

class _InsightsHomePageState extends State<InsightsHomePage> {
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetBlogData(
        lat: double.parse(SharedPrefs.readStringValue(PrefConstants.latitude)),
        lng: double.parse(SharedPrefs.readStringValue(PrefConstants.longitude)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: const SizedBox(),
        centerTitle: true,
        title: Text(
          "Insights",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: Obx(
        () => _homeController.showProgress
            ? const ProgressBarView()
            : _homeController.getBlogDataModel.data?.isEmpty ??
                    false || _homeController.getBlogDataModel.data == null
                ? const NoItemsWidget(text: "No Blog Data Found")
                : ListView.separated(
                    separatorBuilder: (context, i) {
                      return const Divider(
                        thickness: 2,
                        color: ColorConstant.divider2Color,
                        indent: 20,
                        endIndent: 20,
                      );
                    },
                    shrinkWrap: true,
                    itemCount:
                        _homeController.getBlogDataModel.data?.length ?? 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    itemBuilder: (context, i) {
                      return InsightsCardWidget(
                        isFav: false,
                        blogData: _homeController.getBlogDataModel.data![i],
                        onPress: () {
                          Get.to(() => InsightsDetailPage(
                                body: _homeController.getBlogDataModel.data?[i]
                                        .description ??
                                    "",
                                title: _homeController
                                        .getBlogDataModel.data?[i].title ??
                                    "",
                                subTitle: _homeController
                                        .getBlogDataModel.data?[i].body ??
                                    "",
                                image:
                                    "${APIConstants.image}${_homeController.getBlogDataModel.data?[i].image ?? ""}",
                              ));
                        },
                      );
                    }),
      ),
    );
  }
}
