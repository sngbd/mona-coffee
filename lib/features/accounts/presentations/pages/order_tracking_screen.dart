import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final LatLng destinationLocation;

  const OrderTrackingScreen({super.key, required this.destinationLocation});

  @override
  State<OrderTrackingScreen> createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    _createPolyline();
    setCustomMarkerIcon();
    startTimer();
    polylinePoints = [sourceLocation, widget.destinationLocation];
  }

  @override
  void dispose() {
    timer?.cancel();
    mapController?.dispose();

    super.dispose();
  }

  GoogleMapController? mapController;

  static const LatLng sourceLocation =
      LatLng(3.5972701734490427, 98.68792492347372);

  Set<Polyline> polylines = {};
  List<LatLng> polylinePoints = [sourceLocation];
  List<LatLng> polylineCoordinates = [];
  int index = 0;
  Timer? timer;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  void setCustomMarkerIcon() {
    BitmapDescriptor.asset(
            ImageConfiguration.empty, "assets/images/mona_marker.png")
        .then(
      (icon) {
        sourceIcon = icon;
      },
    );
    BitmapDescriptor.asset(
            ImageConfiguration.empty, "assets/images/scooter_marker.png")
        .then(
      (icon) {
        currentLocationIcon = icon;
      },
    );
  }

  void _createPolyline() {
    setState(() {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  void startTimer() async {
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (index < polylinePoints.length - 1) {
        setState(() {
          index++;
          if (mapController != null) {
            mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  zoom: 13.5,
                  target: polylinePoints[index],
                ),
              ),
            );
          }
        });
      } else {
        timer.cancel(); // Stop the timer when the end is reached
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: sourceLocation,
          zoom: 13.5,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("source"),
            position: sourceLocation,
            icon: sourceIcon,
          ),
          Marker(
            markerId: const MarkerId("current"),
            position: polylinePoints[index],
            icon: currentLocationIcon,
          ),
          Marker(
            markerId: const MarkerId("destination"),
            position: widget.destinationLocation,
          ),
        },
        myLocationEnabled: false,
        polylines: polylines,
        onMapCreated: (controller) {
          mapController = controller;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                zoom: 13.5,
                target: polylinePoints[index],
              ),
            ),
          );
        },
      ),
    );
  }
}
