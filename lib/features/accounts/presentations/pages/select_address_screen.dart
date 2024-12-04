import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key});

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  LatLng _currentPosition =
      const LatLng(37.7749, -122.4194); // Default: San Francisco
  String _selectedAddress = "Move the map to select an address";
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Handle cases where permission is not granted
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _errorMessage =
              'Location permissions are required to get current location';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Get address for current location
      await _getAddressFromLatLng(_currentPosition);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location';
        _isLoading = false;
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
        setState(() {
          _selectedAddress = 'Address not found';
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Unable to retrieve address';
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
    _getAddressFromLatLng(_currentPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Address"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                        target: _currentPosition,
                        zoom: 14.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {},
                      onCameraMove: _onCameraMove,
                      onCameraIdle: _onCameraIdle,
                    ),
                    const Center(
                      child:
                          Icon(Icons.location_pin, size: 40, color: Colors.red),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 10,
                      right: 10,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedAddress,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed:
                                    _selectedAddress != 'Address not found'
                                        ? () {
                                            Navigator.pop(
                                                context, _selectedAddress);
                                          }
                                        : null,
                                child: const Text("Confirm Address"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
