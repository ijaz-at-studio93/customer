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
import '../../constant/variable_constant.dart';
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
    // Ensure blog data is available (user may reach here without opening the
    // Content tab first).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((_homeController.getBlogDataModel.data ?? []).isEmpty) {
        final lat =
            double.tryParse(SharedPrefs.readStringValue(PrefConstants.latitude));
        final lng = double.tryParse(
            SharedPrefs.readStringValue(PrefConstants.longitude));
        if (lat != null && lng != null) {
          _homeController.doGetBlogData(lat: lat, lng: lng);
        }
      }
    });
  }

  List<BlogData> get _salonBlogs =>
      (_homeController.getBlogDataModel.data ?? [])
          .where((b) => b.salon?.id == widget.salonId)
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: ColorConstant.blackColor),
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
                Get.dialog(FullScreenReelView(data: item));
              },
            );
          },
        );
      }),
    );
  }
}
