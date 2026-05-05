import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:salon_customer/model/blog_data_model.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/page/stylist/widget/network_video_view_widget.dart';
import 'package:salon_customer/controller/home_controller.dart';

import '../../../constant/color_constant.dart';
import '../../home/saloon_after_selecting_page.dart';

class FullScreenReelView extends StatefulWidget {
  final BlogData data;

  const FullScreenReelView({super.key, required this.data});

  @override
  State<FullScreenReelView> createState() => _FullScreenReelViewState();
}

class _FullScreenReelViewState extends State<FullScreenReelView> {
  final _homeController = Get.find<HomeController>();
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final image = widget.data.image;
    final video = widget.data.video;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 🔥 MEDIA
          Positioned.fill(
            child: (video != null && video.isNotEmpty)
                ? NetworkVideoViewWidget(
                    videoString: "${APIConstants.image}$video",
                  )
                : (image != null && image.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: "${APIConstants.image}$image",
                        fit: BoxFit.cover,
                      )
                    : Container(color: Colors.black),
          ),

          /// 🔥 BACK BUTTON
          Positioned(
            top: 40,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
            ),
          ),

          /// 🔥 SALON NAME
          Positioned(
            top: 40,
            left: 60,
            child: GestureDetector(
              onTap: (widget.data.salon?.id == null)
                  ? null
                  : () {
                      Get.to(() => SaloonAfterSelectingServicesPage(
                            isPayNowMode: true,
                            id: widget.data.salon!.id ?? "",
                            callback: () {},
                          ));
                    },
              child: Opacity(
                opacity: (widget.data.salon?.id == null) ? 0.8 : 0.9,
                child: Container(
                    height: 44,
                    constraints: BoxConstraints(
                      maxWidth: Get.width *
                          0.4, // 👈 prevents it from growing too much
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        widget.data.salon?.displayName ?? "By Scuts",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ColorConstant.primaryColor,
                          fontSize: 12,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
              ),
            ),
          ),

          /// 🔥 LIKE BUTTON (FIXED)
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  widget.data.isFavourite = !(widget.data.isFavourite ?? false);

                  if (widget.data.isFavourite ?? false) {
                    _homeController.doAddFavBlog(
                      callback: () {},
                      blogId: widget.data.id ?? "",
                    );
                  } else {
                    _homeController.doRemoveBlog(
                      callback: () {},
                      blogId: widget.data.id ?? "",
                    );
                  }
                });
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: widget.data.isFavourite ?? false
                      ? const Icon(Icons.favorite, color: Colors.red)
                      : const Icon(Icons.favorite_border, color: Colors.white),
                ),
              ),
            ),
          ),

          /// 🔥 BOTTOM CONTENT
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 👈 KEY
              children: [
                /// 🔵 LEFT → DESCRIPTION
                LayoutBuilder(
                  builder: (context, constraints) {
                    final description = widget.data.description ?? "";
                    final hasOverflow =
                        isTextOverflowing(description, constraints.maxWidth);

                    return GestureDetector(
                      onTap: hasOverflow
                          ? () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            }
                          : null,
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(text: description),
                            if (hasOverflow && !isExpanded)
                              const TextSpan(
                                text: "  Read more",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (hasOverflow && isExpanded)
                              const TextSpan(
                                text: "  Read less",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        maxLines: isExpanded ? null : 3,
                        overflow: isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),

                const SizedBox(width: 10), // optional spacing

                /// 🔴 RIGHT → ARTIST
                if ((widget.data.artist?.name ?? "").isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: (widget.data.artist?.profileImage !=
                                    null &&
                                widget.data.artist!.profileImage!.isNotEmpty)
                            ? NetworkImage(
                                "${APIConstants.image}${widget.data.artist!.profileImage}",
                              )
                            : null,
                        child: (widget.data.artist?.profileImage == null ||
                                widget.data.artist!.profileImage!.isEmpty)
                            ? const Icon(Icons.person,
                                size: 12, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.data.artist?.name ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isTextOverflowing(String text, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13,
          fontFamily: 'Outfit',
        ),
      ),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: maxWidth);

    return textPainter.didExceedMaxLines;
  }
}
