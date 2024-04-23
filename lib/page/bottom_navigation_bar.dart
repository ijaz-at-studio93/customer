import 'package:flutter/material.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/page/Insights/Insights_home_page.dart';
import 'package:sallon_customer/page/home/home_page.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

import '../constant/variable_constant.dart';
import '../util/SharedPrefs.dart';

class BottomNavBarPage extends StatefulWidget {
  const BottomNavBarPage({super.key});

  @override
  State<BottomNavBarPage> createState() => _BottomNavBarPageState();
}

class _BottomNavBarPageState extends State<BottomNavBarPage> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? const HomePage()
          : _selectedIndex == 1
              ? SizedBox()
              : const InsightsHomePage(),
      extendBody: false,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        unselectedLabelStyle: AppTextTheme.medium
            .copyWith(color: ColorConstant.grayTextColor, fontSize: 14),
        selectedLabelStyle: AppTextTheme.medium
            .copyWith(color: changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)), fontSize: 14),
        selectedItemColor: changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)),
        unselectedItemColor: ColorConstant.grayTextColor,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              AssetsConstant.home,
              height: 24,
              width: 24,
              color: _selectedIndex == 0
                  ? changeTheme(SharedPrefs.readStringValue(PrefConstants.gender))
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
                  ?changeTheme(SharedPrefs.readStringValue(PrefConstants.gender))
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
                  ? changeTheme(SharedPrefs.readStringValue(PrefConstants.gender))
                  : ColorConstant.grayTextColor,
            ),
            label: 'Insights',
          ),
        ],
        onTap: (val) {
          setState(() {
            _selectedIndex = val;
          });
        },
      ),
    );
  }
}
