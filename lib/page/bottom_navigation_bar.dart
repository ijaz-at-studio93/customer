import 'package:flutter/material.dart';
import 'package:salon_customer/api/dio_client.dart';
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

class _BottomNavBarPageState extends State<BottomNavBarPage> {
  int _selectedIndex = 0;
  bool _canPopNow = false;
  DateTime? _currentBackPressTime;
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
                    icon: Image.asset(
                      AssetsConstant.insights,
                      height: 24,
                      width: 24,
                      color: _selectedIndex == 2
                          ? selectedGender.value == 0
                              ? ColorConstant.primaryColor
                              : ColorConstant.primary2
                          : ColorConstant.grayTextColor,
                    ),
                    label: 'Content',
                  ),
                ],
                onTap: (val) {
                  setState(() {
                    _selectedIndex = val;
                  });
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
