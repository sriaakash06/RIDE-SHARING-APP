class DriverModel {
  final String uid;
  final String name;
  final double rating;
  final String carModel;
  final String carColor;
  final String licensePlate;
  final double latitude;
  final double longitude;

  DriverModel({
    required this.uid,
    required this.name,
    required this.rating,
    required this.carModel,
    required this.carColor,
    required this.licensePlate,
    required this.latitude,
    required this.longitude,
  });

  factory DriverModel.fromMap(Map<String, dynamic> data) {
    return DriverModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      carModel: data['carModel'] ?? '',
      carColor: data['carColor'] ?? '',
      licensePlate: data['licensePlate'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'rating': rating,
      'carModel': carModel,
      'carColor': carColor,
      'licensePlate': licensePlate,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
