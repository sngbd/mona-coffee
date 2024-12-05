import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:logger/web.dart';

class OrderTrackingScreen extends StatefulWidget {
  final LatLng destinationLocation;

  const OrderTrackingScreen({super.key, required this.destinationLocation});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const LatLng sourceLocation =
      LatLng(3.5972701734490427, 98.68792492347372);

  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  Timer? movementTimer;
  int currentPointIndex = 0;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    setCustomMarkerIcon();
    getRoutePoints();
  }

  @override
  void dispose() {
    movementTimer?.cancel();
    super.dispose();
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.asset(
            ImageConfiguration.empty, "assets/images/mona_marker.png")
        .then((icon) {
      setState(() {
        sourceIcon = icon;
        _updateMarkers();
      });
    });

    BitmapDescriptor.asset(
            ImageConfiguration.empty, "assets/images/scooter_marker.png")
        .then((icon) {
      setState(() {
        currentLocationIcon = icon;
        _updateMarkers();
      });
    });

  }

  void _updateMarkers() {
    markers = {
      Marker(
        markerId: const MarkerId("source"),
        position: sourceLocation,
        icon: sourceIcon,
      ),
      Marker(
        markerId: const MarkerId("destination"),
        position: widget.destinationLocation,
      ),
      if (polylineCoordinates.isNotEmpty)
        Marker(
          markerId: const MarkerId("current"),
          position: polylineCoordinates[currentPointIndex],
          icon: currentLocationIcon,
        ),
    };
  }

  void getRoutePoints() async {
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: 'AIzaSyC6JodHoq3oyOK47Wzx-PtEmKI6oub5F3U',
        request: PolylineRequest(
          origin:
              PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
          destination: PointLatLng(widget.destinationLocation.latitude,
              widget.destinationLocation.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.clear();
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        setState(() {
          polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ));
          _updateMarkers();
        });

        // Fit the route on the map
        await _fitRoute();

        // Start route animation
        startRouteAnimation();
      } else {
        Logger().e('No route found: ${result.errorMessage}');
      }
    } catch (e) {
      Logger().e('Error getting route: $e');
    }
  }

  Future<void> _fitRoute() async {
    if (polylineCoordinates.isNotEmpty) {
      final GoogleMapController controller = await _controller.future;

      // Calculate bounds
      double minLat = polylineCoordinates
          .map((p) => p.latitude)
          .reduce((a, b) => a < b ? a : b);
      double maxLat = polylineCoordinates
          .map((p) => p.latitude)
          .reduce((a, b) => a > b ? a : b);
      double minLng = polylineCoordinates
          .map((p) => p.longitude)
          .reduce((a, b) => a < b ? a : b);
      double maxLng = polylineCoordinates
          .map((p) => p.longitude)
          .reduce((a, b) => a > b ? a : b);

      // Add some padding
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          50,
        ),
      );
    }
  }

  void startRouteAnimation() {
    movementTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (currentPointIndex < polylineCoordinates.length - 1) {
        setState(() {
          currentPointIndex++;
          _updateMarkers();
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
        mapType: MapType.normal,
        initialCameraPosition: const CameraPosition(
          target: sourceLocation,
          zoom: 13.5,
        ),
        markers: markers,
        polylines: polylines,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
