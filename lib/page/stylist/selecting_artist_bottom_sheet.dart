import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/appointment/appointment_booking_page.dart';
import 'package:salon_customer/page/stylist/widget/selected_fav_artist_card_widget.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import '../../constant/assetsconstant.dart';
import '../../model/artiest_list_model.dart';
import '../../util/SharedPrefs.dart';
import 'package:salon_customer/service/analytics_service.dart';

class SelectingArtistBottomSheetWidget extends StatefulWidget {
  final String serviceId;
  final String salonId;
  final VoidCallback callback;

  const SelectingArtistBottomSheetWidget(
      {super.key, required this.serviceId, required this.callback, required this.salonId});

  @override
  State<SelectingArtistBottomSheetWidget> createState() =>
      _SelectingArtistBottomSheetWidgetState();
}

class _SelectingArtistBottomSheetWidgetState
    extends State<SelectingArtistBottomSheetWidget> {
  final _homeController = Get.find<HomeController>();
  final ValueNotifier<Map<String, String>> selectedArtistMap =
  ValueNotifier({});
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetArtiestListData();
    });
  }




  @override
  Widget build(BuildContext context) {
    return Container(
      height: 575,//Get.height * 0.7,
      width: 402,//Get.width,
      decoration: const BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [

          /// 🔥 MAIN CONTENT (SCROLLABLE)
          Column(
            children: [

              /// 🔹 HEADER (UNCHANGED)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        selectedArtistIdsGlobal.value = [];
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: ColorConstant.crossMarkColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            AssetsConstant.xMark,
                            width: 15,
                            height: 15,
                          ),
                        ),
                      ),
                    ),

                    /// TITLE
                    const Text(
                      "Stylist Selection",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        height: 1.0,
                        color: Colors.black,
                      ),
                    ),

                    /// SKIP BUTTON (UNCHANGED)
                    GestureDetector(
                      onTap: () {
                        final List<String> artistIds = [];
                        //final artistIds = getDefaultArtistIds();

                        // if (artistIds.isEmpty) {
                        //   SnackbarUtil.show("Error", "No artists available");
                        //   return;
                        // }

                        //Navigator.pop(context);

                        // 📊 select_stylist (skipped)
                        AnalyticsService.instance.logSelectStylist(
                          stylistIds: const [],
                          salonId: widget.salonId,
                        );
                        Get.to(() => AppointmentBookingPage(
                          artistIds: artistIds,
                        ));
                      },
                      child: Container(
                        width: 94,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Center(
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Outfit',
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// 🔥 SCROLL CONTENT
              Expanded(
                child: Obx(() {
                  final data = _homeController.getArtiestListData;

                  if (_homeController.showProgress) {
                    return const ProgressBarView();
                  }

                  final maleHair = data.maleHairArtists ?? [];
                  final femaleHair = data.femaleHairArtists ?? [];
                  final maleBeauty = data.maleBeautyArtists ?? [];
                  final femaleBeauty = data.femaleBeautyArtists ?? [];
                  final meta = data.serviceMeta;

                  // if (meta == null) {
                  //   return const NoItemsWidget(text: "No Artist Available");
                  // }
                  if (_homeController.showProgress) {
                    return const ProgressBarView();
                  }

                  final hasNoArtist =
                  (maleHair.isEmpty &&
                      femaleHair.isEmpty &&
                      maleBeauty.isEmpty &&
                      femaleBeauty.isEmpty);

                  if (meta != null && hasNoArtist) {
                    return SizedBox.expand(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.groups_2_outlined, size: 60, color: Colors.grey),
                          const SizedBox(height: 20),
                          const Text(
                            "Optional Staff Selection",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Best staff will be assigned at the salon",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Tap 'Skip' to continue",
                            style: TextStyle(
                              fontFamily: "Outfit",
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final isBothGender =
                  (meta?.hasMaleServices ?? false) && (meta?.hasFemaleServices ?? false);

                  return SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(), // 🔥 disables scroll
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// ================= CASE 1 =================
                  // final themeColor = changeTheme(
                  // SharedPrefs.readStringValue(PrefConstants.gender),
                  // ) ??
                  // ColorConstant.primaryColor;
                      if (!isBothGender) ...[
                        if (maleHair.isNotEmpty || femaleHair.isNotEmpty) ...[
                          buildTitle("Select Stylist", changeTheme(
                            SharedPrefs.readStringValue(PrefConstants.gender),
                          )),
                          const SizedBox(height: 2),

                          /// ✅ stylist section
                          buildSection(
                            [...maleHair, ...femaleHair],
                            "stylist",
                          ),
                        ],

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            thickness: 1,
                            color: Color(0xFFE5E5E5),
                          ),
                        ),

                        if (maleBeauty.isNotEmpty || femaleBeauty.isNotEmpty) ...[
                          buildTitle("Select Beautician", changeTheme(
                            SharedPrefs.readStringValue(PrefConstants.gender),
                          )),
                          const SizedBox(height: 2),

                          /// ✅ beautician section
                          buildSection(
                            [...maleBeauty, ...femaleBeauty],
                            "beautician",
                          ),
                        ],
                      ],

                      /// ================= CASE 2 =================
                      if (isBothGender) ...[
                        buildTitle("For Men Services", changeTheme("0")),
                        const SizedBox(height: 2),

                        /// ✅ men section
                        buildSection(
                          getMenPriorityArtists(
                            maleHair: maleHair,
                            maleBeauty: maleBeauty,
                            meta: meta!,
                          ),
                          "male",
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            thickness: 1,
                            color: Color(0xFFE5E5E5),
                          ),
                        ),

                        buildTitle("For Women Services", changeTheme("1")),
                        const SizedBox(height: 2),

                        /// ✅ women section
                        buildSection(
                          getWomenPriorityArtists(
                            femaleHair: femaleHair,
                            femaleBeauty: femaleBeauty,
                            meta: meta,
                          ),
                          "female",
                        ),
                      ],
                    ],
                  ));
                }),
              ),
            ],
          ),

          /// 🔥 FLOATING CONTINUE BUTTON
          // Positioned(
          //   bottom: 12,
          //   left: 0,
          //   right: 0,
          //   child: ValueListenableBuilder<List<String>>(
          //     valueListenable: selectedArtistIdsGlobal,
          //     builder: (context, selectedList, _) {
          //       return Center(
          //         child: GestureDetector(
          //           onTap: selectedList.isEmpty
          //               ? null
          //               : () {
          //             Navigator.pop(context);
          //
          //             Get.to(() => AppointmentBookingPage(
          //               artistIds: selectedList,
          //             ));
          //           },
          //           child: Container(
          //             width: 220,
          //             height: 40,
          //             decoration: BoxDecoration(
          //               color: selectedList.isEmpty
          //                   ? Colors.grey.withOpacity(0.7)
          //                   : ColorConstant.primaryColor,
          //               borderRadius: BorderRadius.circular(20),
          //             ),
          //             child: const Center(
          //               child: Text(
          //                 "Continue",
          //                 style: TextStyle(
          //                   color: Colors.white,
          //                   fontSize: 16,
          //                   fontWeight: FontWeight.w600,
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget buildTitle(String text, Color? color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Text(
        "$text :",
        style: TextStyle(
          fontFamily: "Outfit",
          fontWeight: FontWeight.w600, // SemiBold
          fontSize: 20,
          height: 1.25, // ~25px line height (20 * 1.25)
          color: color ?? ColorConstant.blackColor, // Figma purple
        ),
      ),
    );
  }

  List<Artiest> getWomenPriorityArtists({
    required List<Artiest> femaleHair,
    required List<Artiest> femaleBeauty,
    required ServiceMeta meta,
  }) {
    // 👩 If ANY beauty service → beauticians first
    if (meta.hasFemaleBeauty) {
      return getUniqueArtists([...femaleBeauty, ...femaleHair]);
    }

    // fallback
    return getUniqueArtists([...femaleHair, ...femaleBeauty]);
  }
  List<Artiest> getMenPriorityArtists({
    required List<Artiest> maleHair,
    required List<Artiest> maleBeauty,
    required ServiceMeta meta,
  }) {
    // 👨 If ANY hair service → stylists first
    if (meta.hasMaleHair) {
      return getUniqueArtists([...maleHair, ...maleBeauty]);
    }

    // fallback
    return getUniqueArtists([...maleBeauty, ...maleHair]);
  }

  Widget buildSection(List<Artiest> list, String sectionType) {
    return Column(
      children: [
        SizedBox(
          height: 185,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),

            itemBuilder: (context, index) {
              final artist = list[index];
              final id = artist.id ?? "";
              final data = _homeController.getArtiestListData;   // ✅ ADD
              final meta = data.serviceMeta;                     // ✅ AD

              return SizedBox(
                width: 138,
                child: ValueListenableBuilder<Map<String, String>>(
                  valueListenable: selectedArtistMap,
                  builder: (context, selectedMap, _) {

                    /// ✅ section-based selection
                    final isSelected = selectedMap[sectionType] == id;
                    //artist.isSelectArtist = isSelected;
                    bool isAllRounder = false;

                    if (sectionType == "male") {
                      isAllRounder =
                          (data.maleHairArtists ?? []).any((e) => e.id == artist.id) &&
                              (data.maleBeautyArtists ?? []).any((e) => e.id == artist.id);
                    } else if (sectionType == "female") {
                      isAllRounder =
                          (data.femaleHairArtists ?? []).any((e) => e.id == artist.id) &&
                              (data.femaleBeautyArtists ?? []).any((e) => e.id == artist.id);
                    }

                    /// ❌ DO NOT show in stylist/beautician sections
                    final showAllRounder =
                        isAllRounder && (sectionType == "male" || sectionType == "female");

                    return SelectedFavArtistCardWidget(
                      artiest: artist,
                      isSelected: isSelected, // ✅ ADD THIS LINE
                      salonId: widget.salonId,
                      serviceMeta: meta!,
                      sectionType: sectionType,// ✅ ADD
                      isFromBeauty: isBeautyArtist(artist, sectionType, data), // ✅ ADD
                      isAllRounder: showAllRounder, // ✅ ONLY ADD THIS LINE

                      callback: () {
                        final current =
                        Map<String, String>.from(selectedMap);

                        /// toggle only within section
                        if (current[sectionType] == id) {
                          current.remove(sectionType);
                        } else {
                          current[sectionType] = id;
                        }

                        selectedArtistMap.value = current;

                        final finalIds = current.values.toList();

                        final data = _homeController.getArtiestListData;
                        final meta = data.serviceMeta;

                        if (meta == null) return;

                        /// 🔥 Detect number of sections
                        int requiredSelections = 1;

                        /// CASE: Men + Women
                        if (meta.hasMaleServices && meta.hasFemaleServices) {
                          requiredSelections = 2;
                        }

                        /// CASE: Stylist + Beautician
                        else {
                          final hasStylist =
                              (data.maleHairArtists?.isNotEmpty ?? false) ||
                                  (data.femaleHairArtists?.isNotEmpty ?? false);

                          final hasBeautician =
                              (data.maleBeautyArtists?.isNotEmpty ?? false) ||
                                  (data.femaleBeautyArtists?.isNotEmpty ?? false);

                          if (hasStylist && hasBeautician) {
                            requiredSelections = 2;
                          }
                        }

                        /// 🔥 FINAL CHECK
                        if (current.length == requiredSelections) {
                          selectedArtistIdsGlobal.value = finalIds;

                          //Navigator.pop(context);

                          // Get.to(() => AppointmentBookingPage(
                          //   artistIds: finalIds,
                          // ));

                          // 📊 select_stylist
                          AnalyticsService.instance.logSelectStylist(
                            stylistIds: finalIds,
                            salonId: widget.salonId,
                          );
                          Get.to(() => AppointmentBookingPage(
                            artistIds: finalIds,
                          ))?.then((_) {
                            selectedArtistMap.value = {};
                            selectedArtistIdsGlobal.value = [];
                          });
                        }
                      },

                      onPress: () {},
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool isBeautyArtist(Artiest artist, String sectionType, dynamic data) {
    if (sectionType == "male") {
      return (data.maleBeautyArtists ?? [])
          .any((e) => e.id == artist.id);
    } else if (sectionType == "female") {
      return (data.femaleBeautyArtists ?? [])
          .any((e) => e.id == artist.id);
    } else if (sectionType == "beautician") {
      return true;
    }
    return false;
  }

  List<String> getDefaultArtistIds() {
    final data = _homeController.getArtiestListData;

    final maleHair = data.maleHairArtists ?? [];
    final femaleHair = data.femaleHairArtists ?? [];
    final maleBeauty = data.maleBeautyArtists ?? [];
    final femaleBeauty = data.femaleBeautyArtists ?? [];
    final meta = data.serviceMeta;

    if (meta == null) return [];

    final List<String> selected = [];

    final isBothGender =
        meta.hasMaleServices && meta.hasFemaleServices;

    /// ✅ CASE 1: BOTH GENDER
    if (isBothGender) {
      final menList = getUniqueArtists([...maleHair, ...maleBeauty]);
      final womenList = getUniqueArtists([...femaleHair, ...femaleBeauty]);

      if (menList.isNotEmpty) {
        selected.add(menList.first.id ?? "");
      }

      if (womenList.isNotEmpty) {
        selected.add(womenList.first.id ?? "");
      }
    }

    /// ✅ CASE 2: SINGLE FLOW
    else {
      final combined = [
        ...maleHair,
        ...femaleHair,
        ...maleBeauty,
        ...femaleBeauty
      ];

      final unique = getUniqueArtists(combined);

      if (unique.isNotEmpty) {
        selected.add(unique.first.id ?? "");
      }
    }

    return selected.where((e) => e.isNotEmpty).toList();
  }

  List<Artiest> getUniqueArtists(List<Artiest> list) {
    final seen = <String>{};

    return list.where((artist) {
      final id = artist.id ?? "";
      if (id.isEmpty || seen.contains(id)) return false;

      seen.add(id);
      return true;
    }).toList();
  }
}