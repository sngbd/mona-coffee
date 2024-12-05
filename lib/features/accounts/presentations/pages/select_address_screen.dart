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
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  String _selectedAddress = "Move the map to select an address";
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

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
        locationSettings: AndroidSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Get address for current location
      await _getAddressFromLatLng(_currentPosition!);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: $e';
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
      setState(() {
        _errorMessage = 'Failed to search address: $e';
      });
    }
  }

  void _confirmAddress() {
    Navigator.pop(context, {
      'address': _selectedAddress,
      'coordinates': _currentPosition,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Address"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmAddress,
          ),
        ],
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
                        target: _currentPosition!,
                        zoom: 14.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      onCameraMove: _onCameraMove,
                      onCameraIdle: _onCameraIdle,
                      myLocationEnabled: true,
                    ),
                    const Center(
                      child:
                          Icon(Icons.location_pin, size: 40, color: Colors.red),
                    ),
                    Positioned(
                      top: 64,
                      left: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search address',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: _searchAddress,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 100,
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
