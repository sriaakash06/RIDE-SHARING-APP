enum RideStatus {
  pending,
  accepted,
  started,
  completed,
  cancelled,
}

class RideModel {
  final String rideId;
  final String userId;
  final String? driverId;
  final double pickupLatitude;
  final double pickupLongitude;
  final double destLatitude;
  final double destLongitude;
  final String pickupAddress;
  final String destAddress;
  final RideStatus status;
  final double fare;

  RideModel({
    required this.rideId,
    required this.userId,
    this.driverId,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destLatitude,
    required this.destLongitude,
    required this.pickupAddress,
    required this.destAddress,
    required this.status,
    required this.fare,
  });

  factory RideModel.fromMap(Map<String, dynamic> data) {
    return RideModel(
      rideId: data['rideId'] ?? '',
      userId: data['userId'] ?? '',
      driverId: data['driverId'],
      pickupLatitude: (data['pickupLatitude'] ?? 0.0).toDouble(),
      pickupLongitude: (data['pickupLongitude'] ?? 0.0).toDouble(),
      destLatitude: (data['destLatitude'] ?? 0.0).toDouble(),
      destLongitude: (data['destLongitude'] ?? 0.0).toDouble(),
      pickupAddress: data['pickupAddress'] ?? '',
      destAddress: data['destAddress'] ?? '',
      status: RideStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => RideStatus.pending,
      ),
      fare: (data['fare'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'userId': userId,
      'driverId': driverId,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'destLatitude': destLatitude,
      'destLongitude': destLongitude,
      'pickupAddress': pickupAddress,
      'destAddress': destAddress,
      'status': status.name,
      'fare': fare,
    };
  }
}
