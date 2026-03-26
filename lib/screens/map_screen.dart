import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ride_provider.dart';
import '../models/ride_model.dart';
import '../theme.dart';

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

    // Fetch nearby drivers
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
          markerId: const MarkerId('current_location'),
          position: LatLng(
            locationProvider.currentLocation!.latitude!,
            locationProvider.currentLocation!.longitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(120), // Green Hue roughly
        ),
      );
    }

    for (var driver in rideProvider.nearbyDrivers) {
      markers.add(
        Marker(
          markerId: MarkerId(driver.uid),
          position: LatLng(driver.latitude, driver.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: InfoWindow(title: driver.name, snippet: '${driver.carModel}'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          locationProvider.currentLocation == null
              ? const Center(child: CircularProgressIndicator(color: AppTheme.secondary))
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
                    // Note: Here we would ideally set a custom dark map style string
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: markers,
                ),
          
          // Custom Back Button & Header Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),
          
          // Ride Status Bottom Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildRideStatusOverlay(rideProvider, authProvider, locationProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildRideStatusOverlay(RideProvider rideProvider, AuthProvider authProvider, LocationProvider locationProvider) {
    if (rideProvider.currentRide == null && !rideProvider.isRequesting) {
      // Initial state: Request Ride Card
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(48), topRight: Radius.circular(48)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Fluid Economy',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Text(
                  '\$15.00',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('4 seats • 3 min away', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary)),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () async {
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
                
                if (error != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.secondary, AppTheme.secondaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(48),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Confirm Ride',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.background, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Glassmorphic tertiary button
            ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  color: AppTheme.surfaceContainerHighest.withOpacity(0.4),
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Text('Add a Stop', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.onSurface)),
                  ),
                ),
              ),
            ),
            SafeArea(child: const SizedBox(height: 0)),
          ],
        ),
      );
    }

    // Searching or Accepted State
    final isSearching = rideProvider.isRequesting || rideProvider.currentRide?.status == RideStatus.pending;

    return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(48), topRight: Radius.circular(48)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              offset: const Offset(0, -10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (isSearching) ...[
              // Searching State
              Row(
                children: [
                  const CircularProgressIndicator(color: AppTheme.secondary, strokeWidth: 3),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Text('Locating your concierge...', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Glassmorphic cancel button
              ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    color: AppTheme.surfaceContainerHighest.withOpacity(0.4),
                    child: TextButton(
                      onPressed: () => rideProvider.cancelRide(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: Text('Cancel Request', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.redAccent)),
                    ),
                  ),
                ),
              ),
            ] else if (rideProvider.currentRide?.status == RideStatus.accepted) ...[
              // Accepted State
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your concierge is arriving', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24)),
                  // Live status chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF004119), // onSecondaryContainer
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('3 min', style: TextStyle(color: Color(0xFF6BFF8F), fontWeight: FontWeight.bold)), // secondaryFixed
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Driver Info Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surfaceContainerLow,
                      ),
                      child: const Icon(Icons.person, color: AppTheme.primary, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('John Doe', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppTheme.secondary, size: 16),
                              const SizedBox(width: 4),
                              Text('4.99', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('ABC-123', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text('Black Tesla', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primary)),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.call, color: AppTheme.onSurface),
                        label: Text('Contact', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.onSurface)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () => rideProvider.cancelRide(),
                      padding: const EdgeInsets.all(20),
                    ),
                  )
                ],
              ),
            ],
            SafeArea(child: const SizedBox(height: 0)),
          ],
        ),
      );
  }
}
