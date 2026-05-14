import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:salon_customer/model/blog_data_model.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/page/stylist/widget/network_video_view_widget.dart';
import 'package:salon_customer/controller/home_controller.dart';

import '../../home/saloon_after_selecting_page.dart';

class FullScreenReelView extends StatefulWidget {
  final BlogData data;

  const FullScreenReelView({super.key, required this.data});

  @override
  State<FullScreenReelView> createState() => _FullScreenReelViewState();
}

class _FullScreenReelViewState extends State<FullScreenReelView> {
  final _homeController = Get.find<HomeController>();
  final _pauseNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _pauseNotifier.dispose();
    super.dispose();
  }

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
                    pauseNotifier: _pauseNotifier,
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
            top: 50,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 22),
              ),
            ),
          ),

          /// 🔥 SALON NAME
          Positioned(
            top: 50,
            left: 60,
            // child: Container(
            //   padding:
            //   const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            //   decoration: BoxDecoration(
            //     color: Colors.purple,
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Text(
            //     widget.data.salon?.displayName ??
            //         //widget.data.salon?.name ??
            //         "By Scuts",
            //     style: const TextStyle(color: Colors.white),
            //   ),
            // ),
            child: GestureDetector(
              onTap: (widget.data.salon?.id == null)
                  ? null
                  : () async {
                      _pauseNotifier.value = true;
                      await Get.to(() => SaloonAfterSelectingServicesPage(
                            isPayNowMode: true,
                            id: widget.data.salon!.id ?? "",
                            callback: () {},
                          ));
                      _pauseNotifier.value = false;
                    },
              child: Opacity(
                opacity: (widget.data.salon?.id == null) ? 0.6 : 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (widget.data.salon?.id == null)
                        ? Colors.grey
                        : Colors.purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.data.salon?.displayName ?? "By Scuts",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          /// 🔥 LIKE BUTTON (FIXED)
          Positioned(
            top: 50,
            right: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  widget.data.isFavourite =
                  !(widget.data.isFavourite ?? false);

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
                      : const Icon(Icons.favorite_border,
                      color: Colors.white),
                ),
              ),
            ),
          ),

          /// 🔥 BOTTOM CONTENT
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((widget.data.artist?.name ?? "").isNotEmpty)
                  Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: (widget.data.artist?.profileImage != null &&
                          widget.data.artist!.profileImage!.isNotEmpty)
                          ? NetworkImage(
                        "${APIConstants.image}${widget.data.artist!.profileImage}",
                      )
                          : null,
                      child: (widget.data.artist?.profileImage == null ||
                          widget.data.artist!.profileImage!.isEmpty)
                          ? const Icon(Icons.person, size: 12, color: Colors.white)
                          : null,
                    ),

                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.data.artist?.name ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.data.description ?? "",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}