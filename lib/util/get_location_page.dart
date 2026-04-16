import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as fp;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salon_customer/constant/assetsconstant.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/constant/variable_constant.dart';
import 'package:salon_customer/project_specific/button_widget.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:salon_customer/util/logger.dart';

import '../api/dio_client.dart';
import '../controller/auth_controller.dart';
import '../project_specific/text_theme.dart';
import 'add_address_sheet.dart';

class GetLocationPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final VoidCallback callback;
  final String addressId;
  final String house;
  final String direction;

  final bool isEdit;

  const GetLocationPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.callback,
    required this.addressId,
    required this.isEdit,
    required this.house,
    required this.direction,
  });

  @override
  State<GetLocationPage> createState() => _GetLocationPageState();
}

class _GetLocationPageState extends State<GetLocationPage> {
  Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        ?.buffer
        .asUint8List();
  }

  Future<BitmapDescriptor> getBitmapDescriptorFromAssetBytes(
      String path, int width) async {
    final Uint8List? imageData = await getBytesFromAsset(path, width);
    return BitmapDescriptor.bytes(imageData!);
  }

  final _authController = Get.find<AuthController>();
  final Completer<GoogleMapController> controller = Completer();

  GoogleMapController? _controller;
  LatLng _initialPosition = const LatLng(0.0, 0.0);
  bool _locationLoaded = false;
  final places =
      fp.FlutterGooglePlacesSdk('AIzaSyASd8ofkbG7ItOylvlTv9Ii71loe0xYPJI');
  ValueNotifier<List<fp.AutocompletePrediction>> locationData =
      ValueNotifier([]);
  final _searchMapLocation = TextEditingController();
  String address = "";
  late Position currentLocation;
  late LatLng _center;

  String locality = "";
  String subLocality = "";

  /*-------------------------- Get Address ---------------*/
  Future<void> getAddressLatLong(LatLng latLang) async {
    List<Placemark> placeMarks =
        await placemarkFromCoordinates(latLang.latitude, latLang.longitude);
    _center = LatLng(latLang.latitude, latLang.longitude);
    Placemark place = placeMarks[0];
    address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    /*-------------- other Data get ---------------*/
    // , ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}
    logger.d(place);
    logger.d(address);
    logger.d(place.locality);
    locality = place.locality ?? "";
    subLocality = address;
    setState(() {});
  }

  /*--------------- Create List Of Marker ---------- */
  final Set<Marker> _markers = {};

  @override
  void initState() {
    _searchMapLocation.clear();
    _setInitialLocation();
    super.initState();
  }

  ValueNotifier<bool> close = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
    bool isKeyboardOpen = bottomInsets != 0;
    logger.d(isKeyboardOpen);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: ColorConstant.whiteColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: ColorConstant.blackColor,
          ),
        ),
        centerTitle: true,
        title: Text(
          "Set Address",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: _locationLoaded
          ? Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 14.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                  onTap: (latLng) async {
                    locationData.value = [];
                    _markers.clear();
                    _markers.add(Marker(
                      markerId: const MarkerId('current_Postion'),
                      position: LatLng(latLng.latitude, latLng.longitude),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueViolet,
                      ),
                    ));

                    getAddressLatLong(
                        LatLng(latLng.latitude, latLng.longitude));
                  },
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  top: 15,
                  left: 10,
                  right: 10,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: ColorConstant.whiteColor,
                            borderRadius: BorderRadius.circular(5)),
                        alignment: Alignment.center,
                        margin:
                            const EdgeInsets.only(left: 10, right: 10, top: 55),
                        // height: 48,
                        child: TextField(
                          controller: _searchMapLocation,
                          style: Get.textTheme.bodyLarge
                              ?.copyWith(color: Colors.black),
                          onChanged: (val) async {
                            if (val != "") {
                              close.value = true;
                              close.notifyListeners();
                              final predictions =
                                  await places.findAutocompletePredictions(val);
                              locationData.value = predictions.predictions;
                            } else {
                              close.value = false;
                              close.notifyListeners();
                              locationData.value = [];
                            }
                            locationData.notifyListeners();
                          },
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(top: 13),
                              border: InputBorder.none,
                              hintText: "Search Location",
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.black, size: 20),
                              suffixIcon: ValueListenableBuilder(
                                  valueListenable: close,
                                  builder: (context, v, c) {
                                    return close.value
                                        ? InkWell(
                                            onTap: () {
                                              _setInitialLocation();
                                              _markers.clear();
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              _searchMapLocation.clear();
                                              locationData.value = [];
                                              close.value = false;
                                              close.notifyListeners();
                                              setState(() {
                                                _setInitialLocation();
                                              });
                                            },
                                            child: const Icon(
                                              CupertinoIcons.xmark_circle,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                          )
                                        : const SizedBox();
                                  })),
                        ),
                      ),
                      Container(
                        color: ColorConstant.whiteColor,
                        margin:
                            const EdgeInsets.only(left: 20, right: 20, top: 15),
                        child: ValueListenableBuilder(
                            valueListenable: locationData,
                            builder: (context, v, c) {
                              return locationData.value.isEmpty
                                  ? const SizedBox()
                                  : ListView.builder(
                                      itemCount: locationData.value.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () async {
                                            _searchMapLocation.text =
                                                locationData
                                                    .value[index].fullText
                                                    .toString();
                                            locationData.value = [];
                                            _markers.clear();
                                            List<Location> location =
                                                await locationFromAddress(
                                                    _searchMapLocation.text);
                                            if (location.isNotEmpty) {
                                              List<Placemark> placeMarks =
                                                  await placemarkFromCoordinates(
                                                      location[0].latitude,
                                                      location[0].longitude);
                                              Placemark place = placeMarks[0];

                                              setState(() {
                                                _markers.add(Marker(
                                                  markerId: const MarkerId(
                                                      'current_Postion'),
                                                  position: LatLng(
                                                      location[0].latitude,
                                                      location[0].longitude),
                                                  icon: BitmapDescriptor
                                                      .defaultMarkerWithHue(
                                                    BitmapDescriptor.hueViolet,
                                                  ),
                                                ));
                                              });
                                              getAddressLatLong(LatLng(
                                                  location[0].latitude,
                                                  location[0].longitude));
                                              // city = "${place.locality}";
                                              // address =
                                              // "${place.street}, ${place.subLocality}, ${place.locality},${place.thoroughfare}, ${place.subThoroughfare} , ${place.administrativeArea} ${place.postalCode}, ${place.country}";
                                              // lat = location[0].latitude;
                                              // lng = location[0].longitude;

                                              _markers.add(Marker(
                                                markerId: const MarkerId('new'),
                                                position: LatLng(
                                                    location[0].latitude,
                                                    location[0].longitude),
                                                icon: BitmapDescriptor
                                                    .defaultMarkerWithHue(
                                                  BitmapDescriptor.hueViolet,
                                                ),
                                              ));

                                              _authController
                                                  .googleMapProgress = true;

                                              setState(() {
                                                _authController
                                                    .googleMapProgress = false;
                                                _center = LatLng(
                                                    location[0].latitude,
                                                    location[0].longitude);
                                                _controller?.animateCamera(
                                                    CameraUpdate.newLatLng(
                                                        LatLng(
                                                            location[0]
                                                                .latitude,
                                                            location[0]
                                                                .longitude)));
                                              });
                                            }
                                          },
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Column(
                                              children: [
                                                index == 0
                                                    ? const SizedBox(
                                                        height: 10,
                                                      )
                                                    : const SizedBox(),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: SizedBox(
                                                    width: Get.width,
                                                    child: Text(
                                                        locationData
                                                            .value[index]
                                                            .fullText
                                                            .toString(),
                                                        style: Get.textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                          color: ColorConstant
                                                              .blackColor,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        )),
                                                  ),
                                                ),
                                                index ==
                                                        locationData
                                                                .value.length -
                                                            1
                                                    ? const SizedBox(
                                                        height: 10,
                                                      )
                                                    : const Divider(
                                                        color: ColorConstant
                                                            .blackColor,
                                                      )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                            }),
                      ),
                    ],
                  ),
                ),
                isKeyboardOpen
                    ? const SizedBox()
                    : Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          width: Get.width,
                          color: ColorConstant.whiteColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Address",
                                style: AppTextTheme.medium.copyWith(
                                    fontSize: 16,
                                    color: ColorConstant.primaryColor),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Image.asset(
                                    AssetsConstant.locationDetails,
                                    width: 25,
                                    height: 25,
                                    color: changeTheme(
                                        SharedPrefs.readStringValue(
                                            PrefConstants.gender)),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        locality,
                                        style: AppTextTheme.bold.copyWith(
                                            fontSize: 17,
                                            color: ColorConstant.blackColor),
                                      ),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        width: Get.width * 0.7,
                                        child: Text(
                                          subLocality,
                                          textScaler:
                                              const TextScaler.linear(0.85),
                                          style: AppTextTheme.medium.copyWith(
                                              fontSize: 17,
                                              color: ColorConstant.blackColor),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 20),
                              ButtonWidget(
                                  buttonTitleText: "Add more address details ",
                                  onPress: () {
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(32),
                                          topRight: Radius.circular(32),
                                        )),
                                        context: context,
                                        builder: (context) {
                                          return SingleChildScrollView(
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom),
                                            child: AddAddressSheet(
                                              house: widget.house,
                                              direction: widget.direction,
                                              isEdit: widget.isEdit,
                                              addressId: widget.addressId,
                                              address: address,
                                              longitude: _center.longitude,
                                              latitude: _center.latitude,
                                              callback: () {
                                                widget.callback.call();
                                              },
                                            ),
                                          );
                                        });
                                  })
                            ],
                          ),
                        ),
                      )
              ],
            )
          : const ProgressBarView(),
    );
  }

  /*----------------- Set  init  Location  -----------------*/
  Future<void> _setInitialLocation() async {
    if (widget.isEdit) {
      await requestPermission();
      Position position = await getCurrentLocation();
      setState(() {
        _initialPosition = LatLng(widget.latitude, widget.longitude);
        _locationLoaded = true;
        _markers.add(Marker(
          markerId: const MarkerId('current_Postion'),
          position: LatLng(widget.latitude, widget.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ));
      });
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placeMarks[0];

      getAddressLatLong(LatLng(widget.latitude, widget.longitude));
    } else {
      await requestPermission();
      Position position = await getCurrentLocation();
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _locationLoaded = true;
        _markers.add(Marker(
          markerId: const MarkerId('current_Postion'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ));
      });
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placeMarks[0];

      getAddressLatLong(LatLng(position.latitude, position.longitude));
    }

    /*city = "${place.locality}";
    address =
    "${place.street}, ${place.subLocality}, ${place.locality},${place.thoroughfare}, ${place.subThoroughfare} , ${place.administrativeArea} ${place.postalCode}, ${place.country}";
    lat = position.latitude;
    lng = position.longitude;*/
  }

  /*------------------- Location  Change Liston --------------------*/
  void _listenToLocationChanges() {
    Geolocator.getPositionStream().listen((Position position) {
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14.0,
          ),
        ),
      );
    });
  }

  /*---------------- Request  Permission  -----------------*/
  Future<void> requestPermission() async {
    var status = await Permission.location.request();
    if (status.isDenied) {
      await Permission.location.request();
    } else if (status.isPermanentlyDenied) {
      showMessage(
          "Location permissions are permanently denied, we cannot request permissions.");
    }
  }

  /*--------------  Get Current Location  -----------------*/
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
