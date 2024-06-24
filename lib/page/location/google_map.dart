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

  final _authController = Get.find<AuthController>();


  @override
  void initState() {
    super.initState();
    getCurrentLatLng();
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
      body: GoogleMap(
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
          List<Placemark> placeMarks =
              await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
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
