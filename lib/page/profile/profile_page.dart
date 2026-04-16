import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import 'package:salon_customer/page/profile/add_address_page.dart';
import 'package:salon_customer/page/profile/edit_profile_page.dart';
import 'package:salon_customer/page/profile/faq_page.dart';
import 'package:salon_customer/page/profile/favourite_salon_page.dart';
import 'package:salon_customer/page/profile/review_rating_page.dart';
import 'package:salon_customer/project_specific/ProgressContainerView.dart';
import 'package:salon_customer/project_specific/log_out_dialog.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import '../../util/call_wrapper.dart';
import 'fav_blog_page.dart';
import 'widget/about_app_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback callback;

  const ProfilePage({super.key, required this.callback});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _authController.doGetProfile(callback: () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return CallWrapper(
      child: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          widget.callback.call();
        },
        child: Scaffold(
          backgroundColor: ColorConstant.bgColor,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: ColorConstant.whiteColor,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).maybePop();
                widget.callback.call();
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
          body: Obx(
            () => ProgressContainerView(
              isProgressRunning: _authController.showProgress,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _imageRowWidget(),
                    const SizedBox(height: 5),
                    const Divider(
                        color: ColorConstant.garyDividerColor,
                        indent: 20,
                        endIndent: 20,
                        thickness: 1),
                    _listTitleWidget(
                        image: AssetsConstant.likeBlank,
                        name: "Favourite Salon",
                        onPress: () {
                          Get.to(() => FavouriteSalonPage(
                                callback: () {
                                  widget.callback.call();
                                },
                              ));
                        }),
                    const Divider(
                        color: ColorConstant.garyDividerColor,
                        indent: 20,
                        endIndent: 20,
                        thickness: 1),
                    _listTitleWidget(
                        image: AssetsConstant.reviewRatings,
                        name: "Review & Ratings",
                        onPress: () {
                          Get.to(() => const ReviewAndRatingPage());
                        }),
                    const Divider(
                        color: ColorConstant.garyDividerColor,
                        indent: 20,
                        endIndent: 20,
                        thickness: 1),
                    _listTitleWidget(
                        image: AssetsConstant.insights,
                        name: "Saved Insights",
                        onPress: () {
                          Get.to(() => const BlogFavPage());
                        }),
                    const Divider(
                        color: ColorConstant.garyDividerColor,
                        indent: 20,
                        endIndent: 20,
                        thickness: 1),
                    _listTitleWidget(
                        image: AssetsConstant.locationDetails,
                        name: "Address",
                        onPress: () {
                          Get.to(() => const AddAddressPage(
                                isSelect: false,
                              ));
                        }),
                    const Divider(
                        color: ColorConstant.garyDividerColor,
                        indent: 20,
                        endIndent: 20,
                        thickness: 1),
                    _listTitleWidget(
                        image: AssetsConstant.faq,
                        name: "FAQ’s & Support",
                        onPress: () {
                          Get.to(() => const FaqPage());
                        }),
                    const Divider(
                        color: ColorConstant.garyDividerColor,
                        indent: 20,
                        endIndent: 20,
                        thickness: 1),
                    _listTitleWidget(
                        image: AssetsConstant.about,
                        name: "About Us",
                        onPress: () {
                          Get.to(() => const AboutAppPage());
                        }),
                    const Divider(
                        color: ColorConstant.garyDividerColor,
                        indent: 20,
                        endIndent: 20,
                        thickness: 1),
                    _listTitleWidget(
                        image: AssetsConstant.signOut,
                        name: "Sign Out",
                        onPress: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return LogOutDialog(
                                  noPress: () {
                                    Navigator.of(context).maybePop();
                                  },
                                  yesPress: () {
                                    _authController.resetApp();
                                  },
                                );
                              });
                        }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /*------------ Image Row Widget -----------*/
  Padding _imageRowWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CachedNetworkImage(
              width: 66,
              height: 66,
              fit: BoxFit.cover,
              imageUrl:
                  "${APIConstants.image}${_authController.getUserProfile.data?.profileImage ?? ""}",
              placeholder: (context, url) => const Image(
                image: AssetImage(AssetsConstant.placeHolder),
                width: 66,
                height: 66,
                fit: BoxFit.cover,
              ),
              errorWidget: (context, url, error) => const Image(
                image: AssetImage(AssetsConstant.placeHolder),
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
                _authController.getUserProfile.data?.name ?? "",
                style: AppTextTheme.bold
                    .copyWith(color: ColorConstant.blackColor, fontSize: 20),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Get.to(() => const EditProfilePage());
                },
                child: Container(
                  height: 35,
                  width: Get.width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(68),
                    border: Border.all(
                        color: changeTheme(SharedPrefs.readStringValue(
                                PrefConstants.gender)) ??
                            ColorConstant.primaryColor,
                        width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetsConstant.editIcon,
                        width: 14,
                        height: 14,
                        color: changeTheme(
                            SharedPrefs.readStringValue(PrefConstants.gender)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Edit Details",
                        style: AppTextTheme.regular.copyWith(
                            color: changeTheme(SharedPrefs.readStringValue(
                                    PrefConstants.gender)) ??
                                ColorConstant.primaryColor,
                            fontSize: 13),
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  /*--------------- List Tile Widget ------------- */
  Padding _listTitleWidget({
    required String image,
    required String name,
    required VoidCallback onPress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onPress,
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              Image.asset(
                image,
                width: 24,
                height: 24,
                color: changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender)),
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
