import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/model/search_model/search_model.dart';
import 'package:salon_customer/project_specific/shine_wrapper.dart';
import 'package:salon_customer/project_specific/text_theme.dart';

/// Compact horizontal salon result tile for the search page.
///
/// Layout: thumbnail on the left; title, description and rating in the middle;
/// a vertically-centred chevron pinned to the right edge. An offer badge
/// ("Get X% OFF via LUZO") overlaps the top edge when the salon has a
/// percentage promo. The rating / "New" block is copied from the home salon
/// card ([SaloonCardWidget]) so both screens match.
class SearchSalonTile extends StatelessWidget {
  final VoidCallback onPress;
  final SalonData salonListData;

  const SearchSalonTile(
      {super.key, required this.onPress, required this.salonListData});

  // Fixed width shared by the rating pill and the "New" chip so both render at
  // exactly the same size (the rating value is always "X.X", so this comfortably
  // fits the star + rating).
  static const double _ratingChipWidth = 62;

  // Card corner radius, also used to clip the flush-left image.
  static const double _cardRadius = 16;

  // Fixed card height so the flush-left image can fill it edge-to-edge without
  // relying on the (async, intrinsic-size-less) network image for sizing.
  // Taller when an offer badge is shown so it fits inside the tile.
  static const double _cardHeight = 96;
  static const double _cardHeightWithOffer = 128;

  // Width of the flush-left image; its height fills the whole card.
  static const double _imageWidth = 96;

  @override
  Widget build(BuildContext context) {
    final salon = salonListData.salon;
    // Highest % promo for this salon, formatted like the home salon card.
    final String discountText = _discountTextForSalon(salon);
    final bool hasDiscount = discountText.isNotEmpty;

    final String title = (salon?.displayName?.isNotEmpty ?? false)
        ? salon!.displayName!
        : (salon?.name ?? "");

    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: hasDiscount ? _cardHeightWithOffer : _cardHeight,
        decoration: BoxDecoration(
          color: ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(_cardRadius),
          // No border — cards read as clean, separated only by the shadow.
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        // Clip so the flush-left image takes the card's rounded corners.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Row(
            // Vertically centre everything, including the trailing arrow.
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _thumbnail(salon?.image),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    // Vertically centre the text block against the image.
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Offer badge — part of the tile, above the title.
                      if (hasDiscount) ...[
                        _discountBadge(discountText),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextTheme.bold.copyWith(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          color: ColorConstant.blackColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        salon?.address ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextTheme.medium.copyWith(
                          fontFamily: 'Outfit',
                          fontSize: 10,
                          color: ColorConstant.grayTextColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _ratingOrNew(salon),
                    ],
                  ),
                ),
              ),
              // Arrow — vertically centred, hugging the right edge.
              const Padding(
                padding: EdgeInsets.only(right: 12, left: 4),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: ColorConstant.grayTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbnail(String? image) {
    // No own radius — the card's ClipRRect rounds the outer (left) corners.
    return SizedBox(
      width: _imageWidth,
      child: CachedNetworkImage(
        height: double.infinity,
        fit: BoxFit.cover,
        imageUrl: "${APIConstants.image}${image ?? ""}",
        placeholder: (context, url) => const Image(
          image: AssetImage(AssetsConstant.placeHolder),
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        errorWidget: (context, url, error) => const Image(
          image: AssetImage(AssetsConstant.placeHolder),
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Rating pill / "New" tag — identical to the home salon card so the two
  /// screens stay visually in sync.
  Widget _ratingOrNew(Salon? salon) {
    final int reviewCount = salon?.reviewCount ?? 0;
    final String rating =
        (double.tryParse(salon?.rating ?? "") ?? 0.0).toStringAsFixed(1);

    return reviewCount == 0
        // No reviews yet → show a "New" tag instead of a 0 rating.
        // Sized to match the rating pill below.
        ? ShineWrapper(
            child: Container(
              height: 24,
              width: _ratingChipWidth,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorConstant.greenColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "New",
                style: AppTextTheme.medium.copyWith(
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: ColorConstant.whiteColor,
                  height: 1.2,
                ),
              ),
            ),
          )
        : Container(
            height: 24,
            width: _ratingChipWidth,
            decoration: BoxDecoration(
              color: ColorConstant.greenColor,
              borderRadius: BorderRadius.circular(10), // 👈 pill shape
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: ColorConstant.whiteColor,
                  size: 20,
                ),
                const SizedBox(width: 2),
                Text(
                  rating,
                  style: AppTextTheme.medium.copyWith(
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: ColorConstant.whiteColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          );
  }

  /// Offer badge — same look as the home salon card ([SaloonCardWidget]):
  /// the offer icon followed by "X% Off".
  Widget _discountBadge(String discountText) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 10, 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AssetsConstant.newOfferIcon,
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 4),
          Text(
            "$discountText Off",
            style: AppTextTheme.bold.copyWith(
              fontFamily: "Inter",
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: const Color(0xFFE800E4),
            ),
          ),
        ],
      ),
    );
  }

  /// Highest percentage promo for this salon, formatted like the home salon
  /// card ([SaloonCardWidget._getHighestDiscountForSalon]), from the same promo
  /// list the home page uses. Returns "" when the salon has no offer.
  String _discountTextForSalon(Salon? salon) {
    final String? salonId = salon?.id;
    if (salonId == null || !Get.isRegistered<HomeController>()) return "";

    final promoList = Get.find<HomeController>().getPromoCodeModel.data;
    if (promoList == null) return "";

    double maxPercent = 0;
    for (final promo in promoList) {
      if (promo.salon?.id == salonId && promo.type == "percentage") {
        final double percent = (promo.amount ?? 0).toDouble();
        if (percent > maxPercent) maxPercent = percent;
      }
    }

    if (maxPercent == 0) return "";
    return _formatPercent(maxPercent);
  }

  String _formatPercent(double value) {
    if (value % 1 == 0) {
      return "${value.toInt()}%";
    } else {
      return "${value.toStringAsFixed(1)}%";
    }
  }
}
