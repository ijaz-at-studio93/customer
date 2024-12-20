import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salon_customer/project_specific/progressbar_view.dart';
import 'package:salon_customer/util/logger.dart';

import '../api/dio_client.dart';
import '../constant/assetsconstant.dart';
import '../constant/color_constant.dart';
import '../project_specific/project_appbar.dart';

class StylistToUserLocation extends StatefulWidget {
  final double latitude;
  final double longitude;

  const StylistToUserLocation(
      {super.key, required this.latitude, required this.longitude});

  @override
  State<StylistToUserLocation> createState() => _StylistToUserLocationState();
}

class _StylistToUserLocationState extends State<StylistToUserLocation> {
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

  GoogleMapController? _controller;
  LatLng _initialPosition = const LatLng(0.0, 0.0);
  bool _locationLoaded = false;
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  late GoogleMapController mapController;
  LatLng? initialPosition;
  List<LatLng> postcodeLocations = [];
  final List<Marker> _marker = <Marker>[];

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
  }

  addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        width: 3,
        color: ColorConstant.primaryColor,
        points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.whiteColor,
      appBar: const AppBarWidget(
        nameOfScreen: "Address",
        isBackIcon: true,
      ),
      body: _locationLoaded
          ? GoogleMap(
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
        initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12.0,
              ),
              polylines: Set<Polyline>.of(polylines.values),
        markers: Set<Marker>.of(
          _marker,
        ),
            )
          : const ProgressBarView(),
    );
  }

  /*---------  Move Camera For Google Map ----------*/
  void _moveToInitialPosition() {
    mapController.animateCamera(CameraUpdate.newLatLng(
        initialPosition ?? const LatLng(22.303894, 70.802162)));
  }

  /*========================= Current location lat lng =========================*/
/*  getCurrentLatLng() async {
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

    makeLines(
        currentLat: position.latitude,
        currentLng: position.longitude,
        destLat: widget.latitude,
        destLng: widget.longitude);

    logger.d(
        "DATA ${position.latitude} AND ${position.longitude} AND lat  ${widget.latitude} AND  long ${widget.longitude}");

    final current = await getBitmapDescriptorFromAssetBytes(
        AssetsConstant.avatarDesign, 70);
    final destination =
        await getBitmapDescriptorFromAssetBytes(AssetsConstant.salonIcon, 70);

    setState(() {
      _marker.add(Marker(
          markerId: const MarkerId('1'),
          position: LatLng(position.latitude, position.longitude),
          icon: current));

      _marker.add(Marker(
          markerId: const MarkerId('2'),
          position: LatLng(widget.latitude, widget.longitude),
          icon: destination));
    });

  }*/

  /*----------------- Set  init  Location  -----------------*/
  Future<void> _setInitialLocation() async {
    await requestPermission();
    Position position = await getCurrentLocation();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _locationLoaded = true;
      makeLines(
          currentLat: position.latitude,
          currentLng: position.longitude,
          destLat: widget.latitude,
          destLng: widget.longitude);
    });
    List<Placemark> placeMarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placeMarks[0];

    logger.d(
        "DATA ${position.latitude} AND ${position.longitude} AND lat  ${widget.latitude} AND  long ${widget.longitude}");

    final current = await getBitmapDescriptorFromAssetBytes(
        AssetsConstant.avatarDesign, 70);
    final destination =
        await getBitmapDescriptorFromAssetBytes(AssetsConstant.salonIcon, 70);

    setState(() {
      _marker.add(Marker(
          markerId: const MarkerId('1'),
          position: LatLng(position.latitude, position.longitude),
          icon: current));

      _marker.add(Marker(
          markerId: const MarkerId('2'),
          position: LatLng(widget.latitude, widget.longitude),
          icon: destination));
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

  void makeLines(
      {required double currentLat,
      required double currentLng,
      required double destLat,
      required double destLng}) async {
    await polylinePoints
        .getRouteBetweenCoordinates(
            request: PolylineRequest(
                headers: {},
                origin: PointLatLng(currentLat, currentLng),
                destination: PointLatLng(destLat, destLng),
                mode: TravelMode.driving),
            googleApiKey: "AIzaSyClfJgsQEwO0zO6io_TuR-TDUsVwGT3ex0")
        .then((value) {
      for (var point in value.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }).then((value) {
      addPolyLine();
    });
  }
}
