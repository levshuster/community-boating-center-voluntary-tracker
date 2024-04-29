import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Returns location:
class LocationService {
  Location location = Location();

  Future<bool> requestPermission() async {
    final permission = await location.requestPermission();
    return permission == PermissionStatus.granted;
  }

  Future<LocationData> getCurrentLocation() async {
    final serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      final result = await location.requestService;
        if (result == true) {
          print('Service has been enabled');
        } else {
             throw Exception('GPS service not enabled');
          }
       }

  final locationData = await location.getLocation();
  return locationData;
  }

  void sendLocationToServer(String id) async {
    //* Get our location, then send it to our database:
    getCurrentLocation().then((locDat) {
      FirebaseFirestore db = FirebaseFirestore.instance;        
      Map<String, dynamic> test = {
        'location': GeoPoint(locDat.latitude!, locDat.longitude!),
        'timestamp': FieldValue.serverTimestamp(),
        'user': id
      };
      db.collection('Location')
          .add(test)
          .then((value) => print('Location ${[locDat.latitude!, locDat.longitude!]} added'));  
    }).catchError((e) {
      print('Error: $e');
    });
  }
}