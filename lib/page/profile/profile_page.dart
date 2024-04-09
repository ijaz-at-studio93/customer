import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

import '../../util/pick_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
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
          "My Details",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _imageRowWidget(),
            const SizedBox(height: 5),
            const Divider(
              color: ColorConstant.garyDividerColor,
              indent: 20,
              endIndent: 20,
              thickness: 1,
            ),
            _listTitleWidget(
                image: AssetsConstant.myBooking,
                name: "My Bookings",
                onPress: () {}),
            const Divider(
              color: ColorConstant.garyDividerColor,
              indent: 20,
              endIndent: 20,
              thickness: 1,
            ),
            _listTitleWidget(
                image: AssetsConstant.reviewRatings,
                name: "Review & Ratings",
                onPress: () {}),
            const Divider(
              color: ColorConstant.garyDividerColor,
              indent: 20,
              endIndent: 20,
              thickness: 1,
            ),
            _listTitleWidget(
                image: AssetsConstant.faq,
                name: "FAQ’s & Support",
                onPress: () {}),
            const Divider(
              color: ColorConstant.garyDividerColor,
              indent: 20,
              endIndent: 20,
              thickness: 1,
            ),
            _listTitleWidget(
                image: AssetsConstant.about, name: "About Us", onPress: () {}),
            const Divider(
              color: ColorConstant.garyDividerColor,
              indent: 20,
              endIndent: 20,
              thickness: 1,
            ),
            _listTitleWidget(
                image: AssetsConstant.signOut,
                name: "Sign Out",
                onPress: () {}),
          ],
        ),
      ),
    );
  }

  /*------------ Image Row Widget -----------*/
  _imageRowWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          InkWell(
            onTap: ()async{
              FileUtils.openPlatformImagePicker(onSelectImage: (file){
                print(file);
              });

            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                "https://plus.unsplash.com/premium_photo-1708271598114-5e6e8892a2ad?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                width: 66,
                height: 66,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sourabh Kumar",
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.blackColor, fontSize: 20),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(68),
                  border:
                      Border.all(color: ColorConstant.primaryColor, width: 1),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AssetsConstant.editIcon,
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Edit Details",
                      style: AppTextTheme.regular.copyWith(
                          color: ColorConstant.primaryColor, fontSize: 13),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  /*--------------- List Tile Widget ------------- */
  _listTitleWidget({
    required String image,
    required String name,
    required VoidCallback onPress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onPress,
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              Image.asset(
                image,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 15),
              Text(
                name,
                style: AppTextTheme.medium
                    .copyWith(fontSize: 16, color: ColorConstant.blackColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
