import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import '../../constant/api_constant.dart';
import '../../project_specific/progressbar_view.dart';
import '../../project_specific/text_theme.dart';
import '../../util/NoItemsWidget.dart';
import '../Insights/insights_detail_page.dart';
import '../Insights/widget/Insights_card_widget.dart';

class BlogFavPage extends StatefulWidget {
  const BlogFavPage({super.key});

  @override
  State<BlogFavPage> createState() => _BlogFavPageState();
}

class _BlogFavPageState extends State<BlogFavPage> {
  final _homeController = Get.find<HomeController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetFavBlogData();
    });
  }

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
      body: Obx(
        () => _homeController.showProgress
            ? const ProgressBarView()
            : _homeController.getFavBlogDataModel.data?.isEmpty ??
                    false || _homeController.getFavBlogDataModel.data == null
                ? const NoItemsWidget(text: "No Insights Data Found")
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
                        _homeController.getFavBlogDataModel.data?.length ?? 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    itemBuilder: (context, i) {
                      return InsightsCardWidget(
                        isFav: true,
                        blogData: _homeController.getFavBlogDataModel.data![i],
                        onPress: () {
                          _homeController.doAddViewForBlogSection(
                              blogID: _homeController
                                      .getFavBlogDataModel.data?[i].id ??
                                  "");
                          Get.to(() => InsightsDetailPage(
                                externalLink: _homeController
                                        .getFavBlogDataModel
                                        .data?[i]
                                        .externalLink ??
                                    "",
                                video: _homeController.getFavBlogDataModel
                                            .data![i].video?.isEmpty ??
                                        false
                                    ? ""
                                    : "${APIConstants.image}${_homeController.getFavBlogDataModel.data?[i].video ?? ""}",
                                body: _homeController.getFavBlogDataModel
                                        .data?[i].description ??
                                    "",
                                title: _homeController
                                        .getFavBlogDataModel.data?[i].title ??
                                    "",
                                subTitle: _homeController
                                        .getFavBlogDataModel.data?[i].body ??
                                    "",
                                image: _homeController.getFavBlogDataModel
                                            .data?[i].image?.isEmpty ??
                                        false
                                    ? ""
                                    : "${APIConstants.image}${_homeController.getFavBlogDataModel.data?[i].image ?? ""}",
                              ));
                        },
                      );
                    }),
      ),
    );
  }
}
