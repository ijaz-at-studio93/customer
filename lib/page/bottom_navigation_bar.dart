import 'package:flutter/material.dart';
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/page/Insights/Insights_home_page.dart';
import 'package:sallon_customer/page/home/home_page.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';

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
              : InsightsHomePage(),
      extendBody: false,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        unselectedLabelStyle: AppTextTheme.medium
            .copyWith(color: ColorConstant.grayTextColor, fontSize: 14),
        selectedLabelStyle: AppTextTheme.medium
            .copyWith(color: ColorConstant.primaryColor, fontSize: 14),
        selectedItemColor: ColorConstant.primaryColor,
        unselectedItemColor: ColorConstant.grayTextColor,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              AssetsConstant.home,
              height: 35,
              width: 35,
              color: _selectedIndex == 0
                  ? ColorConstant.primaryColor
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
              height: 35,
              width: 35,
              color: _selectedIndex == 1
                  ? ColorConstant.primaryColor
                  : ColorConstant.grayTextColor,
            ),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              AssetsConstant.insights,
              height: 35,
              width: 35,
              color: _selectedIndex == 2
                  ? ColorConstant.primaryColor
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
