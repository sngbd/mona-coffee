// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/widgets/flasher.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key});

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  String _selectedAddress = "Move the map to select an address";
  bool _isLoading = true;
  String _errorMessage = '';
  double totalDistance = 0.0;
  int deliveryFee = 0;
  LatLng sourceLocation = const LatLng(3.5972701734490427, 98.68792492347372);

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371;

    double lat1 = start.latitude * math.pi / 180;
    double lon1 = start.longitude * math.pi / 180;
    double lat2 = end.latitude * math.pi / 180;
    double lon2 = end.longitude * math.pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  int calculateDeliveryFee(double distance) {
    int baseFee = 10000;

    int feePerKm = 1000;

    int totalFee = baseFee + (feePerKm * distance.ceil());

    return totalFee;
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _errorMessage =
              'Location permissions are required to get current location';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Get address for current location
      await _getAddressFromLatLng(_currentPosition!);
    } catch (e) {
      Flasher.showSnackBar(
        context,
        'Error',
        'Failed to get current location: $e',
        Icons.error_outline,
        Colors.red,
      );
      setState(() {
        _errorMessage = 'Failed to get current location: $e';
        _isLoading = false;
      });
      Navigator.pop(context, {
        'address': _selectedAddress,
        'distance': totalDistance,
        'fee': deliveryFee,
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress = _formatAddress(place);
        });
      } else {
        Flasher.showSnackBar(
          context,
          'Error',
          'Address not found',
          Icons.error_outline,
          Colors.red,
        );
        setState(() {
          _selectedAddress = 'Address not found';
        });
        Navigator.pop(context, {
          'address': _searchController.text,
          'distance': double.infinity,
          'fee': 999999999,
        });
      }
    } catch (e) {
      Flasher.showSnackBar(
        context,
        'Error',
        'Unable to retrieve address',
        Icons.error_outline,
        Colors.red,
      );
      setState(() {
        _selectedAddress = 'Unable to retrieve address';
      });
      Navigator.pop(context, {
        'address': _searchController.text,
        'distance': double.infinity,
        'fee': 999999999,
      });
    }
  }

  String _formatAddress(Placemark place) {
    // Create a more readable and comprehensive address format
    List<String> addressParts = [];

    if (place.name != null && place.name != place.street) {
      addressParts.add(place.name!);
    }
    if (place.street != null) {
      addressParts.add(place.street!);
    }
    if (place.locality != null) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.postalCode != null) {
      addressParts.add(place.postalCode!);
    }
    if (place.country != null) {
      addressParts.add(place.country!);
    }

    return addressParts.join(', ');
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentPosition = position.target;
    });
  }

  void _onCameraIdle() {
    _getAddressFromLatLng(_currentPosition!);
  }

  Future<void> _searchAddress() async {
    try {
      List<Location> locations =
          await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newPosition = LatLng(location.latitude, location.longitude);
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newPosition, zoom: 14.0),
          ),
        );
        setState(() {
          _currentPosition = newPosition;
        });
        await _getAddressFromLatLng(newPosition);
      } else {
        setState(() {
          _errorMessage = 'Address not found';
        });
      }
    } catch (e) {
      Flasher.showSnackBar(
        context,
        'Error',
        'Failed to search address: $e',
        Icons.error_outline,
        Colors.red,
      );
      setState(() {
        _errorMessage = 'Failed to search address: $e';
      });
      Navigator.pop(context, {
        'address': _searchController.text,
        'distance': double.infinity,
        'fee': 999999999,
      });
    }
  }

  void _confirmAddress() {
    totalDistance = calculateDistance(
      sourceLocation,
      _currentPosition!,
    );
    deliveryFee = calculateDeliveryFee(totalDistance);
    Navigator.pop(context, {
      'address': _selectedAddress,
      'distance': totalDistance,
      'fee': deliveryFee,
    });
  }

  void _zoomIn() {
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: mDarkBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Address',
          style: TextStyle(
            color: mDarkBrown,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmAddress,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: mDarkBrown))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,
                        zoom: 14.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      onCameraMove: _onCameraMove,
                      onCameraIdle: _onCameraIdle,
                      zoomControlsEnabled: false,
                    ),
                    const Center(
                      child:
                          Icon(Icons.location_pin, size: 40, color: Colors.red),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    hintText: 'Search address',
                                    border: InputBorder.none,
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    )),
                                  ),
                                  onSubmitted: (value) => _searchAddress(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: _searchAddress,
                                color: mBrown,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 32,
                      left: 16,
                      right: 16,
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedAddress,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: mBrown,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 144,
                      right: 16,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            backgroundColor: Colors.white,
                            onPressed: _zoomIn,
                            mini: true,
                            child: const Icon(Icons.zoom_in, color: mBrown),
                          ),
                          const SizedBox(height: 3),
                          FloatingActionButton(
                            backgroundColor: Colors.white,
                            onPressed: _zoomOut,
                            mini: true,
                            child: const Icon(Icons.zoom_out, color: mBrown),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
