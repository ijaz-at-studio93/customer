import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/NoItemsWidget.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:salon_customer/util/get_location_page.dart';

import 'widget/saved_address_widget.dart';

class AddAddressPage extends StatefulWidget {
  final bool isSelect;
  const AddAddressPage({super.key, required this.isSelect});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetSaveAddress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 1.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: ColorConstant.blackColor,
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.isSelect ? "Select Home Address" : "Add Address",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: Column(
        children: [
          addAddress(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  width: Get.width,
                  color: changeTheme(SharedPrefs.readStringValue(
                      PrefConstants.gender)) ??
                      ColorConstant.primaryColor,
                ),
              ),
              Text(
                "SAVED ADDRESS",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  width: Get.width,
                  color: changeTheme(SharedPrefs.readStringValue(
                      PrefConstants.gender)) ??
                      ColorConstant.primaryColor,
                ),
              ),
            ],
          ),
          Expanded(
            child: Obx(
              () => _homeController.showProgress
                  ? const ProgressBarView()
                  : _homeController.getSaveAddressModel.data?.isEmpty ?? false
                      ? const NoItemsWidget(text: "No Any Saved Address Found")
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _homeController
                                  .getSaveAddressModel.data?.length ??
                              0,
                          itemBuilder: (context, index) {
                            return SavedAddressWidget(
                              onPress: () {
                                if (widget.isSelect) {
                                  userServiceAddressIdSelect = _homeController
                                          .getSaveAddressModel
                                          .data?[index]
                                          .id ??
                                      "";
                                  Get.back();
                                }
                              },
                              saveAddressList: _homeController
                                  .getSaveAddressModel.data![index],
                            );
                          }),
            ),
          ),
        ],
      ),
    );
  }

  /*-----------   Add Address --------------*/
  addAddress() {
    return GestureDetector(
      onTap: () {
        Get.to(() => GetLocationPage(
            direction: "",
            house: "",
            isEdit: false,
            addressId: "",
            callback: () {
              _homeController.doGetSaveAddress();
            },
            latitude: double.parse(
                SharedPrefs.readStringValue(PrefConstants.latitude)),
            longitude: double.parse(
                SharedPrefs.readStringValue(PrefConstants.longitude))));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: ColorConstant.whiteColor,
            borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                  Icon(Icons.add, color: changeTheme(SharedPrefs.readStringValue(
                    PrefConstants.gender)) ??
                    ColorConstant.primaryColor,),
                const SizedBox(width: 10),
                Text(
                  "Add Address",
                  style: AppTextTheme.medium
                      .copyWith(color: changeTheme(SharedPrefs.readStringValue(
                      PrefConstants.gender)) ??
                      ColorConstant.primaryColor,),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: ColorConstant.grayTextColor,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
}
