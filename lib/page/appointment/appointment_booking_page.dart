import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import 'package:salon_customer/controller/home_controller.dart';
import 'package:salon_customer/page/appointment/widget/know_what_you_widget.dart';
import 'package:salon_customer/page/appointment/widget/popular_service_widget.dart';
import 'package:salon_customer/page/appointment/widget/promocode_sheet_widget.dart';
import 'package:salon_customer/page/appointment/your_approval_page.dart';
import 'package:salon_customer/project_specific/ProgressContainerView.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import '../../api/dio_client.dart';
import '../home/widget/add_product_sheet_widget.dart';
import '../profile/add_address_page.dart';

class AppointmentBookingPage extends StatefulWidget {
  final String artiestId;

  const AppointmentBookingPage({super.key, required this.artiestId});

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final _homeController = Get.find<HomeController>();
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      userServiceAddressIdSelect = "";
      DateTime date = DateTime.now();
      String formatDate = DateFormat("yyyy-MM-dd").format(date);
      selectDate = formatDate;
      _homeController.doGetPopularServiceByYourStylist(
          stylistId: widget.artiestId);
      _homeController.doGetBlogData(
        lat: double.parse(SharedPrefs.readStringValue(PrefConstants.latitude)),
        lng: double.parse(SharedPrefs.readStringValue(PrefConstants.longitude)),
      );
      _homeController.doGetUnAvailableDatesListData(
          artiestId: widget.artiestId,
          date: formatDate,
          callback: () {
            _homeController.doGetCart();
            _homeController.doGetAvailabilitiesTimeSlot(
              artiestId: widget.artiestId,
              date: formatDate,
            );
            _homeController.doGetOrderId();
          });
    });
  }

  int selectedIndex = 0;
  String selectTime = '';
  Razorpay razorpay = Razorpay();

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: ColorConstant.bgColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: ColorConstant.whiteColor,
          leading: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: ColorConstant.blackColor,
              )),
          centerTitle: true,
          title: Text(
            "Booking Appointment",
            style: AppTextTheme.bold
                .copyWith(color: ColorConstant.blackColor, fontSize: 19),
          ),
        ),
        body: Obx(
          () => ProgressContainerView(
            isProgressRunning: _homeController.showBookingProgress,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _customBackgroundExample(),
                  const SizedBox(height: 29),
                  /*----------- Popular Service By Your Artist ---------------*/
                  _homeController.showProgress
                      ? Column(
                          children: [
                            SizedBox(height: Get.height * 0.23),
                            const ProgressBarView(),
                          ],
                        )
                      : Column(
                          children: [
                            _homeController.getArtistPopularServicesModel.data
                                        ?.isEmpty ??
                                    false
                                ? const SizedBox()
                                : Container(
                                    width: Get.width,
                                    color: ColorConstant.whiteColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Popular Service By Your Artist",
                                          style: AppTextTheme.bold.copyWith(
                                              fontSize: 16,
                                              color: ColorConstant.blackColor),
                                        ),
                                        const SizedBox(height: 15),
                                        Dash(
                                          direction: Axis.horizontal,
                                          length: Get.width * 0.88,
                                          dashLength: 2,
                                          dashColor: const Color(0xffCFCFCF),
                                        ),
                                        const SizedBox(height: 15),
                                        SizedBox(
                                          height: 150,
                                          child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: _homeController
                                                      .getArtistPopularServicesModel
                                                      .data
                                                      ?.length ??
                                                  0,
                                              itemBuilder: (context, index) {
                                                return PopularServiceWidget(
                                                  addButtonTap: () {
                                                    _homeController
                                                        .getArtistPopularServicesModel
                                                        .data?[index]
                                                        .isAddCart = !(_homeController
                                                            .getArtistPopularServicesModel
                                                            .data?[index]
                                                            .isAddCart ??
                                                        false);

                                                    if (_homeController
                                                            .getArtistPopularServicesModel
                                                            .data?[index]
                                                            .isAddCart ??
                                                        false) {
                                                      _homeController.doAddCart(
                                                          salonServiceId:
                                                              _homeController
                                                                      .getArtistPopularServicesModel
                                                                      .data?[
                                                                          index]
                                                                      .id ??
                                                                  "",
                                                          isHomeService: SharedPrefs
                                                              .readBoolValue(
                                                                  PrefConstants
                                                                      .isHomeService),
                                                          callback: () {
                                                            _homeController
                                                                .doGetCart();
                                                            if (_homeController
                                                                    .getServiceAddCartModel
                                                                    .data
                                                                    ?.items ==
                                                                null) {
                                                              stylistId.value =
                                                                  "";
                                                              stylistId
                                                                  .notifyListeners();
                                                            }
                                                          });
                                                    } else {
                                                      _homeController
                                                          .doRemoveCart(
                                                              salonServiceId:
                                                                  _homeController
                                                                          .getArtistPopularServicesModel
                                                                          .data?[
                                                                              index]
                                                                          .id ??
                                                                      "",
                                                              callback: () {
                                                                _homeController
                                                                    .doGetCart();

                                                                if (_homeController
                                                                        .getServiceAddCartModel
                                                                        .data
                                                                        ?.items ==
                                                                    null) {
                                                                  stylistId
                                                                      .value = "";
                                                                  stylistId
                                                                      .notifyListeners();
                                                                }
                                                              });
                                                    }
                                                  },
                                                  review: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .reviewCount
                                                          .toString() ??
                                                      "",
                                                  rating: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .rating ??
                                                      0.0,
                                                  name: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .name ??
                                                      "",
                                                  image: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .image ??
                                                      "",
                                                  duration: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .duration
                                                          .toString() ??
                                                      "",
                                                  isAdd: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .isAddCart ??
                                                      false,
                                                  price: _homeController
                                                          .getArtistPopularServicesModel
                                                          .data?[index]
                                                          .price
                                                          .toString() ??
                                                      "",
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                            const SizedBox(height: 2),
                            /*-------------- Select Time Slot  ---------------*/
                            Container(
                              color: ColorConstant.whiteColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select Time Slot",
                                    style: AppTextTheme.bold.copyWith(
                                        fontSize: 16,
                                        color: ColorConstant.blackColor),
                                  ),
                                  const SizedBox(height: 15),
                                  Dash(
                                    direction: Axis.horizontal,
                                    length: Get.width * 0.88,
                                    dashLength: 2,
                                    dashColor: const Color(0xffCFCFCF),
                                  ),
                                  const SizedBox(height: 10),
                                  _homeController
                                              .getAvailabilitiesTimeSlotModelData
                                              .data
                                              ?.isEmpty ??
                                          false
                                      ? Center(
                                          child: Text(
                                          "No Time Slot Available",
                                          style: AppTextTheme.bold.copyWith(
                                              fontSize: 16,
                                              color: ColorConstant.blackColor),
                                        ))
                                      : Column(
                                          children: [
                                            SizedBox(
                                              height: 50,
                                              width: Get.width,
                                              child: ListView.builder(
                                                  itemCount: _homeController
                                                          .getAvailabilitiesTimeSlotModelData
                                                          .data
                                                          ?.length ??
                                                      0,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder: (context, i) {
                                                    return _timeSlotContainerWidget(
                                                        isSelected:
                                                            selectedIndex == i,
                                                        onPress: () {
                                                          setState(() {
                                                            selectedIndex = i;
                                                            selectTime =
                                                                _homeController
                                                                        .getAvailabilitiesTimeSlotModelData
                                                                        .data?[
                                                                            i]
                                                                        .time ??
                                                                    "";
                                                          });
                                                        },
                                                        timeSlot:
                                                            convertTimesToAmPmString(
                                                                _homeController
                                                                        .getAvailabilitiesTimeSlotModelData
                                                                        .data?[
                                                                            i]
                                                                        .time ??
                                                                    ""));
                                                  }),
                                            ),
                                            const SizedBox(height: 18),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),

                            /*------------- Apply PromoCode ---------------*/
                            Dash(
                              direction: Axis.horizontal,
                              length: Get.width * 0.88,
                              dashLength: 2,
                              dashColor: const Color(0xffCFCFCF),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: Text(
                                    "Apply For PromoCode",
                                    textScaler: const TextScaler.linear(0.90),
                                    style: AppTextTheme.bold.copyWith(
                                        fontSize: 17,
                                        color: ColorConstant.blackColor),
                                  ),
                                ),
                                if (_homeController.getServiceAddCartModel.data
                                        ?.isDiscountApplied ??
                                    false)
                                  GestureDetector(
                                    onTap: () async {
                                      _homeController.doRemovePromoCode(
                                          callback: () {
                                        _homeController.doGetCart();
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      width: Get.width,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: ColorConstant.whiteColor,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: ColorConstant.primaryColor,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                AssetsConstant.offerIcon,
                                                color: changeTheme(SharedPrefs
                                                        .readStringValue(
                                                            PrefConstants
                                                                .gender)) ??
                                                    ColorConstant.primaryColor,
                                                width: 25,
                                                height: 25,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                "Remove PromoCode",
                                                style: AppTextTheme.bold
                                                    .copyWith(
                                                        fontSize: 14,
                                                        color: ColorConstant
                                                            .blackColor),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _homeController.doRemovePromoCode(
                                                  callback: () {
                                                _homeController.doGetCart();
                                              });
                                            },
                                            child: Container(
                                              height: 40,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                color: ColorConstant.redBgColor,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Remove",
                                                  style: AppTextTheme.medium
                                                      .copyWith(fontSize: 13),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () async {
                                      String id = await showModalBottomSheet(
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(32),
                                            topRight: Radius.circular(32),
                                          )),
                                          context: context,
                                          builder: (context) {
                                            return const PromoCodeSheetWidget();
                                          });

                                      _homeController.doApplyPromoCode(
                                          data: {
                                            "discountId": id,
                                          },
                                          callback: () {
                                            _homeController.doGetCart();
                                          });
                                    },
                                    child: Container(
                                      height: 50,
                                      width: Get.width,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: ColorConstant.whiteColor,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: ColorConstant.primaryColor,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                AssetsConstant.offerIcon,
                                                width: 25,
                                                color: changeTheme(SharedPrefs
                                                        .readStringValue(
                                                            PrefConstants
                                                                .gender)) ??
                                                    ColorConstant.primaryColor,
                                                height: 25,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                "Apply PromoCode",
                                                style: AppTextTheme.bold
                                                    .copyWith(
                                                        fontSize: 14,
                                                        color: ColorConstant
                                                            .blackColor),
                                              ),
                                            ],
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 20,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Dash(
                              direction: Axis.horizontal,
                              length: Get.width * 0.88,
                              dashLength: 2,
                              dashColor: const Color(0xffCFCFCF),
                            ),
                            /*------------ Know What You are paying For ------------*/
                            Container(
                              width: Get.width,
                              color: ColorConstant.whiteColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Know What You Are Paying For",
                                    style: AppTextTheme.bold.copyWith(
                                        fontSize: 16,
                                        color: ColorConstant.blackColor),
                                  ),
                                  const SizedBox(height: 15),
                                  Dash(
                                    direction: Axis.horizontal,
                                    length: Get.width * 0.88,
                                    dashLength: 2,
                                    dashColor: const Color(0xffCFCFCF),
                                  ),
                                  const SizedBox(height: 10),
                                  ListView.separated(
                                      separatorBuilder: (context, index) {
                                        return const Divider(
                                          height: 24,
                                          color: Color(0xffE0E0E0),
                                          thickness: 1.5,
                                        );
                                      },
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _homeController
                                              .getServiceAddCartModel
                                              .data
                                              ?.servicesWithProduct
                                              ?.length ??
                                          0,
                                      itemBuilder: (context, index) {
                                        return KnowWhatYouWidget(
                                          editProduct: () {
                                            showModalBottomSheet(
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                  topLeft: Radius.circular(32),
                                                  topRight: Radius.circular(32),
                                                )),
                                                context: context,
                                                builder: (context) {
                                                  return AddProductSheetWidget(
                                                    price: _homeController
                                                            .getServiceAddCartModel
                                                            .data
                                                            ?.servicesWithProduct?[
                                                                index]
                                                            .totalCost ??
                                                        0,
                                                    rating: _homeController
                                                            .getServiceAddCartModel
                                                            .data
                                                            ?.servicesWithProduct?[
                                                                index]
                                                            .rating ??
                                                        0.0,
                                                    review: 0,
                                                    nameOfService: _homeController
                                                            .getServiceAddCartModel
                                                            .data
                                                            ?.servicesWithProduct?[
                                                                index]
                                                            .name ??
                                                        "",
                                                    serviceId: _homeController
                                                            .getServiceAddCartModel
                                                            .data
                                                            ?.servicesWithProduct?[
                                                                index]
                                                            .serviceId ??
                                                        "",
                                                  );
                                                });
                                          },
                                          removeBtn: () {
                                            _homeController.doRemoveCart(
                                                salonServiceId: _homeController
                                                        .getServiceAddCartModel
                                                        .data
                                                        ?.servicesWithProduct?[
                                                            index]
                                                        .serviceId ??
                                                    "",
                                                callback: () {
                                                  _homeController
                                                      .doGetPopularServiceByYourStylist(
                                                          stylistId:
                                                              widget.artiestId);
                                                  _homeController.doGetSalonDetailsService(
                                                      serviceGender: SharedPrefs
                                                                  .readStringValue(
                                                                      PrefConstants
                                                                          .gender) ==
                                                              "0"
                                                          ? "male"
                                                          : "female",
                                                      salonId: _homeController
                                                              .getServiceAddCartModel
                                                              .data
                                                              ?.salonId ??
                                                          "");
                                                  _homeController.doGetCart();
                                                  if (_homeController
                                                          .getServiceAddCartModel
                                                          .data
                                                          ?.items ==
                                                      null) {
                                                    stylistId.value = "";
                                                    stylistId.notifyListeners();
                                                  }
                                                });
                                          },
                                          items: _homeController
                                              .getServiceAddCartModel
                                              .data!
                                              .servicesWithProduct![index],
                                        );
                                      }),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            )
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Obx(
          () => _homeController.showProgress
              ? const SizedBox()
              : _homeController.getServiceAddCartModel.data?.servicesWithProduct
                          ?.isEmpty ??
                      false ||
                          _homeController.getServiceAddCartModel.data
                                  ?.servicesWithProduct ==
                              null
                  ? const SizedBox()
                  : Container(
                      width: Get.width,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: ColorConstant.whiteColor,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1E000000),
                            blurRadius: 8,
                            offset: Offset(-2, -2),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Price",
                                style: AppTextTheme.bold.copyWith(
                                    fontSize: 13,
                                    color: ColorConstant.grayTextColor),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "₹${_homeController.getServiceAddCartModel.data?.price ?? ""}",
                                style: AppTextTheme.bold.copyWith(
                                    fontSize: 19,
                                    color: ColorConstant.blackColor),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "GST is included",
                                style: AppTextTheme.regular.copyWith(
                                    color: ColorConstant.blackColor,
                                    fontSize: 12),
                              )
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_homeController.getServiceAddCartModel.data
                                      ?.items?.isEmpty ??
                                  false) {
                                showMessage("Cart Service Not Found");
                              } else {
                                if (_homeController
                                        .getAvailabilitiesTimeSlotModelData
                                        .data
                                        ?.isEmpty ??
                                    false) {
                                  showMessage(
                                      "This Date No Available Any Slot Please Select Next Date");
                                } else {
                                  if (SharedPrefs.readBoolValue(
                                      PrefConstants.isHomeService)) {
                                    if (userServiceAddressIdSelect == "") {
                                      Get.to(() =>
                                          const AddAddressPage(isSelect: true));
                                    } else {
                                      var options = {
                                        'key': _homeController.getOrderIdModel
                                                .data?.razorpayKey ??
                                            "",
                                        'amount': _homeController
                                                .getServiceAddCartModel
                                                .data
                                                ?.price ??
                                            0 * 100,
                                        'name': 'Salon',
                                        'timeout': 60,
                                        "order_id": _homeController
                                                .getOrderIdModel
                                                .data
                                                ?.orderId ??
                                            "",
                                        'description': 'Booking Appointment',
                                        'retry': {
                                          'enabled': true,
                                          'max_count': 1
                                        },
                                        'send_sms_hash': true,
                                        'prefill': {
                                          'contact': _authController
                                                  .userResponseModel
                                                  .data
                                                  ?.userData
                                                  ?.mobile ??
                                              "",
                                          'email': _authController
                                                  .userResponseModel
                                                  .data
                                                  ?.userData
                                                  ?.mobile ??
                                              ""
                                        },
                                        'external': {}
                                      };
                                      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
                                          handlePaymentErrorResponse);
                                      razorpay.on(
                                          Razorpay.EVENT_PAYMENT_SUCCESS,
                                          handlePaymentSuccessResponse);
                                      razorpay.on(
                                          Razorpay.EVENT_EXTERNAL_WALLET,
                                          handleExternalWalletSelected);

                                      razorpay.open(options);
                                    }
                                  } else {
                                    var options = {
                                      'key': _homeController.getOrderIdModel
                                              .data?.razorpayKey ??
                                          "",
                                      'amount': _homeController
                                              .getServiceAddCartModel
                                              .data
                                              ?.price ??
                                          0 * 100,
                                      'name': 'Salon',
                                      'timeout': 60,
                                      "order_id": _homeController
                                              .getOrderIdModel.data?.orderId ??
                                          "",
                                      'description': 'Booking Appointment',
                                      'retry': {
                                        'enabled': true,
                                        'max_count': 1
                                      },
                                      'send_sms_hash': true,
                                      'prefill': {
                                        'contact': _authController
                                                .userResponseModel
                                                .data
                                                ?.userData
                                                ?.mobile ??
                                            "",
                                        'email': _authController
                                                .userResponseModel
                                                .data
                                                ?.userData
                                                ?.mobile ??
                                            ""
                                      },
                                      'external': {}
                                    };
                                    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
                                        handlePaymentErrorResponse);
                                    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                                        handlePaymentSuccessResponse);
                                    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                                        handleExternalWalletSelected);

                                    razorpay.open(options);
                                  }
                                }
                              }
                            },
                            child: Container(
                              height: 45,
                              width: Get.width * 0.35,
                              decoration: BoxDecoration(
                                color: changeTheme(SharedPrefs.readStringValue(
                                        PrefConstants.gender)) ??
                                    ColorConstant.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Pay & Book",
                                    textScaler: const TextScaler.linear(0.85),
                                    style: AppTextTheme.medium.copyWith(
                                        fontSize: 16,
                                        color: ColorConstant.whiteColor),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: ColorConstant.whiteColor,
                                    size: 20,
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  /*================  Razor Pay ==============*/
  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  /*-------------  On Payment Fail Method ------------- */
  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    showAlertDialog(context, "Payment Failed",
        "You may have cancelled the payment or there was a delay in response from the UPI App \n  mobile : +91 ${_authController.userResponseModel.data?.userData?.mobile}  Email : ${_authController.userResponseModel.data?.userData?.email} Name : ${_authController.userResponseModel.data?.userData?.name}");
  }

  /*---------------  On Payment Success Method ------------ */
  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    showMessage("Payment Successful");
    if (selectTime == "") {
      selectTime =
          _homeController.getAvailabilitiesTimeSlotModelData.data?[0].time ??
              "";
      String inputDateTime = "$selectDate$selectTime";
      String correctedDateTime =
          '${inputDateTime.substring(0, 10)}T${inputDateTime.substring(10)}';
      DateTime dateTime = DateTime.parse(correctedDateTime);
      String isoDateTime = dateTime.toIso8601String();

      if (_homeController.getServiceAddCartModel.data?.isHomeService ?? false) {
        if (userServiceAddressIdSelect == "") {
          Get.to(() => const AddAddressPage(
                isSelect: true,
              ));
        } else {
          _homeController.doCreateBooking(
              userAddressId: userServiceAddressIdSelect,
              isHomeService:
                  _homeController.getServiceAddCartModel.data?.isHomeService ??
                      false,
              salonArtistId: widget.artiestId,
              startAt: isoDateTime,
              callback: () {
                stylistId.value = "";
                stylistId.notifyListeners();

                Get.to(() => YourApprovalPage(
                      salonAppointmentId: _homeController
                              .getCreateBookingAppointmentModel
                              .data
                              ?.salonAppointmentId ??
                          "",
                    ));
              });
        }
      } else {
        _homeController.doCreateBooking(
            userAddressId: "",
            isHomeService:
                _homeController.getServiceAddCartModel.data?.isHomeService ??
                    false,
            salonArtistId: widget.artiestId,
            startAt: isoDateTime,
            callback: () {
              stylistId.value = "";
              stylistId.notifyListeners();

              Get.to(() => YourApprovalPage(
                    salonAppointmentId: _homeController
                            .getCreateBookingAppointmentModel
                            .data
                            ?.salonAppointmentId ??
                        "",
                  ));
            });
      }
    } else {
      String inputDateTime = "$selectDate$selectTime";
      String correctedDateTime =
          '${inputDateTime.substring(0, 10)}T${inputDateTime.substring(10)}';
      DateTime dateTime = DateTime.parse(correctedDateTime);
      String isoDateTime = dateTime.toIso8601String();

      if (SharedPrefs.readBoolValue(PrefConstants.isHomeService)) {
        _homeController.doCreateBooking(
            userAddressId: userServiceAddressIdSelect,
            isHomeService:
                _homeController.getServiceAddCartModel.data?.isHomeService ??
                    false,
            salonArtistId: widget.artiestId,
            startAt: isoDateTime,
            callback: () {
              stylistId.value = "";
              stylistId.notifyListeners();

              Get.to(() => YourApprovalPage(
                    salonAppointmentId: _homeController
                            .getCreateBookingAppointmentModel
                            .data
                            ?.salonAppointmentId ??
                        "",
                  ));
            });
      } else {
        stylistId.value = "";
        _homeController.doCreateBooking(
            userAddressId: "",
            isHomeService:
                _homeController.getServiceAddCartModel.data?.isHomeService ??
                    false,
            salonArtistId: widget.artiestId,
            startAt: isoDateTime,
            callback: () {
              Get.to(() => YourApprovalPage(
                    salonAppointmentId: _homeController
                            .getCreateBookingAppointmentModel
                            .data
                            ?.salonAppointmentId ??
                        "",
                  ));
            });
      }
    }
  }

  /*---------------  On  External Success Method ------------ */
  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
        context, "External Wallet Selected", "${response.walletName}");
  }

  String selectDate = "";

  /*------------  Time Slot ------*/
  _timeSlotContainerWidget(
      {required String timeSlot,
      required bool isSelected,
      required VoidCallback onPress}) {
    return InkWell(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? changeTheme(
                      SharedPrefs.readStringValue(PrefConstants.gender)) ??
                  ColorConstant.primaryColor
              : ColorConstant.whiteColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ColorConstant.grayBorderColor, width: 1),
        ),
        child: Center(
          child: Text(
            timeSlot,
            style: AppTextTheme.bold.copyWith(
                color: isSelected
                    ? ColorConstant.whiteColor
                    : ColorConstant.blackColor,
                fontSize: 13),
          ),
        ),
      ),
    );
  }

  final Rx<bool> _isMonthChange = false.obs;

  bool get isDialogShow => _isMonthChange.value;

  /*---------------  Date Calender Time ------------*/
  EasyDateTimeLine _customBackgroundExample() {
    final List<Map<String, String>> unavailableDates = [];

    for (int i = 0;
        i <
            (_homeController.getUnAvailableDatesListData.data?.unavailableDates
                    ?.length ??
                0);
        i++) {
      unavailableDates.add({
        "date": _homeController
                .getUnAvailableDatesListData.data?.unavailableDates?[i].date ??
            ""
      });
    }

    List<DateTime> dateTimeList = unavailableDates.map((dateMap) {
      return DateTime.parse(dateMap["date"]!);
    }).toList();

    return EasyDateTimeLine(
      key: ValueKey(selectDate),
      // Force rebuild when selectDate changes
      onMonthChange: (val) {
        selectDate = "";
        String inputString = val.toString();
        RegExp regExp = RegExp(r'\d+');
        Iterable<RegExpMatch> matches = regExp.allMatches(inputString);
        String result = matches.map((match) => match.group(0)).join('');
        String year = DateFormat("yyyy").format(DateTime.now());
        String finalDate =
            "$year-${result.length == 1 ? '0$result' : result}-01";

        // Update selectDate to the first day of the new month
        setState(() {
          selectDate = finalDate;
        });

        _homeController.doGetUnAvailableDatesListData(
          artiestId: widget.artiestId,
          date: finalDate,
          callback: () {
            _homeController.doGetAvailabilitiesTimeSlot(
              artiestId: widget.artiestId,
              date: finalDate,
            );
          },
        );
      },
      initialDate:
          selectDate == "" ? DateTime.now() : DateTime.parse(selectDate),
      onDateChange: (selectedDate) {
        //`selectedDate` the new date selected.
        selectDate = "";
        String formatDate = DateFormat("yyyy-MM-dd").format(selectedDate);
        selectDate = formatDate;
        _homeController.doGetAvailabilitiesTimeSlot(
          artiestId: widget.artiestId,
          date: formatDate,
        );
      },
      headerProps: const EasyHeaderProps(
          showSelectedDate: true,
          monthPickerType: MonthPickerType.switcher,
          dateFormatter: DateFormatter.dayOnly()),
      disabledDates: dateTimeList,
      dayProps: EasyDayProps(
        height: 72,
        width: 58,
        dayStructure: DayStructure.dayStrDayNum,
        activeDayStyle: DayStyle(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: changeTheme(
                    SharedPrefs.readStringValue(PrefConstants.gender)) ??
                ColorConstant.primaryColor,
          ),
        ),
      ),
    );
  }

  /*-------------- Convert AM PM Date Time --------------------*/
  String convertTimesToAmPmString(String timeSlot) {
    DateTime time = DateFormat("HH:mm").parse(timeSlot);
    String convertTimeSlot = DateFormat("hh:mm a").format(time);
    return convertTimeSlot;
  }
}
