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
import 'package:sallon_customer/constant/assetsconstant.dart';
import 'package:sallon_customer/constant/color_constant.dart';
import 'package:sallon_customer/constant/variable_constant.dart';
import 'package:sallon_customer/project_specific/button_widget.dart';
import 'package:sallon_customer/util/SharedPrefs.dart';
import 'package:sallon_customer/util/logger.dart';
import 'package:sallon_customer/util/permission_dialog.dart';
import '../api/dio_client.dart';
import '../controller/auth_controller.dart';
import '../project_specific/progressbar_view.dart';
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
    return BitmapDescriptor.fromBytes(imageData!);
  }

  final _authController = Get.find<AuthController>();
  final Completer<GoogleMapController> controller = Completer();
  late GoogleMapController _googleMapController;
  bool isMapCreated = false;
  final places =
      fp.FlutterGooglePlacesSdk('AIzaSyASd8ofkbG7ItOylvlTv9Ii71loe0xYPJI');
  ValueNotifier<List<fp.AutocompletePrediction>> locationData =
      ValueNotifier([]);
  final _searchMapLocation = TextEditingController();
  String address = "";
  late Position currentLocation;
  LatLng _center = const LatLng(78.409989, 101.98901);

  String locality = "";
  String subLocality = "";

  /*-------------------------- Get Address ---------------*/
  Future<void> getAddressLatLong(LatLng latLang) async {
    List<Placemark> placeMarks =
        await placemarkFromCoordinates(latLang.latitude, latLang.longitude);
    Placemark place = placeMarks[0];
    address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    /*-------------- other Data get ---------------*/
    // , ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}
    logger.d(place);
    logger.d(address);
    locality = place.locality ?? "";
    subLocality = place.subLocality ?? "";
    setState(() {});
  }

  getUserLocation() async {
    _authController.googleMapProgress = true;
    final icon =
        await getBitmapDescriptorFromAssetBytes(AssetsConstant.markerIcon, 150);
    currentLocation = await getCurrentLatLng(_googleMapController);
    if (widget.longitude == 0 && widget.latitude == 0) {
      _center = LatLng(currentLocation.latitude, currentLocation.longitude);

      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: const MarkerId('20'),
        icon: icon,
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(
          title: address,
          //  snippet: '5 Star Rating',
        ),
      ));
      getAddressLatLong(_center);
      setState(() {});
    } else {
      _center = LatLng(widget.latitude, widget.longitude);

      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: const MarkerId('20'),
        icon: icon,
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(
          title: address,
          //  snippet: '5 Star Rating',
        ),
      ));

      getAddressLatLong(_center);
      _googleMapController.animateCamera(CameraUpdate.newLatLng(
          LatLng(currentLocation.latitude, widget.longitude)));
      setState(() {});
    }

    _authController.googleMapProgress = false;
  }

  /*--------------- Create List Of Marker ---------- */
  final Set<Marker> _markers = {};

  @override
  void initState() {
    _searchMapLocation.clear();
    super.initState();
  }

  ValueNotifier<bool> close = ValueNotifier(false);

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

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
            Get.back();
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
      body: Column(children: [
        _authController.googleMapProgress
            ? Column(
                children: [
                  SizedBox(height: Get.height * 0.4),
                  const ProgressBarView(),
                ],
              )
            : notGivenPermission
                ? Column(
                    children: [
                      SizedBox(height: Get.height * 0.4),
                      locationPermission(),
                    ],
                  )
                : Expanded(
                    child: Stack(
                      children: [
                        SizedBox(
                          child: GoogleMap(
                            liteModeEnabled: false,
                            myLocationButtonEnabled: false,
                            myLocationEnabled: true,
                            zoomControlsEnabled: false,
                            mapType: MapType.normal,
                            initialCameraPosition:
                                CameraPosition(target: _center, zoom: 14.4746),
                            markers: _markers,
                            onMapCreated: (controller) async {
                              _googleMapController = controller;
                              if (!isMapCreated) {
                                isMapCreated = true;
                                await getUserLocation();
                              }
                            },
                            onCameraMove: (val) {

                            },
                            onTap: (tap) {
                              locationData.value = [];
                            },
                          ),
                        ),
                        Positioned(
                          top: 15,
                          left: 10,
                          right: 10,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 50,
                                width: Get.width,
                                decoration: BoxDecoration(
                                  color: ColorConstant.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: ColorConstant.borderColor,
                                  ),
                                ),
                                // height: 48,
                                child: TextField(
                                  controller: _searchMapLocation,
                                  style: Get.textTheme.bodyLarge
                                      ?.copyWith(color: Colors.white),
                                  onChanged: (val) async {
                                    if (val != "") {
                                      close.value = true;
                                      close.notifyListeners();
                                      final predictions = await places
                                          .findAutocompletePredictions(val);
                                      locationData.value =
                                          predictions.predictions;
                                    } else {
                                      close.value = false;
                                      close.notifyListeners();
                                      locationData.value = [];
                                    }
                                    locationData.notifyListeners();
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Search Location",
                                      hintStyle: Get.textTheme.bodyLarge
                                          ?.copyWith(color: Colors.white),
                                      prefixIcon: const Icon(Icons.search,
                                          color: Colors.white, size: 20),
                                      suffixIcon: ValueListenableBuilder(
                                          valueListenable: close,
                                          builder: (context, v, c) {
                                            return close.value
                                                ? InkWell(
                                                    onTap: () {
                                                      FocusManager
                                                          .instance.primaryFocus
                                                          ?.unfocus();
                                                      _searchMapLocation
                                                          .clear();
                                                      locationData.value = [];
                                                      close.value = false;
                                                      close.notifyListeners();
                                                      getUserLocation();
                                                    },
                                                    child: const Icon(
                                                      CupertinoIcons
                                                          .xmark_circle,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  )
                                                : const SizedBox();
                                          })),
                                ),
                              ),
                              Container(
                                color: ColorConstant.blackColor,
                                margin: const EdgeInsets.only(
                                    left: 5, right: 5, top: 15),
                                child: ValueListenableBuilder(
                                    valueListenable: locationData,
                                    builder: (context, v, c) {
                                      return locationData.value.isEmpty
                                          ? const SizedBox()
                                          : ListView.separated(
                                              separatorBuilder: (context, i) {
                                                return const Divider(
                                                  color:
                                                      ColorConstant.whiteColor,
                                                );
                                              },
                                              itemCount:
                                                  locationData.value.length,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                    final icon =
                                                        await getBitmapDescriptorFromAssetBytes(
                                                            AssetsConstant
                                                                .markerIcon,
                                                            150);

                                                    _searchMapLocation.text =
                                                        locationData
                                                            .value[index]
                                                            .fullText
                                                            .toString();
                                                    locationData.value = [];
                                                    _markers.clear();
                                                    List<Location> location =
                                                        await locationFromAddress(
                                                            _searchMapLocation
                                                                .text);
                                                    if (location.isNotEmpty) {
                                                      address =
                                                          _searchMapLocation
                                                              .text;

                                                      _markers.add(Marker(
                                                        // This marker id can be anything that uniquely identifies each marker.
                                                        markerId:
                                                            const MarkerId('2'),
                                                        position: LatLng(
                                                            location[0]
                                                                .latitude,
                                                            location[0]
                                                                .longitude),
                                                        infoWindow: InfoWindow(
                                                          title: address,
                                                          //  snippet: '5 Star Rating',
                                                        ),
                                                        icon: icon,
                                                      ));

                                                      _authController
                                                              .googleMapProgress =
                                                          true;
                                                      _center = LatLng(
                                                          location[0].latitude,
                                                          location[0]
                                                              .longitude);

                                                      setState(() {
                                                        getAddressLatLong(
                                                            _center);
                                                        _authController
                                                                .googleMapProgress =
                                                            false;

                                                        _googleMapController
                                                            .animateCamera(CameraUpdate
                                                                .newLatLng(LatLng(
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
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          child: SizedBox(
                                                            width: Get.width,
                                                            child: Text(
                                                                locationData
                                                                    .value[
                                                                        index]
                                                                    .fullText
                                                                    .toString(),
                                                                style: Get
                                                                    .textTheme
                                                                    .titleMedium
                                                                    ?.copyWith(
                                                                  color: ColorConstant
                                                                      .whiteColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                )),
                                                          ),
                                                        ),
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
                                  height: Get.height * 0.2,
                                  width: Get.width,
                                  color: ColorConstant.whiteColor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                subLocality,
                                                textScaler:
                                                    const TextScaler.linear(
                                                        0.85),
                                                style: AppTextTheme.bold
                                                    .copyWith(
                                                        fontSize: 17,
                                                        color: ColorConstant
                                                            .blackColor),
                                              ),
                                              Text(
                                                locality,
                                                textScaler:
                                                    const TextScaler.linear(
                                                        0.85),
                                                style: AppTextTheme.medium
                                                    .copyWith(
                                                        fontSize: 17,
                                                        color: ColorConstant
                                                            .blackColor),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      ButtonWidget(
                                          buttonTitleText:
                                              "Add more address details ",
                                          onPress: () {
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
                                                  return SingleChildScrollView(
                                                    padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                context)
                                                            .viewInsets
                                                            .bottom),
                                                    child: AddAddressSheet(
                                                      house: widget.house,
                                                      direction:
                                                          widget.direction,
                                                      isEdit: widget.isEdit,
                                                      addressId:
                                                          widget.addressId,
                                                      address: address,
                                                      longitude:
                                                          _center.longitude,
                                                      latitude:
                                                          _center.latitude,
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
                    ),
                  ),
      ]),
    );
  }

  /*---------- location  Permission Not Granted ---------------*/
  bool notGivenPermission = false;

  Future<Position> getCurrentLatLng(
      GoogleMapController googleMapController) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission;
    if (!serviceEnabled) {
      Get.back();
      await Permission.location.request();
      showMessage("Location services are disabled.");
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.back();
        // await Permission.location.request();

        setState(() {
          notGivenPermission = true;
        });
        showMessage("Location permissions are denied");
        _authController.googleMapProgress = false;
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        notGivenPermission = true;
      });
      Get.back();

      _authController.googleMapProgress = false;
      // showMessage("Location permissions are permanently denied, we cannot request permissions.");
      Get.dialog(const PermissionDialog(
        title: "Enable GPS Location",
        desc: "Please Give access of Location service.",
      ));
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition();
    /*-------------  current location  marker code ----------*/
    // _marker.add(Marker(
    //     position: LatLng(position.latitude, position.longitude),
    //     onTap: () {},
    //     markerId: const MarkerId("11")));
    googleMapController.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
    return position;
  }

  /*No  Permission  Assign*/
  Widget locationPermission() {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.location_off_rounded, size: 40, color: Colors.white),
          const SizedBox(height: 12),
          Text("Please allow permission for map location",
              style: Get.textTheme.titleMedium!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
