import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/page/Insights/content_page.dart';
import 'package:salon_customer/page/booking/booking_home_page.dart';
import 'package:salon_customer/page/home/home_page.dart';
import 'package:salon_customer/project_specific/status_bar_color_appbar.dart';
import 'package:salon_customer/project_specific/text_theme.dart';

import '../constant/variable_constant.dart';
import '../util/SharedPrefs.dart';

class BottomNavBarPage extends StatefulWidget {
  const BottomNavBarPage({super.key});

  @override
  State<BottomNavBarPage> createState() => _BottomNavBarPageState();
}

class _BottomNavBarPageState extends State<BottomNavBarPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _canPopNow = false;
  DateTime? _currentBackPressTime;

  /// Bouncy attention animation for the Content tab — plays only while Content
  /// (index 2) is NOT the selected tab.
  late final AnimationController _contentBounceController;

  @override
  void initState() {
    super.initState();
    // Loops continuously; the icon only *shows* the bounce while Content is
    // unselected (the AnimatedBuilder zeroes the offset when selected), so it
    // keeps playing reliably whenever Content isn't the active tab.
    _contentBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _contentBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPopNow,
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          tapBackAgainToCloseApp();
        }
      },
      child: Scaffold(
        appBar: statusBarTheme(context),
        backgroundColor: ColorConstant.whiteColor,
        body: _selectedIndex == 0
            ? const HomePage()
            : _selectedIndex == 1
                ? const BookingHomePage()
                : const ContentPage(),
        extendBody: false,
        bottomNavigationBar: ValueListenableBuilder(
            valueListenable: selectedGender,
            builder: (context, v, c) {
              return BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                showUnselectedLabels: true,
                showSelectedLabels: true,
                unselectedLabelStyle: AppTextTheme.medium
                    .copyWith(color: ColorConstant.grayTextColor, fontSize: 14),
                selectedLabelStyle: AppTextTheme.medium.copyWith(
                    color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)),
                    fontSize: 14),
                selectedItemColor: changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender)),
                unselectedItemColor: ColorConstant.grayTextColor,
                selectedIconTheme: IconThemeData(
                    color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender))),
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      AssetsConstant.home,
                      height: 24,
                      width: 24,
                      color: _selectedIndex == 0
                          ? selectedGender.value == 0
                              ? ColorConstant.primaryColor
                              : ColorConstant.primary2
                          : ColorConstant.grayTextColor,
                    ),
                    label: 'Home',
                  ),
                  /* BottomNavigationBarItem(
                  icon: Image.asset(
                    AssetsConstant.home,
                    height: 35,
                    width: 35,
                    color: _selectedIndex == 1
                        ? ColorConstant.primaryColor
                        : ColorConstant.grayTextColor,
                  ),
                  label: 'Explore',
                ),*/
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      AssetsConstant.bookings,
                      height: 24,
                      width: 24,
                      color: _selectedIndex == 1
                          ? selectedGender.value == 0
                              ? ColorConstant.primaryColor
                              : ColorConstant.primary2
                          : ColorConstant.grayTextColor,
                    ),
                    label: 'Bookings',
                  ),
                  BottomNavigationBarItem(
                    // Row 32 + bounce: normalized colour; a scale-pop when
                    // selected, and a bouncy bob while unselected to draw
                    // attention to the Content tab.
                    icon: AnimatedBuilder(
                      animation: _contentBounceController,
                      builder: (context, child) {
                        final selected = _selectedIndex == 2;
                        final dy = selected
                            ? 0.0
                            : -6.0 *
                                Curves.easeInOut
                                    .transform(_contentBounceController.value);
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: Transform.scale(
                            scale: selected ? 1.25 : 1.0,
                            child: child,
                          ),
                        );
                      },
                      child: Image.asset(
                        AssetsConstant.insights,
                        height: 24,
                        width: 24,
                        color: _selectedIndex == 2
                            ? selectedGender.value == 0
                                ? ColorConstant.primaryColor
                                : ColorConstant.primary2
                            : ColorConstant.grayTextColor,
                      ),
                    ),
                    label: 'Content',
                  ),
                ],
                onTap: (val) {
                  setState(() {
                    _selectedIndex = val;
                  });
                  // Row 36: refresh bookings when the Bookings tab is opened so
                  // an accepted/cancelled appointment is reflected right away
                  // (the page is kept-alive and won't otherwise re-fetch).
                  if (val == 1) {
                    Get.find<HomeController>().refreshBookingListsSilent();
                  }
                },
              );
            }),
      ),
    );
  }

  /*---------------  TapBack Button ----------------*/
  void tapBackAgainToCloseApp() {
    DateTime now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 3)) {
      _currentBackPressTime = now;
      showMessage("Tap back again to close the app");
      setState(() {
        _canPopNow = true; // Temporarily let user exit app on the next back tap
      });
      Future.delayed(
        const Duration(seconds: 3),
        () {
          setState(() {
            _canPopNow = false;
            _currentBackPressTime = null;
          });
        },
      );
    }
  }
}
