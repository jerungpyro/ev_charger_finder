// File: lib/charging_station.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChargingStation {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final int availablePorts;
  final int totalPorts;

  ChargingStation({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.availablePorts,
    required this.totalPorts,
  });

  // --- NEW: Add this factory constructor ---
  // It creates a ChargingStation instance from a Firestore document.
  factory ChargingStation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Safely handle the location field
    GeoPoint geoPoint = data['location'] ?? const GeoPoint(0, 0);

    return ChargingStation(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Station',
      address: data['address'] ?? 'No Address',
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      availablePorts: data['availablePorts'] ?? 0,
      totalPorts: data['totalPorts'] ?? 0,
    );
  }
}