import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mona_coffee/core/utils/polyline.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> {
  GoogleMapController? mapController;

  static const LatLng sourceLocation =
      LatLng(3.5972701734490427, 98.68792492347372);
  static const LatLng destinationLocation =
      LatLng(3.5626441083765146, 98.6591347800891);

  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  int index = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _createPolyline();
    setCustomMarkerIcon();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  void setCustomMarkerIcon() {
    BitmapDescriptor.asset(ImageConfiguration.empty, "assets/images/mona_marker.png").then(
      (icon) {
        sourceIcon = icon;
      },
    );
    BitmapDescriptor.asset(ImageConfiguration.empty, "assets/images/scooter_marker.png")
        .then(
      (icon) {
        currentLocationIcon = icon;
      },
    );
  }

  void _createPolyline() {
    setState(() {
      polylines.add(
        const Polyline(
          polylineId: PolylineId('route'),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  void startTimer() async {
    timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (index < polylinePoints.length - 1) {
        setState(() {
          index++;
          GoogleMapController? controller = mapController;
          controller?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                zoom: 13.5,
                target: polylinePoints[index],
              ),
            ),
          );
        });
      } else {
        timer.cancel(); // Stop the timer when the end is reached
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            markerId: const MarkerId(" constation"),
            position: destinationLocation,
            icon: destinationIcon,
          ),
        },
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
