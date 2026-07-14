import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/Insights/salon_content_page.dart';
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

  // Row 10: search by salon name — while a query is active the results area
  // lists matching salons (backend search); tapping one opens that salon's
  // content page.
  final TextEditingController _searchController = TextEditingController();
  String _query = "";
  Timer? _debounce;

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    // Clear any salon-search results left over from another screen so the
    // grid shows on entry.
    _homeController.getSearchSalonModel.data = null;
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
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Debounced backend salon search (searchBy: "salon"), matching the
  // content-search page's behaviour.
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _homeController.doSalonSearch(
        query: query,
        lat: SharedPrefs.readStringValue(PrefConstants.latitude),
        lng: SharedPrefs.readStringValue(PrefConstants.longitude),
        searchBy: "salon",
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
      body: Column(
        children: [
          /// Row 10: search matched against the salon name on each tile's chip.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (v) {
                setState(() => _query = v);
                final q = v.trim();
                if (q.isEmpty) {
                  _debounce?.cancel();
                  _homeController.getSearchSalonModel.data = null;
                } else {
                  _onSearchChanged(q);
                }
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search by salon name",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _debounce?.cancel();
                          _searchController.clear();
                          _homeController.getSearchSalonModel.data = null;
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
            child: Stack(
              children: [
                // Base layer: the content grid. Stays visible underneath while
                // searching (only the initial load shows the progress bar).
                Obx(() {
                  final all = _homeController.getBlogDataModel.data ?? [];
                  if (all.isEmpty) {
                    return _homeController.showProgress
                        ? const ProgressBarView()
                        : const NoItemsWidget(
                            text: "Content is not available",
                          );
                  }
                  return GridView.builder(
                    key: _ContentPageState.insightsListKey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    itemCount: all.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, i) {
                      final item = all[i];
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

                // Overlay: floating salon-search dropdown, shown right below the
                // search field while a query is active. Tapping a salon opens
                // its content page. Results are filtered to salons and deduped
                // by id (the endpoint can also return services/artists).
                Obx(() {
                  // Read the observable unconditionally so Obx always has a
                  // dependency to track, even on the empty-query early return.
                  final data = _homeController.getSearchSalonModel.data ?? [];
                  final q = _query.trim();
                  if (q.isEmpty) return const SizedBox.shrink();

                  final seen = <String>{};
                  final salons = data.where((d) {
                    if (!(d.isSalon ?? false)) return false;
                    final id = d.salon?.id;
                    if (id == null || seen.contains(id)) return false;
                    seen.add(id);
                    return true;
                  }).toList();

                  return Positioned(
                    top: 4,
                    left: 12,
                    right: 12,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        constraints:
                            BoxConstraints(maxHeight: Get.height * 0.4),
                        decoration: BoxDecoration(
                          color: ColorConstant.whiteColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: salons.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                child: Text(
                                  _homeController.showProgress
                                      ? "Searching…"
                                      : "No salon found.",
                                  style: Get.textTheme.titleMedium?.copyWith(
                                    color: ColorConstant.grayTextColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                itemCount: salons.length,
                                itemBuilder: (context, index) {
                                  final salon = salons[index].salon;
                                  final name = salon?.displayName ??
                                      salon?.name ??
                                      "";
                                  return GestureDetector(
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      Get.to(() => SalonContentPage(
                                            salonId: salon?.id ?? "",
                                            salonName: name,
                                          ));
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: Text(
                                                name,
                                                style: Get.textTheme.titleMedium
                                                    ?.copyWith(
                                                  color:
                                                      ColorConstant.blackColor,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ),
                                          index == salons.length - 1
                                              ? const SizedBox()
                                              : Divider(
                                                  height: 1,
                                                  color: Colors.grey.shade300,
                                                ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
