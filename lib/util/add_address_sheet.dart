import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/api/dio_client.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/controller/home_controller.dart';
import 'package:sallon_customer/project_specific/ProgressContainerView.dart';
import 'package:sallon_customer/project_specific/button_widget.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/simple_text_field.dart';

class AddAddressSheet extends StatefulWidget {
  final String address;
  final double latitude;
  final double longitude;
  final String addressId;
  final String house;
  final String direction;
  final bool isEdit;
  final VoidCallback callback;
  const AddAddressSheet(
      {super.key,
      required this.address,
      required this.latitude,
      required this.longitude,
      required this.callback,
      required this.addressId,
      required this.isEdit, required this.house, required this.direction});

  @override
  State<AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<AddAddressSheet> {
  final _flatHouseNo = TextEditingController();
  final _description = TextEditingController();
  final _homeController = Get.find<HomeController>();


  @override
  void initState() {
    super.initState();
    if(widget.isEdit){
      _flatHouseNo.text  =  widget.house;
      _description.text  =  widget.direction;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: Get.height * 0.5,
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
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Enter Complete Address",
                  style: AppTextTheme.bold
                      .copyWith(fontSize: 15, color: ColorConstant.blackColor),
                ),
              ),
              Obx(
                () => Expanded(
                    child: ProgressContainerView(
                  isProgressRunning: _homeController.showProgress,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SimpleTextFieldWidget(
                            textEditingController: _flatHouseNo,
                            hintText: "Flat / House no /Floor /Building *",
                            textInputType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            title: "Flat / House no /Floor /Building *"),
                        const SizedBox(height: 10),
                        _address(
                            title: "Direction To Reach (Optional)",
                            textInputAction: TextInputAction.none,
                            textEditingController: _description,
                            hintText: "Direction To Reach........",
                            textInputType: TextInputType.text),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: ButtonWidget(
                              buttonTitleText: "Save Address",
                              onPress: () {
                                if (_flatHouseNo.text.isEmpty) {
                                  showMessage("Please Fill Up Flat-House-No.");
                                } else {
                                  if (widget.isEdit) {
                                    _homeController.doSaveEditAddress(
                                        addressID: widget.addressId,
                                        geolocationLng:
                                            widget.longitude.toString(),
                                        address: widget.address,
                                        directions: _description.text,
                                        geolocationLat:
                                            widget.latitude.toString(),
                                        house: _flatHouseNo.text,
                                        callback: () {
                                          Get.back();
                                          Get.back();
                                          widget.callback.call();
                                        });
                                  } else {
                                    _homeController.doSaveAddress(
                                        geolocationLng:
                                            widget.longitude.toString(),
                                        address: widget.address,
                                        directions: _description.text,
                                        geolocationLat:
                                            widget.latitude.toString(),
                                        house: _flatHouseNo.text,
                                        callback: () {
                                          Get.back();
                                          Get.back();
                                          widget.callback.call();
                                        });
                                  }
                                }
                              }),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: -50,
          left: 0,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                  color: ColorConstant.crossMarkColor, shape: BoxShape.circle),
              child: Center(
                child: Image.asset(
                  AssetsConstant.xMark,
                  width: 15,
                  height: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /*------------ Saloon Address TextField -----------*/
  _address({
    required TextEditingController textEditingController,
    required String hintText,
    required String title,
    required TextInputType textInputType,
    required TextInputAction textInputAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextTheme.regular
                .copyWith(fontSize: 13, color: ColorConstant.blackColor),
          ),
          const SizedBox(height: 12),
          Container(
              height: 130,
              width: Get.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorConstant.borderColor,
                ),
              ),
              child: TextField(
                controller: textEditingController,
                maxLines: 8,
                keyboardType: textInputType,
                textInputAction: textInputAction,
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 13),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 12, top: 15),
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: AppTextTheme.medium.copyWith(
                        color: ColorConstant.grayColor, fontSize: 13)),
              )),
        ],
      ),
    );
  }
}
