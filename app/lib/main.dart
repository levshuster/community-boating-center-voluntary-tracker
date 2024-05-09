import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'location_services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Future<UserCredential> signInWithGoogle() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();
    UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
    return userCredential;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Welcome'),
            content: const Text('Thank you for helping us keep track of our boats! Please sign in to continue. Once you launch, start your trip. When you return, end your trip. Thank you!'),
            actions: <Widget>[
              OutlinedButton(
                child: const Text('Sign In With Apple'),
                onPressed: () async {
                  // await signInWithGoogle();
                  Navigator.of(context).pop();
                },
              ),
            OutlinedButton(
                child: const Text('Sign In With Google'),
                onPressed: () async {
                  await signInWithGoogle();
                  print(FirebaseAuth.instance.currentUser?.email);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }



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
    // Polyline layer
    List<LatLng> points = [];
    PolylineLayer polylineLayer = PolylineLayer(
      polylines: [
        Polyline(
          points: points,
          strokeWidth: 4.0,
          color: Colors.red,
        ),
      ],
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
      children: [tileLayer, markerLayer, polylineLayer],
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
          onChanged: value ? null : (value) {
            // Handle the selected value here
          },
        );
      },
    );


    Future<void> signOut() async {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }

    // make a help and info button
    OutlinedButton helpAndInfoButton = OutlinedButton(
      onPressed: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help and Info'),
          content: const Text(
          'This app is designed to help us manage our fleet of boats. Before you leave the dock, please start your trip. When you return, please end your trip. Thank you!'),
            actions: <Widget>[
            TextButton(
              onPressed: () {
              Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
              signOut();
              },
              child: const Text('Sign Out'),
            ),
            ],
        );
        },
      );
      },
      style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      ),
      child: const Text('❓📞🆘'),
    );

    // Add padding to the column
    Padding bodyColumn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Column(
        children: <Widget>[
            Row(
            children: <Widget>[
              Expanded(
              flex: 2,
              child: hullNumberField,
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
              child: activityTypeField,
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
              child: helpAndInfoButton,
              ),
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
          flutterMap.mapController?.camera.zoom ?? 16.0); //! Do we want to force a cameramove?
      // Add our current location to the map:
      markers.removeLast();
      markers.add(Marker(
          point: point,
          child: const Icon(Icons.directions_boat_filled_rounded,
                            size: 50.0,
                            color: Colors.red),
          ));
      // Add our current location to the path and send to the server if tracking:
      if (tracking.value) {
        // Add to our trip:
        points.add(point);
        // Send our location to the server:
        locationService.sendLocationToServer(
            FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
            LatLng(locationData.latitude!, locationData.longitude!));
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
