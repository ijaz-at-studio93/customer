import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/Insights/widget/full_screen_reel_view.dart';
import 'package:salon_customer/page/Insights/widget/insights_grid_item.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import '../../constant/color_constant.dart';
import '../../constant/variable_constant.dart';
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

  // Row 10: live search matched against the salon name shown on each
  // content tile's top-left chip.
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetBlogData(
        lat: double.tryParse(
                SharedPrefs.readStringValue(PrefConstants.latitude)) ??
            0.0,
        lng: double.tryParse(
                SharedPrefs.readStringValue(PrefConstants.longitude)) ??
            0.0,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      body: Column(
        children: [
          /// Row 10: search matched against the salon name on each tile's chip.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search by salon name",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = "");
                        },
                      )
                    : null,
                filled: true,
                fillColor: ColorConstant.whiteColor,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: changeTheme(SharedPrefs.readStringValue(
                            PrefConstants.gender)) ??
                        ColorConstant.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_homeController.showProgress) {
                return const ProgressBarView();
              }
              final all = _homeController.getBlogDataModel.data ?? [];
              final q = _query.trim().toLowerCase();
              // Match against the exact label shown on the tile's top-left
              // chip (salon displayName, falling back to "By Scuts").
              final items = q.isEmpty
                  ? all
                  : all
                      .where((b) => (b.salon?.displayName ?? "By Scuts")
                          .toLowerCase()
                          .contains(q))
                      .toList();

              if (items.isEmpty) {
                return NoItemsWidget(
                  text: q.isEmpty
                      ? "Content is not available"
                      : "No content found for that salon.",
                );
              }

              return GridView.builder(
                key: _ContentPageState.insightsListKey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, i) {
                  final item = items[i];
                  return InsightsGridItem(
                    blogData: item,
                    onTap: () {
                      _homeController.doAddViewForBlogSection(
                          blogID: item.id ?? "");
                      Get.dialog(FullScreenReelView(data: item));
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    ));
  }
}
