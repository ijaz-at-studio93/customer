import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/model/save_address_model.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:salon_customer/util/get_location_page.dart';

import '../../../project_specific/remove_and_add_service_dialog.dart';

class SavedAddressWidget extends StatefulWidget {
  final SaveAddressList saveAddressList;
  final VoidCallback onPress;

  const SavedAddressWidget(
      {super.key, required this.saveAddressList, required this.onPress});

  @override
  State<SavedAddressWidget> createState() => _SavedAddressWidgetState();
}

class _SavedAddressWidgetState extends State<SavedAddressWidget> {
  final _homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPress,
      child: Container(
        width: Get.width,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              CupertinoIcons.home,
              color: changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender)) ??
                  ColorConstant.primaryColor,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Home",
                  style: AppTextTheme.bold
                      .copyWith(color: ColorConstant.blackColor, fontSize: 14),
                ),
                SizedBox(
                  width: Get.width * 0.75,
                  child: Text(
                    widget.saveAddressList.address ?? "",
                    style: AppTextTheme.medium.copyWith(
                        color: ColorConstant.blackColor, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10),
                widget.saveAddressList.directions == ""
                    ? const SizedBox()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Directions",
                            style: AppTextTheme.bold.copyWith(
                                color: ColorConstant.blackColor, fontSize: 14),
                          ),
                          SizedBox(
                            width: Get.width * 0.75,
                            child: Text(
                              widget.saveAddressList.directions ?? "",
                              style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.blackColor,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "House",
                      style: AppTextTheme.bold.copyWith(
                          color: ColorConstant.blackColor, fontSize: 14),
                    ),
                    SizedBox(
                      width: Get.width * 0.75,
                      child: Text(
                        widget.saveAddressList.house ?? "",
                        style: AppTextTheme.medium.copyWith(
                            color: ColorConstant.blackColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return RemoveAndAddServiceDialog(
                                  descriptionText:
                                      "Are You Sure You Want to Remove this Address.",
                                  noPress: () {
                                    Navigator.of(context).maybePop();
                                  },
                                  yesPress: () {
                                    _homeController.doDeleteSaveAddress(
                                        id: widget.saveAddressList.id ?? "",
                                        callback: () {
                                          Navigator.of(context).maybePop();
                                          _homeController.doGetSaveAddress();
                                        });
                                  });
                            });
                      },
                      icon: const Icon(
                        size: 20,
                        CupertinoIcons.delete_solid,
                        color: ColorConstant.redBgColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Get.to(() => GetLocationPage(
                            house: widget.saveAddressList.house ?? "",
                            direction: widget.saveAddressList.directions ?? "",
                            addressId: widget.saveAddressList.id ?? "",
                            isEdit: true,
                            callback: () {
                              _homeController.doGetSaveAddress();
                            },
                            latitude: widget.saveAddressList.geoLocationPoint
                                    ?.coordinates?[1] ??
                                0.0,
                            longitude: widget.saveAddressList.geoLocationPoint
                                    ?.coordinates?[0] ??
                                0.0));
                      },
                      icon: const Icon(
                        size: 20,
                        CupertinoIcons.pencil_circle,
                        color: ColorConstant.redBgColor,
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
