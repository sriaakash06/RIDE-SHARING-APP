import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier {
  Location _location = Location();
  LocationData? _currentLocation;
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  LocationData? get currentLocation => _currentLocation;

  LocationProvider() {
    _initLocation();
  }

  Future<void> _initLocation() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _location.onLocationChanged.listen((LocationData currentLocation) {
      _currentLocation = currentLocation;
      notifyListeners();
    });

    _currentLocation = await _location.getLocation();
    notifyListeners();
  }

  Future<void> animateCamera(GoogleMapController? controller) async {
    if (_currentLocation != null && controller != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            zoom: 15,
          ),
        ),
      );
    }
  }
}
