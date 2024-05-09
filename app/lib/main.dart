import 'dart:async';
import 'dart:js_interop';
import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                child: const Text('Sign In'),
                onPressed: () {
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
    // Marker Layer:
    List<Marker> markers = [];
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
          onChanged: value ? null : (value) {
            // Handle the selected value here
          },
        );
      },
    );

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
              flex: 4,
              child: emailField,
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

    //! Timer:
    Timer locationTracker = Timer.periodic(const Duration(seconds: 10), (timer) async {
      // Add our current location to the map:
      markers.removeWhere((element) => true);

      // Pull all location data in the last 20 minutes from the firebase server:
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      Timestamp twentyMinutesAgo = Timestamp.fromDate(
        Timestamp
          .now()
          .toDate()
          .subtract(const Duration(minutes: 20)));

      QuerySnapshot querySnapshot = await firestore
        .collection('Location') 
        .where('timestamp', isGreaterThan: twentyMinutesAgo)
        .orderBy('timestamp', descending: true)
        .get(); 
            
      // From this query snapshot, get each unique most recent marker:
      var temp_ids = <String>[];
      querySnapshot.docs.forEach((element) {
        var data = element.data() as Map<String, dynamic>;
        GeoPoint location = data['location'];

        if (!temp_ids.contains(data['id'])) {
          temp_ids.add(data['id']);
        //   markers.add(Marker(
        //     width: 80.0,
        //     height: 80.0,
        //     point: LatLng(location.latitude, location.longitude),
        //     child: const Icon(Icons.directions_boat_filled_rounded, color: Colors.red),
        //   ));
        }

      });


    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Boating Center Rental Tracker'),
      ),
      body: bodyColumn,
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
