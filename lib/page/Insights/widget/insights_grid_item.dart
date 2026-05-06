import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/model/blog_data_model.dart';
import 'package:get/get.dart';
import '../../home/saloon_after_selecting_page.dart';

class InsightsGridItem extends StatelessWidget {
  final BlogData blogData;
  final VoidCallback onTap;

  const InsightsGridItem({
    super.key,
    required this.blogData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = blogData.image;
    final video = blogData.video;
    final thumbnail = blogData.thumbnail;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: (video != null && video.isNotEmpty)
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: "${APIConstants.image}$thumbnail",
                          cacheKey: '${APIConstants.image}$thumbnail',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.asset(
                            AssetsConstant.placeHolder,
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            AssetsConstant.placeHolder,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                        // Play button (visual only)
                        const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    )
                  : (image != null && image.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: "${APIConstants.image}$image",
                          cacheKey: '${APIConstants.image}$image',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.asset(
                            AssetsConstant.placeHolder,
                            fit: BoxFit.cover,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            AssetsConstant.placeHolder,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade300,
                        ),
            ),

            /// TOP LEFT → SALON
            Positioned(
              top: 8,
              left: 4,
              child: GestureDetector(
                onTap: (blogData.salon?.id == null)
                    ? null
                    : () {
                        Get.to(() => SaloonAfterSelectingServicesPage(
                              isPayNowMode: true,
                              id: blogData.salon!.id ?? "",
                              callback: () {},
                            ));
                      },
                child: Opacity(
                  opacity: (blogData.salon?.id == null) ? 0.8 : 1,
                  child: Container(
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
                    child: Text(
                      blogData.salon?.displayName ?? "By Scuts",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ColorConstant.primaryColor,
                        fontSize: 10,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// TOP RIGHT → LIKE
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: Icon(
                    blogData.isFavourite == true
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: blogData.isFavourite == true
                        ? Colors.red
                        : Colors.white,
                  )),
            ),

            /// BOTTOM → USER
            if ((blogData.artist?.name ?? "").isNotEmpty)
              Positioned(
                bottom: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: (blogData.artist?.profileImage != null &&
                              blogData.artist!.profileImage!.isNotEmpty)
                          ? NetworkImage(
                              "${APIConstants.image}${blogData.artist!.profileImage}",
                            )
                          : null,
                      child: (blogData.artist?.profileImage == null ||
                              blogData.artist!.profileImage!.isEmpty)
                          ? const Icon(Icons.person,
                              size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      blogData.artist!.name!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
