import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:salon_customer/constant/api_constant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/stylist/selecting_artist_bottom_sheet.dart';
import 'package:salon_customer/page/stylist/widget/review_and_ratings_widget.dart';
import 'package:salon_customer/page/stylist/widget/service_offered_list_tile_widget.dart';
import 'package:salon_customer/page/stylist/widget/stylist_portfolio_gird_view.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/status_bar_color_appbar.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:share_plus/share_plus.dart';
import '../../constant/assetsconstant.dart';
import '../../project_specific/remove_and_add_service_dialog.dart';
import '../appointment/appointment_booking_page.dart';
import '../home/widget/add_product_sheet_widget.dart';
import '../home/widget/selected_services_sheet_page.dart';

class StylistSaloonDetailsPage extends StatefulWidget {
  final String artiestId;
  final String salonId;
  final bool isViewDetails;

  const StylistSaloonDetailsPage(
      {super.key,
      required this.artiestId,
      required this.salonId,
      required this.isViewDetails});

  @override
  State<StylistSaloonDetailsPage> createState() =>
      _StylistSaloonDetailsPageState();
}

class _StylistSaloonDetailsPageState extends State<StylistSaloonDetailsPage>
    with SingleTickerProviderStateMixin {
  final _homeController = Get.find<HomeController>();
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _homeController.getArtiestDetailsModel.data = null;
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeController.doGetArtiestPortfolio(artistId: widget.artiestId);
      //_homeController.doGetCart();
    });
  }

  String serviceId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: statusBarTheme(context),
      backgroundColor: ColorConstant.bgColor,
      body: Obx(
        () => _homeController.showProgress
            ? const ProgressBarView()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _imageHeaderWidget(),
                    _nameContainColum(),
                    _tabBarView(),
                    isSelectedTab == 0
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.only(bottom: Get.height * 0.16),
                            itemCount: _homeController.getArtiestDetailsModel
                                    .data?.categorizedServiceList?.length ??
                                0,
                            itemBuilder: (context, index) {
                              return ExpansionTile(
                                initiallyExpanded: index == 0 ? true : false,
                                title: Text(
                                  _homeController
                                          .getArtiestDetailsModel
                                          .data
                                          ?.categorizedServiceList?[index]
                                          .name ??
                                      "",
                                  style: AppTextTheme.bold.copyWith(
                                      fontSize: 17.5,
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black // female
                                      ),
                                ),
                                children: [
                                  ListView.separated(
                                      separatorBuilder: (context, i) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                              top: 25, bottom: 10),
                                          height: 1,
                                          width: Get.width,
                                          color: ColorConstant.dividerColor,
                                        );
                                      },
                                      shrinkWrap: true,
                                      itemCount: _homeController
                                              .getArtiestDetailsModel
                                              .data
                                              ?.categorizedServiceList?[index]
                                              .services
                                              ?.length ??
                                          0,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, i) {
                                        return ServiceOfferListTileWidget(
                                          rate: _homeController
                                                  .getArtiestDetailsModel
                                                  .data
                                                  ?.categorizedServiceList?[
                                                      index]
                                                  .services?[i]
                                                  .rating ??
                                              0.0,
                                          image:
                                              "${APIConstants.image}${_homeController.getArtiestDetailsModel.data?.categorizedServiceList?[index].services?[i].image ?? 0.0}",
                                          name: _homeController
                                                  .getArtiestDetailsModel
                                                  .data
                                                  ?.categorizedServiceList?[
                                                      index]
                                                  .services?[i]
                                                  .name ??
                                              "",
                                          description: _homeController
                                                  .getArtiestDetailsModel
                                                  .data
                                                  ?.categorizedServiceList?[
                                                      index]
                                                  .services?[i]
                                                  .description ??
                                              "",
                                          price: _homeController
                                                  .getArtiestDetailsModel
                                                  .data
                                                  ?.categorizedServiceList?[
                                                      index]
                                                  .services?[i]
                                                  .price
                                                  .toString() ??
                                              "",
                                          duration: _homeController
                                                  .getArtiestDetailsModel
                                                  .data
                                                  ?.categorizedServiceList?[
                                                      index]
                                                  .services?[i]
                                                  .duration
                                                  .toString() ??
                                              "",
                                          reviewCount: _homeController
                                                  .getArtiestDetailsModel
                                                  .data
                                                  ?.categorizedServiceList?[
                                                      index]
                                                  .services?[i]
                                                  .reviewCount
                                                  .toString() ??
                                              "",
                                          isSelect: _homeController
                                                  .getArtiestDetailsModel
                                                  .data
                                                  ?.categorizedServiceList?[
                                                      index]
                                                  .services?[i]
                                                  .isAddedToCart ??
                                              false,
                                          addButtonTap: () async {
                                            if (stylistId.value.isEmpty) {
                                              _homeController
                                                  .getArtiestDetailsModel
                                                  .data
                                                  ?.categorizedServiceList?[
                                                      index]
                                                  .services?[i]
                                                  .isAddedToCart = !(_homeController
                                                      .getArtiestDetailsModel
                                                      .data
                                                      ?.categorizedServiceList?[
                                                          index]
                                                      .services?[i]
                                                      .isAddedToCart ??
                                                  false);

                                              if (_homeController
                                                      .getArtiestDetailsModel
                                                      .data
                                                      ?.categorizedServiceList?[
                                                          index]
                                                      .services?[i]
                                                      .isAddedToCart ??
                                                  false) {
                                                // showModalBottomSheet(
                                                //     context: context,
                                                //     isScrollControlled: true,
                                                //     shape:
                                                //     const RoundedRectangleBorder(
                                                //         borderRadius:
                                                //         BorderRadius
                                                //             .only(
                                                //           topLeft:
                                                //           Radius.circular(32),
                                                //           topRight:
                                                //           Radius.circular(32),
                                                //         )),
                                                //     builder: (context) {
                                                //       return AddProductSheetWidget(
                                                //         price: _homeController
                                                //             .getArtiestDetailsModel
                                                //             .data
                                                //             ?.categorizedServiceList?[
                                                //         index]
                                                //             .services?[i]
                                                //             .price ??
                                                //             0,
                                                //         rating: _homeController
                                                //             .getArtiestDetailsModel
                                                //             .data
                                                //             ?.categorizedServiceList?[
                                                //         index]
                                                //             .services?[i]
                                                //             .rating ??
                                                //             0.0,
                                                //         review: _homeController
                                                //             .getArtiestDetailsModel
                                                //             .data
                                                //             ?.categorizedServiceList?[
                                                //         index]
                                                //             .services?[i]
                                                //             .reviewCount
                                                //             ?.toInt() ??
                                                //             0,
                                                //         nameOfService: _homeController
                                                //             .getArtiestDetailsModel
                                                //             .data
                                                //             ?.categorizedServiceList?[
                                                //         index]
                                                //             .services?[i]
                                                //             .name ??
                                                //             "",
                                                //         serviceId: _homeController
                                                //             .getArtiestDetailsModel
                                                //             .data
                                                //             ?.categorizedServiceList?[
                                                //         index]
                                                //             .services?[i]
                                                //             .id ??
                                                //             "",
                                                //       );
                                                //     });
                                                _homeController.doAddCart(
                                                    salonServiceId: _homeController
                                                            .getArtiestDetailsModel
                                                            .data
                                                            ?.categorizedServiceList?[
                                                                index]
                                                            .services?[i]
                                                            .id ??
                                                        "",
                                                    isHomeService: SharedPrefs
                                                        .readBoolValue(
                                                            PrefConstants
                                                                .isHomeService),
                                                    callback: () {
                                                      stylistId.value =
                                                          widget.artiestId;
                                                      // _homeController
                                                      //     .doGetCart();
                                                      _homeController.doGetSalonDetailsService(
                                                          serviceGender:
                                                              SharedPrefs.readStringValue(
                                                                          PrefConstants
                                                                              .gender) ==
                                                                      "0"
                                                                  ? "male"
                                                                  : "female",
                                                          salonId:
                                                              widget.salonId);

                                                      // showModalBottomSheet(
                                                      //     context: context,
                                                      //     isScrollControlled:
                                                      //     true,
                                                      //     shape:
                                                      //     const RoundedRectangleBorder(
                                                      //         borderRadius:
                                                      //         BorderRadius
                                                      //             .only(
                                                      //           topLeft:
                                                      //           Radius.circular(
                                                      //               32),
                                                      //           topRight:
                                                      //           Radius.circular(
                                                      //               32),
                                                      //         )),
                                                      //     builder: (context) {
                                                      //       return AddProductSheetWidget(
                                                      //         price: _homeController
                                                      //             .getArtiestDetailsModel
                                                      //             .data
                                                      //             ?.categorizedServiceList?[
                                                      //         index]
                                                      //             .services?[
                                                      //         i]
                                                      //             .price ??
                                                      //             0,
                                                      //         rating: _homeController
                                                      //             .getArtiestDetailsModel
                                                      //             .data
                                                      //             ?.categorizedServiceList?[
                                                      //         index]
                                                      //             .services?[
                                                      //         i]
                                                      //             .rating ??
                                                      //             0.0,
                                                      //         review: _homeController
                                                      //             .getArtiestDetailsModel
                                                      //             .data
                                                      //             ?.categorizedServiceList?[
                                                      //         index]
                                                      //             .services?[
                                                      //         i]
                                                      //             .reviewCount
                                                      //             ?.toInt() ??
                                                      //             0,
                                                      //         nameOfService: _homeController
                                                      //             .getArtiestDetailsModel
                                                      //             .data
                                                      //             ?.categorizedServiceList?[
                                                      //         index]
                                                      //             .services?[
                                                      //         i]
                                                      //             .name ??
                                                      //             "",
                                                      //         serviceId: _homeController
                                                      //             .getArtiestDetailsModel
                                                      //             .data
                                                      //             ?.categorizedServiceList?[
                                                      //         index]
                                                      //             .services?[
                                                      //         i]
                                                      //             .id ??
                                                      //             "",
                                                      //       );
                                                      //     });
                                                    });
                                              } else {
                                                _homeController.doRemoveCart(
                                                    salonServiceId: _homeController
                                                            .getArtiestDetailsModel
                                                            .data
                                                            ?.categorizedServiceList?[
                                                                index]
                                                            .services?[i]
                                                            .id ??
                                                        "",
                                                    callback: () {
                                                      // _homeController
                                                      //     .doGetCart();
                                                    });
                                              }
                                            } else {
                                              if (stylistId.value ==
                                                  widget.artiestId) {
                                                _homeController
                                                    .getArtiestDetailsModel
                                                    .data
                                                    ?.categorizedServiceList?[
                                                        index]
                                                    .services?[i]
                                                    .isAddedToCart = !(_homeController
                                                        .getArtiestDetailsModel
                                                        .data
                                                        ?.categorizedServiceList?[
                                                            index]
                                                        .services?[i]
                                                        .isAddedToCart ??
                                                    false);

                                                if (_homeController
                                                        .getArtiestDetailsModel
                                                        .data
                                                        ?.categorizedServiceList?[
                                                            index]
                                                        .services?[i]
                                                        .isAddedToCart ??
                                                    false) {
                                                  // showModalBottomSheet(
                                                  //     context: context,
                                                  //     isScrollControlled: true,
                                                  //     shape:
                                                  //     const RoundedRectangleBorder(
                                                  //         borderRadius:
                                                  //         BorderRadius
                                                  //             .only(
                                                  //           topLeft:
                                                  //           Radius.circular(32),
                                                  //           topRight:
                                                  //           Radius.circular(32),
                                                  //         )),
                                                  //     builder: (context) {
                                                  //       return AddProductSheetWidget(
                                                  //         price: _homeController
                                                  //             .getArtiestDetailsModel
                                                  //             .data
                                                  //             ?.categorizedServiceList?[
                                                  //         index]
                                                  //             .services?[i]
                                                  //             .price ??
                                                  //             0,
                                                  //         rating: _homeController
                                                  //             .getArtiestDetailsModel
                                                  //             .data
                                                  //             ?.categorizedServiceList?[
                                                  //         index]
                                                  //             .services?[i]
                                                  //             .rating ??
                                                  //             0.0,
                                                  //         review: _homeController
                                                  //             .getArtiestDetailsModel
                                                  //             .data
                                                  //             ?.categorizedServiceList?[
                                                  //         index]
                                                  //             .services?[i]
                                                  //             .reviewCount
                                                  //             ?.toInt() ??
                                                  //             0,
                                                  //         nameOfService: _homeController
                                                  //             .getArtiestDetailsModel
                                                  //             .data
                                                  //             ?.categorizedServiceList?[
                                                  //         index]
                                                  //             .services?[i]
                                                  //             .name ??
                                                  //             "",
                                                  //         serviceId: _homeController
                                                  //             .getArtiestDetailsModel
                                                  //             .data
                                                  //             ?.categorizedServiceList?[
                                                  //         index]
                                                  //             .services?[i]
                                                  //             .id ??
                                                  //             "",
                                                  //       );
                                                  //     });
                                                  _homeController.doAddCart(
                                                      salonServiceId: _homeController
                                                              .getArtiestDetailsModel
                                                              .data
                                                              ?.categorizedServiceList?[
                                                                  index]
                                                              .services?[i]
                                                              .id ??
                                                          "",
                                                      isHomeService: SharedPrefs
                                                          .readBoolValue(
                                                              PrefConstants
                                                                  .isHomeService),
                                                      callback: () {
                                                        stylistId.value =
                                                            widget.artiestId;
                                                        // _homeController
                                                        //     .doGetCart();
                                                        _homeController
                                                            .doGetSalonDetailsService(
                                                                serviceGender:
                                                                    SharedPrefs.readStringValue(PrefConstants.gender) ==
                                                                            "0"
                                                                        ? "male"
                                                                        : "female",
                                                                salonId: widget
                                                                    .salonId);

                                                        // showModalBottomSheet(
                                                        //     context: context,
                                                        //     isScrollControlled:
                                                        //     true,
                                                        //     shape:
                                                        //     const RoundedRectangleBorder(
                                                        //         borderRadius:
                                                        //         BorderRadius
                                                        //             .only(
                                                        //           topLeft: Radius
                                                        //               .circular(32),
                                                        //           topRight: Radius
                                                        //               .circular(32),
                                                        //         )),
                                                        //     builder: (context) {
                                                        //       return AddProductSheetWidget(
                                                        //         price: _homeController
                                                        //             .getArtiestDetailsModel
                                                        //             .data
                                                        //             ?.categorizedServiceList?[
                                                        //         index]
                                                        //             .services?[
                                                        //         i]
                                                        //             .price ??
                                                        //             0,
                                                        //         rating: _homeController
                                                        //             .getArtiestDetailsModel
                                                        //             .data
                                                        //             ?.categorizedServiceList?[
                                                        //         index]
                                                        //             .services?[
                                                        //         i]
                                                        //             .rating ??
                                                        //             0.0,
                                                        //         review: _homeController
                                                        //             .getArtiestDetailsModel
                                                        //             .data
                                                        //             ?.categorizedServiceList?[
                                                        //         index]
                                                        //             .services?[
                                                        //         i]
                                                        //             .reviewCount
                                                        //             ?.toInt() ??
                                                        //             0,
                                                        //         nameOfService: _homeController
                                                        //             .getArtiestDetailsModel
                                                        //             .data
                                                        //             ?.categorizedServiceList?[
                                                        //         index]
                                                        //             .services?[
                                                        //         i]
                                                        //             .name ??
                                                        //             "",
                                                        //         serviceId: _homeController
                                                        //             .getArtiestDetailsModel
                                                        //             .data
                                                        //             ?.categorizedServiceList?[
                                                        //         index]
                                                        //             .services?[
                                                        //         i]
                                                        //             .id ??
                                                        //             "",
                                                        //       );
                                                        //     });
                                                      });
                                                } else {
                                                  _homeController.doRemoveCart(
                                                      salonServiceId: _homeController
                                                              .getArtiestDetailsModel
                                                              .data
                                                              ?.categorizedServiceList?[
                                                                  index]
                                                              .services?[i]
                                                              .id ??
                                                          "",
                                                      callback: () {
                                                        // _homeController
                                                        //     .doGetCart();
                                                      });
                                                }
                                              } else {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return RemoveAndAddServiceDialog(
                                                          noPress: () {
                                                        Navigator.of(context)
                                                            .maybePop();
                                                      }, yesPress: () {
                                                        setState(() {
                                                          _homeController
                                                              .doClearCart(
                                                                  callback: () {
                                                            _homeController
                                                                .doGetArtiestPortfolio(
                                                                    artistId: widget
                                                                        .artiestId);
                                                            // _homeController
                                                            //     .doGetCart();
                                                            serviceId = "";
                                                            stylistId.value =
                                                                "";
                                                            Navigator.of(
                                                                    context)
                                                                .maybePop();
                                                          });
                                                        });
                                                      });
                                                    });
                                              }
                                            }
                                          },
                                        );
                                      }),
                                  const SizedBox(height: 22),
                                ],
                              );
                            })
                        : isSelectedTab == 1
                            ? StylistPortfolioGridview(
                                artiestPortfolio:
                                    _homeController.getArtiestDetailsModel,
                              )
                            : ReviewAndRating(
                                artiestPortfolio:
                                    _homeController.getArtiestDetailsModel,
                              )
                  ],
                ),
              ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: Obx(
      //       () => _homeController.getServiceAddCartModel.data?.servicesWithProduct
      //       ?.isEmpty ??
      //       false ||
      //           _homeController
      //               .getServiceAddCartModel.data?.servicesWithProduct ==
      //               null
      //       ? const SizedBox()
      //       : Stack(
      //     alignment: Alignment.center,
      //     clipBehavior: Clip.none,
      //     children: [
      //       Container(
      //         width: Get.width,
      //         height: 100,
      //         decoration: const BoxDecoration(
      //           color: ColorConstant.whiteColor,
      //           boxShadow: [
      //             BoxShadow(
      //               color: Color(0x1E000000),
      //               blurRadius: 8,
      //               offset: Offset(-2, -2),
      //               spreadRadius: 0,
      //             )
      //           ],
      //         ),
      //         clipBehavior: Clip.none,
      //         padding: const EdgeInsets.symmetric(horizontal: 16),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Row(
      //               children: [
      //                 _homeController.getServiceAddCartModel.data
      //                     ?.previewImages?.isEmpty ??
      //                     false
      //                     ? const SizedBox()
      //                     : Row(
      //                   children: [
      //                     _homeController
      //                         .getServiceAddCartModel
      //                         .data
      //                         ?.previewImages
      //                         ?.length ==
      //                         1
      //                         ? Row(
      //                       children: [
      //                         for (int i = 0; i < 1; i++)
      //                           Align(
      //                             widthFactor: 0.8,
      //                             child: ClipRRect(
      //                               borderRadius:
      //                               BorderRadius.circular(
      //                                   100),
      //                               child: CachedNetworkImage(
      //                                 fit: BoxFit.cover,
      //                                 width: 30,
      //                                 height: 30,
      //                                 imageUrl:
      //                                 "${APIConstants.image}${_homeController.getServiceAddCartModel.data?.previewImages?[i] ?? ""}",
      //                                 placeholder:
      //                                     (context, url) =>
      //                                 const Image(
      //                                   image: AssetImage(
      //                                       AssetsConstant
      //                                           .placeHolder),
      //                                   fit: BoxFit.cover,
      //                                   width: 30,
      //                                   height: 30,
      //                                 ),
      //                                 errorWidget: (context,
      //                                     url, error) =>
      //                                 const Image(
      //                                   image: AssetImage(
      //                                       AssetsConstant
      //                                           .placeHolder),
      //                                   fit: BoxFit.cover,
      //                                   width: 30,
      //                                   height: 30,
      //                                 ),
      //                               ),
      //                             ),
      //                           )
      //                       ],
      //                     )
      //                         : _homeController
      //                         .getServiceAddCartModel
      //                         .data
      //                         ?.previewImages
      //                         ?.length ==
      //                         2
      //                         ? Row(
      //                       children: [
      //                         for (int i = 0; i < 2; i++)
      //                           Align(
      //                             widthFactor: 0.8,
      //                             child: ClipRRect(
      //                               borderRadius:
      //                               BorderRadius
      //                                   .circular(
      //                                   100),
      //                               child:
      //                               CachedNetworkImage(
      //                                 fit: BoxFit.cover,
      //                                 width: 30,
      //                                 height: 30,
      //                                 imageUrl:
      //                                 "${APIConstants.image}${_homeController.getServiceAddCartModel.data?.previewImages?[i] ?? ""}",
      //                                 placeholder:
      //                                     (context,
      //                                     url) =>
      //                                 const Image(
      //                                   image: AssetImage(
      //                                       AssetsConstant
      //                                           .placeHolder),
      //                                   fit: BoxFit.cover,
      //                                   width: 30,
      //                                   height: 30,
      //                                 ),
      //                                 errorWidget:
      //                                     (context, url,
      //                                     error) =>
      //                                 const Image(
      //                                   image: AssetImage(
      //                                       AssetsConstant
      //                                           .placeHolder),
      //                                   fit: BoxFit.cover,
      //                                   width: 30,
      //                                   height: 30,
      //                                 ),
      //                               ),
      //                             ),
      //                           )
      //                       ],
      //                     )
      //                         : Row(
      //                       children: [
      //                         for (int i = 0; i < 2; i++)
      //                           Align(
      //                             widthFactor: 0.7,
      //                             child: ClipRRect(
      //                               borderRadius:
      //                               BorderRadius
      //                                   .circular(
      //                                   100),
      //                               child:
      //                               CachedNetworkImage(
      //                                 fit: BoxFit.cover,
      //                                 width: 35,
      //                                 height: 35,
      //                                 imageUrl:
      //                                 "${APIConstants.image}${_homeController.getServiceAddCartModel.data?.previewImages?[i] ?? ""}",
      //                                 placeholder:
      //                                     (context,
      //                                     url) =>
      //                                 const Image(
      //                                   image: AssetImage(
      //                                       AssetsConstant
      //                                           .placeHolder),
      //                                   fit: BoxFit.cover,
      //                                   width: 35,
      //                                   height: 35,
      //                                 ),
      //                                 errorWidget:
      //                                     (context, url,
      //                                     error) =>
      //                                 const Image(
      //                                   image: AssetImage(
      //                                       AssetsConstant
      //                                           .placeHolder),
      //                                   fit: BoxFit.cover,
      //                                   width: 35,
      //                                   height: 35,
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                         const SizedBox(width: 2),
      //                         Container(
      //                           width: 33,
      //                           height: 33,
      //                           decoration:
      //                           const BoxDecoration(
      //                               color:
      //                               ColorConstant
      //                                   .primaryColor,
      //                               shape: BoxShape
      //                                   .circle),
      //                           child: Center(
      //                             child: Text(
      //                               _homeController
      //                                   .getServiceAddCartModel
      //                                   .data
      //                                   ?.previewImages
      //                                   ?.length
      //                                   .toString() ??
      //                                   "",
      //                               style: AppTextTheme
      //                                   .medium
      //                                   .copyWith(
      //                                 color: ColorConstant
      //                                     .whiteColor,
      //                               ),
      //                             ),
      //                           ),
      //                         )
      //                       ],
      //                     ),
      //                   ],
      //                 ),
      //                 const SizedBox(width: 15),
      //                 GestureDetector(
      //                   onTap: () {
      //                     showModalBottomSheet(
      //                         isScrollControlled: true,
      //                         shape: const RoundedRectangleBorder(
      //                             borderRadius: BorderRadius.only(
      //                               topLeft: Radius.circular(32),
      //                               topRight: Radius.circular(32),
      //                             )),
      //                         context: context,
      //                         builder: (context) {
      //                           return SelectedServiceSheetPage(
      //                             salonId: widget.salonId,
      //                             artistIds: selectedArtistIdsGlobal.value,
      //                             serviceId: serviceId,
      //                           );
      //                         });
      //
      //                     /*  showModalBottomSheet(
      //                                   isScrollControlled: true,
      //                                   shape: const RoundedRectangleBorder(
      //                                       borderRadius: BorderRadius.only(
      //                                     topLeft: Radius.circular(32),
      //                                     topRight: Radius.circular(32),
      //                                   )),
      //                                   context: context,
      //                                   builder: (context) {
      //                                     return CustomizedSheetWidget(
      //                                       serviceAddCartModel: _homeController
      //                                           .getServiceAddCartModel,
      //                                     );
      //                                   });*/
      //                   },
      //                   child: Column(
      //                     mainAxisAlignment: MainAxisAlignment.center,
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       Row(
      //                         children: [
      //                           Text(
      //                             "${_homeController.getServiceAddCartModel.data?.items?.length} Added",
      //                             style: AppTextTheme.bold.copyWith(
      //                                 fontSize: 13,
      //                                 color: ColorConstant.grayTextColor),
      //                           ),
      //                           const SizedBox(width: 2),
      //                           Image.asset(
      //                             AssetsConstant.arrowUpIcon,
      //                             height: 8,
      //                             width: 11,
      //                             color: changeTheme(
      //                                 SharedPrefs.readStringValue(
      //                                     PrefConstants.gender)),
      //                           )
      //                         ],
      //                       ),
      //                       Text(
      //                         "₹${_homeController.getServiceAddCartModel.data?.price ?? ""}",
      //                         style: AppTextTheme.bold.copyWith(
      //                             fontSize: 19,
      //                             color: ColorConstant.blackColor),
      //                       )
      //                     ],
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             GestureDetector(
      //               onTap: () {
      //                 if (stylistId.value != "") {
      //                   Get.to(() => AppointmentBookingPage(
      //                     artistIds: [stylistId.value],
      //                   ));
      //                 } else {
      //                   showModalBottomSheet(
      //                       isScrollControlled: true,
      //                       isDismissible: false,
      //                       enableDrag: false,
      //                       shape: const RoundedRectangleBorder(
      //                           borderRadius: BorderRadius.only(
      //                             topLeft: Radius.circular(32),
      //                             topRight: Radius.circular(32),
      //                           )),
      //                       context: context,
      //                       builder: (context) {
      //                         return SelectingArtistBottomSheetWidget(
      //                           salonId: widget.salonId,
      //                           serviceId: serviceId,
      //                           callback: () {
      //                             setState(() {});
      //                           },
      //                         );
      //                       });
      //                 }
      //               },
      //               child: Container(
      //                 height: 45,
      //                 width: Get.width * 0.4,
      //                 decoration: BoxDecoration(
      //                   color: changeTheme(SharedPrefs.readStringValue(
      //                       PrefConstants.gender)),
      //                   borderRadius: BorderRadius.circular(12),
      //                 ),
      //                 child: Row(
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   children: [
      //                     ValueListenableBuilder(
      //                         valueListenable: stylistId,
      //                         builder: (context, v, c) {
      //                           return Text(
      //                             stylistId.value.isNotEmpty
      //                                 ? "Book Slot"
      //                                 : "Select Stylist",
      //                             textScaler:
      //                             const TextScaler.linear(0.70),
      //                             style: AppTextTheme.medium.copyWith(
      //                                 fontSize: 16,
      //                                 color: ColorConstant.whiteColor),
      //                           );
      //                         }),
      //                     const SizedBox(width: 10),
      //                     const Icon(
      //                       Icons.arrow_forward,
      //                       color: ColorConstant.whiteColor,
      //                       size: 20,
      //                     )
      //                   ],
      //                 ),
      //               ),
      //             ), /*IconButton(
      //                         onPressed: () {
      //                           showDialog(
      //                               context: context,
      //                               builder: (context) {
      //                                 return RemoveAndAddServiceDialog(
      //                                     noPress: () {
      //                                   Navigator.of(context).maybePop();
      //                                 }, yesPress: () {
      //                                   setState(() {
      //                                     _homeController.doClearCart(
      //                                         callback: () {
      //                                       _homeController.doClearCart(
      //                                           callback: () {
      //                                         _homeController
      //                                             .doGetHomeSalonDetails(
      //                                                 salonId: widget.id);
      //                                         _homeController
      //                                             .doGetSalonDetailsService(
      //                                                 salonId: widget.id);
      //                                         _homeController
      //                                             .doGetSalonArtiestListData(
      //                                                 salonId: widget.id);
      //                                         _homeController.doGetCart();
      //                                         Navigator.pop(context);
      //                                       });
      //                                     });
      //                                     serviceId = "";
      //                                     artiestId = "";
      //                                   });
      //                                 });
      //                               });
      //                         },
      //                         icon: Icon(
      //                           CupertinoIcons.xmark_circle_fill,
      //                           color: changeTheme(SharedPrefs.readStringValue(
      //                               PrefConstants.gender)),
      //                         ),
      //                       ),*/
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  /*-------------- Image header Widget ------------*/
  Stack _imageHeaderWidget() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CachedNetworkImage(
          width: Get.width,
          height: Get.height * 0.28,
          fit: BoxFit.fitWidth,
          imageUrl:
              "${APIConstants.image}${_homeController.getArtiestDetailsModel.data?.salon?.image ?? ""}",
          placeholder: (context, url) => Image(
            image: const AssetImage(AssetsConstant.placeHolder),
            width: Get.width,
            height: Get.height * 0.28,
            fit: BoxFit.fitWidth,
          ),
          errorWidget: (context, url, error) => Image(
            image: const AssetImage(AssetsConstant.placeHolder),
            width: Get.width,
            height: Get.height * 0.28,
            fit: BoxFit.fitWidth,
          ),
        ),
        Positioned(
            child: Container(
          width: Get.width,
          height: Get.height * 0.28,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.02, 1.00),
              end: Alignment(-0.02, -1),
              colors: [Colors.black, Color(0x003D3636)],
            ),
          ),
        )),
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buttonWidget(
                imageUrl: AssetsConstant.backArrow,
                onPress: () {
                  Navigator.of(context).maybePop();
                },
                h: 15,
                w: 15,
              ),
              Row(
                children: [
                  /*      buttonWidget(
                    imageUrl: AssetsConstant.iconSearch,
                    onPress: () {
                      Get.to(() => StylistSearchPage(
                            salonName: _homeController
                                    .homeSalonDetailsData.data?.name ??
                                "",
                            salonId: stylistId.value,
                          ));
                    },
                    h: 24,
                    w: 24,
                  ),*/
                  const SizedBox(width: 15),
                  buttonWidget(
                    imageUrl: AssetsConstant.shareIcon,
                    onPress: () {
                      Share.share("https://play.google.com/store/apps");
                    },
                    h: 18,
                    w: 18,
                  ),
                  /*  const SizedBox(width: 15),
                  buttonWidget(
                    imageUrl: AssetsConstant.likeBlank,
                    onPress: () {},
                    h: 20,
                    w: 20,
                  ),*/
                ],
              )
            ],
          ),
        ),
        Positioned(
          bottom: -50,
          left: 0,
          right: 0,
          child: Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: ColorConstant.bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  imageUrl:
                      "${APIConstants.image}${_homeController.getArtiestDetailsModel.data?.profileImage ?? ""}",
                  placeholder: (context, url) => const Image(
                    image: AssetImage(AssetsConstant.placeHolder),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  errorWidget: (context, url, error) => const Image(
                    image: AssetImage(AssetsConstant.placeHolder),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /*------------ Back Button --------------*/
  GestureDetector buttonWidget(
      {required String imageUrl,
      required VoidCallback onPress,
      required double h,
      required double w}) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorConstant.blackColor.withOpacity(0.50),
          ),
          child: Center(
            child: Image.asset(
              imageUrl,
              width: w,
              height: h,
              fit: BoxFit.contain,
            ),
          )),
    );
  }

  /*------------ Naming Contain Colum --------*/
  Column _nameContainColum() {
    return Column(
      children: [
        SizedBox(height: Get.height * 0.07),
        Text(
          "Basic Information",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
        const SizedBox(height: 5),
        Text(
          _homeController.getArtiestDetailsModel.data?.name ?? "",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 14),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// 🔥 LINE 1 → Rating + Stars + Reviews
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${_homeController.getArtiestDetailsModel.data?.rating ?? 0}",
                  style: AppTextTheme.bold.copyWith(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: ColorConstant.blackColor,
                  ),
                ),

                const SizedBox(width: 6),

                RatingBar.builder(
                  initialRating:
                  _homeController.getArtiestDetailsModel.data?.rating ?? 0.0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 22.0,
                  ignoreGestures: true,
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: changeTheme(
                        SharedPrefs.readStringValue(PrefConstants.gender)) ??
                        ColorConstant.primaryColor,
                  ),
                  onRatingUpdate: (rating) {},
                ),

                const SizedBox(width: 8),

                Text(
                  "(${_homeController.getArtiestDetailsModel.data?.reviewCount ?? 0} Reviews)",
                  style: AppTextTheme.medium.copyWith(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            /// 🔥 LINE 2 → Languages (only if present)
            Builder(
              builder: (context) {
                final languages =
                    _homeController.getArtiestDetailsModel.data?.languagesKnown ?? [];

                if (languages.isEmpty) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    children: [

                      /// 🔹 LABEL
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Can Understand : ",
                              style: AppTextTheme.medium.copyWith(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// 🔹 CHIPS (your pill UI)
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: languages.map((lang) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF8454E5),
                                  Color(0xFFCD73B4),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              lang,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /*------------- Tab Bar View ------------*/
  int isSelectedTab = 0;

  TabBar _tabBarView() {
    return TabBar(
      labelPadding: EdgeInsets.zero,
      controller: _tabController,
      labelColor: _selectedColor,
      indicatorColor: _selectedColor,
      indicatorWeight: 2,
      unselectedLabelColor: _unselectedColor,
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: _tabs,
      onTap: (val) {
        setState(() {
          isSelectedTab = val;
        });
      },
    );
    /*return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    isSelectedTab = 1;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      "Service Offered",
                      style: isSelectedTab == 1
                          ? AppTextTheme.bold.copyWith(
                              fontSize: 16,
                              color: changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  ColorConstant.primaryColor)
                          : AppTextTheme.medium.copyWith(
                              fontSize: 16, color: ColorConstant.grayTextColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      width: Get.width * 0.2,
                      decoration: BoxDecoration(
                          color: isSelectedTab == 1
                              ? changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  ColorConstant.primaryColor
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12))),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isSelectedTab = 2;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      "Portfolio",
                      style: isSelectedTab == 2
                          ? AppTextTheme.bold.copyWith(
                              fontSize: 16,
                              color: changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  ColorConstant.primaryColor)
                          : AppTextTheme.medium.copyWith(
                              fontSize: 16, color: ColorConstant.grayTextColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      width: Get.width * 0.2,
                      decoration: BoxDecoration(
                          color: isSelectedTab == 2
                              ? changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  ColorConstant.primaryColor
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12))),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isSelectedTab = 3;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      "Review & ratings",
                      style: isSelectedTab == 3
                          ? AppTextTheme.bold.copyWith(
                              fontSize: 16,
                              color: changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  ColorConstant.primaryColor)
                          : AppTextTheme.medium.copyWith(
                              fontSize: 16, color: ColorConstant.grayTextColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 4,
                      width: Get.width * 0.2,
                      decoration: BoxDecoration(
                          color: isSelectedTab == 3
                              ? changeTheme(SharedPrefs.readStringValue(
                                      PrefConstants.gender)) ??
                                  ColorConstant.primaryColor
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12))),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          width: Get.width,
          color: const Color(0xffADADAD),
        ),
      ],
    );*/
  }

  /*------------- Tab Bar View  -------------*/
  late TabController _tabController;
  final _selectedColor =
      changeTheme(SharedPrefs.readStringValue(PrefConstants.gender)) ??
          ColorConstant.primaryColor;
  final _unselectedColor = ColorConstant.grayTextColor;

  final _tabs = [
    const Tab(text: 'Service Offered'),
    const Tab(text: 'Portfolio'),
    const Tab(text: 'Review & ratings'),
  ];
}
