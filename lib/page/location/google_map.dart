import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as fp;

class GoogleMapGetLocation extends StatefulWidget {
  final VoidCallback callback;
  const GoogleMapGetLocation({super.key, required this.callback});

  @override
  State<GoogleMapGetLocation> createState() => _GoogleMapGetLocationState();
}

class _GoogleMapGetLocationState extends State<GoogleMapGetLocation> {
  late GoogleMapController mapController;
  LatLng? initialPosition;
  List<LatLng> postcodeLocations = [];
  final List<Marker> _marker = <Marker>[];

  final _searchMapLocation = TextEditingController();
  final _authController = Get.find<AuthController>();
  ValueNotifier<bool> close = ValueNotifier(false);

  final places =
      fp.FlutterGooglePlacesSdk('AIzaSyCfT7gdH9_FxaRT90cxexYlxgUGsXOEo_Q');
  ValueNotifier<List<fp.AutocompletePrediction>> locationData =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _searchMapLocation.clear();
    getCurrentLatLng();
  }

  @override
  void dispose() {
    super.dispose();
    _searchMapLocation.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgColor,
      appBar: AppBar(
        elevation: 0.0,
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
          "Set Address",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
        actions: [
          IconButton(
              onPressed: () {
                widget.callback.call();
                Get.back();
              },
              icon: const Icon(
                Icons.check_circle_rounded,
                color: ColorConstant.blackColor,
              ))
        ],
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            tiltGesturesEnabled: true,
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
              _moveToInitialPosition();
            },
            onTap: (latLng) async {
              List<Placemark> placeMarks = await placemarkFromCoordinates(
                  latLng.latitude, latLng.longitude);
              Placemark place = placeMarks[0];

              setState(() {
                _marker.add(Marker(
                  markerId: const MarkerId('current_Postion'),
                  position: LatLng(latLng.latitude, latLng.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueViolet,
                  ),
                ));
              });
              _authController.userCity = "${place.locality}";
              _authController.userCurrentLocation =
                  "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";

              SharedPrefs.writeValue(
                  PrefConstants.longitude, latLng.longitude.toString());
              SharedPrefs.writeValue(
                  PrefConstants.latitude, latLng.latitude.toString());
            },
            initialCameraPosition: CameraPosition(
              target: initialPosition ?? const LatLng(22.303894, 70.802162),
              zoom: 12.0,
            ),
            markers: Set<Marker>.of(
              _marker,
            ),
          ),
          Positioned(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: ColorConstant.whiteColor,
                   borderRadius: BorderRadius.circular(5)
                  ),
                  alignment: Alignment.center,
                   margin: const EdgeInsets.only(left: 10, right: 10, top: 25),
                  // height: 48,
                  child: TextField(
                    controller: _searchMapLocation,
                    style:
                        Get.textTheme.bodyLarge?.copyWith(color: Colors.black),
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
                                        _marker.clear();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        _searchMapLocation.clear();
                                        locationData.value = [];
                                        close.value = false;
                                        close.notifyListeners();
                                        getCurrentLatLng();
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
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 15),
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
                                      _searchMapLocation.text = locationData
                                          .value[index].fullText
                                          .toString();
                                      locationData.value = [];
                                      _marker.clear();
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
                                          _marker.add(Marker(
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
                                        _authController.userCity =
                                            "${place.locality}";
                                        _authController.userCurrentLocation =
                                            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";

                                        SharedPrefs.writeValue(
                                            PrefConstants.longitude,
                                            location[0].longitude.toString());
                                        SharedPrefs.writeValue(
                                            PrefConstants.latitude,
                                            location[0].latitude.toString());

                                        _marker.add(Marker(
                                          markerId: const MarkerId('new'),
                                          position: LatLng(location[0].latitude,
                                              location[0].longitude),
                                          icon: BitmapDescriptor
                                              .defaultMarkerWithHue(
                                            BitmapDescriptor.hueViolet,
                                          ),
                                        ));

                                        _authController.googleMapProgress =
                                            true;

                                        setState(() {
                                          _authController.googleMapProgress =
                                              false;

                                          mapController.animateCamera(
                                              CameraUpdate.newLatLng(LatLng(
                                                  location[0].latitude,
                                                  location[0].longitude)));
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: SizedBox(
                                              width: Get.width,
                                              child: Text(
                                                  locationData
                                                      .value[index].fullText
                                                      .toString(),
                                                  style: Get
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    color: ColorConstant
                                                        .blackColor,
                                                    fontWeight: FontWeight.w400,
                                                  )),
                                            ),
                                          ),
                                          index == locationData.value.length - 1
                                              ? const SizedBox(
                                                  height: 10,
                                                )
                                              : const Divider(
                                                  color:
                                                      ColorConstant.blackColor,
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
        ],
      ),
    );
  }

  /*---------  Move Camera For Google Map ----------*/
  void _moveToInitialPosition() {
    mapController.animateCamera(CameraUpdate.newLatLng(
        initialPosition ?? const LatLng(22.303894, 70.802162)));
  }

  /*------------------------ Get Current Location to Lat Lng ------------------------*/
  getCurrentLatLng() async {
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
        await Permission.location.request();
        showMessage("Location permissions are denied");
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Get.back();
      showMessage(
          "Location permissions are permanently denied, we cannot request permissions.");
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition();
    initialPosition = LatLng(position.latitude, position.latitude);
    setState(() {
      _marker.add(Marker(
        markerId: const MarkerId('current_Postion'),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
      ));
    });
  }
}
