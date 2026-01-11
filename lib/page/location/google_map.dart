import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as fp;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salon_customer/api/dio_client.dart';
import 'package:salon_customer/constant/color_constant.dart';
import 'package:salon_customer/controller/auth_controller.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/project_specific/text_theme.dart';
import 'package:salon_customer/util/SharedPrefs.dart';

class GoogleMapGetLocation extends StatefulWidget {
  final VoidCallback callback;
  const GoogleMapGetLocation({super.key, required this.callback});

  @override
  State<GoogleMapGetLocation> createState() => _GoogleMapGetLocationState();
}

class _GoogleMapGetLocationState extends State<GoogleMapGetLocation> {
  final _authController = Get.find<AuthController>();

  GoogleMapController? _controller;
  LatLng _initialPosition = const LatLng(0.0, 0.0);
  bool _locationLoaded = false;
  final List<Marker> _marker = <Marker>[];

  final _searchMapLocation = TextEditingController();
  ValueNotifier<bool> close = ValueNotifier(false);

  final places =
      fp.FlutterGooglePlacesSdk('AIzaSyATecmTI6WWH24gR6wCR4IooVH77VCnSgc');
  ValueNotifier<List<fp.AutocompletePrediction>> locationData =
      ValueNotifier([]);

  String address = "";
  String city = "";
  double lat = 0.0;
  double lng = 0.0;

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
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
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: ColorConstant.blackColor,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _authController.userCity = city;
                _authController.userCurrentLocation = address;
                SharedPrefs.writeValue(
                    PrefConstants.userCity, _authController.userCity);
                SharedPrefs.writeValue(
                    PrefConstants.address, _authController.userCurrentLocation);
                SharedPrefs.writeValue(PrefConstants.longitude, lng.toString());
                SharedPrefs.writeValue(PrefConstants.latitude, lat.toString());
                widget.callback.call();
                Get.back();
              },
              icon: const Icon(
                Icons.check_circle,
                color: ColorConstant.blackColor,
              ))
        ],
        centerTitle: true,
        title: Text(
          "Set Address",
          style: AppTextTheme.bold
              .copyWith(color: ColorConstant.blackColor, fontSize: 19),
        ),
      ),
      body: _locationLoaded
          ? Stack(
              clipBehavior: Clip.none,
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
                    _marker.clear();
                    List<Placemark> placeMarks = await placemarkFromCoordinates(
                        latLng.latitude, latLng.longitude);
                    Placemark place = placeMarks[0];
                    _marker.add(Marker(
                      markerId: const MarkerId('current_Postion23'),
                      position: LatLng(latLng.latitude, latLng.longitude),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueViolet,
                      ),
                    ));

                    _authController.userCity = "${place.locality}";
                    _authController.userCurrentLocation =
                        "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";

                    SharedPrefs.writeValue(
                        PrefConstants.longitude, latLng.longitude.toString());
                    SharedPrefs.writeValue(
                        PrefConstants.latitude, latLng.latitude.toString());
                    setState(() {});
                  },
                  markers: Set<Marker>.of(
                    _marker,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
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
                                              _marker.clear();
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
                                              city = "${place.locality}";
                                              address =
                                                  "${place.street}, ${place.subLocality}, ${place.locality},${place.thoroughfare}, ${place.subThoroughfare} , ${place.administrativeArea} ${place.postalCode}, ${place.country}";
                                              lat = location[0].latitude;
                                              lng = location[0].longitude;

                                              _marker.add(Marker(
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

                                                _controller?.animateCamera(
                                                    CameraUpdate.newLatLng(
                                                        LatLng(
                                                            location[0]
                                                                .latitude,
                                                            location[0]
                                                                .longitude)));
                                              });
                                              // code of coming to home page automatically when i clicked on any location result
                                              // Save to controller
                                              _authController.userCity = city;
                                              _authController.userCurrentLocation = address;

                                              // Save to shared prefs
                                              SharedPrefs.writeValue(PrefConstants.userCity, city);
                                              SharedPrefs.writeValue(PrefConstants.address, address);
                                              SharedPrefs.writeValue(PrefConstants.latitude, lat.toString());
                                              SharedPrefs.writeValue(PrefConstants.longitude, lng.toString());

                                              // Notify home page
                                              widget.callback.call();

                                              // Go back automatically
                                              Get.back();

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
              ],
            )
          : const ProgressBarView(),
    );
  }

  /*----------------- Set  init  Location  -----------------*/
  Future<void> _setInitialLocation() async {
    await requestPermission();
    Position position = await getCurrentLocation();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _locationLoaded = true;
      _marker.add(Marker(
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

    city = "${place.locality}";
    address =
        "${place.street}, ${place.subLocality}, ${place.locality},${place.thoroughfare}, ${place.subThoroughfare} , ${place.administrativeArea} ${place.postalCode}, ${place.country}";
    lat = position.latitude;
    lng = position.longitude;
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
