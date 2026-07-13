import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/model/blog_data_model.dart';
import 'package:salon_customer/page/Insights/widget/full_screen_reel_view.dart';
import 'package:salon_customer/page/Insights/widget/insights_grid_item.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import '../../constant/color_constant.dart';
import '../../project_specific/text_theme.dart';

/// Row 15: Salon Page → Content redirect. Shows only the content (blogs/reels)
/// belonging to a specific salon, filtered from the blog list by salon id.
class SalonContentPage extends StatefulWidget {
  final String salonId;
  final String salonName;

  const SalonContentPage({
    super.key,
    required this.salonId,
    required this.salonName,
  });

  @override
  State<SalonContentPage> createState() => _SalonContentPageState();
}

class _SalonContentPageState extends State<SalonContentPage> {
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    // Fetch content filtered to this salon directly from the API using the
    // salonId query param (server-side filter).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeController.doGetSalonBlogData(
        lat: double.tryParse(
                SharedPrefs.readStringValue(PrefConstants.latitude)) ??
            0.0,
        lng: double.tryParse(
                SharedPrefs.readStringValue(PrefConstants.longitude)) ??
            0.0,
        salonId: widget.salonId,
      );
    });
  }

  List<BlogData> get _salonBlogs =>
      _homeController.getSalonBlogDataModel.data ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child:
              const Icon(Icons.arrow_back_ios, color: ColorConstant.blackColor),
        ),
        centerTitle: true,
        title: Text(
          widget.salonName.isNotEmpty ? widget.salonName : "Content",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: Obx(() {
        if (_homeController.showProgress) {
          return const ProgressBarView();
        }
        final blogs = _salonBlogs;
        if (blogs.isEmpty) {
          return const NoItemsWidget(
              text: "No content available for this salon yet");
        }
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          itemCount: blogs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, i) {
            final item = blogs[i];
            return InsightsGridItem(
              blogData: item,
              onTap: () {
                _homeController.doAddViewForBlogSection(blogID: item.id ?? "");
                Get.to(() => FullScreenReelView(data: item));
              },
            );
          },
        );
      }),
    );
  }
}
