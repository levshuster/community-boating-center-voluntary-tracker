import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'location_services.dart';
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
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Code'),
      ),
      body: Center(
        child: Text('You have pressed the button $_count times.'),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(height: 50.0),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          _count++;
        }),
        tooltip: 'Increment Counter',
        child: const Icon(Icons.navigation),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
