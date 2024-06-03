import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/controller/home_controller.dart';
import 'package:sallon_customer/page/home/saloon_after_selecting_page.dart';
import 'package:sallon_customer/page/home/widget/saloon_card_widget.dart';
import 'package:sallon_customer/page/profile/fav_salon_card_widget.dart';
import 'package:sallon_customer/project_specific/progressbar_view.dart';
import 'package:sallon_customer/project_specific/text_theme.dart';
import 'package:sallon_customer/util/NoItemsWidget.dart';

class FavouriteSalonPage extends StatefulWidget {
  final VoidCallback callback;
  const FavouriteSalonPage({super.key, required this.callback});

  @override
  State<FavouriteSalonPage> createState() => _FavouriteSalonPageState();
}

class _FavouriteSalonPageState extends State<FavouriteSalonPage> {
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetFavouriteSalon();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (val) {
        widget.callback.call();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 1.0,
          backgroundColor: ColorConstant.whiteColor,
          leading: IconButton(
            onPressed: () {
              Get.back();
              widget.callback.call();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: ColorConstant.blackColor,
            ),
          ),
          centerTitle: true,
          title: Text(
            "Favourite Salon",
            style: AppTextTheme.bold
                .copyWith(color: ColorConstant.blackColor, fontSize: 19),
          ),
        ),
        body: Obx(
          () => _homeController.gteShowAddProgress
              ? const ProgressBarView()
              : _homeController.getFavSalonList.data?.isEmpty ?? false
                  ? const NoItemsWidget(
                      text: "No Any Found Favourite Salon",
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _homeController.getFavSalonList.data?.length,
                      itemBuilder: (context, index) {
                        return FavSalonCardWidget(
                          favSalon:
                              _homeController.getFavSalonList.data![index],
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
