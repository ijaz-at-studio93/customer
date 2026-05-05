import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/Insights/insights_detail_page.dart';
import 'package:salon_customer/page/Insights/widget/Insights_card_widget.dart';
import 'package:salon_customer/page/Insights/widget/full_screen_reel_view.dart';
import 'package:salon_customer/page/Insights/widget/insights_grid_item.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import '../../constant/color_constant.dart';
import '../../project_specific/text_theme.dart';
import '../../util/call_wrapper.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage>
    with AutomaticKeepAliveClientMixin<ContentPage> {
  final _homeController = Get.find<HomeController>();
  static const insightsListKey = PageStorageKey<String>('insights_main_list');

  @override
  bool get wantKeepAlive => true;
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
    super.build(context);
    return CallWrapper(
        child: Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: const SizedBox(),
        centerTitle: true,
        title: Text(
          "Content",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: Obx(() => _homeController.showProgress
              ? const ProgressBarView()
              : _homeController.getBlogDataModel.data?.isEmpty ??
                      false || _homeController.getBlogDataModel.data == null
                  ? const NoItemsWidget(text: "Content is not available")
                  : GridView.builder(
                      key: _ContentPageState.insightsListKey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      itemCount:
                          _homeController.getBlogDataModel.data?.length ?? 0,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 👈 2 columns
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75, // 👈 adjust based on design
                      ),
                      itemBuilder: (context, i) {
                        final item = _homeController.getBlogDataModel.data![i];

                        return InsightsGridItem(
                          blogData: item,
                          onTap: () {
                            _homeController.doAddViewForBlogSection(
                                blogID: item.id ?? "");

                            // Get.to(() => InsightsDetailPage(
                            //   externalLink: item.externalLink ?? "",
                            //   video: item.video?.isEmpty ?? false
                            //       ? ""
                            //       : "${APIConstants.image}${item.video}",
                            //   body: item.description ?? "",
                            //   title: item.title ?? "",
                            //   subTitle: item.body ?? "",
                            //   image: item.image?.isEmpty ?? false
                            //       ? ""
                            //       : "${APIConstants.image}${item.image}",
                            // ));
                            Get.dialog(
                              FullScreenReelView(
                                data: item,
                              ),
                              // barrierColor: Colors.black, // dark background
                              // barrierDismissible: true,   // 👈 tap outside closes
                            );
                          },
                        );
                      },
                    )
          // : ListView.separated(
          //     key: _InsightsHomePageState.insightsListKey,
          //     separatorBuilder: (context, i) {
          //       return const Divider(
          //         thickness: 1,
          //         color: ColorConstant.divider2Color,
          //         indent: 20,
          //         endIndent: 20,
          //       );
          //     },
          //     shrinkWrap: true,
          //     itemCount:
          //         _homeController.getBlogDataModel.data?.length ?? 0,
          //     padding:
          //         const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          //     itemBuilder: (context, i) {
          //       return InsightsCardWidget(
          //         isFav: false,
          //         blogData: _homeController.getBlogDataModel.data![i],
          //         onPress: () {
          //           _homeController.doAddViewForBlogSection(
          //               blogID: _homeController
          //                       .getBlogDataModel.data?[i].id ??
          //                   "");
          //           Get.to(() => InsightsDetailPage(
          //                 externalLink: _homeController.getBlogDataModel
          //                         .data?[i].externalLink ??
          //                     "",
          //                 video: _homeController.getBlogDataModel.data?[i]
          //                             .video?.isEmpty ??
          //                         false
          //                     ? ""
          //                     : "${APIConstants.image}${_homeController.getBlogDataModel.data?[i].video ?? ""}",
          //                 body: _homeController.getBlogDataModel.data?[i]
          //                         .description ??
          //                     "",
          //                 title: _homeController
          //                         .getBlogDataModel.data?[i].title ??
          //                     "",
          //                 subTitle: _homeController
          //                         .getBlogDataModel.data?[i].body ??
          //                     "",
          //                 image: _homeController.getBlogDataModel.data?[i]
          //                             .image?.isEmpty ??
          //                         false
          //                     ? ""
          //                     : "${APIConstants.image}${_homeController.getBlogDataModel.data?[i].image ?? ""}",
          //               ));
          //         },
          //       );
          //     }),
          ),
    ));
  }
}
