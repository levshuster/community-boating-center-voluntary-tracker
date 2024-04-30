import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'location_services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
/* Currently used in location_services.dart:
  * import 'package:firebase_auth/firebase_auth.dart';
  * import 'package:cloud_firestore/cloud_firestore.dart';
*/


/*
  + NECESSARY:
  * We need to ensure we spin up the DB when we go to grab location.
  * Perhaps we can do this in the background, but for now we'll just do it here.
*/
/// Flutter code sample for [Scaffold].

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ScaffoldExampleApp());
}

class ScaffoldExampleApp extends StatelessWidget {
  const ScaffoldExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ScaffoldExample(),
    );
  }
}

class ScaffoldExample extends StatefulWidget {
  const ScaffoldExample({super.key});

  @override
  State<ScaffoldExample> createState() => _ScaffoldExampleState();
}

class _ScaffoldExampleState extends State<ScaffoldExample> {
  @override
  Widget build(BuildContext context) {
    // Options for our map:
    const MapOptions mapOptions = MapOptions(
      initialCenter: LatLng(48.7250079,-122.5128632),
      initialZoom: 16.0,
    );
    // Tile layer represents the map we're using.
    TileLayer tileLayer = TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.app',
    );
    // Marker layer: [<home>, <current location>]
    List<Marker> markers = [
      const Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(48.7216016,-122.5094043),
          child: Icon(Icons.location_on, size: 50.0, color: Colors.red),
        ),
        const Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(48.7216016,-122.5094043),
          child: Icon(Icons.location_on, size: 50.0, color: Colors.red),
        )
    ];

    // Marker layer represents the location we're at.
    MarkerLayer markerLayer = MarkerLayer(
      markers: markers,
    );
    // Map layer:
    FlutterMap flutterMap = FlutterMap(
          options: mapOptions,
          mapController: MapController(),
          children: [
            tileLayer,
            markerLayer
          ],
        );
    
    // Location services for tracking our location:
    LocationService locationService = LocationService();
    bool tracking = false;
    // Timer:
    Timer locationTracker = Timer.periodic(const Duration(seconds: 5), (timer) async {
        // Get our location:
        final locationData = await locationService.getCurrentLocation();
        // center ourselves on the map:
        LatLng point = LatLng(locationData.latitude!, locationData.longitude!);
        flutterMap.mapController?.move(point, flutterMap.mapController?.camera.zoom ?? 16.0); //! Do we want to force a cameramove?
        // Add our current location to the map:
        markers.removeLast();
        markers.add(
          Marker(
            point: point,
            child: const Icon(Icons.location_on, size: 50.0, color: Colors.red)
          )
        );
        // Add our current location to the path and send to the server if tracking:
        print("tracking: " + tracking.toString());
        if (tracking) {
          // TODO: Why is 'tracking' not being consistent?
          // Send our location to the server:
          locationService.sendLocationToServer('TestID', LatLng(locationData.latitude!, locationData.longitude!));
        }
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Code'),
      ),
      body: Center(
        child: flutterMap
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(height: 50.0),
      ),
      floatingActionButton: FloatingActionButton.extended(  
        onPressed: () => setState(() {
          tracking = !tracking;
          // Start Trip:
          if (!tracking) {
            // change button color and icon.
          }
          // End trip:
          else {
          }
        }),
        tooltip: 'Start Trip',
        label: const Text('Start Trip'),
        icon: const Icon(Icons.navigation),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
