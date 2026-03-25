import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_model.dart';
import '../models/driver_model.dart';
import '../main.dart';

class RideProvider with ChangeNotifier {
  FirebaseFirestore? get _firestore => isFirebaseInitialized ? FirebaseFirestore.instance : null;
  RideModel? _currentRide;
  List<DriverModel> _nearbyDrivers = [];
  bool _isRequesting = false;

  RideModel? get currentRide => _currentRide;
  List<DriverModel> get nearbyDrivers => _nearbyDrivers;
  bool get isRequesting => _isRequesting;

  void fetchNearbyDrivers(double lat, double lng) {
    _nearbyDrivers = [
      DriverModel(
        uid: 'driver1',
        name: 'John Doe',
        rating: 4.8,
        carModel: 'Toyota Corolla',
        carColor: 'White',
        licensePlate: 'ABC-123',
        latitude: lat + 0.005,
        longitude: lng + 0.005,
      ),
      DriverModel(
        uid: 'driver2',
        name: 'Jane Smith',
        rating: 4.9,
        carModel: 'Honda Civic',
        carColor: 'Black',
        licensePlate: 'XYZ-789',
        latitude: lat - 0.005,
        longitude: lng - 0.005,
      ),
    ];
    notifyListeners();
  }

  Future<String?> requestRide({
    required String userId,
    required double pickupLat,
    required double pickupLng,
    required double destLat,
    required double destLng,
    required String pickupAddr,
    required String destAddr,
    required double fare,
  }) async {
    _isRequesting = true;
    notifyListeners();

    String rideId = isFirebaseInitialized ? _firestore!.collection('rides').doc().id : "mock_ride_id";
    RideModel ride = RideModel(
      rideId: rideId,
      userId: userId,
      pickupLatitude: pickupLat,
      pickupLongitude: pickupLng,
      destLatitude: destLat,
      destLongitude: destLng,
      pickupAddress: pickupAddr,
      destAddress: destAddr,
      status: RideStatus.pending,
      fare: fare,
    );

    try {
      if (isFirebaseInitialized) {
        await _firestore!.collection('rides').doc(rideId).set(ride.toMap());
      }
      _currentRide = ride;
      
      Future.delayed(Duration(seconds: 5), () {
        _acceptRideMock(rideId);
      });
      _isRequesting = false;
      notifyListeners();
      return null;
    } on FirebaseException catch (e) {
      _isRequesting = false;
      notifyListeners();
      return e.message ?? "Database error. Please check Firestore rules.";
    } catch (e) {
      _isRequesting = false;
      notifyListeners();
      return e.toString();
    }
  }

  void _acceptRideMock(String rideId) async {
    if (_currentRide != null && _currentRide!.rideId == rideId) {
      if (isFirebaseInitialized) {
        await _firestore!.collection('rides').doc(rideId).update({
          'status': 'accepted',
          'driverId': 'driver1',
        });
      }
      
      _currentRide = RideModel(
        rideId: _currentRide!.rideId,
        userId: _currentRide!.userId,
        driverId: 'driver1',
        pickupLatitude: _currentRide!.pickupLatitude,
        pickupLongitude: _currentRide!.pickupLongitude,
        destLatitude: _currentRide!.destLatitude,
        destLongitude: _currentRide!.destLongitude,
        pickupAddress: _currentRide!.pickupAddress,
        destAddress: _currentRide!.destAddress,
        status: RideStatus.accepted,
        fare: _currentRide!.fare,
      );
      notifyListeners();
    }
  }

  Future<void> cancelRide() async {
    if (_currentRide != null) {
      if (isFirebaseInitialized) {
        await _firestore!.collection('rides').doc(_currentRide!.rideId).update({
          'status': 'cancelled',
        });
      }
      _currentRide = null;
      notifyListeners();
    }
  }
}
