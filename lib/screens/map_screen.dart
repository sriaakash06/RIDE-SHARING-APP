import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ride_provider.dart';
import '../models/ride_model.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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
    if (rideProvider.currentRide == null && !rideProvider.isRequesting) {
      // Initial state: Request Ride Button
      return Positioned(
        bottom: 30,
        left: 20,
        right: 20,
        child: ElevatedButton(
          onPressed: () async {
            String? error = await rideProvider.requestRide(
              userId: authProvider.userModel!.uid,
              pickupLat: locationProvider.currentLocation!.latitude!,
              pickupLng: locationProvider.currentLocation!.longitude!,
              destLat: locationProvider.currentLocation!.latitude! + 0.01,
              destLng: locationProvider.currentLocation!.longitude! + 0.01,
              pickupAddr: 'Current Location',
              destAddr: 'Mock Destination',
              fare: 15.0,
            );
            
            if (error != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text('Confirm Ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
          ),
        ),
      );
    }

    // Either requesting or ride is active: Show Bottom Sheet style container
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, spreadRadius: 0)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (rideProvider.isRequesting || rideProvider.currentRide?.status == RideStatus.pending) ...[
              // Finding Driver State
              Row(
                children: [
                  CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                  SizedBox(width: 20),
                  Text('Finding your driver...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10),
              Text('This might take a few seconds', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child:OutlinedButton(
                  onPressed: () => rideProvider.cancelRide(),
                  child: Text('Cancel Request', style: TextStyle(color: Colors.black)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ] else if (rideProvider.currentRide?.status == RideStatus.accepted) ...[
              // Driver Accepted State
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Driver is arriving', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                    child: Text('3 min', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Divider(height: 1, color: Colors.grey[300]),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.person, size: 35, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('John Doe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Mock mapping
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 4),
                            Text('4.8', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ABC-123', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text('Toyota Corolla • White', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {}, // Action for call
                      icon: Icon(Icons.call, color: Colors.black),
                      label: Text('Call', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => rideProvider.cancelRide(),
                      icon: Icon(Icons.close, color: Colors.white),
                      label: Text('Cancel', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
