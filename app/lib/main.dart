import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'location_services.dart';
import 'package:flutter_map/flutter_map.dart';
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

const double defaultPadding = 16;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CommunityBoatingTrackerApp());
}

class CommunityBoatingTrackerApp extends StatelessWidget {
  const CommunityBoatingTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CommunityBoatingTracker(),
    );
  }
}

class CommunityBoatingTracker extends StatefulWidget {
  const CommunityBoatingTracker({super.key});

  @override
  State<CommunityBoatingTracker> createState() =>
      _CommunityBoatingTrackerState();
}

class _CommunityBoatingTrackerState extends State<CommunityBoatingTracker> {
  @override
  Widget build(BuildContext context) {
    // Options for our map:
    const MapOptions mapOptions = MapOptions(
      initialCenter: LatLng(48.7250079, -122.5128632),
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
        point: LatLng(48.7216016, -122.5094043),
        child: Icon(Icons.location_on, size: 50.0, color: Colors.green),
      ),
      const Marker(
        // TODO: why is there two markers?
        width: 80.0,
        height: 80.0,
        point: LatLng(48.7216016, -122.5094043),
        child: Icon(Icons.location_on, size: 50.0, color: Colors.green),
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
      children: [tileLayer, markerLayer],
    );

    ValueNotifier<bool> tracking = ValueNotifier<bool>(false);

    ValueListenableBuilder hullNumberField = ValueListenableBuilder(
      valueListenable: tracking,
      builder: (context, value, child) {
        return TextField(
            decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: 'Hull Number',
          enabled: !value,
        ));
      },
    );

    ValueListenableBuilder emailField = ValueListenableBuilder(
      valueListenable: tracking,
      builder: (context, value, child) {
        return TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Email Address',
          ),
          enableSuggestions: true,
          autocorrect: true,
          autofillHints: const [AutofillHints.email],
          enabled: !value,
        );
      },
    );

    ValueListenableBuilder activityTypeField = ValueListenableBuilder(
      valueListenable: tracking,
      builder: (context, value, child) {
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Activity Type',
            enabled: !value,

          ),
          items: const [
            DropdownMenuItem(
              value: 'lesson',
              child: Text('Lesson'),
            ),
            DropdownMenuItem(
              value: 'rental',
              child: Text('Rental'),
            ),
            DropdownMenuItem(
              value: 'admin',
              child: Text('Admin'),
            ),
          ],
          onChanged: (value) {
            // Handle the selected value here
          },
        );
      },
    );

    // Add padding to the column
    Padding bodyColumn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: hullNumberField,
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: emailField,
              ),
              const SizedBox(width: defaultPadding),
              Expanded(child: activityTypeField),
            ],
          ),
          const SizedBox(height: defaultPadding),
          Expanded(child: flutterMap),
        ],
      ),
    );

    // Location services for tracking our location:
    LocationService locationService = LocationService();

    // Timer:
    Timer locationTracker =
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      // Get our location:
      final locationData = await locationService.getCurrentLocation();
      // center ourselves on the map:
      LatLng point = LatLng(locationData.latitude!, locationData.longitude!);
      flutterMap.mapController?.move(
          point,
          flutterMap.mapController?.camera.zoom ??
              16.0); //! Do we want to force a cameramove?
      // Add our current location to the map:
      markers.removeLast();
      markers.add(Marker(
          point: point,
          child: const Icon(Icons.location_on, size: 50.0, color: Colors.red)));
      // Add our current location to the path and send to the server if tracking:
      if (tracking.value) {
        // Send our location to the server:
        locationService.sendLocationToServer(
            'TestID', LatLng(locationData.latitude!, locationData.longitude!));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Boating Center Rental Tracker'),
      ),
      body: bodyColumn,
      // bottomNavigationBar: BottomAppBar(
      //   shape: const CircularNotchedRectangle(),
      //   notchMargin: -100,
      //   child: Container(height: 20.0),
      // ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: defaultPadding),
        child: FloatingActionButton.extended(
          onPressed: () => tracking.value = !tracking.value,
          tooltip:
              'Before Leaving the Dock, start your trip to help us manage our fleet.',
          // label: tracking.value ? const Text('End Trip') : const Text('Start Trip'),
          label: ValueListenableBuilder(
            valueListenable: tracking,
            builder: (context, value, child) {
              return value ? const Text('End Trip') : const Text('Start Trip');
            },
          ),
          icon: const Icon(Icons.navigation),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
