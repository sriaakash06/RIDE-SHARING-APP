import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ride_provider.dart';
import '../models/ride_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final rideProvider = Provider.of<RideProvider>(context);

    // Fetch nearby drivers when location is available
    if (locationProvider.currentLocation != null && rideProvider.nearbyDrivers.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        rideProvider.fetchNearbyDrivers(
          locationProvider.currentLocation!.latitude!,
          locationProvider.currentLocation!.longitude!,
        );
      });
    }

    Set<Marker> markers = {};
    if (locationProvider.currentLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(
            locationProvider.currentLocation!.latitude!,
            locationProvider.currentLocation!.longitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    for (var driver in rideProvider.nearbyDrivers) {
      markers.add(
        Marker(
          markerId: MarkerId(driver.uid),
          position: LatLng(driver.latitude, driver.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          infoWindow: InfoWindow(title: driver.name, snippet: '${driver.carModel} (${driver.rating}⭐)'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('RideShare'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: Stack(
        children: [
          locationProvider.currentLocation == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      locationProvider.currentLocation!.latitude!,
                      locationProvider.currentLocation!.longitude!,
                    ),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: markers,
                ),
          _buildRideStatusOverlay(rideProvider, authProvider, locationProvider),
        ],
      ),
    );
  }

  Widget _buildRideStatusOverlay(RideProvider rideProvider, AuthProvider authProvider, LocationProvider locationProvider) {
    if (rideProvider.isRequesting) {
      return Center(child: CircularProgressIndicator());
    }

    if (rideProvider.currentRide == null) {
      return Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: ElevatedButton(
          onPressed: () {
            rideProvider.requestRide(
              userId: authProvider.userModel!.uid,
              pickupLat: locationProvider.currentLocation!.latitude!,
              pickupLng: locationProvider.currentLocation!.longitude!,
              destLat: locationProvider.currentLocation!.latitude! + 0.01,
              destLng: locationProvider.currentLocation!.longitude! + 0.01,
              pickupAddr: 'Current Location',
              destAddr: 'Mock Destination',
              fare: 15.0,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text('Request a Ride', style: TextStyle(fontSize: 18)),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      );
    }

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rideProvider.currentRide!.status == RideStatus.pending
                    ? 'Finding a driver...'
                    : 'Driver is on the way!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (rideProvider.currentRide!.status == RideStatus.accepted) ...[
                SizedBox(height: 10),
                ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('John Doe'), // Mocked driver name
                  subtitle: Text('Toyota Corolla • ABC-123'),
                  trailing: Icon(Icons.star, color: Colors.amber),
                ),
                Text('Rating: 4.8'),
              ],
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => rideProvider.cancelRide(),
                child: Text('Cancel Ride'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
