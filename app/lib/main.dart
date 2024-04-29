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
/// Flutter code sample for [Scaffold].

void main() async {
  /*
    + NECESSARY:
    * We need to ensure we spin up the DB when we go to grab location.
    * Perhaps we can do this in the background, but for now we'll just do it here.
  */
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
    // Marker layer represents the location we're at.
    const MarkerLayer markerLayer = MarkerLayer(
      markers: [
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(48.7216016,-122.5094043),
          child: Icon(Icons.location_on, size: 50.0, color: Colors.red),
        ),
      ],
    );
    // Map layer:
    FlutterMap flutterMap = FlutterMap(
          options: mapOptions,
          children: [
            tileLayer,
            markerLayer,
          ]
        );

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
          //! Start Trip!
        }),
        tooltip: 'Start Trip',
        label: const Text('Start Trip'),
        icon: const Icon(Icons.navigation),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
