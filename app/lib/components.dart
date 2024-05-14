import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

// --- Constants ---

const double defaultPadding = 16;

// --- Map ---

// Options for our map:
const MapOptions mapOptions = MapOptions(
  initialCenter: LatLng(48.7250079, -122.5128632),
  initialZoom: 16.0,
);

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
