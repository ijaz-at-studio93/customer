import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

/// Row 29: "Pay After Service" onboarding carousel shown once on first launch.
///
/// Pages are data-driven ([_onboardingPages]) so text and illustrations are
/// easy to swap without touching the layout. Illustrations fall back to a
/// neutral placeholder until the real assets are added under
/// `assets/images/pay_after_service/` (and registered in `pubspec.yaml`).
class OnboardingPageData {
  final String titleBlackTop;
  final String titlePurple;
  final String titleBlackBottom;
  final String subtitle;
  final String imagePath;
  final bool showBadge;

  const OnboardingPageData({
    this.titleBlackTop = "",
    this.titlePurple = "",
    this.titleBlackBottom = "",
    required this.subtitle,
    required this.imagePath,
    this.showBadge = false,
  });
}

/// Brand purple used across onboarding (runs before a gender/theme is chosen,
/// so it deliberately does NOT use the gender theme colour).
const Color _brandPurple = Color(0xFF7C4DFF);

const List<OnboardingPageData> _onboardingPages = [
  OnboardingPageData(
    showBadge: true,
    titleBlackTop: "Introducing",
    titlePurple: "Pay After Service",
    subtitle: "Enjoy your salon service first,\npay only after it's done",
    imagePath: "assets/images/pay_after_service/introducing.png",
  ),
  OnboardingPageData(
    titleBlackTop: "Book Your",
    titlePurple: "Appointment",
    titleBlackBottom: "In the App",
    subtitle: "Choose your salon, service\nand time that suits you",
    imagePath: "assets/images/pay_after_service/book_appointment.png",
  ),
  OnboardingPageData(
    titleBlackTop: "Reach Salon & Enjoy",
    titlePurple: "Salon Service",
    titleBlackBottom: "First",
    subtitle: "Relax and get the best\nexperience from top salons",
    imagePath: "assets/images/pay_after_service/enjoy_salon_service.png",
  ),
  OnboardingPageData(
    titlePurple: "Enter the Bill in App",
    titleBlackBottom: "Pay the Discounted\nprice in App",
    subtitle: "Once you're happy with the\nservice, pay securely in app.",
    imagePath: "assets/images/pay_after_service/pay_discounted_price.png",
  ),
];

class PayAfterServiceOnboardingPage extends StatefulWidget {
  /// Where to go once onboarding is finished/skipped (resolved by the splash
  /// router for the logged-in user).
  final Widget nextPage;

  const PayAfterServiceOnboardingPage({super.key, required this.nextPage});

  /// Wraps [destination] in the first-launch onboarding for a logged-in user
  /// who hasn't seen it yet; otherwise returns [destination] unchanged. Use at
  /// every "enter the app" point (splash + post-login) so onboarding shows
  /// exactly once for a first-time logged-in user.
  static Widget gate(Widget destination) {
    if (SharedPrefs.readBoolValue(PrefConstants.hasSeenOnboarding)) {
      return destination;
    }
    return PayAfterServiceOnboardingPage(nextPage: destination);
  }

  @override
  State<PayAfterServiceOnboardingPage> createState() =>
      _PayAfterServiceOnboardingPageState();
}

class _PayAfterServiceOnboardingPageState
    extends State<PayAfterServiceOnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _onboardingPages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await SharedPrefs.writeBoolValue(PrefConstants.hasSeenOnboarding, true);
    Get.offAll(() => widget.nextPage);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            /// SKIP
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  "Skip",
                  style: AppTextTheme.medium.copyWith(
                    color: ColorConstant.grayTextColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            /// PAGES
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _onboardingPages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _buildPage(_onboardingPages[i]),
              ),
            ),

            /// DOTS
            _dots(),
            const SizedBox(height: 24),

            /// NEXT / GET STARTED
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandPurple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _next,
                  child: Text(
                    _isLast ? "Get Started" : "Next",
                    style: AppTextTheme.bold.copyWith(
                      color: ColorConstant.whiteColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          if (page.showBadge) ...[
            _badge(),
            const SizedBox(height: 18),
          ],
          _title(page),
          const SizedBox(height: 12),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: AppTextTheme.medium.copyWith(
              color: ColorConstant.grayTextColor,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: _illustration(page)),
        ],
      ),
    );
  }

  Widget _badge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: _brandPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            "NEW FEATURE",
            style: AppTextTheme.bold.copyWith(
              color: ColorConstant.whiteColor,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(OnboardingPageData page) {
    TextStyle style(Color color) => AppTextTheme.bold.copyWith(
          color: color,
          fontSize: 28,
          height: 1.15,
        );
    return Column(
      children: [
        if (page.titleBlackTop.isNotEmpty)
          Text(page.titleBlackTop,
              textAlign: TextAlign.center,
              style: style(ColorConstant.blackColor)),
        if (page.titlePurple.isNotEmpty)
          Text(page.titlePurple,
              textAlign: TextAlign.center, style: style(_brandPurple)),
        if (page.titleBlackBottom.isNotEmpty)
          Text(page.titleBlackBottom,
              textAlign: TextAlign.center,
              style: style(ColorConstant.blackColor)),
      ],
    );
  }

  Widget _illustration(OnboardingPageData page) {
    return Image.asset(
      page.imagePath,
      fit: BoxFit.contain,
      // Neutral placeholder until the real asset is added.
      errorBuilder: (context, error, stackTrace) => Center(
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: _brandPurple.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            Icons.image_outlined,
            size: 56,
            color: _brandPurple.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_onboardingPages.length, (i) {
        final active = i == _index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? _brandPurple : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
