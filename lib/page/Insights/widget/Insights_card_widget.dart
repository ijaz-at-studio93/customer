import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/model/blog_data_model.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import '../../../project_specific/network_video_view_widget.dart';
import '../../../util/SharedPrefs.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';

class InsightsCardWidget extends StatefulWidget {
  final VoidCallback onPress;
  final BlogData blogData;
  final bool isFav;
  const InsightsCardWidget(
      {super.key,
      required this.onPress,
      required this.blogData,
      required this.isFav});

  @override
  State<InsightsCardWidget> createState() => _InsightsCardWidgetState();
}

class _InsightsCardWidgetState extends State<InsightsCardWidget> {
  final _homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _buildMedia(),

                  // widget.blogData.image?.isEmpty ?? false
                  //     ? Container(
                  //         width: Get.width,
                  //         height: Get.height * 0.22,
                  //         decoration: BoxDecoration(
                  //         color: ColorConstant.primaryColor.withOpacity(0.3),
                  //           borderRadius: BorderRadius.circular(4),
                  //         ),
                  //         child: Center(
                  //           child: Image.asset(
                  //             AssetsConstant.playIcon,
                  //             width: 50,
                  //             height: 50,
                  //           ),
                  //         ),
                  //       )
                  //     : ClipRRect(
                  //         borderRadius: BorderRadius.circular(4),
                  //         child: CachedNetworkImage(
                  //           width: Get.width,
                  //           height: Get.height * 0.22,
                  //           fit: BoxFit.cover,
                  //           imageUrl:
                  //               "${APIConstants.image}${widget.blogData.image}",
                  //           placeholder: (context, url) => Image(
                  //             image:
                  //                 const AssetImage(AssetsConstant.placeHolder),
                  //             width: Get.width,
                  //             height: Get.height * 0.22,
                  //             fit: BoxFit.cover,
                  //           ),
                  //           errorWidget: (context, url, error) => Image(
                  //             image:
                  //                 const AssetImage(AssetsConstant.placeHolder),
                  //             width: Get.width,
                  //             height: Get.height * 0.22,
                  //             fit: BoxFit.cover,
                  //           ),
                  //         ),
                  //       ),
                  Positioned(
                    top: 15,
                    right: 10,
                    left: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: ColorConstant.blackColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(6)),
                          child: Center(
                            child: Text(
                              "By ${widget.blogData.artist?.salon?.displayName ?? ""}",
                              style: AppTextTheme.medium.copyWith(
                                  color: ColorConstant.whiteColor,
                                  fontSize: 11),
                            ),
                          ),
                        ),
                        widget.isFav
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _homeController.doRemoveBlog(
                                        callback: () {
                                          if (widget.isFav) {
                                            _homeController.doGetFavBlogData();
                                          }
                                        },
                                        blogId: widget.blogData.id ?? "");
                                  });
                                },
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ColorConstant.blackColor
                                          .withOpacity(0.50)),
                                  child: Center(
                                    child: widget.blogData.isFavourite ?? true
                                        ? const Icon(
                                            CupertinoIcons.heart_fill,
                                            color: Colors.red,
                                          )
                                        : Image.asset(
                                            AssetsConstant.likeBlank,
                                            height: 20,
                                            width: 20,
                                            color: ColorConstant.whiteColor,
                                          ),
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    widget.blogData.isFavourite =
                                        !(widget.blogData.isFavourite ?? false);

                                    if (widget.blogData.isFavourite ?? false) {
                                      _homeController.doAddFavBlog(
                                          callback: () {},
                                          blogId: widget.blogData.id ?? "");
                                    } else {
                                      _homeController.doRemoveBlog(
                                          callback: () {
                                            _homeController.doGetBlogData(
                                              lat: double.parse(
                                                  SharedPrefs.readStringValue(
                                                      PrefConstants.latitude)),
                                              lng: double.parse(
                                                  SharedPrefs.readStringValue(
                                                      PrefConstants.longitude)),
                                            );
                                          },
                                          blogId: widget.blogData.id ?? "");
                                    }
                                  });
                                },
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ColorConstant.blackColor
                                          .withOpacity(0.50)),
                                  child: Center(
                                    child: widget.blogData.isFavourite ?? false
                                        ? const Icon(
                                            CupertinoIcons.heart_fill,
                                            color: Colors.red,
                                          )
                                        : Image.asset(
                                            AssetsConstant.likeBlank,
                                            height: 20,
                                            width: 20,
                                            color: ColorConstant.whiteColor,
                                          ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.blogData.title ?? "",
                style: AppTextTheme.medium
                    .copyWith(color: ColorConstant.blackColor, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye,
                        color: ColorConstant.grayTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${widget.blogData.viewCount ?? ""} Views",
                        style: AppTextTheme.medium.copyWith(
                            color: ColorConstant.grayTextColor, fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                          imageUrl:
                              "${APIConstants.image}${widget.blogData.artist?.profileImage ?? ""}",
                          placeholder: (context, url) => const Image(
                            image: AssetImage(AssetsConstant.placeHolder),
                            height: 30,
                            width: 30,
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => const Image(
                            image: AssetImage(AssetsConstant.placeHolder),
                            height: 30,
                            width: 30,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.blogData.artist?.name ?? "",
                        style: AppTextTheme.medium.copyWith(
                            color: ColorConstant.grayTextColor, fontSize: 11),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedia() {
    final image = widget.blogData.image;
    final video = widget.blogData.video;

    /// 🎥 CASE 1 → VIDEO exists
    if (video != null && video.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: NetworkVideoViewWidget(
          videoString: "${APIConstants.image}$video",
          thumbnail: "${APIConstants.image}${widget.blogData.thumbnail ?? ""}",
        ),
      );
    }

    /// 🖼 CASE 2 → IMAGE exists
    if (image != null && image.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          width: Get.width,
          height: Get.height * 0.22,
          fit: BoxFit.cover,
          imageUrl: "${APIConstants.image}$image",
          placeholder: (context, url) => Image.asset(
            AssetsConstant.placeHolder,
            fit: BoxFit.cover,
          ),
          errorWidget: (context, url, error) => Image.asset(
            AssetsConstant.placeHolder,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    /// ❌ CASE 3 → NONE
    return Container(
      width: Get.width,
      height: Get.height * 0.22,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Future<Uint8List?> _generateThumbnail(String videoUrl) async {
    return await VideoThumbnail.thumbnailData(
      video: "${APIConstants.image}$videoUrl",
      imageFormat: ImageFormat.JPEG,
      maxWidth: 400,
      quality: 75,
    );
  }

  Widget _videoFallback() {
    return Container(
      width: Get.width,
      height: Get.height * 0.22,
      decoration: BoxDecoration(
        color: ColorConstant.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Image.asset(
          AssetsConstant.playIcon,
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}
