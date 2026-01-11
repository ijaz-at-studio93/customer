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
      height: Get.height * 0.7,
      width: Get.width,
      decoration: const BoxDecoration(
        color: ColorConstant.whiteColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);

                    stylistId.value = "";
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                        color: ColorConstant.crossMarkColor,
                        shape: BoxShape.circle),
                    child: Center(
                      child: Image.asset(
                        AssetsConstant.xMark,
                        width: 15,
                        height: 15,
                      ),
                    ),
                  ),
                ),
                Text(
                  "Select a Stylist",
                  textScaler: const TextScaler.linear(0.85),
                  style: AppTextTheme.bold.copyWith(
                    fontSize: 19,
                    color: ColorConstant.blackColor,
                  ),
                ),
                const SizedBox(),
                const SizedBox(),
              ],
            ),
          ),
          Obx(
                () => Expanded(
              child: _homeController.showProgress
                  ? const ProgressBarView()
                  : _homeController.getArtiestListData.data == null ||
                  (_homeController.getArtiestListData.data?.isEmpty ?? true)
                  ? const NoItemsWidget(text: "No Artiest Available For Selected Services")
                  : Builder(builder: (context) {
                // 👇 NEW: de-duplicate by artist id
                final seen = <String>{};
                final unique = (_homeController.getArtiestListData.data ?? [])
                    .where((a) {
                  final id = a.id?.trim() ?? '';
                  if (id.isEmpty || seen.contains(id)) return false;
                  seen.add(id);
                  return true;
                })
                    .toList();

                return GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.0,
                    crossAxisSpacing: 12.0,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: unique.length, // 👈 use unique
                  itemBuilder: (context, index) {
                    final artist = unique[index]; // 👈 use unique
                    return SelectedFavArtistCardWidget(
                      callback: () {
                        stylistId.value = artist.id ?? "";
                        widget.callback.call();
                      },
                      salonId: widget.salonId,
                      artiest: artist,
                      onPress: () {
                        Navigator.pop(context);
                        Get.to(() => AppointmentBookingPage(
                          artiestId: artist.id ?? "",
                        ));

                        setState(() {
                          artist.isSelectArtist = !(artist.isSelectArtist ?? false);
                          if (artist.isSelectArtist ?? false) {
                            stylistId.value = artist.id ?? "";
                            widget.callback.call();
                          } else {
                            stylistId.value = "";
                          }
                        });
                      },
                    );
                  },
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
